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
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { UpgradeAdapter } from './UpgradeAdapter';
import { ConfigType } from '../model/base/ConfigType';
import { ConfigData, SettingsLinkageState, EnableState } from '../model/base/ConfigModel';
import { El1ModeDataManager } from '../manager/El1ModeDataManager';
import { ConfigDataManager } from '../manager/ConfigDataManager';
import { El1CallConfigManager } from '../manager/El1CallConfigManager';
import { HistoryDataManager } from '../manager/HistoryDataManager';
import { El1ConfigDataManager } from '../manager/El1ConfigDataManager';
import { ModeData, ModeType } from '../model/base/ModeModel';

/**
 * 手机产品EL1数据库版本升级版本号，数据表数据初始化函数映射map
 */
const PHONE_EL1_FUNCTION_MAP: Map<number, (() => Promise<boolean>)> = new Map([
  [1, async () => {
    return await PhoneEl1Adapter.initEl1Data();
  }]
]);
const TAG: string = 'PhoneEl1Adapter: ';

export class PhoneEl1Adapter extends UpgradeAdapter {
  async upgradeData(dbVersion: number): Promise<boolean> {
    return await UpgradeAdapter.initUpgradedDbData(PHONE_EL1_FUNCTION_MAP, dbVersion);
  }

  static async initEl1Data(): Promise<boolean> {
    let isSuccess: boolean = await PhoneEl1Adapter.initEl1ModeData();
    isSuccess = await PhoneEl1Adapter.initEl1CallNotDisturbData() && isSuccess;
    isSuccess = await HistoryDataManager.getInstance().migrate() && isSuccess;
    return isSuccess;
  }

  static async initEl1ModeData(): Promise<boolean> {
    let isSuccess: boolean = await El1ModeDataManager.getInstance().copyEl2Data() >= 0;
    LogUtil.showInfo(TAG, `initEl1ModeData success: ${isSuccess}`);
    return isSuccess;
  }

  static async initEl1CallNotDisturbData(): Promise<boolean> {
    const configs: ConfigData[] =
      await ConfigDataManager.getInstance().queryConfigDataByConfigType([ConfigType.CALL_NOT_DISTURB_POLICY]);
    if (configs.length <= 0) {
      LogUtil.showInfo(TAG, 'no mode data, no need copy');
      return true;
    }
    const result: number = await El1CallConfigManager.batchInsertCallConfig(configs);
    return result >= 0;
  }
}
