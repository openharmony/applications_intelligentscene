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
import { LanguageUtils } from '../../utils/LanguageUtils';
import { PADDING_4, PADDING_8, PADDING_12 } from '../../framework/common/StyleConstant';

/* instrument ignore file */
const TAG: string = 'PopupComponent:';

/**
 * arkui 提供的 Popup 高级组件不符合要求 这里自己实现一个
 */
@Component
export struct PopupComponent {
  action: Function = () => {
  };
  close: Function = () => {
  };
  @Prop icon: ResourceStr = '';
  @Prop iconBackgroundColor: ResourceColor = '';
  @Prop title: ResourceStr = '';
  @Prop message: ResourceStr = '';
  @Prop linkText: ResourceStr = '';
  @Prop isSupportClose: boolean = true;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  build() {
    Row() {
      // 图标
      Column() {
        Image(this.icon)
          .fillColor($r('sys.color.icon_on_primary'))
          .draggable(false)
          .matchTextDirection(true)
          .size({
            width: 20,
            height: 20,
          })
      }
      .justifyContent(FlexAlign.Center)
      .size({
        height: 32,
        width: 32,
      })
      .borderRadius(8)
      .backgroundColor(this.iconBackgroundColor)
      .margin({
        end: PADDING_8,
      })

      Column() {
        // 标题栏
        Row() {
          // 标题
          Text(this.title)
            .width('100%')
            .fontSize(16)
            .lineHeight(LanguageUtils.getLineHeight(21))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .constraintSize({
              minHeight: 22,
            })
            .padding({
              start: PADDING_4,
              end: PADDING_12,
            })

          // 关闭按钮
          if (this.isSupportClose) {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r(`sys.symbol.xmark`))
                .draggable(false)
                .fontColor([$r('sys.color.ohos_id_color_primary')])
                .fontSize('16vp')
            }
            .stateStyles({
              normal: this.normalStyles,
              pressed: this.pressedStyles,
            })
            .onClick(() => {
              this.onClose();
            })
            .width(22)
            .height(22)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .accessibilityText($r('app.string.close_button'))
          }
        }
        .alignItems(VerticalAlign.Top)

        // 内容
        Text(this.message)
          .width('100%')
          .fontSize(14)
          .lineHeight(LanguageUtils.getLineHeight(19))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .padding({
            start: PADDING_4,
          })
          .margin({
            top: 2,
            bottom: 8,
          })

        // 超链接按钮
        Row() {
          Text(this.linkText)
            .fontSize(14)
            .lineHeight(LanguageUtils.getLineHeight(19))
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Medium)
        }
        .padding(4)
        .borderRadius(14)
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick(() => {
          this.onAction();
        })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Top)
    .padding({
      top: 12,
      bottom: 8,
      left: 12,
      right: 12,
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear.`);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }

  /**
   * 点击超链接
   */
  private onAction(): void {
    this.action();
  }

  /**
   * 关闭卡片
   */
  private onClose(): void {
    this.close();
  }
}