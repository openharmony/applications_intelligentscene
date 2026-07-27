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

import uiEffect from '@ohos.graphics.uiEffect';
// import { hdsEffect } from '@hms.hds.hdsBaseComponent';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AccessibilityUtils, SCENE_BOARD_PACKAGE_NAME } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';

/* instrument ignore file */
export const TITLE_ID: string = 'control_center_title';

const TAG: string = 'TitleBarComponent:';

/**
 * 标题栏组件
 */
@Component
export struct TitleBarComponent {
  @Link isDarkMode: boolean;
  // 新折叠态产品外屏显示标记位
  isPocketExternalDisplayMode: boolean = false;
  symbolCode: string = '';
  title: ResourceStr = '';

  /**
   * 图标 Builder
   */
  @Builder
  IconBuilder(): void {
    SymbolGlyph($r(`sys.symbol.${this.symbolCode}`))
      .fontSize('24vp')
      .draggable(false)
      .fontColor([$r('sys.color.icon_primary')])
      .fontWeight(500)
      // .advancedBlendMode(uiEffect.createBrightnessBlender(
      //   hdsEffect.getBrightnessParam({
      //     scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
      //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_1,
      //     fraction: 0,
      //     isDarkMode: this.isDarkMode,
      //   })
      // ))
  }

  /**
   * 标题 Builder
   */
  @Builder
  TitleBuilder(): void {
    Text(this.title)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(600)
      .fontSize(20)
      .lineHeight(25)
      .id(TITLE_ID)
      .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.5)
      .fontColor($r('sys.color.font_primary'))
      // .advancedBlendMode(uiEffect.createBrightnessBlender(
      //   hdsEffect.getBrightnessParam({
      //     scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
      //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_1,
      //     fraction: 0,
      //     isDarkMode: this.isDarkMode,
      //   })
      // ))
      .maxLines(this.isPocketExternalDisplayMode ? 1 : undefined)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .constraintSize(this.isPocketExternalDisplayMode ? { maxWidth: 'calc(100% - 56vp)' } : undefined)
  }

  build() {
    // 小屏
    if (this.isPocketExternalDisplayMode) {
      Row({ space: 8 }) {
        this.IconBuilder();
        this.TitleBuilder();
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({
        top: 15,
        bottom: 14,
        left: 12,
        right: 12,
      })
    } else {
      Column({ space: 9 }) {
        this.IconBuilder();
        this.TitleBuilder();
      }
      .width('100%')
      .padding({
        top: 16,
        bottom: 20,
        left: 12,
        right: 12,
      })
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
    AccessibilityUtils.requestFocusAccessibility(TITLE_ID, SCENE_BOARD_PACKAGE_NAME);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }
}