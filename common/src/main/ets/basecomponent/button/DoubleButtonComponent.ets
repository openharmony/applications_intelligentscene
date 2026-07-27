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
import { FontScaleUtils } from '../../utils/FontScaleUtils';

const TAG: string = 'DoubleButtonComponent:';

@Extend(Button)
function buttonCommonStyle(style?: ButtonStyle) {
  .type(ButtonType.ROUNDED_RECTANGLE)
  .constraintSize({
    minHeight: 40,
    maxHeight: 56,
  })
  .labelStyle({
    maxLines: 1,
    overflow: TextOverflow.Ellipsis,
    minFontSize: 8,
    maxFontSize: 16,
    heightAdaptivePolicy: TextHeightAdaptivePolicy.MAX_LINES_FIRST,
  })
}

/**
 * 底部双按钮基础组件
 */
@Component
export struct DoubleButtonComponent {
  isShowDivider: boolean = true;
  @Prop cancelTitle: ResourceStr = $r('app.string.cancel');
  @Prop cancelEnabled: boolean = true;
  cancelButtonStyle: ButtonStyleMode = ButtonStyleMode.TEXTUAL;
  cancelButtonRole: ButtonRole = ButtonRole.NORMAL;
  cancelAction: Function = () => {
  };
  @Prop confirmTitle: ResourceStr = $r('app.string.confirm');
  @Prop confirmEnabled: boolean = true;
  confirmButtonStyle: ButtonStyleMode = ButtonStyleMode.TEXTUAL;
  confirmButtonRole: ButtonRole = ButtonRole.NORMAL;
  confirmAction: Function = () => {
  };
  maxFontSize: number = FontScaleUtils.EXTRA_LARGE_FONT_3;
  // 外部传入，以外部为准处理横竖布局;否则按适老化处理
  isVerticalShow?: boolean;

  build() {
    if (this.isVerticalShow ?? FontScaleUtils.isExtraLargeFontMode()) {
      Column({ space: 4 }) {
        Button(this.cancelTitle)
          .buttonCommonStyle()
          .enabled(this.cancelEnabled)
          .role(this.cancelButtonRole)
          .buttonStyle(this.cancelButtonStyle)
          .width('100%')
          .maxFontScale(this.maxFontSize)
          .onClick(() => {
            this.cancelAction();
          })

        Button(this.confirmTitle)
          .buttonCommonStyle()
          .enabled(this.confirmEnabled)
          .role(this.confirmButtonRole)
          .buttonStyle(this.confirmButtonStyle)
          .width('100%')
          .maxFontScale(this.maxFontSize)
          .onClick(() => {
            this.confirmAction();
          })
      }
      .padding({
        top: 8,
        bottom: 16,
      })
      .width('100%')
    } else {
      Row({ space: this.isShowDivider ? 8 : 16 }) {
        Button(this.cancelTitle)
          .buttonCommonStyle()
          .enabled(this.cancelEnabled)
          .role(this.cancelButtonRole)
          .buttonStyle(this.cancelButtonStyle)
          .layoutWeight(1)
          .maxFontScale(this.maxFontSize)
          .onClick(() => {
            this.cancelAction();
          })

        // 分割线
        if (this.isShowDivider) {
          Divider()
            .vertical(true)
            .height(24)
            .strokeWidth('2px')
            .color($r('sys.color.ohos_id_color_list_separator'))
        }

        Button(this.confirmTitle)
          .buttonCommonStyle()
          .enabled(this.confirmEnabled)
          .role(this.confirmButtonRole)
          .buttonStyle(this.confirmButtonStyle)
          .layoutWeight(1)
          .maxFontScale(this.maxFontSize)
          .onClick(() => {
            this.confirmAction();
          })
      }
      .padding({
        top: 8,
        bottom: 16,
      })
      .width('100%')
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }
}