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

import { LogUtil } from '../../utils/LogUtil';
import { DeviceUtil } from '../../utils/DeviceUtil';
import { LanguageUtils } from '../../utils/LanguageUtils';
import { FontScaleUtils } from '../../utils/FontScaleUtils';
import { EventBus } from '../../framework/common/EventBus';
import { EventBusNameConstant } from '../../constant/EventBusNameConstant';
import { PADDING_4 } from '../../framework/common/StyleConstant';
import { DoubleButtonComponent } from '../../basecomponent/button/DoubleButtonComponent';

/* instrument ignore file */
const TAG: string = 'ConfirmDialogComponent:';

/**
 * 确认弹框公用builder组件
 */
@CustomDialog
@Component
export struct ConfirmDialogComponent {
  controller?: CustomDialogController;
  // 标题与内容
  title: ResourceStr = '';
  content: ResourceStr = '';
  contentAlign: TextAlign = TextAlign.Start;
  warningTipTitle: ResourceStr = '';
  warningTipArr: ResourceStr[] = [];
  // 勾选按钮
  checkboxText: ResourceStr = '';
  onCheckboxChange: OnCheckboxChangeCallback = (isChecked: boolean) => {
  };
  // 取消按钮
  cancelText: ResourceStr = '';
  onCancel: Function = () => {
  };
  // 确认按钮
  confirmText: ResourceStr = '';
  confirmButtonStyle: ButtonStyleMode = ButtonStyleMode.TEXTUAL;
  onConfirm: Function = () => {
  };
  isShowDivider: boolean = true;
  // 新折叠态产品外屏显示标记位
  isPocketExternalDisplayMode: boolean = DeviceUtil.isPocketExternalDisplayMode();
  @State confirmEnabled: boolean = true;
  /**
   * 使能通知事件
   */
  private onConfirmEnabledCallback = (isEnabled: boolean): void => {
    LogUtil.showInfo(TAG, `onConfirmEnabledCallback. isEnabled:${isEnabled}`);
    this.confirmEnabled = isEnabled;
  };

  /**
   * 弹框标题 Builder
   */
  @Builder
  TitleBuilder(): void {
    Column() {
      Text(this.title)
        .textAlign(TextAlign.Center)
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Title_S'))
        .lineHeight(LanguageUtils.getLineHeight(25))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 2.2)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({
      left: 24,
      right: 24,
      top: 15,
    })
    .constraintSize({
      minHeight: 56,
    })
  }

  /**
   * 警告提示语 Builder
   */
  @Builder
  WarningTipBuilder(title: ResourceStr) {
    Row() {
      Column() {
      }
      .width(4)
      .height(4)
      .borderRadius(2)
      .backgroundColor($r('sys.color.icon_secondary'))
      .margin({
        // 获取Text文本一行的实际高度的一半
        top: FontScaleUtils.getTextRealHeight(21, this.isPocketExternalDisplayMode ? 1 : 1.8) / 2 - 1,
        left: 6,
        right: 6,
      })

      Text(title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'))
        .lineHeight(LanguageUtils.getLineHeight(21))
        .layoutWeight(1)
        .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
        .margin({
          start: PADDING_4,
        })
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
  }

  /**
   * 弹框内容区域 Builder
   */
  @Builder
  ContentBuilder(): void {
    Column() {
      // 文本区域
      Column() {
        // 警告语
        if (this.warningTipTitle) {
          Text(this.warningTipTitle)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .lineHeight(LanguageUtils.getLineHeight(21))
            .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
            .width('100%')
            .margin({
              bottom: 16,
            })
        }
        if (this.warningTipArr?.length) {
          // 警告列表
          Column({ space: 2 }) {
            ForEach(this.warningTipArr, (str: ResourceStr, index: number) => {
              this.WarningTipBuilder(str)
            })
          }
          .margin({
            bottom: 16,
          })
        }
        // 主内容文本
        Text(this.content)
          .textAlign(this.contentAlign)
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.Subtitle_M'))
          .lineHeight(LanguageUtils.getLineHeight(21))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .width('100%')
          .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
      }
      .accessibilityGroup(true)
      .padding({
        left: 8,
        right: 8,
      })

      // 勾选框
      if (this.checkboxText) {
        Row() {
          // Checkbox ark组件热区失效 这里通过尺寸来实现放大点击区域
          Checkbox()
            .width(40)
            .height(40)
            .padding(10)
            .margin(0)
            .onChange((value: boolean) => {
              this.onCheckboxChange(value)
            })

          Text(this.checkboxText)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Subtitle_M'))
            .lineHeight(LanguageUtils.getLineHeight(21))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .padding({
              start: PADDING_4,
            })
            .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
            .width('calc(100% - 40vp)')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding({
          top: 4,
          bottom: 4,
        })
      }
    }
    .align(Alignment.Top)
    .padding({
      left: 16,
      right: 16,
    })
  }

  /**
   * 弹框底部按钮 Builder
   */
  @Builder
  BottomButtonBuilder(): void {
    DoubleButtonComponent({
      cancelTitle: this.cancelText,
      cancelAction: () => {
        this.onCancel();
      },
      confirmTitle: this.confirmText,
      confirmButtonStyle: this.confirmButtonStyle,
      confirmEnabled: this.confirmEnabled,
      confirmAction: () => {
        this.confirmEnabled = false;
        this.onConfirm();
      },
      isShowDivider: this.isShowDivider,
      isVerticalShow: this.isPocketExternalDisplayMode ? false : undefined,
      maxFontSize: this.isPocketExternalDisplayMode ? 1 : 3.2,
    })
      .padding({
        left: 16,
        right: 16,
      })
  }

  build() {
    Scroll() {
      Column() {
        // 标题
        this.TitleBuilder()

        // 内容区域
        Scroll() {
          this.ContentBuilder()
        }
        .constraintSize({
          maxHeight: '50%',
        })
        // 上下分屏场景下 联动外层 Scroll 一起滚动
        .nestedScroll({
          scrollForward: NestedScrollMode.SELF_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        })

        // 底部按钮
        this.BottomButtonBuilder()
      }
    }
    .scrollBar(BarState.Off)
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
    EventBus.getInstance().on(EventBusNameConstant.COMMON_DIALOG_CONFIRM_ENABLE, this.onConfirmEnabledCallback);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
    EventBus.getInstance().detach(EventBusNameConstant.COMMON_DIALOG_CONFIRM_ENABLE, this.onConfirmEnabledCallback);
  }
}