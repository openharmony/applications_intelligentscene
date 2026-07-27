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
import { AppCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';

export class ApplicationManager {
  private static instance: ApplicationManager;
  public isAdd: boolean = true;
  private appCondition: AppCondition = ApplicationManager.getDefaultCondition();

  public static getInstance(): ApplicationManager {
    if (ApplicationManager.instance == null) {
      ApplicationManager.instance = new ApplicationManager();
    }
    return ApplicationManager.instance;
  }

  public static getDefaultCondition(): AppCondition {
    return {
      enable: true,
      configId: '',
      configType: ConfigType.TRIGGER_CONDITION_APP,
      appConditionList: []
    }
  }

  public filInfo(param: ParsedConfigData): void {
    let condition = param.parsedValue as AppCondition;
    this.appCondition = {
      appConditionList: condition.appConditionList,
      enable: condition.enable,
      configId: condition.configId,
      configType: condition.configType,
    }
  }

  public getInfo(): AppCondition {
    return this.appCondition;
  }
}