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
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { FactorType, FactorTypeValue } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { ALL_CONDITION_TYPE } from '../utils/ModeUtil';
import { ModeHistory } from '../model/ModeHistory';
import { DateTimeUtil } from '../utils/DateTimeUtil';
import { MigrateUtil } from '../utils/MigrateUtil';
import { ConfigDataManager, ConfigType, El1ConfigDataManager } from '../../../../Index';

const TAG: string = 'HistoryDataManager:';
const INVALID_RESULT: number = -1;

export class HistoryDataManager {
  private static instance: HistoryDataManager;

  public static getInstance(): HistoryDataManager {
    if (HistoryDataManager.instance == null) {
      HistoryDataManager.instance = new HistoryDataManager();
    }
    return HistoryDataManager.instance;
  }

  /**
   *  自动启停模式数据记录
   *
   * @param newDataList 更新的数据
   */
  public async recordAutoData(newDataList: ModeHistory[]): Promise<void> {
    LogUtil.showInfo(TAG, `recordAutoData, length: ${newDataList.length}`);
    const configIds: string[] = newDataList.map(item => item.configId);
    let preDataList: ModeHistory[] = await this.queryDataByConfigIds(configIds);
    let insertData: ModeHistory[] = [];
    for (let j = 0; j < newDataList.length; j++) {
      let newData: ModeHistory = newDataList[j];
      let hasFound: boolean = false;
      for (let i = 0; i < preDataList.length; i++) {
        let preData: ModeHistory = preDataList[i];
        if (newData.configId === preData.configId) {
          newData.id = preData.id;
          await this.updateData(newData);
          hasFound = true;
          break;
        }
      }
      if (!hasFound) {
        insertData.push(newData);
      }
    }
    await this.batchInsertData(insertData);
  }

  /**
   * 手动启停模式数据记录
   *
   * @param currentScene 当前正在开启的模式Id
   * @param nextScene 即将要开启的模式Id
   * @param operType 操作类型
   * @returns 是否成功
   */
  public async recordManualData(currentScene: string, nextScene: string, operType: number): Promise<boolean> {
    let manualType: string = FactorTypeValue.MANUAL_OFF;
    let modeId: string = currentScene;
    let result: boolean = false;
    if (nextScene !== NO_SCENE) {
      manualType = FactorTypeValue.MANUAL_ON;
      modeId = nextScene;
    }
    if (operType !== FactorType.AUTO && operType !== FactorType.WEARABLE_SYNC) {
      let manualData: ModeHistory[] = await this.queryManualData();
      let modeHistory: ModeHistory = {
        'operType': manualType,
        'ruleName': '',
        'configId': '',
        'modeId': modeId,
        'priority': 0,
        'timestamp': DateTimeUtil.getCurrentTimeStamp()
      }
      if (!CheckEmptyUtils.isEmptyArr(manualData)) {
        modeHistory.id = manualData[0].id;
        result = await this.updateData(modeHistory);
      } else {
        result = await this.insertData(modeHistory);
      }
    }
    LogUtil.showInfo(TAG,
      `recordManualData result:${result}, modeId:${modeId}, manualType:${manualType}, operType: ${operType}`);
    return result;
  }

  /**
   * 刷新指定模式的手动记录为关闭，若无该模式手动记录则不处理
   *
   * @param modeId 模式id
   */
  public async manualOffMode(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `manualOffMode, modeId: ${modeId}`);
    let manualData: ModeHistory[] = await this.queryManualData();
    if (!CheckEmptyUtils.isEmptyArr(manualData) && modeId === manualData[0].modeId) {
      let modeHistory = manualData[0];
      modeHistory.operType = FactorTypeValue.MANUAL_OFF;
      let result = await this.updateData(modeHistory);
      LogUtil.showInfo(TAG, `manualOffMode, result: ${result}`);
    }
  }

  public async queryDataByModeAndType(modeId: string, operType: FactorTypeValue): Promise<ModeHistory[]> {
    LogUtil.showInfo(TAG, 'queryDataByModeAndType');
    let predicates = new relationalStore.RdbPredicates(DB_CONFIG.HISTORY_DATA.TABLE_NAME);
    predicates.equalTo('modeId', modeId).and().equalTo('operType', operType);
    return await this.queryData(predicates);
  }

  /**
   * 删除无效状态记录，configId已不存在（控制中心临时记录和手动启停记录除外），即条件已被删除的状态记录
   *
   * @returns 删除记录数量
   */
  public async deleteInValidRecord(): Promise<number> {
    LogUtil.showInfo(TAG, 'deleteInValidRecord');
    let validConfigIds: string[] = ConfigDataManager.getInstance().queryConfigIdsByTypeSync(ALL_CONDITION_TYPE);
    // 手动启停状态记录configIds为空字符串
    validConfigIds.push('');
    let gameTempCondition: string = '%18_temp_condition%';
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.HISTORY_DATA.TABLE_NAME);
      predicates.notIn('configId', validConfigIds).and().notContains('configId', gameTempCondition);
      let result: number = await El1RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteInValidRecord changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteInValidRecord error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 删除模式时删除无效状态记录
   *
   * @param modeId 模式id
   */
  public async clearRecordWhenDeleteMode(modeId: string): Promise<void> {
    this.manualOffMode(modeId);
    this.deleteInValidRecord();
  }

  private async batchInsertData(data: ModeHistory[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertData, length: ${data.length}`);
    if (data.length === 0) {
      return 0;
    }
    try {
      let result: number = 0;
      let valuesBuckets: relationalStore.ValuesBucket[] = [];
      const currentTime = DateTimeUtil.getCurrentTimeStamp();
      data.forEach((item) => {
        valuesBuckets.push({
          'operType': item.operType,
          'ruleName': item.ruleName,
          'configId': item.configId,
          'modeId': item.modeId,
          'priority': item.priority,
          'timestamp': item.timestamp ?? currentTime
        });
      });
      result = await El1RdbStoreHelper.getInstance().batchInsert(DB_CONFIG.HISTORY_DATA.TABLE_NAME, valuesBuckets);
      LogUtil.showInfo(TAG, `batchInsertData changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchInsertData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  private async insertData(data: ModeHistory): Promise<boolean> {
    LogUtil.showInfo(TAG, 'insertData');
    if (!data) {
      LogUtil.showError(TAG, 'insertData failed: data is empty');
      return false;
    }
    let result: number = 0;
    const valuesBucket: relationalStore.ValuesBucket = {
      'operType': data.operType,
      'ruleName': data.ruleName,
      'configId': data.configId,
      'modeId': data.modeId,
      'priority': data.priority,
      'timestamp': data.timestamp ?? DateTimeUtil.getCurrentTimeStamp()
    };
    try {
      result = await El1RdbStoreHelper.getInstance().insert(DB_CONFIG.HISTORY_DATA.TABLE_NAME, valuesBucket);
      let isSuccess: boolean = result !== INVALID_RESULT;
      LogUtil.showInfo(TAG, `insertManuallyData isSuccess: ${isSuccess}`);
      return isSuccess;
    } catch (error) {
      LogUtil.showError(TAG, `insertManuallyData error:${error?.code}, msg: ${error?.message}`);
      return false;
    }
  }

  private async updateData(data: ModeHistory): Promise<boolean> {
    LogUtil.showInfo(TAG, 'updateData');
    if (!data) {
      LogUtil.showError(TAG, 'updateData failed: data is empty');
      return false;
    }
    let predicates = new relationalStore.RdbPredicates(DB_CONFIG.HISTORY_DATA.TABLE_NAME);
    predicates.equalTo('id', data.id);
    const updateValueBucket: relationalStore.ValuesBucket = {
      'operType': data.operType,
      'ruleName': data.ruleName,
      'configId': data.configId,
      'modeId': data.modeId,
      'priority': data.priority,
      'timestamp': data.timestamp ?? DateTimeUtil.getCurrentTimeStamp()
    };
    let result = await El1RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
    let isSuccess: boolean = result !== INVALID_RESULT;
    LogUtil.showInfo(TAG, `updateData isSuccess: ${isSuccess}`);
    return isSuccess;
  }

  public async queryManualData(): Promise<ModeHistory[]> {
    LogUtil.showInfo(TAG, 'queryManualData');
    let predicates = new relationalStore.RdbPredicates(DB_CONFIG.HISTORY_DATA.TABLE_NAME);
    predicates.in('operType', [FactorTypeValue.MANUAL_ON, FactorTypeValue.MANUAL_OFF]);
    return await this.queryData(predicates);
  }

  private async queryDataByConfigIds(configIds: string[]): Promise<ModeHistory[]> {
    LogUtil.showInfo(TAG, 'queryDataByConfigIds');
    let predicates = new relationalStore.RdbPredicates(DB_CONFIG.HISTORY_DATA.TABLE_NAME);
    predicates.in('configId', configIds);
    return await this.queryData(predicates);
  }

  private async queryData(predicates: relationalStore.RdbPredicates, isEL2Data?: boolean): Promise<ModeHistory[]> {
    let result: ModeHistory[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      if (isEL2Data) {
        resultSet = await RdbStoreHelper.getInstance().query(predicates);
      } else {
        resultSet = await El1RdbStoreHelper.getInstance().query(predicates);
      }
      if (!resultSet) {
        LogUtil.showError(TAG, 'resultSet is empty.');
        return result;
      }
      while (resultSet.goToNextRow()) {
        const id: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.HISTORY_DATA.id));
        const operType: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.HISTORY_DATA.operType));
        const ruleName: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.HISTORY_DATA.ruleName));
        const configId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.HISTORY_DATA.configId));
        const modeId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.HISTORY_DATA.modeId));
        const priority: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.HISTORY_DATA.priority));
        const timestamp: number = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.HISTORY_DATA.timestamp));
        result.push({
          'id': id,
          'operType': operType,
          'ruleName': ruleName,
          'configId': configId,
          'modeId': modeId,
          'priority': priority,
          'timestamp': timestamp
        });
      }
    } catch (err) {
      LogUtil.showError(TAG, `queryData error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    LogUtil.showInfo(TAG, `queryData result length: ${result.length}`);
    return result;
  }

  public async migrate(): Promise<boolean> {
    LogUtil.showInfo(TAG, 'migrate start');
    if (MigrateUtil.isHistoryDataMigrated()) {
      LogUtil.showInfo(TAG, 'has migrated, no need migrate');
      return true;
    }
    MigrateUtil.setHistoryDataMigrated(true);
    MigrateUtil.setNeedUpdateRule(true);
    let predicates = new relationalStore.RdbPredicates(DB_CONFIG.HISTORY_DATA.TABLE_NAME);
    predicates.orderByAsc(DB_CONFIG.HISTORY_DATA.timestamp);
    let allData: ModeHistory[] = await this.queryData(predicates, true);
    for (let history of allData) {
      if (history.operType !== FactorTypeValue.AUTO_ON && history.operType !== FactorTypeValue.AUTO_OFF) {
        continue;
      }
      if (!history.configId) {
        const ruleNameParts: string[] = history.ruleName.split('-');
        history.configId = ruleNameParts.length >= 2 ? ruleNameParts[1] : '';
      }
    }

    const result: number = await this.batchInsertData(allData);
    LogUtil.showInfo(TAG, `migrate to EL1 end, historySize: ${allData.length} result: ${result}`);
    if (result < 0) {
      MigrateUtil.setHistoryDataMigrated(false);
      MigrateUtil.setNeedUpdateRule(false);
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, '', '', 'migrateHistoryData');
      return false;
    }
    return true;
  }
}
