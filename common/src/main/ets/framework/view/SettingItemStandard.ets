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

import { LengthMetrics } from '@ohos.arkui.node';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { display, uiExtensionHost, window } from '@kit.ArkUI';
import { SymbolGlyphModifier } from '@ohos.arkui.modifier';
import uiAppearance from '@ohos.uiAppearance';
import { DebounceUtil } from '../../utils/DebounceUtil';
import { FontScaleUtils } from '../../utils/FontScaleUtils';
import { PADDING_12, FOCUS_BOX_PADDING_METRICS } from '../common/StyleConstant';
import { DataVerify } from '../common/DataVerify';
import { EventBus } from '../common/EventBus';
import { EventBusNameConstant } from '../../constant/EventBusNameConstant';
import { LogHelper } from '../common/LogHelper';
import { ModalLoader } from '../common/ModalLoader';
import { Optional } from '../common/Optional';
import { PageConfig } from '../common/PageConfig';
import { PageContext, PageParams } from '../common/PageLoader';
import { PageRouter } from '../common/PageRouter';
import {
  DefaultSettingItemModel,
  ItemDetailType,
  ItemPos,
  ItemResultType,
  ItemType,
  SettingDialogModel,
  SettingIconModel,
  SettingIconStyle,
  SettingIconType,
  SettingItemDetailModel,
  SettingItemDividerModel,
  SettingItemLayout,
  SettingItemModel,
  SettingItemResultModel,
  SettingMenuStyle,
  SettingRadioModel,
  SettingRadioStyle,
  SettingSelectMenu,
  SettingTextModel,
  SettingTextStyle,
  SettingTextType,
  SettingToggleModel,
  SettingToggleStyle,
  DespLinkTextContent,
} from '../model/SettingItemModel';
import { SettingSheetPageContext } from '../model/SettingPageModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingDialogState,
  SettingIconState,
  SettingModalState,
  SettingRadioState,
  SettingResultState,
  SettingSelectMenuState,
  SettingStateType,
  SettingTextState,
  SettingToggleState
} from '../model/SettingStateModel';
import { ResourceUtil } from '../../utils/ResourceUtil';
import { LinkTextComponent } from '../../basecomponent/text/LinkTextComponent';

@Extend(Image)
function iconStyle(style: SettingIconStyle) {
  .width(style.width)
  .height(style.height)
  .objectFit(style.objectFit)
  .borderRadius(style.borderRadius)
  .draggable(style.draggable)
  .interpolation(style.interpolation)
  .edgeAntialiasing(style.edgeAntialiasing)
  .border(style.border)
  .clip(style.clip)
  .syncLoad(true)
  .matchTextDirection(style.mirrored)
}

@Extend(SymbolGlyph)
function symbolIconStyle(style: SettingIconStyle) {
  .fontSize(style.height)
  .fontColor([style?.fillColor])
  .borderRadius(style.borderRadius)
  .draggable(style.draggable)
  .renderingStrategy(style.renderingStrategy)
}

@Extend(Text)
function textStyle(style: SettingTextStyle, fontColor?: ResourceColor) {
  .fontSize(style.fontSize)
  .fontColor(fontColor ?? style.fontColor)
  .fontWeight(style.fontWeight)
  .fontFamily(style.fontFamily)
  .textAlign(style.textAlign)
  .maxLines(style.maxLines)
  .textOverflow({ overflow: style.textOverflow })
  .minFontSize(style.minFontSize)
  .maxFontSize(style.maxFontSize)
  .wordBreak(style.wordBreak)
  .lineHeight(style.lineHeight)
  .opacity(style.opacity)
  .direction(style.direction)
}

@Extend(Toggle)
function toggleStyle(style?: SettingToggleStyle) {
  .margin(style?.margin)
  .hoverEffect(style?.hoverEffect ?? HoverEffect.None)
  .width(style?.width)
  .height(style?.height)
}

@Observed
class SettingIconVM {
  public icon?: ResourceStr | PixelMap = '';
}

@Observed
class SettingTextVM {
  public content: ResourceStr = '';
  public fontColor?: ResourceColor;
}

@Observed
class SettingDespVM extends SettingTextVM {
  public builder?: WrappedBuilder<[object]>;
  public linkTextContent?: DespLinkTextContent;
}

@Observed
class SettingToggleVM {
  public state: boolean = false;
  public enabled?: boolean = true;
  public onAllowChanged?: (isOn: boolean) => boolean;
}

type SheetDetents = [(SheetSize | Length), (SheetSize | Length)?, (SheetSize | Length)?]

@Observed
class SettingRadioVM {
  public state: boolean = false;
}

const TAG: string = 'SettingItemStandard';
const UX_DESIGN_SHEET_HEIGHT_PAD: number = 320;
const DEBOUNCE_DELAY: number = 200;
const WAIT_MODAL_CLOSE_DELAY: number = 200;

@Component
export struct SettingItemStandard {
  itemInfo: SettingItemModel = DefaultSettingItemModel.get();
  compId: string = '';
  homePageComp: boolean = false;
  parentId?: string;
  openDialog?: (item: SettingItemModel, dialog: SettingDialogModel) => void;
  closeDialog?: () => void;
  sheetPageCtx?: SettingSheetPageContext;
  private isCircleScreen: boolean = PageConfig.getInstance().isCircleScreen();
  private layout?: SettingItemLayout;
  private currentFontSizeScale?: number;
  private isLargeFontMode: boolean = false;
  private subWindow?: window.Window;
  private isFirstCreateSubWindow: boolean = true;
  private uiContextInSubWindow?: UIContext;
  private hostWindow?: uiExtensionHost.UIExtensionHostWindowProxy;
  private isDisappeared: boolean = false;
  @State itemPos: number = 0;
  @State isSelected: boolean = false;
  @State isShowSelectedBackColor: boolean = false;
  @State enabledState: boolean = true;
  @State iconState: SettingIconVM = new SettingIconVM();
  @State titleState: SettingTextVM = new SettingTextVM();
  @State despState: SettingDespVM = new SettingDespVM();
  @State resultState: SettingTextVM | SettingIconVM | SettingToggleVM | SettingRadioVM = new SettingTextVM();
  @State minHeight: Length = 0;
  @State isModalShow: boolean = false;
  @State menuSelectIndex?: number = undefined;
  @State itemRadioChecked: boolean = false;
  @State isHover: boolean = false;
  @State isVisible: boolean = true;
  @State sheetHeight?: SheetSize | Length = undefined;
  @State sheetDetents?: SheetDetents = undefined;
  @State isSheetCenter: boolean = false;
  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogHelper.error(TAG, 'invalid eventbus data type.');
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };
  private handleResizeSubWindow = DebounceUtil.debounce(async () => {
    try {
      const displayManage: display.Display = display.getDefaultDisplaySync();
      const windowRect: window.Rect | undefined = this.getProxyWindow()?.properties.uiExtensionHostWindowProxyRect;
      const hostWidth: number = windowRect?.width || 0;
      const hostHeight: number = windowRect?.height || 0;
      let targetWidth: number = displayManage.width;
      let targetHeight: number = displayManage.height;

      if (hostWidth > 0 && hostHeight > 0) {
        // 悬浮/分屏：宿主宽度明显小于屏幕，跟宿主真实尺寸，避免半模态占满整屏
        // 全屏：宿主常为扣除状态栏后的区域(如 1200x1770)，若仍跟宿主高度，底部导航条上方会露缝；此时用整屏尺寸
        const isCompactHost: boolean = hostWidth < displayManage.width * 0.95;
        if (isCompactHost) {
          targetWidth = hostWidth;
          targetHeight = hostHeight;
        }
        LogHelper.info(TAG,
          `handleResizeSubWindow host=${hostWidth}x${hostHeight}, compact=${isCompactHost}, ` +
            `target=${targetWidth}x${targetHeight}`);
      } else {
        LogHelper.warn(TAG,
          `handleResizeSubWindow host rect invalid, fallback display ${targetWidth}x${targetHeight}`);
      }
      await this.subWindow?.resize(targetWidth, targetHeight);
    } catch (err) {
      LogHelper.error(TAG, `handleResizeSubWindow fail, code: ${err?.code}, msg:${err?.message}`);
    }
  }, DEBOUNCE_DELAY);

  private getProxyWindow(): uiExtensionHost.UIExtensionHostWindowProxy | undefined {
    return LocalStorage.getShared()?.get<UIExtensionContentSession>('ExtensionContentSession')
    ?.getUIExtensionHostWindowProxy();
  }

  private buildPageParam(pageUrl: string, pageCtx: PageContext): PageParams {
    return {
      router: this.compId.split('.')[0],
      pageUrl: pageUrl,
      pageCtx: {
        configGenerator: pageCtx.configGenerator,
        pageBuilder: pageCtx.pageBuilder
      },
      param: this.sheetPageCtx ? this.sheetPageCtx : { itemComp: this.itemInfo } as SettingSheetPageContext
    }
  }

  private hasBindSheet(detail?: SettingItemDetailModel): boolean {
    if (!detail) {
      return false;
    }
    return (detail.type === ItemDetailType.DETAIL_TYPE_MODAL) && (detail.destination !== undefined ||
      detail.sheetBuilder !== undefined);
  }

  private getSheetHeight(): SheetSize | Length | undefined {
    if (this.isLargeFontMode) {
      return SheetSize.LARGE;
    }
    if (this.isSheetCenter) {
      const firstSize: SheetSize | Length | undefined = this.sheetDetents ? this.sheetDetents[0] : undefined;
      // 如果sheetDetents第一个就是SheetSize.LARGE，说明需要一个大窗口（不是320的高度规格）
      return firstSize === SheetSize.LARGE ? SheetSize.LARGE : (this.sheetHeight || UX_DESIGN_SHEET_HEIGHT_PAD);
    } else {
      return this.sheetHeight;
    }
  }

  private getSheetDetents(): SheetDetents | undefined {
    if (this.isLargeFontMode) {
      return [SheetSize.LARGE];
    }
    return this.isSheetCenter ? undefined : this.sheetDetents;
  }

  private buildSheetOptions(userCfg?: SheetOptions): SheetOptions {
    return {
      height: this.getSheetHeight(),
      detents: this.getSheetDetents(),
      dragBar: userCfg?.dragBar !== undefined ? userCfg.dragBar : false,
      showClose: userCfg?.showClose !== undefined ? userCfg.showClose : false,
      showInSubWindow: userCfg?.showInSubWindow !== undefined ? userCfg.showInSubWindow : false,
      uiContext: this.uiContextInSubWindow,
      title: userCfg?.title ?? undefined,
      preferType: userCfg?.preferType ?? SheetType.CENTER,
      backgroundColor: userCfg?.backgroundColor ?? $r('sys.color.ohos_id_color_dialog_bg'),
      maskColor: userCfg?.maskColor ?? $r('sys.color.mask_fourth'),
      onTypeDidChange: (sheetType: SheetType) => {
        LogHelper.info(TAG, `item bind sheet type change, compID: ${this.compId} sheetType: ${sheetType}`);
        EventBus.getInstance().emit(EventBusNameConstant.SHEET_TYPE_CHANGE, sheetType);
        // pad 分屏场景会改变模态框的形式
        this.isSheetCenter = sheetType === SheetType.CENTER;
      },
      onAppear: () => {
        LogHelper.info(TAG, `item bind sheet appear, compID: ${this.compId}`);
        userCfg?.onAppear?.();
      },
      onDisappear: () => {
        LogHelper.info(TAG, `item bind sheet disappear, compID: ${this.compId}`);
        userCfg?.onDisappear?.();
      },
      onWillDisappear: () => {
        LogHelper.info(TAG, `item bind sheet will disappear, compID: ${this.compId}`);
        this.isModalShow = false;
        setTimeout(() => {
          this.closeWindow();
        }, WAIT_MODAL_CLOSE_DELAY);
      }
    };
  }

  private async createSubWin(): Promise<void> {
    if (!this.isFirstCreateSubWindow) {
      return;
    }
    LogHelper.info(TAG, 'createSubWin');
    this.isFirstCreateSubWindow = false;
    const extensionWindow: uiExtensionHost.UIExtensionHostWindowProxy | undefined = this.getProxyWindow();
    try {
      // 创建子窗口
      let subWindowName = 'subWindowForHost_' + new Date().getTime().toString();
      let subWindowOpts: window.SubWindowOptions = {
        title: 'sheet subWindow',
        decorEnabled: false,
        isModal: false
      };
      this.subWindow = await extensionWindow?.createSubWindowWithOptions(subWindowName, subWindowOpts);
      this.handleResizeSubWindow();
      // 加载空页面作为模态框的载体，并传入LocalStorage, 保证主窗和子窗的LocalStorage一致
      this.subWindow?.loadContent('', this.getUIContext().getSharedLocalStorage());
      // 在子窗上挂载监听, 当子窗口可见状态变化时展示模态框, 这里使用监听是为了规避底层渲染时机偶现错乱的问题
      this.subWindow?.on('windowVisibilityChange', (data: boolean) => {
        LogHelper.info(TAG, `Window visibility change event, visible value: ${data}`);
        if (data) {
          this.onWindowEvent();
        }
      });
      // 展示子窗
      await this.subWindow?.showWindow();
      // 初始化窗口大小监听
      this.handleWindowSizeChange();
      // 将子窗口设置透明, 这里不用 Color.TransParent 主要是因为要求是字符串
      this.subWindow?.setWindowBackgroundColor('#00000000');
      // 关闭窗口边缘阴影
      this.subWindow?.setShadow(0);
      // 获取子窗的上下文, 用于后面挂载到模态框内
      this.uiContextInSubWindow = this.subWindow?.getUIContext();
    } catch (err) {
      LogHelper.error(TAG, `Failed crete sub window. code: ${err?.code}, msg: ${err?.message}`);
      this.closeWindow();
    }
  }

  private closeWindow(): void {
    this.isFirstCreateSubWindow = true;
    try {
      LogHelper.info(TAG, 'closeWindow start');
      this.hostWindow?.off('windowSizeChange', this.handleResizeSubWindow);
      this.subWindow?.destroyWindow(() => {
        LogHelper.info(TAG, 'closeWindow finish');
      });
    } catch (err) {
      LogHelper.error(TAG, `Failed to destroy the window. error code: ${err?.code}, message: ${err?.message}`);
    }
  }

  private onWindowEvent(): void {
    //  多实例场景，如果半模态已经消失，需要关闭子窗，否则会冻屏
    if (this.isDisappeared) {
      LogHelper.info(TAG, 'bind sheet is disAppear need close window');
      this.closeWindow();
    } else {
      this.isModalShow = true;
    }
    LogHelper.info(TAG, `onWindowEvent isDisappeared: ${this.isDisappeared}, isModalShow: ${this.isModalShow}`);
  }

  private handleWindowSizeChange(): void {
    this.hostWindow = this.getProxyWindow();
    if (!this.hostWindow) {
      LogHelper.warn(TAG, 'hostWindow undefined');
      return;
    }
    try {
      // 使用 proxyWindow 取窗口大小有时延，导致窗口取用的数据可能不准，需要加上防护能力
      this.hostWindow?.on('windowSizeChange', this.handleResizeSubWindow);
    } catch (err) {
      LogHelper.error(TAG, `Failed to register windowSizeChange. code: ${err?.code}, msg: ${err?.message}`);
    }
  }

  private supportMenu(detail?: SettingItemDetailModel): boolean {
    if (!detail) {
      return false;
    }
    return detail.type === ItemDetailType.DETAIL_TYPE_MENU && detail.menu !== undefined;
  }

  private isSupportClick(item: SettingItemModel): boolean {
    if (!item.detail && !item.compControl?.onClick) {
      if (item.result?.type === ItemResultType.RESULT_TYPE_RADIO ||
        (PageConfig.getInstance().isCircleScreen() && item.result?.type === ItemResultType.RESULT_TYPE_TOGGLE)) {
        return true;
      }
      return false;
    }
    return true;
  }

  private onHomePageSelected(): void {
    LogHelper.info(TAG, `${this.compId} change to selected`);
    this.isShowSelectedBackColor = PageConfig.getInstance().isSplitMode();
    let lastKey: string = AppStorage.get('currentHomeKey') as string;
    if (lastKey === this.compId) {
      return;
    }
    notifyCompStateChange(lastKey,
      new Map([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
        { state: false } as SettingCompState]]));
    AppStorage.setOrCreate('currentHomeKey', this.compId);
  }

  private getItemDividerMargin(divider?: SettingItemDividerModel, icon?: SettingIconModel): LocalizedPadding {
    if (divider?.leftPadding) {
      return { start: divider.leftPadding };
    }

    if (!icon) {
      return {};
    }

    let iconStyle = PageConfig.getInstance().getIconStyle(icon);
    return { start: LengthMetrics.vp((iconStyle.width as number) + (this.layout?.leftMiddleSpace?.value ?? 0)) };
  }

  private initTextState(state: SettingTextVM, textCtx: SettingTextModel): void {
    state.content = textCtx.content;
    state.fontColor = PageConfig.getInstance().getTextStyle(textCtx).fontColor;
  }

  private storeTextState(state: SettingTextVM, textCtx: SettingTextModel): void {
    textCtx.content = state.content;
    if (!textCtx.style) {
      textCtx.style = {};
    }
    textCtx.style.fontColor = state.fontColor;
  }

  private initItemContent(item: SettingItemModel): void {
    this.isVisible = item.visible ?? true;
    if (item.getInitEnabled) {
      this.enabledState = item.getInitEnabled();
    } else if (item.enabled !== undefined) {
      this.enabledState = item.enabled;
    }
    if (item.icon) {
      this.iconState.icon = item.icon.icon;
    }
    if (item.title) {
      item.title.textType = SettingTextType.TEXT_TYPE_PRIMARY;
      this.initTextState(this.titleState, item.title);
    }
    if (item.desp) {
      item.desp.textType = SettingTextType.TEXT_TYPE_SECONDARY;
      this.initTextState(this.despState, item.desp);
      this.despState.builder = item.desp.builder;
      this.despState.linkTextContent = item.desp.linkTextContent;
    }
    if (item.detail && (item.detail.iconType === undefined)) {
      item.detail.iconType = SettingIconType.ICON_TYPE_ARROW;
    }
    if (item.detail?.menu?.selectIndex !== undefined) {
      this.menuSelectIndex = item.detail.menu.selectIndex;
    }
    if (item.result) {
      if (item.result.type === ItemResultType.RESULT_TYPE_TEXT) {
        (item.result.result as SettingTextModel).textType = SettingTextType.TEXT_TYPE_SECONDARY;
        this.initTextState(this.resultState as SettingTextVM, item.result.result as SettingTextModel);
      } else if (item.result.type === ItemResultType.RESULT_TYPE_IMAGE) {
        (item.result.result as SettingIconModel).iconType = SettingIconType.ICON_TYPE_TIP;
        (this.resultState as SettingIconVM).icon = (item.result.result as SettingIconModel).icon;
      } else if (item.result.type === ItemResultType.RESULT_TYPE_TOGGLE) {
        (this.resultState as SettingToggleVM).state = (item.result.result as SettingToggleModel).state;
        (this.resultState as SettingToggleVM).enabled = (item.result.result as SettingToggleModel).enabled ?? true;
        if ((item.result.result as SettingToggleModel).onAllowChanged) {
          (this.resultState as SettingToggleVM).onAllowChanged =
            (item.result.result as SettingToggleModel).onAllowChanged;
        }
      } else if (item.result.type === ItemResultType.RESULT_TYPE_RADIO) {
        if ((item.result.result as SettingRadioModel).checked) {
          this.itemRadioChecked = true;
        }
      }
    }
    if (this.hasBindSheet(item.detail)) {
      this.sheetHeight = item.detail?.sheetOptions?.height ?? undefined;
      this.sheetDetents = item.detail?.sheetOptions?.detents;
    }
  }

  private storeItemContent(item: SettingItemModel): void {
    item.enabled = this.enabledState;
    if (item.icon) {
      item.icon.icon = this.iconState.icon;
    }
    if (item.title) {
      this.storeTextState(this.titleState, item.title);
    }
    if (item.desp) {
      this.storeTextState(this.despState, item.desp);
    }
    if (item.result) {
      if (item.result.type === ItemResultType.RESULT_TYPE_TEXT) {
        this.storeTextState(this.resultState as SettingTextVM, item.result.result as SettingTextModel);
      } else if (item.result.type === ItemResultType.RESULT_TYPE_IMAGE) {
        (item.result.result as SettingIconModel).icon = (this.resultState as SettingIconVM).icon;
      } else if (item.result.type === ItemResultType.RESULT_TYPE_TOGGLE) {
        (item.result.result as SettingToggleModel).state = (this.resultState as SettingToggleVM).state;
      } else if (item.result.type === ItemResultType.RESULT_TYPE_RADIO) {
        (item.result.result as SettingRadioModel).checked = this.itemRadioChecked;
      }
    }
  }

  private updateTextState(value: SettingBaseState, state: SettingTextVM): void {
    let textState = value as SettingTextState;
    if (!textState) {
      LogHelper.error(TAG, 'invaild text state event');
      return;
    }

    if (textState.content !== undefined && textState.content !== state.content) {
      state.content = textState.content;
    }
    if (textState.fontColor && textState.fontColor !== state.fontColor) {
      state.fontColor = textState.fontColor;
    }
  }

  private updateItemEnabled(value: SettingBaseState, state: boolean): void {
    let enabledState = value as SettingCompState;
    if (!enabledState) {
      LogHelper.error(TAG, 'invaild enabled state event');
      return;
    }

    LogHelper.info(TAG, `enabled state change: ${JSON.stringify(enabledState)}`);
    if (enabledState.state !== undefined && enabledState.state !== this.enabledState) {
      this.enabledState = enabledState.state;
    }
  }

  private updateIconState(value: SettingBaseState, state: SettingIconVM): void {
    let iconState = value as SettingIconState;
    if (!iconState) {
      LogHelper.error(TAG, 'invaild icon state event');
      return;
    }

    LogHelper.info(TAG, `icon state change: ${JSON.stringify(iconState)}`);
    if (iconState.icon && iconState.icon !== state.icon) {
      state.icon = iconState.icon;
    }
  }

  private updateToggleState(value: SettingBaseState, state: SettingToggleVM): void {
    let toggleState = value as SettingToggleState;
    if (!toggleState) {
      LogHelper.error(TAG, 'invaild toggle state event');
      return;
    }

    LogHelper.info(TAG, `toggle state change: ${JSON.stringify(toggleState)}`);
    if (toggleState.state !== undefined && toggleState.state !== state.state) {
      state.state = toggleState.state;
    }
    if (toggleState.enabled !== undefined && toggleState.enabled !== state.enabled) {
      state.enabled = toggleState.enabled;
    }
    if (toggleState.onAllowChanged !== undefined && toggleState.onAllowChanged !== state.onAllowChanged) {
      state.onAllowChanged = toggleState.onAllowChanged;
    }
  }

  private updateRadioState(value: SettingBaseState): void {
    const radioState: SettingRadioState = value as SettingRadioState;
    if (!radioState) {
      LogHelper.error(TAG, 'invaild radio state event');
      return;
    }

    LogHelper.info(TAG, `radio state change: ${JSON.stringify(radioState)}`);
    if (radioState.checked !== this.itemRadioChecked) {
      this.itemRadioChecked = radioState.checked;
    }
  }

  private updateResultState(value: SettingBaseState,
    state: SettingTextVM | SettingIconVM | SettingToggleVM | SettingRadioVM): void {
    let result = value as SettingResultState;
    if (!result || result.type !== this.itemInfo.result?.type) {
      LogHelper.error(TAG, 'invaild result state event');
      return;
    }

    LogHelper.info(TAG, `item component result update, compId: ${this.compId}`);
    switch (result.type) {
      case ItemResultType.RESULT_TYPE_TEXT:
        this.updateTextState(result.result, state as SettingTextVM);
        break;

      case ItemResultType.RESULT_TYPE_IMAGE:
        this.updateIconState(result.result, state as SettingIconVM);
        break;

      case ItemResultType.RESULT_TYPE_TOGGLE:
        this.updateToggleState(result.result, state as SettingToggleVM);
        break;

      case ItemResultType.RESULT_TYPE_RADIO:
        this.updateRadioState(result.result);
        break;

      default:
        LogHelper.error(TAG, `invaild result type: ${result.type}`);
        break;
    }
  }

  private updateItemSelected(value: SettingBaseState): void {
    let state = value as SettingCompState;
    LogHelper.info(TAG, `set item selected state to ${state.state}, compId: ${this.compId}`);
    if (state.state) {
      if (this.homePageComp) {
        this.isShowSelectedBackColor = PageConfig.getInstance().isSplitMode();
      }
    } else {
      // 消除之前的选中状态
      this.isShowSelectedBackColor = false;
    }
  }

  private procDialogEvent(item: SettingItemModel, dialog: SettingDialogModel): void {
    if (!dialog || (!dialog.contentBuilder && !dialog.message)) {
      LogHelper.info(TAG, `item close dialog event, compId: ${this.compId}`);
      this.closeDialog?.();
    } else {
      LogHelper.info(TAG, `item open dialog event, compId: ${this.compId}`);
      this.openDialog?.(item, dialog);
    }
  }

  private procSheetEvent(state: SettingModalState): void {
    if (state.state === false) {
      LogHelper.info(TAG, `close item modal sheet, compId: ${this.compId}`);
      this.isModalShow = false;
      return;
    }
    if (state.sheetDetents !== undefined) {
      this.sheetDetents = state.sheetDetents;
    }
    if (state.sheetHeight !== undefined) {
      this.sheetHeight = state.sheetHeight;
    }
    if (state.state === true) {
      LogHelper.info(TAG, `open item modal sheet, compId: ${this.compId}`);
      PageRouter.pushModal(this.itemInfo.detail?.destination as string, this.itemInfo).then(async () => {
        await this.createSubWin();
      });
    }
  }

  private procItemPosChange(state: SettingCompState) {
    LogHelper.info(TAG, `item pos change to ${state.state}, compId: ${this.compId}`);
    if (state.state) {
      this.itemPos |= ItemPos.ITEM_POS_END;
    } else {
      this.itemPos &= ~ItemPos.ITEM_POS_END;
    }
  }

  private procItemIsGroupStartChange(state: SettingCompState) {
    LogHelper.info(TAG, `group start pos change to ${state.state}, compId: ${this.compId}`);
    if (state.state) {
      this.itemPos |= ItemPos.ITEM_POS_START;
    } else {
      this.itemPos &= ~ItemPos.ITEM_POS_START;
    }
  }

  private updateDespState(value: SettingTextState): void {
    if (value.content !== undefined && value.content !== this.despState.content) {
      this.minHeight = PageConfig.getInstance().getItemMinHeight(this.itemInfo, (value.content !== ''));
      LogHelper.info(TAG, `update min height to ${this.minHeight}`);
    }

    this.updateTextState(value, this.despState);

    if (!this.itemInfo.desp) {
      this.itemInfo.desp = { content: '', textType: SettingTextType.TEXT_TYPE_SECONDARY };
    } else {
      this.itemInfo.desp.textType = SettingTextType.TEXT_TYPE_SECONDARY;
    }
  }

  private procItemMenuChange(item: SettingItemModel, menu: SettingSelectMenuState): void {
    if (item.detail?.type !== ItemDetailType.DETAIL_TYPE_MENU) {
      return;
    }
    if (menu.items !== undefined) {
      (item.detail.menu as SettingSelectMenu).items = menu.items;
    }
    if (menu?.selectIndex !== undefined) {
      this.menuSelectIndex = menu?.selectIndex;
      if (this.itemInfo.detail && this.itemInfo.detail?.menu?.onSelected !== undefined) {
        this.itemInfo.detail?.menu?.onSelected(this.menuSelectIndex,
          item.detail.menu?.items[this.menuSelectIndex]?.content);
      }
      if (item.result?.type === ItemResultType.RESULT_TYPE_TEXT) {
        (this.resultState as SettingTextState).content = item.detail.menu?.items[this.menuSelectIndex]?.content;
      }
    }
  }

  private procItemVisible(state: SettingCompState): void {
    LogHelper.info(TAG, `item visible to ${state.state}, compId: ${this.compId}`);
    if (state.state === undefined || state.state === this.isVisible) {
      LogHelper.warn(TAG, 'the state is not empty or no update required');
      return;
    }
    this.isVisible = state.state;
  }

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      switch (key) {
        case SettingStateType.STATE_TYPE_ITEM_ENABLED:
          this.updateItemEnabled(value, this.enabledState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_ICON:
          this.updateIconState(value, this.iconState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_TITLE:
          this.updateTextState(value, this.titleState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_DESP:
          this.updateDespState(value as SettingTextState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_RESULT:
          this.updateResultState(value, this.resultState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_SELECTED:
          this.updateItemSelected(value);
          break;

        case SettingStateType.STATE_TYPE_ITEM_DIALOG:
          this.procDialogEvent(this.itemInfo, value as SettingDialogState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_SHEET:
          this.procSheetEvent(value as SettingModalState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_POS:
          this.procItemPosChange(value as SettingCompState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START:
          this.procItemIsGroupStartChange(value as SettingCompState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_MENU:
          this.procItemMenuChange(this.itemInfo, value as SettingSelectMenuState);
          break;

        case SettingStateType.STATE_TYPE_ITEM_VISIBLE:
          this.procItemVisible(value as SettingCompState);
          break;

        default:
          LogHelper.error(TAG, `invaild event data key: ${key}`);
          break;
      }
    })
  }

  private onDetailInteraction(item: SettingItemModel, detail: SettingItemDetailModel): void {
    detail?.onItemClick?.(item);
    if (detail.type === ItemDetailType.DETAIL_TYPE_CUSTOM) {
      LogHelper.info(TAG, `custom detail onClick, item: ${this.compId}`);
    } else if (detail.type === ItemDetailType.DETAIL_TYPE_NAVIGATE) {
      LogHelper.info(TAG, `navigate to ${detail.destination}`);
      PageRouter.push(detail.destination as string, this.itemInfo);
    } else if (detail.type === ItemDetailType.DETAIL_TYPE_DIALOG) {
      if (detail.dialog) {
        this.openDialog?.(item, detail.dialog);
      }
    } else if (detail.type === ItemDetailType.DETAIL_TYPE_MODAL) {
      if (this.sheetPageCtx) {
        let pageCtx = ModalLoader.getPageContext(detail.destination as string);
        if (!pageCtx.isPresent()) {
          LogHelper.info(TAG, `jump modal page ${detail.destination} failed, item ${this.compId}`);
          return;
        }
        PageRouter.pushModal(detail.destination as string, this.itemInfo);
        LogHelper.info(TAG, `jump modal page, item ${this.compId}`);
        // 添加新页面到绑定的设置项上
        this.sheetPageCtx.pathStack?.pushPathByName(detail.destination,
          this.buildPageParam(detail.destination as string, pageCtx.get()));
      } else {
        LogHelper.info(TAG, `entry modal page, item ${this.compId}`);
        PageRouter.pushModal(detail.destination as string, this.itemInfo).then(async () => {
          await this.createSubWin();
        })
      }
    }
  }

  private onItemClick(item: SettingItemModel): void {
    if (this.homePageComp) {
      // 主页分栏场景，点击才能选中
      this.onHomePageSelected();
    }

    if (item.detail) {
      this.onDetailInteraction(item, item.detail);
      if (item.compControl?.onClick) {
        item.compControl?.onClick(item);
      }
    } else if (item.compControl?.onClick) {
      LogHelper.info(TAG, `comp ctrl onClick, item: ${this.compId}`);
      item.compControl?.onClick(item);
    } else if (item.result?.type === ItemResultType.RESULT_TYPE_RADIO) {
      if (!this.itemRadioChecked) {
        (item.result.result as SettingRadioModel).onCheck?.(true, this.itemInfo);
        this.itemRadioChecked = true;
      }
    } else if (item.result?.type === ItemResultType.RESULT_TYPE_TOGGLE && PageConfig.getInstance().isCircleScreen()) {
      let isOn = (this.resultState as SettingToggleVM).state;
      LogHelper.info(TAG, `Toggle switch is ${isOn}, compId: ${this.compId}`);
      (this.resultState as SettingToggleVM).state = !isOn;
      EventBus.getInstance().emit(`${this.compId}.toggle`, { state: !isOn } as SettingCompState);
      (item.result.result as SettingToggleModel).onChanged?.(!isOn);
    }
  }

  private onItemTouch(item: SettingItemModel, touchType: TouchType): void {
    // 没有detail时，不支持选中背景
    if (!item.detail) {
      return;
    }

    if (touchType === TouchType.Down) {
      this.isSelected = true;
    } else if (touchType === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private onMouseEvent(item: SettingItemModel, event: MouseEvent): void {
    // 没有detail时，不支持选中背景
    if (!item.detail) {
      return;
    }

    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private getNormalColor(): ResourceColor | undefined {
    if (this.isShowSelectedBackColor) {
      return this.getBackgroundColorResource();
    }
    if (this.isHover && this.isSupportClick(this.itemInfo)) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return this.layout?.background?.normalBackgroundColor;
  }

  private getBackgroundColorResource(): ResourceColor {
    try {
      LogHelper.info(TAG, 'getDarkMode success');
      return uiAppearance.getDarkMode() === 0 ? '#19317AF7' : '#190A59F7';
    } catch (err) {
      LogHelper.error(TAG, 'getDarkMode fail');
      return '#190A59F7';
    }
  }

  private getPressedColor(): ResourceColor | undefined {
    if (PageConfig.getInstance().isSplitMode() && this.homePageComp && !this.isShowSelectedBackColor) {
      return this.layout?.background?.normalBackgroundColor;
    }

    if (this.isShowSelectedBackColor) {
      return this.getBackgroundColorResource();
    }
    return this.layout?.background?.pressedBackgroundColor;
  }

  private getItemPressedColor(item: SettingItemModel): ResourceColor | undefined {
    if (this.isSupportClick(item)) {
      return this.getPressedColor();
    }

    if (this.isCircleScreen) {
      return this.layout?.background?.normalBackgroundColor;
    }
    return undefined;
  }

  private titleSizeRestricted(result?: SettingItemResultModel): boolean {
    return !!result && (result.type === ItemResultType.RESULT_TYPE_TEXT ||
      result.type === ItemResultType.RESULT_TYPE_CUSTOM);
  }

  private getOpacity(): number | Resource {
    return this.enabledState === false ? $r('sys.float.alpha_tertiary') : 1;
  }

  private getMenuSelectState(isHideSelected: boolean | undefined, index: number): boolean {
    return !isHideSelected && this.menuSelectIndex === index;
  }

  @Builder
  itemIconBuilder(iconStyle: SettingIconStyle, iconMargin?: LocalizedPadding): void {
    if (iconStyle.builder) {
      iconStyle.builder?.builder(this.itemInfo)
    } else if (iconStyle.fillColor !== undefined) {
      Image(this.iconState.icon)
        .id(`${this.compId}.icon`)
        .iconStyle(iconStyle)
        .opacity(this.getOpacity())
        .fillColor(iconStyle.fillColor)
        .margin(iconMargin)
    } else {
      Image(this.iconState.icon)
        .id(`${this.compId}.icon`)
        .iconStyle(iconStyle)
        .opacity(this.getOpacity())
        .margin(iconMargin)
    }
  }

  @Builder
  itemSymbolIconBuilder(iconStyle: SettingIconStyle, iconMargin?: LocalizedPadding): void {
    SymbolGlyph(this.iconState.icon as Resource)
      .id(`${this.compId}.symbolIcon`)
      .symbolIconStyle(iconStyle)
      .opacity(this.getOpacity())
      .margin(iconMargin)
  }

  @Builder
  itemTitleBuilder(textStyle: SettingTextStyle): void {
    Text(this.titleState.content)
      .id(`${this.compId}.title`)
      .textStyle(textStyle, this.titleState.fontColor)
      .opacity(this.getOpacity())
  }

  @Builder
  itemDespBuilder(textStyle: SettingTextStyle, textMargin: Padding): void {
    if (this.despState.linkTextContent) {
      LinkTextComponent({
        fontSize: textStyle.fontSize,
        linkColor: this.despState.linkTextContent.linkTextColor,
        fullResource: this.despState.linkTextContent.fullResource,
        fillResourceList:this.despState.linkTextContent.fillResourceList
      })
        .id(`${this.compId}.desp`)
        .margin(textMargin)
        .opacity(this.getOpacity())
    } else if (this.despState.builder) {
      this.despState.builder.builder({
        styles: textStyle,
        textMargin: textMargin,
        isLargeFontMode: this.isLargeFontMode
      })
    } else {
      Text(this.despState.content)
        .id(`${this.compId}.desp`)
        .textStyle(textStyle, this.despState.fontColor)
        .opacity(this.getOpacity())
        .margin(textMargin)
        .wordBreak(WordBreak.BREAK_WORD)
    }
  }

  @Builder
  itemRadioBuilder(radio: SettingRadioModel, style: SettingRadioStyle): void {
    if (this.itemRadioChecked || style.showUnchecked) {
      Radio({ value: this.itemInfo.id, group: this.parentId, indicatorType: style.indicatorType })
        .id(`${this.compId}.result`)
        .width(style.width)
        .height(style.height)
        .checked(this.itemRadioChecked)
        .radioStyle(style.radioStyle)
        .margin(0)// 覆盖掉ark组件自带margin
        .hitTestBehavior(HitTestMode.None)
        .onChange((isChecked: boolean) => {
          if (isChecked === false) {
            this.itemRadioChecked = false;
            radio.onCheck?.(false, this.itemInfo);
          }
        })
    }
  }

  @Builder
  itemResultIconBuilder(iconStyle: SettingIconStyle): void {
    if (iconStyle.fillColor !== undefined) {
      Image((this.resultState as SettingIconVM).icon)
        .id(`${this.compId}.result`)
        .iconStyle(iconStyle)
        .opacity(this.getOpacity())
        .fillColor(iconStyle.fillColor)
    } else {
      Image((this.resultState as SettingIconVM).icon)
        .id(`${this.compId}.result`)
        .iconStyle(iconStyle)
        .opacity(this.getOpacity())
    }
  }

  @Builder
  itemResultBuilder(result: SettingItemResultModel): void {
    if (result.type === ItemResultType.RESULT_TYPE_CUSTOM) {
      Column() {
        result.builder?.builder(this.itemInfo)
      }
      .opacity(this.getOpacity())
      .id(`${this.compId}.result`)
      .constraintSize(this.isLargeFontMode ? undefined : { maxWidth: this.layout?.resultWidthRatio })
      .flexShrink(1)
    } else if (result.type === ItemResultType.RESULT_TYPE_TEXT) {
      Text((this.resultState as SettingTextVM).content)
        .id(`${this.compId}.result`)
        .textStyle(PageConfig.getInstance().getTextStyle((result.result as SettingTextModel)),
          (this.resultState as SettingTextVM).fontColor)
        .opacity(this.getOpacity())
        .textAlign(this.isLargeFontMode ? TextAlign.Start : TextAlign.End)
        .constraintSize(this.isLargeFontMode ? undefined : { maxWidth: this.layout?.resultWidthRatio })
        .flexShrink(1)
    } else if (result.type === ItemResultType.RESULT_TYPE_TOGGLE) {
      Toggle({ type: ToggleType.Switch, isOn: (this.resultState as SettingToggleVM).state })
        .id(`${this.compId}.result`)
        .onChange((isOn: boolean) => {
          const log = `isOn:${isOn} oldState:${(this.resultState as SettingToggleVM).state}`;
          LogHelper.info(TAG, `Toggle switch, ${log}, compId: ${this.compId}`);
          if ((this.resultState as SettingToggleVM).state !== isOn) {
            (this.resultState as SettingToggleVM).state = isOn;
            // 是否允许点击切换状态 如果自定义函数onAllowChanged返回false则把状态还原(ark组件点击了必改变按钮视图 只能手动还原状态)
            const isAllowChange = (this.resultState as SettingToggleVM).onAllowChanged?.(isOn) ?? true;
            if (!isAllowChange) {
              LogHelper.info(TAG, `Toggle switch, isAllowChange:${isAllowChange}, compId: ${this.compId}`);
              (this.resultState as SettingToggleVM).state = !isOn;
              return;
            }
            EventBus.getInstance().emit(`${this.compId}.toggle`, { state: isOn } as SettingCompState);
            (result.result as SettingToggleModel).onChanged?.(isOn);
          } else {
            // 被动改变状态的时候 需要借助框架来发消息
            EventBus.getInstance().emit(`${this.compId}.toggle`, { state: isOn } as SettingCompState);
            (result.result as SettingToggleModel).onChanged?.(isOn);
          }
        })
        .enabled((this.resultState as SettingToggleVM).enabled)
        .hitTestBehavior(PageConfig.getInstance().isCircleScreen() ? HitTestMode.None : undefined)
        .toggleStyle((result.result as SettingToggleModel).style)
    } else if (result.type === ItemResultType.RESULT_TYPE_IMAGE) {
      this.itemResultIconBuilder(PageConfig.getInstance().getIconStyle((result.result as SettingIconModel)))
    } else if (result.type === ItemResultType.RESULT_TYPE_RADIO) {
      this.itemRadioBuilder(result.result as SettingRadioModel,
        PageConfig.getInstance().getRadioStyle(result.result as SettingRadioModel))
    }
  }

  @Builder
  itemDetailBuilder(detail: SettingItemDetailModel, style: SettingIconStyle,
    iconMargin: LocalizedPadding, independentClick: boolean): void {
    if (detail.icon !== '') {
      if (style.fillColor) {
        Image(detail.icon)
          .id(`${this.compId}.detail`)
          .iconStyle(style)
          .opacity(this.getOpacity())
          .fillColor(style.fillColor)
          .margin(iconMargin)
          .responseRegion(independentClick ? detail.responseRegion : undefined)
          .onTouch(independentClick ? (event: TouchEvent) => {
            event.stopPropagation();
          } : undefined)
          .onClick(independentClick ? () => {
            detail.onSelfClick?.(this.itemInfo);
          } : undefined)
      } else {
        Image(detail.icon)
          .id(`${this.compId}.detail`)
          .iconStyle(style)
          .opacity(this.getOpacity())
          .margin(iconMargin)
          .responseRegion(independentClick ? detail.responseRegion : undefined)
          .onTouch(independentClick ? (event: TouchEvent) => {
            event.stopPropagation();
          } : undefined)
          .onClick(independentClick ? () => {
            detail.onSelfClick?.(this.itemInfo);
          } : undefined)
      }
    }
  }

  @Builder
  itemDividerBuilder(dividerPad?: LocalizedPadding, dividerMargin?: LocalizedPadding): void {
    Divider()
      .strokeWidth('2px')
      .color($r('sys.color.ohos_id_color_list_separator'))
      .lineCap(LineCapStyle.Square)
      .padding(dividerPad)
      .margin(dividerMargin)
      .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  @Styles
  normalStateIconStyles() {
    .backgroundColor(this.getNormalColor())
  }

  @Styles
  pressedStyles() {
    .backgroundColor(this.getItemPressedColor(this.itemInfo))
  }

  @Styles
  accessibilityStyle() {
    .accessibilityDescription(this.getAccessibilityDescription(this.itemInfo))
  }

  @Builder
  itemSheet(pageUrl: string, pageCtx: Optional<PageContext>): void {
    if (DataVerify.checkStr(pageUrl) && pageCtx.isPresent()) {
      pageCtx.get().pageBuilder?.builder(this.buildPageParam(pageUrl, pageCtx.get()))
    }
  }

  @Builder
  sheetBuilder(detail: SettingItemDetailModel): void {
    Column() {
      if (detail.sheetBuilder) {
        detail.sheetBuilder.builder(this.itemInfo)
      } else if (detail.destination) {
        this.itemSheet(detail.destination, ModalLoader.getPageContext(detail.destination))
      }
    }
    // ark模态框组件设置了clip导致圆角裁剪可能会有白边
    // 在内容组件最上层开启离屏 规避此问题
    .renderGroup(true)
  }

  @Builder
  menuBuilder(menu: SettingSelectMenu, menuStyle: SettingMenuStyle): void {
    if (menu.items.length > 0) {
      Column() {
        ForEach(menu.items, (item: MenuItemOptions, index: number) => {
          Column() {
            MenuItem({
              startIcon: item.startIcon,
              content: item.content,
              symbolStartIcon: item.symbolStartIcon,
              symbolEndIcon: (!menu.isHideSelected && this.menuSelectIndex === index) ?
                new SymbolGlyphModifier($r('sys.symbol.checkmark')) : item.symbolEndIcon,
            })
              .accessibilityChecked(this.getMenuSelectState(menu.isHideSelected, index))
              .onClick(() => {
                (this.resultState as SettingTextState).content = item.content;
                this.menuSelectIndex = index;
                menu.onSelected?.(index, item.content);
              })
              .width('100%')
              .defaultFocus(index === 0)
            if (index !== menu.items.length - 1) {
              this.itemDividerBuilder(undefined, {
                start: menu.dividerStart ?? PADDING_12,
                end: menu.dividerEnd ?? PADDING_12,
              });
            }
          }
          .width('100%')
        })
      }
      .width(menuStyle.width)
      .borderRadius(menuStyle.borderRadius)
      .padding(menuStyle.padding)
    }
  }

  private buildMenuOptions(menu?: SettingSelectMenu): MenuOptions {
    return {
      placement: menu?.placement ?? Placement.BottomRight,
      // 覆盖默认弹簧关闭动画，避免退出拖尾灰块闪烁
      transition: TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseOut }),
    };
  }

  @Builder
  standardItemBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        if (item.icon.isSymbolIcon) {
          this.itemSymbolIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        } else {
          this.itemIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        }
      }

      Row() {
        if (this.despState.content !== '' || this.despState.linkTextContent || this.despState.builder) {
          Column() {
            if (item.title) {
              this.itemTitleBuilder(PageConfig.getInstance().getTextStyle(item.title))
            }
            this.itemDespBuilder(PageConfig.getInstance().getTextStyle(item.desp),
              { top: this.layout?.middleColumnSpace?.value })
          }
          .alignItems(HorizontalAlign.Start)
          .flexShrink(this.titleSizeRestricted(item.result) ? 0 : 1)
          .padding({ end: this.layout?.middleRowSpace })
          .layoutWeight(1)
        } else {
          if (item.title) {
            Text(this.titleState.content)
              .id(`${this.compId}.title`)
              .wordBreak(WordBreak.BREAK_WORD)
              .textStyle(PageConfig.getInstance().getTextStyle(item.title), this.titleState.fontColor)
              .opacity(this.getOpacity())
              .flexShrink(this.titleSizeRestricted(item.result) ? 0 : 1)
              .padding({ end: this.layout?.middleRowSpace })
              .layoutWeight(1)
          }
        }

        if (item.result) {
          this.itemResultBuilder(item.result)
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
      .padding({ top: this.layout?.safetyPadding, bottom: this.layout?.safetyPadding })
      .constraintSize({ minHeight: this.minHeight })

      if (item.detail) {
        this.itemDetailBuilder(item.detail, PageConfig.getInstance().getIconStyle(item.detail),
          { start: this.layout?.rightMiddleSpace }, item.detail.onSelfClick !== undefined)
      }
    }
    .accessibilityStyle()
    .id(this.compId)
    .width('100%')
    .borderRadius(this.layout?.borderRadius)
    .enabled(this.enabledState)
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .defaultFocus(true)
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStyles
    })
    .padding({ start: this.layout?.innerLeftSpace, end: this.layout?.innerRightSpace })
    .onClick(() => {
      this.onItemClick(item);
      if (item?.result?.type === ItemResultType.RESULT_TYPE_RADIO) {
      }
    })
    .onTouch((event: TouchEvent) => {
      this.onItemTouch(item, event.type);
    })
    .onMouse((event: MouseEvent) => {
      if (event) {
        this.onMouseEvent(item, event);
      }
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
    .bindMenu(this.supportMenu(item.detail) ? this.menuBuilder(item.detail?.menu,
      PageConfig.getInstance().getMenuStyle(item.detail?.menu?.style)) : undefined,
      this.buildMenuOptions(item.detail?.menu))
    .bindSheet(this.isModalShow, this.hasBindSheet(item.detail) ? this.sheetBuilder(item.detail) : undefined,
      this.buildSheetOptions(item.detail?.sheetOptions))
  }

  @Builder
  extraLargeStandardItemBuilder(item: SettingItemModel): void {
    Row() {
      Column() {
        this.extraLargeItemResultBuilder(item);
        if (this.despState.content !== '' || this.despState.linkTextContent || this.despState.builder) {
          this.extraLargeItemDespBuilder(item);
        }
        this.extraLargeItemTextBuilder(item);
      }
      .width('100%')
      .padding({ top: this.layout?.safetyPadding, bottom: this.layout?.safetyPadding })
      .constraintSize({ minHeight: this.minHeight })
    }
    .id(this.compId)
    .width('100%')
    .borderRadius(this.layout?.borderRadius)
    .enabled(this.enabledState)
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStyles
    })
    .padding({ start: this.layout?.innerLeftSpace, end: this.layout?.innerRightSpace })
    .onClick(() => {
      this.onItemClick(item);
    })
    .onTouch((event: TouchEvent) => {
      this.onItemTouch(item, event.type);
    })
    .onMouse((event: MouseEvent) => {
      if (event) {
        this.onMouseEvent(item, event);
      }
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
    .bindMenu(this.supportMenu(item.detail) ? this.menuBuilder(item.detail?.menu,
      PageConfig.getInstance().getMenuStyle(item.detail?.menu?.style)) : undefined,
      this.buildMenuOptions(item.detail?.menu))
    .bindSheet(this.isModalShow, this.hasBindSheet(item.detail) ? this.sheetBuilder(item.detail) : undefined,
      this.buildSheetOptions(item.detail?.sheetOptions))
  }

  @Builder
  extraLargeItemResultBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        if (item.icon.isSymbolIcon) {
          this.itemSymbolIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        } else {
          this.itemIconBuilder(PageConfig.getInstance().getIconStyle(item.icon),
            { end: this.layout?.leftMiddleSpace })
        }
      }

      Row() {
        if (item.title) {
          Text(this.titleState.content)
            .id(`${this.compId}.title`)
            .textStyle(PageConfig.getInstance().getTextStyle(item.title), this.titleState.fontColor)
            .opacity(this.getOpacity())
            .wordBreak(WordBreak.BREAK_WORD)
            .flexShrink(this.titleSizeRestricted(item.result) ? 0 : 1)
            .padding({ end: this.layout?.middleRowSpace })
        }
      }
      .layoutWeight(1)

      if (item.detail) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.detail).width)
        .margin({ end: this.layout?.innerRightSpace })
      }
    }
  }

  @Builder
  extraLargeItemDespBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.icon).width)
        .margin({ end: this.layout?.leftMiddleSpace })
      }

      Row() {
        this.itemDespBuilder(PageConfig.getInstance().getTextStyle(item.desp),
          { top: this.layout?.middleColumnSpace?.value })
      }
      .layoutWeight(1)

      if (item.detail) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.detail).width)
        .margin({ end: this.layout?.innerRightSpace })
      }
    }
  }

  @Builder
  extraLargeItemTextBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        Row() {
        }
        .width(PageConfig.getInstance().getIconStyle(item.icon).width)
        .margin({ end: this.layout?.leftMiddleSpace })
      }

      Row() {
        if (item.result) {
          this.itemResultBuilder(item.result)
        }
      }
      .layoutWeight(1)

      if (item.detail) {
        this.itemDetailBuilder(item.detail, PageConfig.getInstance().getIconStyle(item.detail),
          { start: this.layout?.innerRightSpace }, item.detail.onSelfClick !== undefined)
      }
    }
    .padding({ top: this.despState.content !== '' ? '16vp' : '2vp' })
  }

  @Builder
  circleScreenItemBuilder(item: SettingItemModel): void {
    Row() {
      if (item.icon) {
        this.itemIconBuilder(PageConfig.getInstance().getIconStyle(item.icon), { start: this.layout?.innerLeftSpace })
      }

      Column() {
        if (item.title) {
          this.itemTitleBuilder(PageConfig.getInstance().getTextStyle(item.title))
        }
        if (this.despState.content !== '') {
          this.itemDespBuilder(PageConfig.getInstance().getTextStyle(item.desp),
            { top: this.layout?.middleColumnSpace?.value })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({ start: this.layout?.leftMiddleSpace, end: this.layout?.rightMiddleSpace })

      if (item.result || item.detail) {
        Column() {
          if (item.detail) {
            this.itemDetailBuilder(item.detail, PageConfig.getInstance().getIconStyle(item.detail),
              { end: this.layout?.innerRightSpace }, item.detail.onSelfClick !== undefined)
          }
          if (item.result) {
            this.itemResultBuilder(item.result)
          }
        }
        .size({ width: '92px', height: '92px' })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
    }
    .id(this.compId)
    .width('100%')
    .borderRadius(this.layout?.borderRadius)
    .enabled(this.enabledState)
    .padding({ top: this.layout?.safetyPadding, bottom: this.layout?.safetyPadding })
    .margin({ top: '6px', bottom: '6px' })
    .constraintSize({ minHeight: this.minHeight })
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStyles,
    })
    .onClick(() => {
      this.onItemClick(item);
    })
    .onTouch((event: TouchEvent) => {
      this.onItemTouch(item, event.type);
    })
  }

  @Builder
  itemBuilder(item: SettingItemModel): void {
    // 手表
    if (this.isCircleScreen) {
      if (item.type === ItemType.ITEM_TYPE_CUSTOM) {
        item.builder?.builder(item);
      } else {
        this.circleScreenItemBuilder(item)
      }
    } else {
      this.standardScreenItemBuilder(item);
    }
  }

  @Builder
  standardScreenItemBuilder(item: SettingItemModel): void {
    Column() {
      if (item.type === ItemType.ITEM_TYPE_CUSTOM) {
        item.builder?.builder(item);
      } else {
        if (this.isLargeFontMode && item.result?.type === ItemResultType.RESULT_TYPE_TEXT) {
          this.extraLargeStandardItemBuilder(item);
        } else {
          this.standardItemBuilder(item)
        }
      }
      if (!(this.itemPos & ItemPos.ITEM_POS_END) && !this.layout?.noNeedDivider) {
        this.itemDividerBuilder({ start: this.layout?.innerLeftSpace, end: this.layout?.innerRightSpace },
          this.getItemDividerMargin(item.divider, item.icon))
      }
    }
  }

  aboutToAppear(): void {
    LogHelper.info(TAG, `setting item ${this.compId} appear.`);
    let item = this.itemInfo;
    this.layout = PageConfig.getInstance().getItemLayout(item, this.homePageComp);
    this.minHeight = this.layout.minHeight ?? 0;
    this.initItemContent(item);

    // 注册事件
    EventBus.getInstance().on(this.compId, this.eventCb);
    item.onItemEvent = (datas: Map<SettingStateType, SettingBaseState>) => {
      this.procEvent(datas);
    };

    if (this.itemInfo.compControl) {
      this.itemInfo.compControl.init({ compId: this.compId, component: this.itemInfo });
    }
    this.isDisappeared = false;
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `setting item ${this.compId} disappear.`);
    let item = this.itemInfo;
    EventBus.getInstance().detach(this.compId, this.eventCb);
    item.onItemEvent = undefined;
    if (this.itemInfo.compControl) {
      this.itemInfo.compControl.destroy();
    }
    this.isDisappeared = true;
  }

  onItemLayoutChange(): boolean {
    if (this.currentFontSizeScale !== FontScaleUtils.getFontScaleSize()) {
      this.isLargeFontMode = FontScaleUtils.isExtraLargeFontMode();
      this.layout = PageConfig.getInstance().getItemLayout(this.itemInfo, this.homePageComp);
      this.currentFontSizeScale = FontScaleUtils.getFontScaleSize();
    }
    return true;
  }

  build() {
    if (this.onItemLayoutChange()) {
      this.itemBuilder(this.itemInfo)
    }
  }

  getAccessibilityDescription(item: SettingItemModel): string | undefined {
    if (this.isSupportClick(item)) {
      // 支持点击时朗读单指双击
      return '';
    }
    // 朗读默认不朗读单指双击
    return ' ';
  }
}