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

import { ParsedConfigData } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { TimeCondition, LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';

export const DEFAULT_START: string = '22:00';
export const DEFAULT_END: string = '7:00';
export const DEFAULT_REPEAT: string = '';
const TAG: string = 'TimeManager';

export class TimeManager {
  private static timeManager: TimeManager;
  private timeInfo: TimeCondition = TimeManager.getDefaultCondition();
  public isAdd: boolean = true;

  public static getInstance(): TimeManager {
    if (TimeManager.timeManager) {
      return TimeManager.timeManager;
    }
    TimeManager.timeManager = new TimeManager();
    return TimeManager.timeManager;
  }

  public static getDefaultCondition(): TimeCondition {
    return {
      enable: true,
      configId: '',
      configType: ConfigType.TRIGGER_CONDITION_TIME,
      loopType: LoopType.ONE_TIME,
      loopDays: DEFAULT_REPEAT,
      timeStart: DEFAULT_START,
      timeEnd: DEFAULT_END
    }
  }

  public filInfo(param: ParsedConfigData): void {
    let timeCondition = param.parsedValue as TimeCondition;
    this.timeInfo = {
      enable: timeCondition.enable,
      configId: param.configId,
      configType: param.configType,
      loopType: timeCondition.loopType,
      loopDays: timeCondition.loopDays,
      timeStart: timeCondition.timeStart,
      timeEnd: timeCondition.timeEnd
    }
  }

  public init(): void {
    this.timeInfo = TimeManager.getDefaultCondition();
    this.isAdd = true;
  }

  public getInfo(): TimeCondition {
    return this.timeInfo;
  }
}