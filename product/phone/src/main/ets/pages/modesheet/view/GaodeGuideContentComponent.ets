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

const TAG: string = 'GaodeGuideContentComponent:';
const POST_AUTHORITY_PAGE_MARGIN_TOP: number = 68;
const PROTOCOL_PAGE_MARGIN_TOP: number = 34;

/**
 * 高德开启路况提醒提示-文本显示
 */
@Component
export struct GaodeGuideContentComponent {
  private isGaoDeAppStatus: boolean = false;
  @StorageLink('occupationIsCheckGaoDeProtocol') isCheckGaoDeProtocol: boolean = false;

  build() {
    Column() {
      Image($r('app.media.gao_de_desc'))
        .height(189)
        .objectFit(ImageFit.Contain)
        .margin({
          top: this.isGaoDeAppStatus ? PROTOCOL_PAGE_MARGIN_TOP : POST_AUTHORITY_PAGE_MARGIN_TOP
        })
      Text($r('app.string.smart_road_condition_alerts'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({
          top: 16
        })
        .fontSize(20)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.color_secondary'))
        .lineHeight(LanguageUtils.getLineHeight(20))
        .maxFontScale(1.5)
      Text(this.isGaoDeAppStatus ? $r('app.string.smart_road_condition_alerts_mode_one') :
        $r('app.string.smart_road_condition_alerts_mode_three'))
        .width('100%')
        .margin({
          top: 16
        })
        .fontSize(16)
        .fontFamily('HarmonyHeiTi')
        .fontColor($r('app.color.color_foreground'))
        .opacity(0.6)
        .lineHeight(LanguageUtils.getLineHeight(21))
        .maxFontScale(1.5)
    }
    .width('100%')
    .padding({
      left: 32,
      right: 32
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
    this.isCheckGaoDeProtocol = false;
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }
}