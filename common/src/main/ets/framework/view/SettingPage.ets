/*
 * Copyright (c) 2026 Huawei Device Co., Ltd. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import window from '@ohos.window';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { TextModifier } from '@ohos.arkui.modifier';
import { LengthMetrics } from '@ohos.arkui.node';
import { BusinessError } from '@ohos.base';
import { PushParam } from '../common/PageRouter';
import {
  PADDING_0,
  PADDING_8,
  INIT_AVOID_WIDTH,
  INIT_DEFAULT_WIDTH,
  STATUS_BAR_HEIGHT,
} from '../common/StyleConstant';
import { DataVerify } from '../common/DataVerify';
import { EventBus } from '../common/EventBus';
import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { PageConfigVerify } from '../common/PageConfigVerify';
import { PageParams } from '../common/PageLoader';
import { LazyDataSource } from '../model/LazyDataSource';
import { SettingBaseModel } from '../model/SettingBaseModel';
import {
  GroupType,
  SettingContentModel,
  SettingContentTextStyle,
  SettingGroupModel
} from '../model/SettingGroupModel';
import {
  ItemPos,
  ItemType,
  SegmentButtonModel,
  SettingIconStyle,
  SettingIconType,
  SettingItemModel,
  SettingMenuStyle,
} from '../model/SettingItemModel';
import {
  DefaultSettingPageModel,
  PageType,
  SettingPageLayout,
  SettingPageMenu,
  SettingPageModel,
  SettingSheetPageContext,
} from '../model/SettingPageModel';
import {
  SettingBaseState,
  SettingContentState,
  SettingStateType
} from '../model/SettingStateModel';
import { SettingTabsModel } from '../model/SettingTabsModel';
import { SettingGroup } from './SettingGroup';
import { SettingGroupFooter } from './SettingGroupFooter';
import { SettingGroupHeader } from './SettingGroupHeader';
import { SettingItemStandard } from './SettingItemStandard';
import { NavEntryKey } from '../../constant/EntryKeyConsts';
import { AppStorageKey } from '../../constant/AppStorageConsts';
import { PageStartReason, UiExtensionConstant } from '../../constant/UiExtensionConstant';

enum SettingListItemType {
  ITEM_TYPE_CUSTOM_GROUP = 0,
  ITEM_TYPE_NORMAL = 1,
  ITEM_TYPE_GROUP_HEADER = 2,
  ITEM_TYPE_GROUP_FOOTER = 3,
  ITEM_TYPE_PAGE_HEADER = 4,
  ITEM_TYPE_PAGE_FOOTER = 5,
}

interface SettingListItem extends SettingBaseModel {
  type: SettingListItemType;
  item: SettingBaseModel;
  itemPos?: ItemPos;
  backgroundColor?: ResourceColor;
  borderRadius?: BorderRadiuses;
  padding?: LocalizedPadding;
  margin?: LocalizedPadding;
}

interface PageContentParam {
  groups: SettingGroupModel[];
  compId?: string;
  hasFixedGroup?: boolean;
  alwaysEnabled?: boolean;
  tabIndex?: number;
}

const TAG: string = 'SettingPage';

@Component
export struct SettingPage {
  pageParam?: PageParams;
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();
  @Prop sheetType: SheetType = SheetType.BOTTOM;
  private compId: string = '';
  private layout?: SettingPageLayout;
  private pageNavTitleOptions: NavigationTitleOptions | undefined;
  private scroller: Scroller = new Scroller();
  private dataSource: LazyDataSource<SettingListItem> = new LazyDataSource();
  private isCircleScreen: boolean = PageConfig.getInstance().isCircleScreen();
  private sheetPageCtx?: SettingSheetPageContext;
  private swiperController?: SwiperController;
  private selectedPageHeight: number[] = [0, 0];
  private tempTabIndex: number = -1;
  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogHelper.error(TAG, 'invalid eventbus data type.');
      return;
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };
  private titleButtonRectWidth: number = INIT_AVOID_WIDTH;
  @State avoidDefaultWidth: number = INIT_DEFAULT_WIDTH;
  @State pageTitle: ResourceStr = '';
  @State needRenderGroup: boolean = false;
  @State cardWidth: number = 0;
  @State cardHeight: number = 0;
  @State @Watch('selectIndexesUpdated') selectedIndexes: number[] = [0];
  @State tabContents: ResourceStr[] = ['', ''];
  @State hideBackIcon: boolean = false;
  @State startReason: string = PageStartReason.DEFAULT;
  @StorageProp(AppStorageKey.NAVIGATION_BAR_HEIGHT) navigationBarHeight: number = 0;
  @StorageLink('navigationMode') navMode: NavigationMode =
    AppStorage.get(UiExtensionConstant.NAVIGATION_MODE) ?? NavigationMode.Stack;
  @BuilderParam segmentButtonLoader: (param: SegmentButtonModel) => void;

  onNavigationModeChange(): void {
    this.hideBackIcon = this.isNeedHideBackIcon();
  }

  private isNeedHideBackIcon(): boolean {
    return this.navMode === NavigationMode.Split && (this.pageInfo.url === NavEntryKey.INTELLIGENT_SCENE_HOME_ENTRY ||
      this.startReason === PageStartReason.FROM_SEARCH);
  }

  private selectIndexesUpdated(): void {
    LogHelper.info(TAG, `change tabs to index ${this.selectedIndexes[0]}`);
    this.cardHeight = this.selectedPageHeight[this.selectedIndexes[0]];
    this.swiperController?.changeIndex(this.selectedIndexes[0]);
    this.pageInfo.onTabSelected?.(this.selectedIndexes[0]);
  }

  private procTitleEvent(value: SettingBaseState): void {
    let titleContent = value as SettingContentState;
    if (!titleContent?.content) {
      LogHelper.error(TAG, 'invaild title state event');
      return;
    }

    LogHelper.info(TAG, 'enabled state change.');
    this.pageTitle = titleContent.content;
  }

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      if (!value) {
        return;
      }
      switch (key) {
        case SettingStateType.STATE_TYPE_PAGE_TITLE:
          this.procTitleEvent(value);
          break;
        case SettingStateType.STATE_TYPE_PAGE_SCROLL_TO_TOP:
          this.scroller.scrollToIndex(0);
          break;

        default:
          LogHelper.error(TAG, `invaild event data key: ${key}`);
          break;
      }
    })
  }

  private getSettingItemBorderRadius(itemIndex: number, itemTotal: number,
    cfgBorderRadiuses?: Length): BorderRadiuses | undefined {
    if (itemIndex > 0 && itemIndex < itemTotal - 1) {
      return undefined;
    }
    if (!cfgBorderRadiuses) {
      cfgBorderRadiuses = PageConfig.getInstance().getGroupLayout().borderRadius;
    }
    if (this.isCircleScreen) {
      return {
        topLeft: cfgBorderRadiuses,
        topRight: cfgBorderRadiuses,
        bottomLeft: cfgBorderRadiuses,
        bottomRight: cfgBorderRadiuses
      };
    }
    let borderRadius: BorderRadiuses = {};
    if (itemIndex === 0) {
      borderRadius.topLeft = cfgBorderRadiuses;
      borderRadius.topRight = cfgBorderRadiuses;
    }
    if (itemIndex === itemTotal - 1) {
      borderRadius.bottomLeft = cfgBorderRadiuses;
      borderRadius.bottomRight = cfgBorderRadiuses;
    }
    return borderRadius;
  }

  private onListSizeChange(newValue: SizeOptions, tabIndex?: number): void {
    let padding: LengthMetrics = this.layout?.padding?.start ? this.layout?.padding?.start : PADDING_0;
    this.cardWidth = vp2px(newValue.width as number - padding.value * 2);
    this.cardHeight = vp2px(newValue.height as number);
    if (this.pageInfo.tabs && this.pageInfo.tabs.length === 2 && tabIndex !== undefined) {
      this.selectedPageHeight[tabIndex] = this.cardHeight;
      if (tabIndex !== this.selectedIndexes[0]) {
        this.cardHeight = this.selectedPageHeight[this.selectedIndexes[0]];
      }
      LogHelper.info(TAG, `page ${this.compId} tab ${tabIndex} height change to ${this.cardHeight}`);
    }
  }

  @Builder
  pageHeader(header: SettingContentModel, style: SettingContentTextStyle): void {
    Column() {
      if (header.builder) {
        header.builder.builder(header);
      } else {
        Text(header.content)
          .width('100%')
          .fontSize(style.fontSize)
          .fontWeight(style.fontWeight)
          .fontColor(style.fontColor)
          .fontFamily(style.fontFamily)
          .textAlign(style.textAlign)
      }
    }
    .width('100%')
    .height(style.height)
    .padding(style.padding)
    .justifyContent(style.justifyContent)
  }

  @Builder
  pageHomeContent(): void {
    Column() {
      List({ scroller: this.scroller }) {
        ListItemGroup() {
          LazyForEach(this.dataSource, (item: SettingListItem) => {
            ListItem() {
              if (item.type === SettingListItemType.ITEM_TYPE_CUSTOM_GROUP) {
                (item.item as SettingGroupModel).builder?.builder((item.item as SettingGroupModel))
              } else if (item.type === SettingListItemType.ITEM_TYPE_NORMAL) {
                if ((item.item as SettingItemModel).type === ItemType.ITEM_TYPE_CUSTOM) {
                  (item.item as SettingItemModel).builder?.builder((item.item as SettingItemModel))
                } else {
                  SettingItemStandard({
                    itemInfo: item.item as SettingItemModel,
                    itemPos: item.itemPos,
                    compId: `${item.item.id}`,
                    homePageComp: true
                  })
                }
              } else if (item.type === SettingListItemType.ITEM_TYPE_PAGE_HEADER) {
                this.pageHeader(item.item as SettingContentModel,
                  PageConfig.getInstance().getPageHeaderStyle(item.item as SettingContentModel))
              }
            }
            .backgroundColor(item.backgroundColor)
            .borderRadius(item.borderRadius)
            .padding(item.padding)
            .margin(item.margin)
            .renderGroup(this.needRenderGroup)
          }, (item: SettingListItem) => item.id)
        }
      }
      .width('100%')
      .height('100%')
      .cachedCount(25)
      .edgeEffect(EdgeEffect.Spring)
      .borderRadius(this.getSettingItemBorderRadius(0, 1))
      .scrollBar(BarState.Off)
      .contentStartOffset(this.layout?.padding?.top?.value)
      .contentEndOffset(this.layout?.padding?.bottom?.value)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .padding({
      start: this.layout?.padding?.start,
      end: this.layout?.padding?.end,
    })

    ScrollBar({
      scroller: this.scroller,
      direction: ScrollBarDirection.Vertical,
      state: this.layout?.barState ?? BarState.Auto
    })
  }

  private preprocessGroups(groups: SettingGroupModel[]): void {
    for (let groupIndex = 0; groupIndex < groups.length; ) {
      let group = groups[groupIndex];
      group.tabIndex = this.tempTabIndex;
      if (group.items && group.items.length > 0) {
        for (let itemIndex = 0; itemIndex < group.items.length; ) {
          let item = group.items[itemIndex];
          if (item.noNeedAdded?.()) {
            group.items.splice(itemIndex, 1);
            continue;
          }
          item.tabIndex = group.tabIndex
          itemIndex++;
        }
        this.tempTabIndex++;
        if (group.items.length == 0) {
          groups.splice(groupIndex, 1);
          continue;
        }
      }
      groupIndex++;
    }
  }

  private preprocess(page: SettingPageModel): void {
    if (page.fixedGroups && page.fixedGroups.length > 0) {
      this.preprocessGroups(page.fixedGroups);
      if (page.fixedGroups.length === 0) {
        page.fixedGroups = undefined;
      }
    }
    if (page.groups && page.groups.length > 0) {
      this.preprocessGroups(page.groups);
      if (page.groups.length === 0) {
        page.groups = undefined;
      }
    }
  }

  private getMenuIconStyle(menuItem: SettingPageMenu): SettingIconStyle {
    menuItem.iconType = SettingIconType.ICON_TYPE_TIP;
    return PageConfig.getInstance().getIconStyle(menuItem);
  }

  private getTitleButtonRectWidth() {
    window.getLastWindow(getContext(), (error: BusinessError, win: window.Window) => {
      if (!win || !win.getTitleButtonRect() || win.getTitleButtonRect().width === 0) {
        LogHelper.warn(TAG, `errorMsg: ${win}, ${win?.getTitleButtonRect()?.width}`);
        return;
      }
      this.titleButtonRectWidth = win.getTitleButtonRect().width;
      AppStorage.setOrCreate('titleButtonRectWidth', this.titleButtonRectWidth);
      LogHelper.info(TAG, `Avoidance Width: ${win.getTitleButtonRect().width}`);
    })
  }

  @Builder
  menuBuilder(bindMenu: MenuElement[], menuIndex: number, menuStyle: SettingMenuStyle): void {
    if (bindMenu !== undefined && bindMenu.length >= 0) {
      Menu() {
        ForEach(bindMenu, (item: MenuElement, index: number) => {
          MenuItem({ content: item.value })
            .id(`${this.compId}.menuItem${index}`)
            .contentFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Medium,
            })
            .contentFontColor($r('sys.color.font_primary'))
            .onClick(() => {
              item.action();
            })
        })
      }
      .id(`${this.compId}.menu${menuIndex}`)
      .width((menuStyle.width as number) + 8)
      .radius(menuStyle.borderRadius as Dimension || $r('sys.float.corner_radius_level4'))
    }
  }

  @Builder
  pageMenuItem(menu: SettingPageMenu, index: number, total: number, style: SettingIconStyle): void {
    if (menu && menu.icon) {
      Button({ type: ButtonType.Circle }) {
        if (style.fillColor !== undefined) {
          Image(menu.icon)
            .width(style.width)
            .height(style.height)
            .fillColor(style.fillColor)
            .draggable(false)
            .focusable(true)
        } else {
          Image(menu.icon)
            .width(style.width)
            .height(style.height)
            .draggable(false)
            .focusable(true)
        }
      }
      .id(`${this.compId}.menu${index}.button`)
      .width(40)
      .height(40)
      .borderRadius($r('sys.float.corner_radius_level4'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .stateEffect(true)
      .margin({
        top: PADDING_8,
        end: ((index + 1) === total) ? this.layout?.padding?.end : PADDING_0
      })
      .onClick(menu.onClick ?? undefined)
      .bindMenu(menu.builder ? menu.builder.builder(menu) : this.menuBuilder(menu.bindMenu, index,
        PageConfig.getInstance().getMenuStyle(menu.menuStyle)), { placement: Placement.BottomRight })
    } else {
      menu.builder?.builder(menu);
    }
  }

  @Builder
  pageMenu(): void {
    if (DataVerify.checkArray(this.pageInfo.menus)) {
      Row() {
        ForEach(this.pageInfo.menus, (item: SettingPageMenu, index: number) => {
          this.pageMenuItem(item, index, this.pageInfo.menus?.length ?? 0, this.getMenuIconStyle(item));
        })
      }
      .margin({
        end: PADDING_0,
        top: PADDING_0,
      })
    }
  }

  @Builder
  groupHeaderBuilder(group: SettingGroupModel, fixedPreviousGroup: boolean, fixed?: boolean): void {
    if (group.header) {
      if (fixed) {
        SettingGroupHeader({ group: group, compId: `${this.compId}.${group.id}.header` })
      } else {
        ListItem() {
          SettingGroupHeader({
            group: group,
            compId: `${this.compId}.${group.id}.header`,
            fixedPreviousGroup: fixedPreviousGroup,
          })
        }
      }
    }
  }

  @Builder
  groupFooterBuilder(group: SettingGroupModel, fixed?: boolean): void {
    if (group.footer) {
      if (fixed) {
        SettingGroupFooter({ group: group, compId: `${this.compId}.${group.id}.footer` })
      } else {
        ListItem() {
          SettingGroupFooter({ group: group, compId: `${this.compId}.${group.id}.footer` })
        }
      }
    }
  }

  @Builder
  pageGroup(group: SettingGroupModel, compId?: string, previous?: SettingGroupModel): void {
    if (group) {
      if (group.type === GroupType.GROUP_TYPE_CUSTOM) {
        if (group.builder) {
          ListItem() {
            group.builder.builder(group);
          }
        }
      } else {
        SettingGroup({
          groupInfo: group,
          compId: compId !== undefined ? `${compId}.${group.id}` : `${this.compId}.${group.id}`,
          pageCached: this.pageInfo.cached ? true : false,
          layout: PageConfig.getInstance().getGroupLayout(group, previous),
          sheetPageCtx: this.sheetPageCtx ?? undefined,
        })
      }
    }
  }

  // TODO: 当前仅处理了非fixed group
  private getPreviousGroup(index: number, groups?: SettingGroupModel[]): SettingGroupModel | undefined {
    if (index > 0) {
      return groups?.[index - 1];
    } else if (this.pageInfo.fixedGroups) {
      let fixedLen = this.pageInfo.fixedGroups.length;
      LogHelper.info(TAG, `fixed group.`);
      return this.pageInfo.fixedGroups[fixedLen - 1];
    }
    return undefined;
  }

  @Builder
  pageClipMask(radius: number): void {
    if (!this.isCircleScreen) {
      Row()
        .width(px2vp(this.cardWidth))
        .height(20)
        .clip(new Path({
          commands:
          `M 0 0
          L 0 ${radius}
          Q 0 0 ${radius} 0
          L ${this.cardWidth - radius} 0
          Q ${this.cardWidth} 0 ${this.cardWidth} ${radius}
          L ${this.cardWidth} 0
          L 0 0`
        }))
        .backgroundColor(this.layout?.backgroundColor)
        .hitTestBehavior(HitTestMode.Transparent)
      Row()
        .offset({ x: 0, y: px2vp(this.cardHeight) - 20 })
        .width(px2vp(this.cardWidth))
        .height(20)
        .clip(new Path({
          commands:
          `M 0 0
          Q 0 ${radius} ${radius} ${radius}
          L ${this.cardWidth - radius} ${radius}
          Q ${this.cardWidth} ${radius} ${this.cardWidth} 0
          L ${this.cardWidth} ${radius}
          L 0 ${radius}`
        }))
        .backgroundColor(this.layout?.backgroundColor)
    }
  }

  @Builder
  customContentBuilder(customContent?: SettingContentModel): void {
    if (customContent && customContent.builder) {
      customContent.builder.builder(customContent);
    }
  }

  @Builder
  modalPageContent(param: PageContentParam): void {
    if (this.pageInfo.fixedGroups) {
      this.pageFixedGroup()
    }
    Stack({ alignContent: Alignment.Bottom }) {
      this.pageContentAutoAvoid({
        groups: this.pageInfo.groups ?? [],
        hasFixedGroup: !!this.pageInfo.fixedGroups,
        alwaysEnabled: param.alwaysEnabled ?? true,
      }, !this.pageInfo.stickBottomContent)
      this.customContentBuilder(this.pageInfo.groupForeground)
    }
    .layoutWeight(1)

    // 模态框贴底组件
    if (this.pageInfo.stickBottomContent) {
      Column() {
        this.customContentBuilder(this.pageInfo.stickBottomContent)
      }
      .padding({
        start: this.layout?.padding?.start,
        end: this.layout?.padding?.end,
      })
      .margin({
        bottom: this.sheetType === SheetType.BOTTOM && this.navMode === NavigationMode.Stack ?
          this.navigationBarHeight : 0
      })
    }
  }

  /**
   * 顶部渐隐区间占列表高度比例，用于 DST_IN 遮罩让靠近标题的列表文字半透明
   */
  private getTopFadeRatio(): number {
    const fadeHeight: number = this.layout?.topFadeHeight ?? 0;
    if (fadeHeight <= 0) {
      return 0;
    }
    if (this.cardHeight <= 0) {
      return 0.12;
    }
    return Math.min(Math.max(vp2px(fadeHeight) / this.cardHeight, 0.05), 0.35);
  }

  private isTopFadeEnabled(): boolean {
    return (this.layout?.topFadeHeight ?? 0) > 0;
  }

  /**
   * 列表内容半透明渐隐遮罩（DST_IN）：顶部文字半透明，向下过渡为不透明
   */
  @Builder
  pageContentFadeOverlay(): void {
    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          // 靠近标题栏：内容（含字体）半透明
          ['#66FFFFFF', 0],
          // 渐隐结束后恢复不透明
          ['#FFFFFFFF', this.getTopFadeRatio()],
        ],
      })
      .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN)
      .hitTestBehavior(HitTestMode.None)
  }

  @Builder
  pageContent(param: PageContentParam, isAvoid?: boolean): void {
    List({ scroller: this.scroller }) {
      if (this.pageInfo.header) {
        ListItem() {
          this.pageHeader(this.pageInfo.header, PageConfig.getInstance().getPageHeaderStyle(this.pageInfo.header))
        }
      }
      ForEach(param.groups, (item: SettingGroupModel, index: number) => {
        this.groupHeaderBuilder(item, (index === 0 && DataVerify.checkArray(this.pageInfo.fixedGroups)))
        this.pageGroup(item, param.compId, this.getPreviousGroup(index, param.groups))
        this.groupFooterBuilder(item)
      }, (item: SettingGroupModel) => item.id)
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: param.alwaysEnabled ?? true })
    .scrollBar(isAvoid ? BarState.Off : BarState.Auto)
    .clip(this.pageInfo.type === PageType.PAGE_TYPE_MODAL)
    .padding({
      start: this.layout?.padding?.start,
      end: this.layout?.padding?.end,
    })
    .contentStartOffset(param.hasFixedGroup ? undefined : this.layout?.padding?.top?.value)
    .contentEndOffset((this.layout?.padding?.bottom?.value || 0) + (isAvoid ? this.navigationBarHeight : 0))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onSizeChange((this.isCircleScreen || this.sheetPageCtx) ? undefined :
      (oldValue: SizeOptions, newValue: SizeOptions) => {
        this.onListSizeChange(newValue, param.tabIndex);
      })
    .onScrollStop(this.pageInfo.scrollListener?.onScrollStop)
    .onScrollStart(this.pageInfo.scrollListener?.onScrollStart)
    .onReachStart(this.pageInfo.scrollListener?.onReachStart)
    .onScroll(this.pageInfo.scrollListener?.onScroll)
  }

  @Builder
  pageContentWithFade(param: PageContentParam, isAvoid?: boolean): void {
    if (this.isTopFadeEnabled()) {
      Stack() {
        this.pageContent(param, isAvoid)
        this.pageContentFadeOverlay()
      }
      .width('100%')
      .height('100%')
      .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN)
    } else {
      this.pageContent(param, isAvoid)
    }
  }

  /**
   * 根据是否需要避让来渲染组件
   */
  @Builder
  pageContentAutoAvoid(param: PageContentParam, isAvoid?: boolean): void {
    if (isAvoid) {
      Stack({ alignContent: Alignment.End }) {
        this.pageContentWithFade(param, isAvoid)
        ScrollBar({ scroller: this.scroller, direction: ScrollBarDirection.Vertical, state: BarState.Auto })
          .margin({
            bottom: this.navigationBarHeight,
          })
      }
      .width('100%')
      .height('100%')
    } else {
      this.pageContentWithFade(param)
    }
  }

  @Builder
  pageFixedGroup(): void {
    Column() {
      ForEach(this.pageInfo.fixedGroups, (item: SettingGroupModel) => {
        this.groupHeaderBuilder(item, false, true)
        if (item.type === GroupType.GROUP_TYPE_CUSTOM) {
          if (item.builder) {
            ListItem() {
              item.builder.builder(item);
            }
          }
        } else {
          SettingGroup({
            groupInfo: item,
            compId: `${this.compId}.${item.id}`,
            fixed: true,
            pageCached: this.pageInfo.cached ? true : false,
            layout: PageConfig.getInstance().getGroupLayout(item),
          })
        }
        this.groupFooterBuilder(item, true)
      }, (item: SettingGroupModel) => item.id)
    }
    .width('100%')
    .padding({
      start: this.layout?.padding?.start,
      end: this.layout?.padding?.end,
      top: this.layout?.padding?.top,
    })
  }

  /**
   * 动态加载SegmentButton, 避免冷启动时就加载
   */
  async loadSegmentButton() {
    let segmentButton = await import('./SegmentButtonLoader');
    this.segmentButtonLoader = segmentButton.segmentButtonLoader;
  }

  @Builder
  pageTabsButton(isTabsShow: boolean): void {
    if (isTabsShow) {
      this.segmentButtonLoader({
        tabContents: this.tabContents,
        compId: this.compId,
        selectedIndexes: this.selectedIndexes,
        layout: this.layout
      })
    }
  }

  @Builder
  pageTabsSwiper(tabs: SettingTabsModel[]): void {
    Swiper(this.swiperController) {
      ForEach(tabs, (item: SettingTabsModel, index: number) => {
        this.pageContent({
          groups: item.groups,
          compId: `${this.compId}.${item.id}`,
          hasFixedGroup: true,
          tabIndex: index
        })
      }, (item: SettingTabsModel) => item.id)
    }
    .id(`${this.compId}.Swiper`)
    .disableSwipe(true)
    .indicator(false)
    .loop(false)
    .vertical(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  pageCustom(builder?: WrappedBuilder<[object]>): void {
    builder?.builder(this.pageParam?.param);
  }

  @Builder
  pageStandard(): void {
    NavDestination() {
      if (this.pageInfo.fixedGroups) {
        this.pageFixedGroup()
        Stack({ alignContent: Alignment.Top }) {
          this.pageContentAutoAvoid(
            { groups: this.pageInfo.groups ?? [], hasFixedGroup: true },
            !this.pageInfo.stickBottomContent,
          )
          this.pageClipMask(vp2px(20))
          this.customContentBuilder(this.pageInfo.groupForeground)
        }
        .layoutWeight(1)

        this.customContentBuilder(this.pageInfo.stickBottomContent)
      } else if (this.pageInfo.tabs) {
        this.pageTabsButton(this.pageInfo.tabs.length === 2)
        Stack({ alignContent: Alignment.Top }) {
          this.pageTabsSwiper(this.pageInfo.tabs)
          this.pageClipMask(vp2px(20))
          this.customContentBuilder(this.pageInfo.groupForeground)
        }
        .layoutWeight(1)

        this.customContentBuilder(this.pageInfo.stickBottomContent)
      } else {
        Stack({ alignContent: this.pageInfo.layout?.pageAlign ?? Alignment.Top }) {
          this.pageContentAutoAvoid(
            { groups: this.pageInfo.groups ?? [] },
            !this.pageInfo.stickBottomContent,
          )
          this.pageClipMask(vp2px(20))
          this.customContentBuilder(this.pageInfo.groupForeground)
        }
        .layoutWeight(1)

        this.customContentBuilder(this.pageInfo.stickBottomContent)
      }
    }
    .id(this.compId)
    .size({ width: '100%', height: '100%' })
    .title(this.pageTitle as string, this.pageNavTitleOptions)
    .backgroundColor(this.layout?.backgroundColor)
    .hideTitleBar(this.layout?.hideTitleBar !== undefined ? this.layout?.hideTitleBar : this.isCircleScreen)
    .menus(this.isCircleScreen ? undefined : this.pageMenu())
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .hideBackButton(this.hideBackIcon)
    .onBackPressed(() => {
      if (this.startReason === PageStartReason.FROM_SEARCH) {
        onBackInSettings();
        return true;
      }
      return false;
    })
    .backButtonIcon(new SymbolGlyphModifier($r('sys.symbol.chevron_backward')).focusable(true))
    .padding({
      top: STATUS_BAR_HEIGHT,
    })
  }

  aboutToAppear(): void {
    this.compId = `${this.pageParam?.router}.${this.pageInfo.id}`;
    if (this.pageInfo.type === PageType.PAGE_TYPE_MODAL) {
      this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    }
    LogHelper.info(TAG, `setting page ${this.compId} appear`);
    this.getTitleButtonRectWidth();
    if (this.pageInfo.compControl) {
      this.pageInfo.compControl.init({
        compId: this.compId,
        component: this.pageInfo,
        param: this.pageParam?.param
      });
    }
    if (!this.pageInfo.tabIndex) {
      if (this.pageInfo.type === PageType.PAGE_TYPE_HOME) {
        this.pageInfo.tabIndex = 1;
      } else {
        this.pageInfo.tabIndex = 100;
      }
    }
    this.tempTabIndex = this.pageInfo.tabIndex;
    if (!PageConfigVerify.checkSettingPageVaild(this.pageInfo)) {
      throw new Error(`invaild page config, page id: ${this.pageInfo.id}`);
    }
    this.preprocess(this.pageInfo);
    this.layout = PageConfig.getInstance().getPageLayout(this.pageInfo);
    this.pageNavTitleOptions =
      this.isCircleScreen ? undefined : { paddingStart: this.layout?.padding?.start,
        mainTitleModifier: new TextModifier().id(`${this.compId}.title_id`)
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR) };
    let tabs = this.pageInfo.tabs;
    if (tabs) {
      this.swiperController = new SwiperController();
      if (tabs.length === 2) {
        this.loadSegmentButton();
        this.tabContents = [tabs[0].content, tabs[1].content];
      }
    }
    let pushParam = this.pageParam?.param as PushParam;
    if (pushParam) {
      this.startReason = pushParam.startReason || PageStartReason.DEFAULT;
    }
    this.hideBackIcon = this.isNeedHideBackIcon();
    this.pageTitle = this.pageInfo.title ?? '';
    EventBus.getInstance().on(this.compId, this.eventCb);
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `setting page ${this.compId} disappear`);
    if (this.pageInfo.compControl) {
      this.pageInfo.compControl.destroy();
    }
    EventBus.getInstance().off(this.compId);
  }

  onPageShow(): void {
    LogHelper.info(TAG, `page show, ${this.pageInfo.id}`);
    if (this.pageInfo.compControl?.onPageShow) {
      this.pageInfo.compControl.onPageShow(this.pageInfo);
    }
  }

  onPageHide(): void {
    LogHelper.info(TAG, `page hide, ${this.pageInfo.id}`);
    if (this.pageInfo.compControl?.onPageHide) {
      this.pageInfo.compControl.onPageHide(this.pageInfo);
    }
  }

  build() {
    if (this.pageInfo.type === PageType.PAGE_TYPE_CUSTOM) {
      this.pageCustom(this.pageParam?.pageCtx.pageBuilder);
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_STANDARD) {
      this.pageStandard();
    } else if (this.pageInfo.type === PageType.PAGE_TYPE_MODAL) {
      this.modalPageContent({
        groups: this.pageInfo.groups ?? [],
        alwaysEnabled: this.pageInfo.layout?.alwaysEnabled,
      });
    }
  }
}

@Builder
export function settingPageBuilder(param: object): void {
  SettingPage({
    pageParam: (param as PageParams),
    pageInfo: (param as PageParams).pageCtx.configGenerator(),
  });
}

/**
 * 外界宿主设置执行Pop动作
 */
export function onBackInSettings(): void {
  LogHelper.info(TAG, 'onBackInSettings');
  const intent: Record<string, Object> = { 'action': 'pop' };
  try {
    LocalStorage.getShared()?.get<UIExtensionContentSession>('ExtensionContentSession')?.sendData(intent);
  } catch (e) {
    LogHelper.error(TAG, `onBack catch err. code:${e?.code} message:${e?.message}`);
  }
}