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
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';

/* instrument ignore file */
const TAG: string = 'WeekListController';

/**
 * 免打扰定时规则重复选择控制器
 */
export class WeekListController implements ComponentControl {
  private timer: TimeCondition;

  constructor(param: TimeCondition) {
    this.timer = param;
  }

  init(compParam: CompCtrlParam): void {
  };

  destroy(): void {
  };

  updateRepeatText(text: string): void {
    LogUtil.showInfo(TAG, `weeklist updateRepeatText ${this.timer.loopDays}`);
    this.timer.loopDays = text;
  }

  updateRepeatType(type: number): void {
    this.timer.loopType = type;
  }


  getRepeatType(): number {
    LogUtil.showInfo(TAG, `getRepeatType ${this.timer.loopType}`);
    return this.timer.loopType === undefined ? 0 : this.timer.loopType;
  }

  getRepeatText(): string {
    LogUtil.showInfo(TAG, `getRepeatText ${this.timer.loopDays}`);
    return this.timer.loopDays === undefined ? '' : this.timer.loopDays;
  }
}