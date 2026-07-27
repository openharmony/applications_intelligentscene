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

import { relationalStore } from '@kit.ArkData';
import { DB_CONFIG, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { OperationData } from '../model/base/OperationData';

const TAG: string = 'OperationDataManager';
const RECORDS_LENGTH: number = 3;
const NINETY_DAY: number = 90 * 24 * 60 * 60 * 1000;
const ONE_WEEK: number = 7 * 24 * 60 * 60 * 1000;
const MAX_LIMIT_NUMBER: number = 1000;
const DELETE_COUNT_IN_ONCE: number = 10;
const RECOMMEND_RULE_LENGTH: number = 4;

export class OperationDataManager {
  private static instance: OperationDataManager;

  public static getInstance(): OperationDataManager {
    if (OperationDataManager.instance == null) {
      OperationDataManager.instance = new OperationDataManager();
    }
    return OperationDataManager.instance;
  }

  async insertOperationData(operation: OperationData): Promise<number> {
    LogUtil.showInfo(TAG, `insertOperationData, id: ${operation.modeId}`);
    try {
      if (operation.modeId === '') {
        LogUtil.showError(TAG, 'insertOperationData fail, invalid modeId.');
        return INVALID_VALUE;
      }
      let result: number = 0;
      let valuesBucket: relationalStore.ValuesBucket = {
        'modeId': operation.modeId,
        'operationTime': operation.operationTime,
        'longitude': StringUtil.fixedString(operation.longitude),
        'latitude': StringUtil.fixedString(operation.latitude),
        'locationDesc': operation.locationDesc,
        'application': operation.application,
        'week': operation.week,
      };
      result = await RdbStoreHelper.getInstance().insert(DB_CONFIG.OPERATION_DATA.TABLE_NAME, valuesBucket);
      LogUtil.showInfo(TAG, `insertOperationData result index: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `insertOperationData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async updateDurationById(id: number, duration: string, application?: string): Promise<number> {
    LogUtil.showInfo(TAG, `updateDurationById, id: ${id}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      predicates.equalTo('id', id);
      const updateValueBucket: relationalStore.ValuesBucket = {
        'duration': duration,
        'application': application ?? ''
      };
      let result = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateDurationById updated change rows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `updateDurationById error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async deleteOperationDataByModeId(modeId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteOperationDataByModeId modeId: ${modeId}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      predicates.equalTo('modeId', modeId);
      predicates.or();
      predicates.equalTo('modeId', `-${modeId}`);
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteOperationDataByModeId changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteOperationDataByModeId error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async deleteOperationDataById(id: number) : Promise<number> {
    LogUtil.showInfo(TAG, `deleteOperationById: ${id}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      predicates.equalTo('id', id);
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteOperationDataById changeRows: ${result}`);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `deleteOperationDataById err: ${err?.code}, msg: ${err?.message}`);
    }
    return INVALID_VALUE;
  }

  async deleteOperationDataByPredicates(predicates: relationalStore.RdbPredicates) : Promise<number> {
    LogUtil.showInfo(TAG, `deleteOperationDataByPredicates: ${predicates !== undefined}`);
    try {
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteOperationDataByPredicates changeRows: ${result}`);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `deleteOperationDataByPredicates err: ${err?.code}, msg: ${err?.message}`);
    }
    return INVALID_VALUE;
  }

  async queryOperationDataCountByModeId(modeId: string): Promise<number> {
    LogUtil.showInfo(TAG, `queryOperationDataCountByModeId id: ${modeId}`);
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      predicates.equalTo('modeId', modeId).or().equalTo('modeId', `-${modeId}`);
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'queryOperationDataCountByModeId warn: resultSet is empty.');
        return 0;
      }
      LogUtil.showInfo(TAG, `resultSet row count: ${resultSet.rowCount}`);
      return resultSet.rowCount;
    } catch (err) {
      LogUtil.showError(TAG, `queryOperationDataCountByModeId error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return 0;
  }

  async deleteOperationDataIfOverflow(modeId: string): Promise<void> {
    const count: number = await this.queryOperationDataCountByModeId(modeId);
    if (count < MAX_LIMIT_NUMBER) {
      return;
    }
    LogUtil.showInfo(TAG, 'deleteOperationDataIfOverflow');
    let predicates: relationalStore.RdbPredicates = new relationalStore
      .RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
    predicates.equalTo('modeId', modeId).or().equalTo('modeId', `-${modeId}`);
    predicates.orderByAsc('id');
    predicates.limitAs(DELETE_COUNT_IN_ONCE);
    const operationData: OperationData[] = await this.getOperationDataByPredicates(predicates);
    if (operationData.length === 0) {
      return;
    }
    let deleteIds: number[] = [];
    for (let data of operationData) {
      if (data.id && data.id > 0) {
        deleteIds.push(data.id);
      }
    }
    LogUtil.showInfo(TAG, `delete ids ${deleteIds.join(',')}`);
    let deletePredicates: relationalStore.RdbPredicates = new relationalStore
      .RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
    deletePredicates.in('id', deleteIds);
    this.deleteOperationDataByPredicates(deletePredicates);
  }

  public async clearOperationData(modeId: string): Promise<void> {
    const now: Date = new Date();
    const deleteTime: number = now.getTime() - NINETY_DAY;
    LogUtil.showInfo(TAG, `clearOperationData operation time: ${deleteTime}`);
    let dayPredicates: relationalStore.RdbPredicates = new relationalStore
      .RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
    dayPredicates.lessThan('operationTime', deleteTime);
    await this.deleteOperationDataByPredicates(dayPredicates);
    await this.deleteOperationDataIfOverflow(modeId);
  }

  public async clearOneWeekOperationData(ruleId: string): Promise<void> {
    LogUtil.showInfo(TAG, `clearOneWeekOperationData ${ruleId}`);
    if (!ruleId) {
      return;
    }
    const ruleArray: string[] = ruleId.split('_');
    if (ruleArray.length < RECOMMEND_RULE_LENGTH) {
      return;
    }
    try {
      const modeId: string = ruleArray[1];
      const openTime: number = parseInt(ruleArray[RECOMMEND_RULE_LENGTH - 1]);
      const deleteTime: number = openTime - ONE_WEEK;
      let dayPredicates: relationalStore.RdbPredicates = new relationalStore
        .RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      dayPredicates.greaterThanOrEqualTo('operationTime', deleteTime).and()
        .lessThanOrEqualTo('operationTime', openTime).and().equalTo('modeId', modeId);
      await this.deleteOperationDataByPredicates(dayPredicates);
    } catch (e) {
      LogUtil.showError(TAG, `clearOneWeekOperationData error: ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 查询最近三次当前模式的操作记录
   *
   * @param modeId 模式Id
   * @returns
   */
  async getLastThreeOperationData(modeId: string): Promise<OperationData[]> {
    let predicates: relationalStore.RdbPredicates = new relationalStore
      .RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
    predicates.equalTo('modeId', modeId);
    predicates.orderByDesc('id');
    predicates.limitAs(RECORDS_LENGTH);
    let operations: OperationData[] = await this.getOperationDataByPredicates(predicates);
    if (operations.length < RECORDS_LENGTH) {
      LogUtil.showWarn(TAG, 'operationData length is less three.');
      return [];
    }
    LogUtil.showInfo(TAG, `getLastThreeOperationData length: ${operations.length}`);
    return operations;
  }

  async queryOperationDataByModeId(modeId: string): Promise<OperationData[]> {
    LogUtil.showInfo(TAG, `queryOperationDataByModeId id: ${modeId}`);
    let result: OperationData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      predicates.equalTo('modeId', modeId);
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, `queryOperationDataByModeId warn: resultSet is empty.`);
        return result;
      }
      LogUtil.showInfo(TAG, `resultSet count: ${resultSet.columnCount}`);
      result = this.convertResultToOperationList(resultSet);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `queryOperationDataByModeId error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  async getOperationDataByPredicates(predicates: relationalStore.RdbPredicates): Promise<OperationData[]> {
    LogUtil.showInfo(TAG, 'getOperationDataByPredicates');
    let result: OperationData[] = [];
    if (!predicates) {
      LogUtil.showWarn(TAG, 'predicates is invalid');
      return result;
    }
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, `getOperationDataByPredicates warn: resultSet is empty.`);
        return result;
      }
      LogUtil.showInfo(TAG, `resultSet count: ${resultSet.columnCount}`);
      result = this.convertResultToOperationList(resultSet);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `getOperationDataByPredicates error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  async queryOperationDataById(id: number): Promise<OperationData | undefined> {
    LogUtil.showInfo(TAG, `queryOperationDataById id: ${id}`);
    let result: OperationData | undefined = undefined;
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      predicates.equalTo('id', id);
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, `queryOperationDataById warn: resultSet is empty.`);
        return result;
      }
      LogUtil.showInfo(TAG, `resultSet count: ${resultSet.columnCount}`);
      if (!resultSet.goToNextRow()) {
        LogUtil.showError(TAG, 'queryOperationDataById result is invalid.');
        return result;
      }
      result = this.convertResultToOperation(resultSet);
    } catch (err) {
      LogUtil.showError(TAG, `queryOperationDataById error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  async queryOperationTimeById(id: number): Promise<string> {
    LogUtil.showInfo(TAG, `queryOperationTimeById id: ${id}`);
    let result: OperationData | undefined = await this.queryOperationDataById(id);
    if (!result) {
        return '';
    }
    return result.operationTime;
  }

  /**
   * 获取当前模式最后一条操作记录
   *
   * @param modeId 模式id
   * @returns
   */
  async getLastOperationData(modeId: string): Promise<OperationData | undefined> {
    let predicates: relationalStore.RdbPredicates = new relationalStore
      .RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
    predicates.equalTo('modeId', modeId);
    predicates.orderByDesc('id');
    predicates.limitAs(1);
    let operations: OperationData[] = await this.getOperationDataByPredicates(predicates);
    LogUtil.showInfo(TAG, `getLastOperationData length: ${operations.length}`);
    return operations[0] || undefined;
  }

  private convertResultToOperation(resultSet: relationalStore.ResultSet): OperationData | undefined {
    let result: OperationData | undefined = undefined;
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToOperation result is empty');
      return result;
    }
    try {
      const id = resultSet.getLong(resultSet.getColumnIndex('id'));
      const modeId = resultSet.getString(resultSet.getColumnIndex('modeId'));
      const operationTime = resultSet.getString(resultSet.getColumnIndex('operationTime'));
      const longitude = resultSet.getString(resultSet.getColumnIndex('longitude'));
      const latitude = resultSet.getString(resultSet.getColumnIndex('latitude'));
      const locationDesc = resultSet.getString(resultSet.getColumnIndex('locationDesc'));
      const application = resultSet.getString(resultSet.getColumnIndex('application'));
      const week = resultSet.getString(resultSet.getColumnIndex('week'));
      const duration = resultSet.getString(resultSet.getColumnIndex('duration'));
      result = {
        id,
        modeId,
        operationTime,
        longitude,
        latitude,
        locationDesc,
        application,
        week,
        duration
      };
    } catch (error) {
      LogUtil.showError(TAG, `convertResultToOperation error code: ${error?.code} message: ${error?.message}`);
    }
    return result;
  }

  private convertResultToOperationList(resultSet: relationalStore.ResultSet): OperationData[] {
    let results: OperationData[] = [];
    if (!resultSet) {
      LogUtil.showWarn(TAG, `convertResultToOperationList result is empty`);
      return results;
    }

    while (resultSet.goToNextRow()) {
      let result: OperationData | undefined = this.convertResultToOperation(resultSet);
      if (!result) {
        LogUtil.showWarn(TAG, 'result is undefined.');
        continue;
      }
      results.push(result);
    }
    return results;
  }
}