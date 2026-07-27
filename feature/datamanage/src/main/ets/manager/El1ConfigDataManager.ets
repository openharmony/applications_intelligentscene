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
import { DB_CONFIG, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { ConfigData } from '../model/base/ConfigModel';
import { ConfigDataManager } from './ConfigDataManager';
import { ModeUtil } from '../utils/ModeUtil';
import { DateTimeUtil } from '../utils/DateTimeUtil';

/* instrument ignore file */
const TAG: string = 'El1ConfigDataManager';
const MODE_CONFIG_DATA_TABLE = DB_CONFIG.CONFIG_DATA.TABLE_NAME;

export class El1ConfigDataManager extends ConfigDataManager {
  protected static instance: El1ConfigDataManager;
  protected rdbStoreHelper: RdbStoreHelper = El1RdbStoreHelper.getInstance();

  public static getInstance(): El1ConfigDataManager {
    if (El1ConfigDataManager.instance == null) {
      El1ConfigDataManager.instance = new El1ConfigDataManager();
    }
    return El1ConfigDataManager.instance as El1ConfigDataManager;
  }

  async copyConfigsToEl1(configIds: string[]): Promise<number> {
    LogUtil.showInfo(TAG, `copyConfigsToEl1, configIds length: ${configIds.length}`);
    if (configIds.length <= 0) {
      return 0;
    }
    const configs: ConfigData[] = await ConfigDataManager.getInstance().queryConfigDataByIds(configIds);
    LogUtil.showInfo(TAG, `quey EL2 configs length: ${configs.length}`);
    if (configs.length <= 0) {
      return 0;
    }
    return await this.batchInsertConfigs(configs);
  }

  async insertConfigData(config: ConfigData): Promise<string> {
    LogUtil.showInfo(TAG, `insertConfigData: ${config.configId}`);
    const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
    const configId =
      CheckEmptyUtils.checkStrIsEmpty(config.configId) ? ModeUtil.generateConfigId(config.modeId, config.configType) :
        config.configId;
    try {
      let valuesBucket: relationalStore.ValuesBucket = {
        'configId': configId,
        'modeId': config.modeId,
        'configType': config.configType,
        'configValue': config.configValue,
        'updateTime': nowTime,
        'createTime': config.createTime ?? nowTime,
      };
      const result: number = await this.rdbStoreHelper.insert(MODE_CONFIG_DATA_TABLE, valuesBucket);
      LogUtil.showInfo(TAG, `insertConfigData result index: ${result}`);
      return result >= 0 ? configId : '';
    } catch (error) {
      LogUtil.showError(TAG, `insertConfigData error:${error?.code}, msg: ${error?.message}`);
      return '';
    }
  }

  async batchInsertConfigs(configs: ConfigData[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertCallConfig: ${configs.length}`);
    let valuesBuckets: relationalStore.ValuesBucket[] = [];
    configs.forEach((config) => {
      valuesBuckets.push({
        'configId': config.configId,
        'modeId': config.modeId,
        'configType': config.configType,
        'configValue': config.configValue
      });
    });
    return await this.batchInsertConfigByValueBuckets(valuesBuckets);
  }

  async batchInsertConfigByValueBuckets(configs: relationalStore.ValuesBucket[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertConfig, configs num: ${configs.length}`);
    if (configs.length <= 0) {
      return 0;
    }
    try {
      const result: number =
        await this.rdbStoreHelper.batchInsert(MODE_CONFIG_DATA_TABLE, configs, true);
      LogUtil.showInfo(TAG, `batchInsertConfig inserted row: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchInsertConfig error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 更新配置数据
   *
   * @param configData 配置数据
   * @returns 更新成功返回配置id；更新失败返回空字符串
   */
  async updateConfigData(configData: ConfigData): Promise<string> {
    LogUtil.showInfo(TAG, `updateConfigData: ${configData.configId}`);
    return await this.updateConfigValue(configData.configId, configData.configValue);
  }
}
