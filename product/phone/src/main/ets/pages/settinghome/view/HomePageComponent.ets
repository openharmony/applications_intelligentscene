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

// import {
//   DividerShowType,
//   HdsNavDestination,
//   HdsNavDestinationAttribute,
//   HdsNavigationTitleBarOptions,
// } from '@kit.UIDesignKit';
// import { BackgroundBrightnessLevel } from '@hms.hds.hdsBaseComponent';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { AppStorageKey } from '@ohos/scene.common/src/main/ets/constant/AppStorageConsts';
import { AccessibilityUtils } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { PromptManager } from '@ohos/scene.common/src/main/ets/basecomponent/prompt/PromptManager';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { HomeSheetCompId } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { onBackInSettings } from '@ohos/scene.common/src/main/ets/framework/view/SettingPage';
import { UiExtensionConstant } from '@ohos/scene.common/src/main/ets/constant/UiExtensionConstant';
import { TemplateModeAdapter } from '../../modesheet/adapter/TemplateModeAdapter';
import { AllModeSwiperComponent } from './AllModeSwiperComponent';
import { HomeGroupComponent } from './HomeGroupComponent';

/* instrument ignore file */
// 最大模式数量
const MAX_MODE_LENGTH: number = 15;
// 动效时间
const ANIMATION_TIME: number = 250;

const TAG: string = 'HomePageComponent:';

@Component
export struct HomePageComponent {
  @Consume('pathInfos') pathInfos: NavPathStack;
  // 生命周期状态
  @State isFirst: boolean = true;
  @State isPageShowing: boolean = true;
  // 背景色
  @State gradientColor: string = '';
  @State enabledModeId: string = NO_SCENE;
  // 标题
  @State title: ResourceStr = $r('app.string.intelligent_scene');
  @State pageOpacity: number = 1;
  @StorageProp(AppStorageKey.NAVIGATION_BAR_HEIGHT) navigationBarHeight: number = 0;
  @StorageLink('navigationMode') navMode: NavigationMode =
    AppStorage.get(UiExtensionConstant.NAVIGATION_MODE) ?? NavigationMode.Stack;
  @StorageLink(UiExtensionConstant.TITLE_ANIMATION_DURATION) titleAnimationDuration?: number = undefined;
  private transitionType: NavigationSystemTransitionType =
    this.navMode === NavigationMode.Stack ? NavigationSystemTransitionType.TITLE : NavigationSystemTransitionType.NONE;
  private scrollerController: Scroller = new Scroller();
  /**
   * 主页主动滑动事件
   */
  private onScrollToCallback = (edge: Edge, accessibilityFocusId?: string): void => {
    LogUtil.showInfo(TAG, `onScrollToCallback. edge:${edge}, accessibilityFocusId: ${accessibilityFocusId}`);
    this.scrollerController.scrollEdge(edge);
    if (accessibilityFocusId) {
      AccessibilityUtils.requestFocusAccessibilityDelay(accessibilityFocusId);
    }
  };
  /**
   * 首页标题切换事件
   */
  private onTitleChangeCallback = (title: ResourceStr): void => {
    LogUtil.showInfo(TAG, `onHomeTitleChangeCallback.`);
    this.title = title ?? $r('app.string.intelligent_scene');
  };
  /**
   * 模式卡片切换事件
   */
  private onScrollNewModeCallback = (): void => {
    const modeId = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(TAG, `onScrollNewModeCallback. modeId:${modeId}`);
    const allModeArr = ModeAdapter.getInstance().getAllModeArr();
    const modeData = allModeArr.find((it) => it.modeId === modeId);
    if (!modeData) {
      return;
    }
    if (typeof this.title !== 'string' && this.title?.id === $r('app.string.intelligent_scene').id) {
      // 如果是初始标题 无需修改
    } else {
      // 如果此时标题不是初始的标题 则需要换成新的模式标题
      LogUtil.showInfo(TAG, `onScrollNewModeCallback. title:${modeData.modeName}`);
      this.title = ModeUtil.getModeNameResourceStr(modeData);
    }
  };
  @Builder
  addModeMenuBuilder(): void {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize('24vp')
          .fontColor([$r('sys.color.icon_primary')])
          .draggable(false)
      }
      .id('addModeIcon')
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .accessibilityText($r('app.string.add_intelligent_scene'))
      // 与左侧返回按钮、标准页菜单右侧留白对齐
      .margin({ right: 16 })
      .onClick(() => {
        this.openAddModeSheet();
      })
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Scroll(this.scrollerController) {
          Column() {
            // 滑块组件
            AllModeSwiperComponent({
              gradientColor: this.gradientColor,
              pageOpacity: this.pageOpacity,
              isPageShowing: this.isPageShowing,
              enabledModeId: this.enabledModeId,
            })
            // 标准组件
            HomeGroupComponent()
              .opacity(this.pageOpacity)
              .animation({ duration: 150, curve: Curve.Sharp })
              .margin({
                top: -13,
              })
          }
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .padding({
          bottom: this.navigationBarHeight,
        })
        .id('homeScroll')
        .clip(true)

        ScrollBar({ scroller: this.scrollerController, direction: ScrollBarDirection.Vertical, state: BarState.Auto })
          .margin({
            bottom: this.navigationBarHeight,
          })
      }
      .layoutWeight(1)
    }
    // 渐变覆盖标题栏/内容区；状态栏区域由 backgroundColor 扩展绘制（与渐变起始色一致）
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: this.gradientColor ? [
        [this.gradientColor.replace('#', '#33'), 0],
        [this.gradientColor.replace('#', '#00'), 0.6],
      ] : [
        // 无模式色时保持透明，避免取消开启时视觉异常
        [Color.Transparent, 0],
      ],
    })
    .animation(this.isFirst ? undefined : {
      duration: ANIMATION_TIME,
      curve: Curve.Sharp,
    })
    // .bindToScrollable([this.scrollerController])
    .hideTitleBar(false)
    .title(this.title, {
      // 标题栏透明，透出下方渐变色
      backgroundColor: Color.Transparent,
    })
    .menus(this.isShowAddModeMenu() ? this.addModeMenuBuilder() : undefined)
    .hideBackButton(this.navMode === NavigationMode.Split)
    // 有模式色时用渐变起始色作为底色，expandSafeArea 会把该色铺到状态栏（时间/电池区域）
    .backgroundColor(this.gradientColor ? this.gradientColor.replace('#', '#33') :
      $r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .systemTransition(this.transitionType)
    .onShown(() => {
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      LogUtil.showInfo(TAG, 'onBackPressed.');
      this.transitionType = NavigationSystemTransitionType.TITLE;
      if (this.navMode !== NavigationMode.Split) {
        onBackInSettings();
      }
      return false;
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear.`);
    TemplateModeAdapter.getInstance().initData();
    EventBus.getInstance().on(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
    EventBus.getInstance().on(EventBusNameConstant.HOME_TITLE_CHANGE, this.onTitleChangeCallback);
    EventBus.getInstance().on(EventBusNameConstant.HOME_SCROLL_TO, this.onScrollToCallback);
    // 第一次进来 如果有背景色不做动效
    setTimeout(() => {
      this.isFirst = false;
    }, ANIMATION_TIME);
  }

  onPageShow(): void {
    LogUtil.showInfo(TAG, 'onPageShow');
    EventBus.getInstance().emit(EventBusNameConstant.PAGE_ROUTER_SETTINGS, 'intelligent_scene_home_entry');
    this.isPageShowing = true;
  }

  onPageHide(): void {
    LogUtil.showInfo(TAG, 'onPageHide');
    this.isPageShowing = false;
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    EventBus.getInstance().detach(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
    EventBus.getInstance().detach(EventBusNameConstant.HOME_TITLE_CHANGE, this.onTitleChangeCallback);
    EventBus.getInstance().detach(EventBusNameConstant.HOME_SCROLL_TO, this.onScrollToCallback);
  }

  /**
   * 是否展示添加模式入口
   */
  private isShowAddModeMenu(): boolean {
    return ModeConfigAdapter.getInstance().getConfigByModeId(this.enabledModeId).isShowOtherMode;
  }

  /**
   * 拉起添加模式模态框
   */
  private openAddModeSheet(): void {
    LogUtil.showInfo(TAG, 'openAddModeSheet.');
    const allModelArr = ModeAdapter.getInstance().getAllModeArr();
    if (allModelArr.length >= MAX_MODE_LENGTH) {
      PromptManager.getInstance().showToastWithThrottle($r('app.string.add_intelligent_scene_max_toast'));
      return;
    }
    void this.showAddModeSheet();
  }

  private async showAddModeSheet(): Promise<void> {
    await TemplateModeAdapter.getInstance().ensureDataLoaded();
    notifyCompStateChange(HomeSheetCompId.ADD_SHEET_COMP_ID,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: true } as SettingModalState]
      ])
    );
  }
}
