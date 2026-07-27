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

import { contextConstant } from '@kit.AbilityKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { UpgradeAdapter } from '../upgrade/UpgradeAdapter';
import { PhoneEl1Adapter } from '../upgrade/PhoneEl1Adapter';
import { PhoneEl2Adapter } from '../upgrade/PhoneEl2Adapter';
import { UpgradeConfig } from '../upgrade/UpgradeConfig';

const TAG: string = 'UpgradeManager: ';
const PHONE_UPGRADE_ADAPTER_MAP: Map<contextConstant.AreaMode, (() => UpgradeAdapter)> = new Map([
  [contextConstant.AreaMode.EL1, () => {
    return new PhoneEl1Adapter();
  }],
  [contextConstant.AreaMode.EL2, () => {
    return new PhoneEl2Adapter();
  }],
]);

/**
 * 数据库表更新对应的表数据管理类
 */
export class UpgradeManager {
  public static createAdapter(product: string, area: contextConstant.AreaMode): UpgradeAdapter | undefined {
    if (product === 'phone') {
      return PHONE_UPGRADE_ADAPTER_MAP.get(area)?.();
    }
    return undefined;
  }

  public static async upgradeData(config: UpgradeConfig, dbVersion: number): Promise<boolean> {
    let upgradeAdapter: UpgradeAdapter | undefined = UpgradeManager.createAdapter(config.product, config.area);
    if (!upgradeAdapter) {
      LogUtil.showError(TAG, 'upgradeData fail, upgradeAdapter undefined');
      return false;
    }

    let isSuccess: boolean = false;
    for (let retry = 0; retry < 3; retry++) {
      isSuccess = await upgradeAdapter.upgradeData(dbVersion);
      if (isSuccess) {
        break;
      }
    }
    if (!isSuccess) {
      const errorMessage: string = `failArea:${config.area},failVersion:${dbVersion}`;
      LogUtil.showError(TAG, `upgradeData ${errorMessage}`);
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.UPDATE_FAIL, 'upgradeData', errorMessage);
    }

    return isSuccess;
  }
}
