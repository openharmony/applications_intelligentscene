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

import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { SettingsConstant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { FormActionType } from '@ohos/scene.form/src/main/ets/constant/FormConstant';

/* instrument ignore file */

const INTELLIGENT_SCENE_ENTRY: string = 'intelligent_scene_entry';

@Entry
@Component
struct SleepForm {
  private readonly modeId: string = ModeType.SLEEP_MODE;
  private readonly BUTTON_FONT_SIZE: number = 16;
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('recentTimeCondition') recentTimeCondition: string = '';
  @LocalStorageProp('isStartStatus') isStartStatus: boolean = false;

  build() {
    Stack() {
      FormLink({
        action: FormActionType.ROUTER,
        bundleName: SettingsConstant.SETTINGS_BUNDLE_NAME,
        uri: INTELLIGENT_SCENE_ENTRY,
        params: {
          'specifiedModeId': this.modeId
        }
      }) {
        Column() {
          Text($r('app.string.sleep_mode'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .align(Alignment.TopStart)
            .width('100%')
          Text(this.isStartStatus ? $r('app.string.not_disturb_turnedon') : this.recentTimeCondition)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .margin({ top: 4 })
            .width('100%')
        }
        .height('100%')
        .width('100%')
        .backgroundImage($r('app.media.sleep_dark_light'))
        .backgroundImageSize(ImageSize.Cover)
        .padding(12)
      }

      FormLink({
        action: FormActionType.MESSAGE,
        params: {
          modeId: this.modeId,
          isStartStatus: this.isStartStatus
        }
      }) {
        Button() {
          Text(this.isStartStatus ? $r('app.string.close_now') : $r('app.string.enable_now'))
            .fontSize(this.BUTTON_FONT_SIZE)
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Medium)
        }
        .type(ButtonType.ROUNDED_RECTANGLE)
        .buttonStyle(ButtonStyleMode.NORMAL)
        .backgroundColor($r('app.color.sleep_card_button_color'))
        .width('100%')
        .id('button')
        .height('40vp')
      }
      .margin({ left: 12, right: 12, bottom: 12 })
    }
    .alignContent(Alignment.BottomEnd)
  }
}