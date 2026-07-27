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

import relationalStore from '@ohos.data.relationalStore';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { DB_CONFIG, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { El1ConfigDataManager } from './El1ConfigDataManager';
import { ConfigData } from '../model/base/ConfigModel';
import { ConfigType } from '../model/base/ConfigType';
import { DateTimeUtil } from '../utils/DateTimeUtil';
import { ModeUtil } from '../utils/ModeUtil';

/* instrument ignore file */
const TAG: string = 'El1CallConfigManager';
const MODE_CONFIG_DATA_TABLE = DB_CONFIG.CONFIG_DATA.TABLE_NAME;

export class El1CallConfigManager {
  static async insertCallConfig(config: ConfigData): Promise<string> {
    LogUtil.showInfo(TAG, `insertConfigData: ${config.configId}`);
    config.configId = config.configId || `${config.modeId}_${ConfigType.CALL_NOT_DISTURB_POLICY}`;
    return await El1ConfigDataManager.getInstance().insertConfigData(config);
  }

  static async batchInsertCallConfigValues(configs: relationalStore.ValuesBucket[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertConfig, configs num: ${configs.length}`);
    const callConfigs: relationalStore.ValuesBucket[] =
      configs.filter(config => config['configType'] === ConfigType.CALL_NOT_DISTURB_POLICY);
    if (callConfigs.length <= 0) {
      return 0;
    }
    return await El1ConfigDataManager.getInstance().batchInsertConfigByValueBuckets(callConfigs);
  }

  static async batchInsertCallConfig(configs: ConfigData[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertCallConfig: ${configs.length}`);
    let callConfigs = configs.filter(config => config.configType === ConfigType.CALL_NOT_DISTURB_POLICY);
    let valuesBuckets: relationalStore.ValuesBucket[] = [];
    callConfigs.forEach((config) => {
      valuesBuckets.push({
        'configId': config.configId || `${config.modeId}_${ConfigType.CALL_NOT_DISTURB_POLICY}`,
        'modeId': config.modeId,
        'configType': config.configType,
        'configValue': config.configValue
      });
    });
    return await El1ConfigDataManager.getInstance().batchInsertConfigByValueBuckets(valuesBuckets);
  }

  /**
   * 批量插入配置数据
   *
   * @param configs 配置数据
   * @returns 插入成功的配置数据个数
   */
  static async batchInsertConfigData(configs: ConfigData[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertConfigData: ${configs.length}`);
    try {
      let result: number = 0;
      let valuesBuckets: relationalStore.ValuesBucket[] = [];
      let nowTime: number = DateTimeUtil.getCurrentTimeStamp();
      configs.forEach((config) => {
        const configId = CheckEmptyUtils.checkStrIsEmpty(config.configId) ?
          ModeUtil.generateConfigId(config.modeId, config.configType) : config.configId;
        valuesBuckets.push({
          'configId': configId,
          'modeId': config.modeId,
          'configType': config.configType,
          'configValue': config.configValue,
          'updateTime': nowTime,
          'createTime': nowTime,
        });
        nowTime++;
      });
      result = await El1RdbStoreHelper.getInstance().batchInsert(MODE_CONFIG_DATA_TABLE, valuesBuckets);
      LogUtil.showInfo(TAG, `batchInsertConfigData changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchInsertConfigData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }
}
