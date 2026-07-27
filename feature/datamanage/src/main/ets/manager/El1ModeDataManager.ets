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
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { ModeDataManager } from './ModeDataManager';

const TAG: string = 'El1ModeDataManager';
const MODE_DATA_TABLE = DB_CONFIG.MODE_DATA.TABLE_NAME;

export class El1ModeDataManager extends ModeDataManager {
  protected static instance: El1ModeDataManager;
  protected rdbStoreHelper: RdbStoreHelper = El1RdbStoreHelper.getInstance();

  public static getInstance(): El1ModeDataManager {
    if (El1ModeDataManager.instance == null) {
      El1ModeDataManager.instance = new El1ModeDataManager();
    }
    return El1ModeDataManager.instance as El1ModeDataManager;
  }

  async copyEl2Data(): Promise<number> {
    let resultSet: relationalStore.ResultSet | undefined = await RdbStoreHelper.getInstance().queryAll(MODE_DATA_TABLE);
    let modeValues: relationalStore.ValuesBucket[] = this.convertResultToValues(resultSet);
    LogUtil.showInfo(TAG, `copyEl2Data, modes num: ${modeValues.length}`);
    if (modeValues.length <= 0) {
      return 0;
    }
    return await this.batchInsertValue(modeValues);
  }

  async batchInsertValue(modes: relationalStore.ValuesBucket[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsert, modes num: ${modes.length}`);
    if (modes.length <= 0) {
      return 0;
    }
    try {
      let result: number = 0;
      result = await this.rdbStoreHelper.batchInsert(MODE_DATA_TABLE, modes, true);
      LogUtil.showInfo(TAG, `batchInsert inserted row: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchInsert error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 删除指定id的模式数据，并删除该模式下所有配置数据
   *
   * @param modeId 模式id
   * @returns 删除成功返回模式下所有的配置行数
   */
  async batchDeleteModeData(modeIds: string[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchDeleteModeData: ${modeIds.length}`);
    try {
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(MODE_DATA_TABLE);
      predicates.in(DB_CONFIG.MODE_DATA.modeId, modeIds);
      const result: number = await this.rdbStoreHelper.delete(predicates);
      LogUtil.showInfo(TAG, `batchDeleteModeData changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchDeleteModeData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  public convertResultToValuesBucket(resultSet: relationalStore.ResultSet | undefined,): relationalStore.ValuesBucket |
    undefined {
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToValues result is empty');
      return undefined;
    }
    const modeId = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeId));
    const modeName = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeName));
    const iconId = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconId));
    const iconColor = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconColor));
    const updateTime = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.updateTime));
    const createTime = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.createTime));
    const isSupportDelete = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.isSupportDelete)) > 0;
    const priority = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modePriority));
    const filletIconString = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.filletIcon));
    const roundIconString = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.roundIcon));
    const valuesBucket: relationalStore.ValuesBucket = {
      'modeId': modeId,
      'modeName': modeName,
      'iconId': iconId,
      'iconColor': iconColor,
      'filletIcon': filletIconString,
      'roundIcon': roundIconString,
      'modePriority': priority,
      'updateTime': updateTime,
      'createTime': createTime,
      'isSupportDelete': isSupportDelete,
    };
    return valuesBucket;
  }

  private convertResultToValues(resultSet: relationalStore.ResultSet | undefined): relationalStore.ValuesBucket[] {
    let result: relationalStore.ValuesBucket[] = [];
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToValues result is empty');
      return result;
    }
    try {
      while (resultSet.goToNextRow()) {
        let valuesBucket: relationalStore.ValuesBucket | undefined = this.convertResultToValuesBucket(resultSet);
        if (valuesBucket) {
          result.push(valuesBucket);
        }
      }
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.QUERY_FAIL, err?.code, err?.message, 'convertResultToValues');
      LogUtil.showError(TAG, `convertResultToValues error: ${err?.code} ${err?.message}`);
    }
    return result;
  }
}
