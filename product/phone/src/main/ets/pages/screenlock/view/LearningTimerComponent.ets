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

import { dataShare } from '@kit.ArkData';
import { LengthMetrics } from '@kit.ArkUI';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { NotificationData } from '@ohos/scene.configlinkage/src/main/ets/constant/LinkageConstants';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { fixVp } from '../LearningMode';

/* instrument ignore file */
const TAG = 'LearningTimerComponent';
const MAX_TIME: number = 99;
const MINUTE: number = 60;
const SECOND: number = 60;

@Component
export struct LearningTimerComponent {
  @Link isDarkMode: boolean;
  @Link defaultDpi: number;
  @State hour: number = 0;
  @State minute: number = 0;
  @State hourTensPlace: string = '0';
  @State hourOnesPlace: string = '0';
  @State minuteTensPlace: string = '0';
  @State minuteOnesPlace: string = '0';
  private dataHelper?: dataShare.DataShareHelper;
  public dataShareHelper?: Promise<dataShare.DataShareHelper> | dataShare.DataShareHelper;

  build() {
    Row() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Row() {
          Image(this.buildNumberCard(this.hourTensPlace))
            .height(fixVp(this.defaultDpi, 88))
            .width(fixVp(this.defaultDpi, 54))
            .margin({
              // 小语种无需镜像，仍保持右边距
              right: fixVp(this.defaultDpi, 4)
            })
          Image(this.buildNumberCard(this.hourOnesPlace))
            .height(fixVp(this.defaultDpi, 88))
            .width(fixVp(this.defaultDpi, 54))
        }
        .direction(Direction.Ltr)

        Text($r('app.string.hour'))
          .margin({
            top: fixVp(this.defaultDpi, 8)
          })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize(fixVp(this.defaultDpi, 10))
          .maxFontScale(1.5)
          .flexShrink(0)
      }

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center }) {
        Column() {
          Row()
            .backgroundColor($r('app.color.learning_timer_color'))
            .height(12)
            .width(4)
            .borderRadius(px2vp(16))
            .margin({ bottom: fixVp(this.defaultDpi, 12), })

          Row()
            .backgroundColor($r('app.color.learning_timer_color'))
            .height(12)
            .width(4)
            .borderRadius(px2vp(16))
        }
        .height(fixVp(this.defaultDpi, 88))
        .margin({
          left: fixVp(this.defaultDpi, 6),
          right: fixVp(this.defaultDpi, 6)
        })
        .justifyContent(FlexAlign.Center)

        Text(' ')
          .margin({ top: fixVp(this.defaultDpi, 8) })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize(fixVp(this.defaultDpi, 10))
          .flexShrink(0)
          .maxFontScale(1.5)
      }

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Row() {
          Image(this.buildNumberCard(this.minuteTensPlace))
            .height(fixVp(this.defaultDpi, 88))
            .width(fixVp(this.defaultDpi, 54))
            .margin({
              // 小语种无需镜像，仍保持右边距
              right: fixVp(this.defaultDpi, 4)
            })

          Image(this.buildNumberCard(this.minuteOnesPlace))
            .height(fixVp(this.defaultDpi, 88))
            .width(fixVp(this.defaultDpi, 54))
        }
        .direction(Direction.Ltr)

        Text($r('app.string.minute'))
          .margin({ top: fixVp(this.defaultDpi, 8) })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize(fixVp(this.defaultDpi, 10))
          .flexShrink(0)
          .maxFontScale(1.5)
      }
    }
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width('100%')
    .height(fixVp(this.defaultDpi, 150))
    .accessibilityGroup(true)
    .accessibilityText(`${ResourceUtil.getPluralStringByNameSync('hour', this.hour)}
      ${ResourceUtil.getPluralStringByNameSync('minute', this.minute)}`)
  }

  private buildNumberCard(num: string): ResourceStr {
    let prefix: string = this.isDarkMode ? 'dark_' : '';
    return $r(`app.media.${prefix}${num}`);
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.registerDataChange()
    let value = SettingsDataUtils.getSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, '');
    if (StringUtil.isNotEmpty(value)) {
      this.refreshUi(value);
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.unRegisterDataChange();
  }

  async registerDataChange(): Promise<void> {
    this.dataHelper = await SettingsDataUtils.createDataHelper(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA);
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper,
        SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, this.onDataChange);
    }
    LogUtil.showInfo(TAG, 'registerDataChange');
  }

  unRegisterDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.unRegisterDataChange(this.dataHelper,
        SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, this.onDataChange);
    }
    LogUtil.showInfo(TAG, 'unRegisterDataChange');
  }

  private onDataChange = () => {
    LogUtil.showInfo(TAG, 'onDataChange');
    let value = SettingsDataUtils.getSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, '');
    if (StringUtil.isNotEmpty(value)) {
      this.refreshUi(value);
    }
  }

  private refreshUi(value: string) {
    LogUtil.showInfo(TAG, 'refreshUi');
    let ntfData = JsonUtil.fromJson(value) as NotificationData;
    let duration: number = ntfData.duration;
    const hours: number = Math.floor(duration / MINUTE);
    this.hour = hours > MAX_TIME ? MAX_TIME : hours;
    this.minute = duration % SECOND;
    let minutesStr: string = String(this.minute).padStart(2, '0');
    let hoursStr: string = String(this.hour).padStart(2, '0');
    this.hourTensPlace = hoursStr.charAt(0);
    this.hourOnesPlace = hoursStr.charAt(1)
    this.minuteTensPlace = minutesStr.charAt(0);
    this.minuteOnesPlace = minutesStr.charAt(1);
  }
}