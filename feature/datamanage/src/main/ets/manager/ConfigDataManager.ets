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
import { DB_CONFIG, INVALID_VALUE, INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { ConfigData, CurrentOpenedMode } from '../model/base/ConfigModel';
import { ConfigType } from '../model/base/ConfigType';
import { DateTimeUtil } from '../utils/DateTimeUtil';
import { ModeUtil } from '../utils/ModeUtil';
import { EnableState } from '../model/base/ConfigModel';

const TAG: string = 'ConfigDataManager';
const MODE_CONFIG_DATA_TABLE = DB_CONFIG.CONFIG_DATA.TABLE_NAME;

export class ConfigDataManager {
  protected static instance: ConfigDataManager;
  protected rdbStoreHelper: RdbStoreHelper = RdbStoreHelper.getInstance();

  public static getInstance(): ConfigDataManager {
    if (ConfigDataManager.instance == null) {
      ConfigDataManager.instance = new ConfigDataManager();
    }
    return ConfigDataManager.instance;
  }

  /**
   * 插入一条配置数据
   *
   * @param config 配置数据
   * @returns 插入成功的配置数据configId; 插入失败返回空字符串
   */
  async insertConfigData(config: ConfigData, updateTime?: number): Promise<string> {
    LogUtil.showInfo(TAG, `insertConfigData configId: ${config.configId}, updateTime: ${updateTime}`);
    try {
      let result: number = 0;
      const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
      const configId: string =
        CheckEmptyUtils.checkStrIsEmpty(config.configId) ? ModeUtil.generateConfigId(config.modeId, config.configType) :
        config.configId;
      if (this.isInvalidConfigId(configId)) {
        LogUtil.showError(TAG, `insertConfigData failed, invalid configId ${configId}`);
        return '';
      }
      let valuesBucket: relationalStore.ValuesBucket = {
        'configId': configId,
        'modeId': config.modeId,
        'configType': config.configType,
        'configValue': config.configValue,
        'updateTime': updateTime ?? nowTime,
        'createTime': config.createTime ?? nowTime,
      };
      result = await this.rdbStoreHelper.insert(MODE_CONFIG_DATA_TABLE, valuesBucket);
      LogUtil.showInfo(TAG, `insertConfigData result index: ${result}`);
      return result >= 0 ? configId : '';
    } catch (error) {
      LogUtil.showError(TAG, `insertConfigData error:${error?.code}, msg: ${error?.message}`);
      return '';
    }
  }

  /**
   * 批量插入配置数据
   *
   * @param configs 配置数据
   * @returns 插入成功的配置数据个数
   */
  async batchInsertConfigData(configs: ConfigData[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertConfigData: ${configs.length}`);
    try {
      let result: number = 0;
      let valuesBuckets: relationalStore.ValuesBucket[] = [];
      let nowTime: number = DateTimeUtil.getCurrentTimeStamp();
      configs.forEach((config) => {
        const configId: string = CheckEmptyUtils.checkStrIsEmpty(config.configId) ?
        ModeUtil.generateConfigId(config.modeId, config.configType) : config.configId;
        if (this.isInvalidConfigId(configId)) {
          LogUtil.showError(TAG, `batchInsertConfigData invalid configId: ${configId}`);
          return;
        }
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
      result = await this.rdbStoreHelper.batchInsert(MODE_CONFIG_DATA_TABLE, valuesBuckets);
      LogUtil.showInfo(TAG, `batchInsertConfigData changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchInsertConfigData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 删除指定id的配置数据
   *
   * @param configId 配置id
   * @returns 成功返回删除的行数；异常返回-1
   */
  async deleteConfigDataById(configId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteConfigDataById: ${configId}`);
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('configId', configId);
      let result = await this.rdbStoreHelper.delete(predicates);
      LogUtil.showInfo(TAG, `deleteConfigDataById changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteConfigDataById error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 删除指定模式id的所有配置数据
   *
   * @param modeId 模式id
   * @returns 删除的行数；异常返回-1
   */
  async deleteConfigDataByModeId(modeId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteConfigDataByModeId: ${modeId}`);
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('modeId', modeId);
      let result = await this.rdbStoreHelper.delete(predicates);
      LogUtil.showInfo(TAG, `deleteConfigDataByModeId changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteConfigDataByModeId error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 删除指定configType的所有配置数据
   *
   * @param configType config类型
   * @returns 删除的行数；异常返回-1
   */
  async deleteConfigDataByConfigType(configType: ConfigType): Promise<number> {
    LogUtil.showInfo(TAG, `deleteConfigDataByConfigType. configType:${configType}`);
    try {
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('configType', configType);
      const result: number = await this.rdbStoreHelper.delete(predicates);
      LogUtil.showInfo(TAG, `deleteConfigDataByConfigType. changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteConfigDataByConfigType. code:${error?.code} message:${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 更新配置数据
   *
   * @param configData 配置数据
   * @returns 更新成功返回配置id；更新失败返回空字符串
   */
  async updateConfigData(configData: ConfigData, updateTime?: number): Promise<string> {
    LogUtil.showInfo(TAG, `updateConfigData: ${configData.configId}`);
    return await this.updateConfigValue(configData.configId, configData.configValue, updateTime);
  }

  /**
   * 更新配置数据
   *
   * @param configId 配置id
   * @param configValue 配置数据
   * @returns 更新成功返回配置id；更新失败返回空字符串
   */
  async updateConfigValue(configId: string, configValue: string, updateTime?: number): Promise<string> {
    LogUtil.showInfo(TAG, `updateConfigValue, configId:${configId} , updateTime:${updateTime}`);
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo(DB_CONFIG.CONFIG_DATA.configId, configId);

      const updateValueBucket: relationalStore.ValuesBucket = {
        'configValue': configValue,
        'updateTime': updateTime ?? DateTimeUtil.getCurrentTimeStamp(),
      };

      let result = await this.rdbStoreHelper.update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateConfigValue updated change rows: ${result}`);
      return result >= 0 ? configId : '';
    } catch (error) {
      LogUtil.showError(TAG, `updateConfigValue error:${error?.code}, msg: ${error?.message}`);
      return '';
    }
  }

  async updateConfigUpdateTime(configId: string): Promise<string> {
    LogUtil.showInfo(TAG, `updateConfigUpdateTime, configId:${configId}`);
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo(DB_CONFIG.CONFIG_DATA.configId, configId);
      const updateValueBucket: relationalStore.ValuesBucket = {
        'updateTime': DateTimeUtil.getCurrentTimeStamp(),
      };

      let result = await this.rdbStoreHelper.update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateConfigUpdateTime updated change rows: ${result}`);
      return result >= 0 ? configId : '';
    } catch (error) {
      LogUtil.showError(TAG, `updateConfigUpdateTime error:${error?.code}, msg: ${error?.message}`);
      return '';
    }
  }

  /**
   * 根据配置id查询配置数据
   *
   * @param configId 配置数据id
   * @returns 查询成功返回配置数据；查询失败返回undefined
   */
  async queryConfigDataById(configId: string): Promise<ConfigData | undefined> {
    let result: ConfigData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('configId', configId);
      resultSet = await this.rdbStoreHelper.query(predicates);
      result = this.convertResultToConfigList(resultSet);
      if (result.length > 0) {
        return result[0];
      }
    } catch (err) {
      LogUtil.showError(TAG, `queryConfigDataById error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return undefined;
  }

  public convertResultToValueBucket(resultSet: relationalStore.ResultSet): relationalStore.ValuesBucket | undefined {
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToValueBucket result is empty');
      return undefined;
    }
    const configId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configId));
    const modeId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.modeId));
    const configType: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configType));
    const configValue: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configValue));
    const updateTime: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.updateTime));
    const createTime: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.createTime));
    return {
      configId,
      modeId,
      configType,
      configValue,
      updateTime,
      createTime
    };
  }

  queryConfigDataByIdSync(configId: string): ConfigData | undefined {
    let result: ConfigData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('configId', configId);
      resultSet = this.rdbStoreHelper.querySync(predicates);
      result = this.convertResultToConfigList(resultSet);
      if (result.length > 0) {
        return result[0];
      }
    } catch (err) {
      LogUtil.showError(TAG, `queryConfigDataById error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return undefined;
  }

  async queryConfigDataByIds(configIds: string[]): Promise<ConfigData[]> {
    let result: ConfigData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.in(DB_CONFIG.CONFIG_DATA.configId, configIds);
      resultSet = await this.rdbStoreHelper.query(predicates);
      result = this.convertResultToConfigList(resultSet);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `queryConfigDataByIds error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  async queryModeIdByConfigTypeAndValue(configType: number, configValue: string): Promise<ConfigData[]> {
    let result: ConfigData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('configType', configType);
      predicates.equalTo('configValue', configValue);
      resultSet = await this.rdbStoreHelper.query(predicates);
      result = this.convertResultToConfigList(resultSet);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `queryModeIdByConfigTypeAndValue error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  /**
   * 查询指定configType的所有配置数据
   *
   * @param configType config类型
   * @returns 查询的数据；异常返回[]
   */
  async queryConfigDataByConfigType(configType: ConfigType[]): Promise<ConfigData[]> {
    let result: ConfigData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.in('configType', configType);
      predicates.orderByAsc('createTime');
      resultSet = await this.rdbStoreHelper.query(predicates);
      result = this.convertResultToConfigList(resultSet);
    } catch (err) {
      LogUtil.showError(TAG, `queryAllConditionConfig error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  /**
   * 根据模式id和配置类型查询所有配置数据
   *
   * @param modeId 模式id
   * @param configType 配置数据类型，可选
   * @returns 配置数据数组，如果有configType参数，按创建时间升序排序
   */
  async queryConfigByModeAndType(modeId: string, configType?: ConfigType): Promise<ConfigData[]> {
    let result: ConfigData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('modeId', modeId);
      if (configType) {
        predicates.equalTo('configType', configType.valueOf());
        predicates.orderByAsc('createTime');
      }
      resultSet = await this.rdbStoreHelper.query(predicates);
      result = this.convertResultToConfigList(resultSet);
    } catch (err) {
      LogUtil.showError(TAG, `queryConfigByModeAndType error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  /**
   * 根据模式id和多个配置类型查询所有配置数据，按创建时间升序排序
   *
   * @param modeId 模式id
   * @param configTypes 配置类型数据
   * @returns 配置数据数组，按创建时间升序排序
   */
  async queryConfigByModeAndTypes(modeId: string, configTypes: ConfigType[]): Promise<ConfigData[]> {
    let result: ConfigData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      predicates.equalTo('modeId', modeId);
      predicates.in('configType', configTypes);
      predicates.orderByAsc('createTime');

      resultSet = await this.rdbStoreHelper.query(predicates);
      result = this.convertResultToConfigList(resultSet);
    } catch (err) {
      LogUtil.showError(TAG, `queryConfigByModeAndTypes error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  /**
   * 根据配置数据类型同步查询配置id
   *
   * @param configType 配置数据类型，可选
   * @returns 配置数据id数组
   */
  queryConfigIdsByTypeSync(configTypes?: ConfigType[]): string[] {
    let result: string[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_CONFIG_DATA_TABLE);
      let columns: string[] = ['configId'];
      if (configTypes) {
        predicates.in('configType', configTypes);
      }
      resultSet = this.rdbStoreHelper.querySync(predicates, columns);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'resultSet is empty');
        return result;
      }
      while (resultSet.goToNextRow()) {
        result.push(resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configId)));
      }
    } catch (err) {
      LogUtil.showError(TAG, `queryConfigIdsByTypeSync error:${err?.code} ${err?.message}}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  /**
   * 插入预置的全局配置数据
   */
  public async insertPresetConfig(): Promise<void> {
    // 插入当前开启模式配置
    const openState: CurrentOpenedMode = {
      modeId: NO_SCENE,
      openType: -1
    };
    const data: ConfigData = {
      configId: `${ConfigType.CURRENT_OPENED_MODE}`,
      modeId: openState.modeId,
      configType: ConfigType.CURRENT_OPENED_MODE,
      configValue: JSON.stringify(openState),
    };
    let configId: string = await this.insertConfigData(data);
    LogUtil.showInfo(TAG, `insertPresetConfig result: ${configId}`);
  }

  /**
   * 获取对应模式配置开关状态
   *
   * @param modeId 模式
   * @param configType 配置类型
   * @returns 开关状态
   */
  public getConfigEnableState(modeId: string, configType: ConfigType): boolean {
    const configId: string = ModeUtil.generateConfigId(modeId, configType);
    const configData: ConfigData | undefined = this.queryConfigDataByIdSync(configId);
    if (!configData) {
      return false;
    }
    const enableState: EnableState = JsonUtil.fromJson(configData.configValue) as EnableState;
    return enableState?.enable;
  }

  protected convertResultToConfigList(resultSet: relationalStore.ResultSet | undefined): ConfigData[] {
    let result: ConfigData[] = [];
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToConfigList result is empty');
      return result;
    }
    try {
      while (resultSet.goToNextRow()) {
        const configId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configId));
        const modeId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.modeId));
        const configType: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configType));
        const configValue: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configValue));
        const updateTime: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.updateTime));
        const createTime: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.createTime));
        result.push({
          configId,
          modeId,
          configType,
          configValue,
          updateTime,
          createTime
        });
      }
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.QUERY_FAIL, String(err?.code), err?.message, 'convertResultToConfigList');
      LogUtil.showError(TAG, `convertResultToConfigList error code: ${err?.code} message: ${err?.message}}`);
    }
    return result;
  }

  protected isInvalidConfigId(configId: string): boolean {
    return configId.startsWith(INVALID_MODE_ID);
  }
}