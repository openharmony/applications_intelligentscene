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

import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';

/* instrument ignore file */
const TAG: string = 'BottomButtonComponent:';

/**
 * 更多设置按钮组件
 */
@Component
export struct BottomButtonComponent {
  onButtonClick?: () => void;
  @State isHover: boolean = false;
  @Prop isDarkMode: boolean;

  @Styles
  normalStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  build() {
    Column() {
      Text($r('app.string.more_settings'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize(16)
        .lineHeight(LanguageUtils.getLineHeight(21))
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxFontScale(1.5)
        .fontColor(this.isDarkMode ? '#ffffff' : $r('app.color.control_center_sub_panel_color'))
    }
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Center)
    .margin({
      top: 8,
      bottom: 16,
      left: 16,
      right: 16,
    })
    .padding({
      top: 10,
      bottom: 10,
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .onHover((isHover: boolean) => {
      this.isHover = isHover;
    })
    .onClick(() => {
      this.onButtonClick?.();
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }
}