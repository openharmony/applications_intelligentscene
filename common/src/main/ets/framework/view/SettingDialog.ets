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

import measure from '@ohos.measure';
import { LengthMetrics } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import { PADDING_8 } from '../common/StyleConstant';
import { LogUtil } from '../../utils/LogUtil';
import { LanguageUtils } from '../../utils/LanguageUtils';
import { PageConfig } from '../common/PageConfig';
import {
  DefaultSettingItemModel,
  DialogButton,
  DialogButtonStyle,
  DialogLayoutStyle,
  SettingDialogModel,
  SettingItemModel
} from '../model/SettingItemModel';
import { FontScaleUtils } from '../../utils/FontScaleUtils';

const TAG: string = 'SettingDialog';

const BUTTON_HORIZONTAL_MARGIN = lazyInit<number>(() => {
  return getLengthMetricsByResource($r('sys.float.alert_right_padding_horizontal'), 16);
});
const BUTTON_MAX_FONT_SIZE = lazyInit<number>(() => {
  return getLengthMetricsByResource($r('sys.float.dialog_button_font_max_size'), 16);
});
const BUTTON_MIN_FONT_SIZE = lazyInit<number>(() => {
  return getLengthMetricsByResource($r('sys.float.dialog_button_font_min_size'), 9);
});
const BUTTON_HORIZONTAL_SPACE = lazyInit<number>(() => {
  return getLengthMetricsByResource($r('sys.float.alert_button_horizontal_space'), 8);
});
const BODY_L: number = getNumberByResourceId(125830970, 16);
const BUTTON_HORIZONTAL_PADDING: number = getNumberByResourceId(125830927, 16);
const MAX_FONT_SCALE: number = 2;
const DEFAULT_FONT_SCALE: number = 1;
const HORIZON_BUTTON_MAX_COUNT: number = 2;
const MIN_CONTENT_HEIGHT: number = 100;
const MAX_CONTENT_HEIGHT: number = 30000;

@Extend(Button)
function customButtonStyle(style?: DialogButtonStyle) {
  .layoutWeight(1)
  .type(style?.type)
  .borderRadius(style?.borderRadius)
  .width(style?.width)
  .alignSelf(style?.alignSelf)
  // 优先用 constraintSize；兼容仅配置了固定 height 的场景
  .constraintSize(style?.constraintSize ?? {
    minHeight: style?.height ?? 40,
    maxHeight: style?.height ?? 56,
  })
  .padding(style?.padding)
  .fontColor(style?.fontColor)
  .backgroundColor(style?.background)
  .buttonStyle(style?.buttonStyle)
  .role(style?.role)
  .controlSize(ControlSize.NORMAL)
  .labelStyle({
    maxLines: 1,
    overflow: TextOverflow.Ellipsis,
    minFontSize: 8,
    maxFontSize: 16,
    heightAdaptivePolicy: TextHeightAdaptivePolicy.MAX_LINES_FIRST,
  })
}

@Component
struct SettingDialog {
  item: SettingItemModel = DefaultSettingItemModel.get();
  dialog?: SettingDialogModel;
  closeDialog?: () => void;
  private isFollowingSystemFontScale: boolean = false;
  private appMaxFontScale: number = 3.2;
  private layout: DialogLayoutStyle = {};
  private isDialogClosedClick: boolean = false;
  @State isButtonVertical: boolean = false;
  @State buttonMaxFontSize: Length = `${BODY_L}fp`;
  @State buttonMinFontSize: Length = 9;
  @State fontSizeScale: number = 1;
  @State contentMaxHeight: Length = '100%';
  @State contentMinHeight: number = MIN_CONTENT_HEIGHT;

  private needDivider(primary: DialogButton, secondary: DialogButton): boolean {
    const primaryStyle = PageConfig.getInstance().getDialogButtonStyle(primary);
    const secondaryStyle = PageConfig.getInstance().getDialogButtonStyle(secondary);
    return (primaryStyle?.buttonStyle === ButtonStyleMode.TEXTUAL &&
      secondaryStyle?.buttonStyle === ButtonStyleMode.TEXTUAL)
  }

  private onButtonClick(button: DialogButton, item: SettingItemModel): void {
    if (this.isDialogClosedClick) {
      LogUtil.showWarn(TAG, 'close dialog clicked, not deal');
      return;
    }
    this.isDialogClosedClick = true;
    button.action(item);
    this.closeDialog?.();
  }

  private updateFontSize(): void {
    if (this.fontSizeScale > MAX_FONT_SCALE) {
      this.buttonMaxFontSize = BUTTON_MAX_FONT_SIZE() * MAX_FONT_SCALE + 'vp';
      this.buttonMinFontSize = BUTTON_MIN_FONT_SIZE() * MAX_FONT_SCALE + 'vp';
    } else {
      this.buttonMaxFontSize = BUTTON_MAX_FONT_SIZE() + 'fp';
      this.buttonMinFontSize = BUTTON_MIN_FONT_SIZE() + 'fp';
    }
  }

  private isVerticalAlignButton(width: number): boolean {
    if (this.dialog?.buttons) {
      if (this.dialog?.buttons.length !== HORIZON_BUTTON_MAX_COUNT || FontScaleUtils.isExtraLargeFontMode() ||
        this.dialog?.style?.isButtonVertical) {
        return true;
      }
      let isVertical: boolean = false;
      let maxButtonTextSize = vp2px(width / HORIZON_BUTTON_MAX_COUNT -
      BUTTON_HORIZONTAL_MARGIN() - BUTTON_HORIZONTAL_SPACE() - 2 * BUTTON_HORIZONTAL_PADDING);
      LogUtil.showInfo(TAG, `maxButtonTextSize: ${maxButtonTextSize}`);
      this.dialog?.buttons.forEach((button) => {
        try {
          let contentSize: SizeOptions = measure.measureTextSize({
            textContent: button.value,
            fontSize: this.buttonMaxFontSize
          });
          LogUtil.showInfo(TAG, `contentSize: ${contentSize?.width}`);
          if (Number(contentSize?.width) > maxButtonTextSize) {
            isVertical = true;
          }
        } catch (err) {
          LogUtil.showError(TAG,
            `Faild to dialog isVerticalAlignButton measureTextSize, code: ${err?.code}, message: ${err?.message}`);
        }
      });
      return isVertical;
    }
    return false;
  }

  private updateFontScale(): number {
    try {
      let uiContext: UIContext = this.getUIContext();
      let systemFontScale: number = (uiContext.getHostContext() as common.UIAbilityContext)?.config?.fontSizeScale ?? 1;
      if (!this.isFollowingSystemFontScale) {
        return DEFAULT_FONT_SCALE;
      }
      return Math.min(systemFontScale, this.appMaxFontScale);
    } catch (error) {
      LogUtil.showError(TAG, `init fontsizescale info error, code: ${error?.code}, message: ${error?.message}`);
      return DEFAULT_FONT_SCALE;
    }
  }

  @Builder
  twoHorizontalButton(primary: DialogButton, secondary: DialogButton): void {
    Row({ space: this.needDivider(primary, secondary) ? 0 : this.layout.buttonSpaceVertical as number }) {
      Button(primary.value)
        .customButtonStyle(PageConfig.getInstance().getDialogButtonStyle(primary))
        .onClick(() => {
          this.onButtonClick(primary, this.item);
        })

      if (this.needDivider(primary, secondary)) {
        Divider()
          .vertical(true)
          .height(24)
          .strokeWidth('2px')
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ start: PADDING_8, end: PADDING_8 })
      }

      Button(secondary?.value)
        .customButtonStyle(PageConfig.getInstance().getDialogButtonStyle(secondary))
        .onClick(() => {
          this.onButtonClick(secondary, this.item);
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  verticalButton(buttons: DialogButton[]): void {
    ForEach(buttons, (item: DialogButton, index: number) => {
      Row() {
        this.buildButton(buttons?.length === HORIZON_BUTTON_MAX_COUNT
          ? buttons[HORIZON_BUTTON_MAX_COUNT - index - 1] : buttons[index]);
      }
      .width('100%')
    })
  }

  @Builder
  buildButton(button: DialogButton): void {
    Button(button.value)
      .width(button.style?.width ?? '100%')
      .customButtonStyle(PageConfig.getInstance().getDialogButtonStyle(button))
      .onClick(() => {
        this.onButtonClick(button, this.item);
      })
  }

  @Builder
  contentTextBuilder(model: SettingDialogModel): void {
    Text(model.message)
      .textAlign(model.style?.contentStyle?.textAlign ?? TextAlign.Center)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(model.style?.contentStyle?.fontWeight ?? FontWeight.Regular)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .lineHeight(LanguageUtils.getLineHeight(21))
      .maxFontScale(1.8)
      .width('100%')
      .wordBreak(model.style?.contentStyle?.wordBreak)
  }

  @Builder
  tipsTextBuilder(message: ResourceStr): void {
    Text(message)
      .textAlign(TextAlign.Start)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontSize($r('sys.float.Caption_M'))
      .fontColor($r('sys.color.font_tertiary'))
      .lineHeight(LanguageUtils.getLineHeight(12))
      .width('100%')
      .wordBreak(WordBreak.BREAK_WORD)
      .maxFontScale(1.8)
      .margin({
        top: 16
      })
  }

  aboutToAppear(): void {
    if (this.dialog) {
      this.layout = PageConfig.getInstance().getDialogStyle(this.dialog);
    }
    let uiContext: UIContext = this.getUIContext();
    this.isFollowingSystemFontScale = uiContext?.isFollowingSystemFontScale();
    this.appMaxFontScale = uiContext?.getMaxFontScale();
    this.fontSizeScale = this.updateFontScale();
    this.contentMaxHeight = FontScaleUtils.isExtraLargeFontMode() ? '40%' : '50%';
  }

  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Array<Measurable>,
    constraint: ConstraintSizeOptions): SizeResult {
    let sizeResult: SizeResult = { width: selfLayoutInfo.width, height: selfLayoutInfo.height };
    let maxWidth: number = Number(constraint.maxWidth);
    let maxHeight: number = Number(constraint.maxHeight);
    this.fontSizeScale = this.updateFontScale();
    this.updateFontSize();
    this.isButtonVertical = this.isVerticalAlignButton(maxWidth - BUTTON_HORIZONTAL_MARGIN() * 2);
    // 限制内容区高度，保证底部确定/取消在弹窗可视区内完整显示（对齐 ConfirmDialog）
    // 关怀大字号按钮竖排占高更大，内容区略收紧
    if (maxHeight > 0 && maxHeight < this.contentMinHeight) {
      this.contentMaxHeight = MAX_CONTENT_HEIGHT;
    } else if (FontScaleUtils.isExtraLargeFontMode()) {
      this.contentMaxHeight = '40%';
    } else {
      this.contentMaxHeight = '50%';
    }
    let height: number = 0;
    children.forEach((child) => {
      let measureResult: MeasureResult = child.measure({
        minWidth: constraint.minWidth,
        maxWidth: constraint.maxWidth,
        minHeight: constraint.minHeight,
        maxHeight: maxHeight > 0 ? maxHeight : constraint.maxHeight,
      });
      height += measureResult.height;
    });
    sizeResult.height = (maxHeight > 0) ? Math.min(height, maxHeight) : height;
    sizeResult.width = maxWidth;
    return sizeResult;
  }

  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Array<Layoutable>,
    constraint: ConstraintSizeOptions) {
    let currentX: number = 0;
    let currentY: number = 0;
    for (let index = 0; index < children.length; index++) {
      let child = children[index];
      child.layout({ x: currentX, y: currentY });
      currentY += child.measureResult.height;
    }
  }

  build() {
    Column() {
      // 标题+内容可滚动，限制最大高度，避免大字号下把底部按钮挤出可视区
      Scroll() {
        Column() {
          // 标题区域
          if (this.dialog?.title) {
            Text(this.dialog.title)
              .width('100%')
              .constraintSize({ minHeight: this.layout.titleHeight })
              .fontSize($r('sys.float.Title_S'))
              .lineHeight(LanguageUtils.getLineHeight(25))
              .maxFontScale(2)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Bold)
              .textAlign(this.layout.titleStyle?.textAlign)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(this.layout.titleStyle?.wordBreak)
              .padding({
                top: 12,
                bottom: 12,
              })
          }
          // 内容区域
          if (this.dialog?.contentBuilder) {
            this.dialog?.contentBuilder?.builder(this.item);
          } else if (this.dialog?.message) {
            this.contentTextBuilder(this.dialog);
            if (this.dialog?.tips) {
              this.tipsTextBuilder(this.dialog.tips);
            }
          }
        }
        // 如果有标题 上边距为0 没有就是24
        // 如果有按钮 下边距为0 没有就是24
        .padding({
          top: this.layout.padding?.top,
          start: this.layout.padding?.start,
          end: this.layout.padding?.end,
          bottom: this.layout.padding?.bottom,
        })
      }
      .id('SettingDialog_ContentScroll')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: this.contentMaxHeight,
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })

      // 按钮区域固定在内容下方，保证确定/取消完整可见
      if (this.dialog?.buttons && this.dialog?.buttons.length > 0) {
        Column({ space: this.layout.buttonSpaceHorizontal?.value }) {
          if (this.isButtonVertical) {
            this.verticalButton(this.dialog?.buttons)
          } else {
            this.twoHorizontalButton(this.dialog.buttons[0], this.dialog.buttons[1])
          }
        }
        .width('100%')
        .padding({
          start: this.layout.buttonPad,
          end: this.layout.buttonPad,
          top: this.layout.contentButtonSpace,
          bottom: this.layout.buttonPad,
        })
      }
    }
    .id('SettingDialog_Root')
    .width('100%')
  }
}

@Builder
export function settingDialog(item: SettingItemModel, dialog: SettingDialogModel,
  closeDialog: () => void): void {
  SettingDialog({ item: item, dialog: dialog, closeDialog: closeDialog })
}

function getLengthMetricsByResource(resource: Resource, defaultValue: number, isAllowZero?: boolean): number {
  if (!resource) {
    LogUtil.showError(TAG, 'getLengthMetricsByResource error, resource invalid');
    return defaultValue;
  }
  try {
    let sourceValue: number = LengthMetrics.resource(resource).value;
    if (sourceValue === 0) {
      return isAllowZero ? sourceValue : defaultValue;
    }
    return sourceValue;
  } catch (error) {
    LogUtil.showError(TAG, `getLengthMetricsByResource error, code: ${error?.code}, message: ${error?.message}`);
    return defaultValue;
  }
}

function lazyInit<T>(initializer: () => T): () => T {
  let value: T | null = null;
  return () => {
    if (value === null) {
      value = initializer();
    }
    return value;
  };
}

function getNumberByResourceId(resourceId: number, defaultValue: number, allowZero?: boolean): number {
  try {
    let sourceValue: number = resourceManager.getSystemResourceManager().getNumber(resourceId);
    if (sourceValue > 0 || allowZero) {
      return sourceValue;
    } else {
      return defaultValue;
    }
  } catch (error) {
    LogUtil.showError(TAG, `getNumberByResourceId error, code: ${error?.code}, message: ${error?.message}`);
    return defaultValue;
  }
}