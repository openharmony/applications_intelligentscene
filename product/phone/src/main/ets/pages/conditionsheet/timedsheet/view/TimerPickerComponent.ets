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

import I18n from '@ohos.i18n';
import { SettingItemModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { TimePickerController } from './controller/TimePickerController';

/* instrument ignore file */
const TAG: string = 'TimerPickerComponent';

@Builder
export function timerPickerComponentBuilder(item: object): void {
  TimerPickerComponent({ item: item as SettingItemModel });
}

@Component
export struct TimerPickerComponent {
  public item?: SettingItemModel;
  private selectTime: Date = new Date();
  private compControl?: TimePickerController;

  build() {
    TimePicker({
      selected: this.compControl?.getCurrentTime()
    })
      .useMilitaryTime(I18n.System.is24HourClock())
      .onChange((value: TimePickerResult) => {
        this.onChange(value);
      })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    if (this.item?.compControl instanceof TimePickerController) {
      this.compControl = this.item?.compControl as TimePickerController;
    }
  }

  private onChange(value: TimePickerResult): void {
    LogUtil.showInfo(TAG, `onChange. hour:${value.hour} minute:${value.minute}`);
    if (value.hour < 0) {
      return;
    }
    this.selectTime.setHours(value.hour, value.minute);
    this.compControl?.updateTime(this.selectTime);
  }
}


