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
import { CLOUD_SYNC_TABLES, DB_CONFIG, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

const TAG: string = 'CursorDataManager';

const TABLE_NAME = DB_CONFIG.CURSOR_DATA.TABLE_NAME;

/**
 * cursor数据管理类，查询和更新云同步表已同步的最新cursor值
 */
export class CursorDataManager {
  private static instance: CursorDataManager;

  public static getInstance(): CursorDataManager {
    if (CursorDataManager.instance == null) {
      CursorDataManager.instance = new CursorDataManager();
    }
    return CursorDataManager.instance;
  }

  async insertCursorData(tableName: string, cursor: number): Promise<number> {
    LogUtil.showInfo(TAG, `insertCursorData: ${StringUtil.getAnonymizedTableName(tableName)} : ${cursor}`);
    let result: number = INVALID_VALUE;
    try {
      let valuesBucket: relationalStore.ValuesBucket = {
        'tableName': tableName,
        'currentCursor': cursor,
      };
      result = await RdbStoreHelper.getInstance().insert(TABLE_NAME, valuesBucket);
      LogUtil.showInfo(TAG, `insertCursorData inserted row: ${result}`);
    } catch (error) {
      LogUtil.showError(TAG, `insertCursorData error:${error?.code}, msg: ${error?.message}`);
    }
    return result;
  }

  async initCursorData(): Promise<number> {
    LogUtil.showInfo(TAG, `initCursorData: len: ${CLOUD_SYNC_TABLES.length}`);
    let result: number = INVALID_VALUE;
    try {
      let valuesBuckets: relationalStore.ValuesBucket[] = [];
      CLOUD_SYNC_TABLES.forEach((tableName) => {
        valuesBuckets.push({
          'tableName': tableName,
          'currentCursor': 0,
        });
      });
      result = await RdbStoreHelper.getInstance().batchInsert(TABLE_NAME, valuesBuckets);
      LogUtil.showInfo(TAG, `initCursorData inserted row: ${result}`);
    } catch (error) {
      LogUtil.showError(TAG, `initCursorData error:${error?.code}, msg: ${error?.message}`);
    }
    return result;
  }

  async updateCursor(tableName: string, cursor: number): Promise<number> {
    let result: number = INVALID_VALUE;
    const oldCursor: number = await this.queryCursor(tableName);
    if (oldCursor === INVALID_VALUE) {
      result = await this.insertCursorData(tableName, cursor);
      LogUtil.showWarn(TAG, `${StringUtil.getAnonymizedTableName(tableName)} has no cursor record, insert ${cursor},isSuccess: ${result}`);
      return result;
    }

    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.equalTo(DB_CONFIG.CURSOR_DATA.tableName, tableName);
      const updateValueBucket: relationalStore.ValuesBucket = {
        'currentCursor': cursor,
      };
      result = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateCursor ${StringUtil.getAnonymizedTableName(tableName)} : ${cursor} changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `updateCursor error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async queryCursor(tableName: string): Promise<number> {
    let result: number = INVALID_VALUE;
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.equalTo(DB_CONFIG.CURSOR_DATA.tableName, tableName);
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'queryCursor: resultSet is empty.');
        return result;
      }
      if (resultSet.goToFirstRow()) {
        result = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CURSOR_DATA.cursor));
      }
    } catch (err) {
      LogUtil.showError(TAG, `queryCursor error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }
}
