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

import { uiAppearance } from '@kit.ArkUI';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { AppStorageKey } from '@ohos/scene.common/src/main/ets/constant/AppStorageConsts';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { LearningPlan } from '@ohos/scene.datamanage/src/main/ets/model/LearningPlan';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { LearningPlanComponent } from './view/LearningPlanComponent';
import { LearningTimerComponent } from './view/LearningTimerComponent';

/* instrument ignore file */
const TAG: string = 'LearningMode';
const BASE_DPI: number = 160;

@Entry
@Component
struct LearningMode {
  @State learningPlans: Array<LearningPlan> = [];
  @State defaultDpi: number = 0;
  @State isDarkMode: boolean =
    AppStorage.get<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE) === uiAppearance.DarkMode.ALWAYS_DARK;

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    let defaultDpiValue: string = SettingsDataUtils.getSettingsData(SettingsDataKeyConstant.DEFAULT_DISPLAY_DPI, '');
    if (StringUtil.isEmpty(defaultDpiValue)) {
      this.defaultDpi = DeviceUtil.getDisplayDensityDpi();
    } else {
      this.defaultDpi = Number(defaultDpiValue);
    }
    LearningPlanManager.getInstance().getAllLearningPlans().then((data) => {
      this.learningPlans = data;
    });
    EventBus.getInstance().on(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, this.onDarkLightModeCallback);
    LogUtil.showInfo(TAG, `length: ${this.learningPlans.length}, device default DPI: ${this.defaultDpi}`);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    EventBus.getInstance().detach(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, this.onDarkLightModeCallback);
  }

  onPageShow(): void {
    LogUtil.showInfo(TAG, 'onPageShow');
  }

  onPageHide(): void {
    LogUtil.showInfo(TAG, 'onPageHide');
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center }) {
      LearningTimerComponent({
        defaultDpi: this.defaultDpi,
        isDarkMode: this.isDarkMode,
      })
      LearningPlanComponent({
        defaultDpi: this.defaultDpi,
        isDarkMode: this.isDarkMode,
      })
    }
    .backgroundColor($r('app.color.screenlock_card_background_color'))
    .padding({
      top: fixVp(this.defaultDpi, 12),
      bottom: fixVp(this.defaultDpi, 12)
    })
    .height('100%')
    .width('100%')
  }

  /**
   * 深浅色模式切换事件
   */
  private onDarkLightModeCallback = (colorMode: uiAppearance.DarkMode): void => {
    const isDarkMode = colorMode === uiAppearance.DarkMode.ALWAYS_DARK;
    LogUtil.showInfo(TAG, `onDarkLightModeCallback. isDarkMode:${isDarkMode}`);
    this.isDarkMode = isDarkMode;
  };
}

export function fixVp(dpi: number, value: number): number {
  return value * dpi / BASE_DPI / vp2px(1);
}