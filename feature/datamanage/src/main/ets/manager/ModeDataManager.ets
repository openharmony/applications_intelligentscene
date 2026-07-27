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

import { image } from '@kit.ImageKit';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import relationalStore from '@ohos.data.relationalStore';
import { DB_CONFIG, INVALID_MODE_ID, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { ImageUtil } from '@ohos/scene.common/src/main/ets/utils/ImageUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { ModeData } from '../model/base/ModeModel';
import { DateTimeUtil } from '../utils/DateTimeUtil';
import { ConfigDataManager } from './ConfigDataManager';
import { El1ConfigDataManager } from './El1ConfigDataManager';

const TAG: string = 'ModeDataManager';

const MODE_DATA_TABLE: string = DB_CONFIG.MODE_DATA.TABLE_NAME;
const SQL_QUERY_MODE_COUNT: string = `SELECT COUNT(1) FROM ${MODE_DATA_TABLE}`;
const INTELLIGENT_SCENE_URI: string = 'datashareproxy://com.ohos.intelligentscene';
const MODE_DATA_URI: string = `${INTELLIGENT_SCENE_URI}/phone/IntelligentScene/MODE_DATA_TABLE`;
const ALL_COLUMNS: string[] = ['*'];

export class ModeDataManager {
  protected static instance: ModeDataManager;
  protected rdbStoreHelper: RdbStoreHelper = RdbStoreHelper.getInstance();

  public static getInstance(): ModeDataManager {
    if (ModeDataManager.instance == null) {
      ModeDataManager.instance = new ModeDataManager();
    }
    return ModeDataManager.instance;
  }

  /**
   * 查询模式名称是否在数据库中已存在
   *
   * @param modeName 模式名称
   * @returns 存在返回true
   */
  async isModeNameExists(modeName: string): Promise<boolean> {
    let isExists: boolean = false;
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_DATA_TABLE);
      predicates.contains(DB_CONFIG.MODE_DATA.modeName, modeName);
      resultSet = await this.rdbStoreHelper.query(predicates);
      isExists = resultSet?.rowCount ? resultSet?.rowCount > 0 : false;
    } catch (err) {
      LogUtil.showError(TAG, `isModeNameExists error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return isExists;
  }

  /**
   * 校验当前模式是否包含在已有的所有的情景模式�?
   *
   * @param modeId 模式Id
   * @returns true：包�? false：不包含
   */
  async isModeIdExist(modeId: string): Promise<boolean> {
    LogUtil.showInfo(TAG, 'isModeIdExist. dataShareHelper.query');
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      const dataShareHelper: dataShare.DataShareHelper = await dataShare
        .createDataShareHelper(AbilityContextManager.getContext() as Context, INTELLIGENT_SCENE_URI, { isProxy: true });
      const condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(DB_CONFIG.MODE_DATA.modeId, modeId);
      resultSet = await dataShareHelper.query(MODE_DATA_URI, condition, ALL_COLUMNS);
      if (!resultSet) {
        LogUtil.showInfo(TAG, 'isModeIdExist: resultSet is empty.');
        return false;
      }
      LogUtil.showInfo(TAG, `resultSet row count: ${resultSet.rowCount}`);
      if (resultSet.rowCount > 0) {
        return true;
      }
    } catch (error) {
      LogUtil.showError(TAG, `isModeIdExist catch error. code:${error?.code} message:${error?.message}`);
      const modeData: ModeData | undefined = await this.queryModeDataById(modeId);
      return !CheckEmptyUtils.isEmpty(modeData);
    } finally {
      resultSet?.close();
    }
    return false;
  }

  /**
   * 插入一条模式数�?
   *
   * @param mode 模式数据
   * @returns 插入成功的模式Id; 插入失败返回-1
   */
  async insertModeData(mode: ModeData): Promise<string> {
    LogUtil.showInfo(TAG, `insertModeData id: ${mode.modeId}`);
    try {
      let result: number = 0;
      let modeId: string = INVALID_MODE_ID;
      if (CheckEmptyUtils.checkStrIsEmpty(mode.modeId) || mode.modeId === INVALID_MODE_ID) {
        modeId = DateTimeUtil.getCurrentTimeStamp().toString();
      } else {
        modeId = mode.modeId;
      }
      let filletIconStr: string | undefined = mode.filletIconStr;
      if (!filletIconStr && mode.filletIcon) {
        filletIconStr = await ImageUtil.pixelMapToBase64('image/png', mode.filletIcon);
      }
      let roundIconStr: string | undefined = mode.roundIconStr;
      if (!roundIconStr && mode.roundIcon) {
        roundIconStr = await ImageUtil.pixelMapToBase64('image/png', mode.roundIcon);
      }
      LogUtil.showInfo(TAG,
        `insertModeData. modeId:${modeId} filletIconStr.length:${filletIconStr?.length} roundIconStr.length:${roundIconStr?.length}`);
      const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
      let valuesBucket: relationalStore.ValuesBucket = {
        'modeId': modeId,
        'modeName': mode.modeName,
        'iconId': mode.iconId,
        'iconColor': mode.iconColor,
        'filletIcon': filletIconStr ?? '',
        'roundIcon': roundIconStr ?? '',
        'modePriority': mode?.modePriority ?? 0,
        'updateTime': nowTime,
        'createTime': mode.createTime ?? nowTime,
        'isSupportDelete': mode.isSupportDelete,
      };
      result = await this.rdbStoreHelper.insert(MODE_DATA_TABLE, valuesBucket);
      LogUtil.showInfo(TAG, `insertModeData inserted row: ${result}`);
      return result >= 0 ? modeId : INVALID_MODE_ID;
    } catch (error) {
      LogUtil.showError(TAG, `insertModeData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_MODE_ID;
    }
  }

  /**
   * 查询模式个数
   *
   * @returns 模式个数
   */
  async queryModeCount(): Promise<number> {
    let result: number = 0;
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      resultSet = await this.rdbStoreHelper.querySql(SQL_QUERY_MODE_COUNT);
      while (resultSet?.goToNextRow()) {
        result = resultSet?.getLong(0);
      }
      LogUtil.showInfo(TAG, `queryModeCount: ${result}`);
    } catch (err) {
      LogUtil.showError(TAG, `queryModeCount error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  /**
   * 删除指定id的模式数据，并删除该模式下所有配置数�?
   *
   * @param modeId 模式id
   * @returns 删除成功返回模式下所有的配置行数
   */
  async deleteModeDataById(modeId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteModeDataById: ${modeId}`);
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_DATA_TABLE);
      predicates.equalTo(DB_CONFIG.MODE_DATA.modeId, modeId);
      let result = await this.rdbStoreHelper.delete(predicates);
      if (this.rdbStoreHelper instanceof El1RdbStoreHelper) {
        result = await El1ConfigDataManager.getInstance().deleteConfigDataByModeId(modeId);
      } else {
        result = await ConfigDataManager.getInstance().deleteConfigDataByModeId(modeId);
      }
      LogUtil.showInfo(TAG, `deleteModeDataById changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteModeDataById error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 更新模式数据
   *
   * @param modeData 模式数据
   * @returns 更新成功，返回模式id；更新失败返�?1
   */
  async updateModeData(modeData: ModeData): Promise<string> {
    LogUtil.showInfo(TAG, `updateModeData: ${modeData.modeId}`);
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(MODE_DATA_TABLE);
      let filletIconStr: string | undefined = modeData.filletIconStr;
      if (!filletIconStr && modeData.filletIcon) {
        filletIconStr = await ImageUtil.pixelMapToBase64('image/png', modeData.filletIcon);
      }
      let roundIconStr: string | undefined = modeData.roundIconStr;
      if (!roundIconStr && modeData.roundIcon) {
        roundIconStr = await ImageUtil.pixelMapToBase64('image/png', modeData.roundIcon);
      }
      LogUtil.showInfo(TAG,
        `updateModeData. modeId:${modeData.modeId} filletIconStr.length:${filletIconStr?.length} roundIconStr.length:${roundIconStr?.length}`);
      predicates.equalTo(DB_CONFIG.MODE_DATA.modeId, modeData.modeId);

      const updateValueBucket: relationalStore.ValuesBucket = {
        'modeName': modeData.modeName,
        'iconId': modeData.iconId,
        'iconColor': modeData.iconColor,
        'filletIcon': filletIconStr ?? '',
        'roundIcon': roundIconStr ?? '',
        'modePriority': modeData?.modePriority ?? Number(modeData.modeId),
        'updateTime': DateTimeUtil.getCurrentTimeStamp(),
      };

      let result = await this.rdbStoreHelper.update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateModeData changeRows: ${result}`);
      return result >= 0 ? modeData.modeId : INVALID_MODE_ID;
    } catch (error) {
      LogUtil.showError(TAG, `updateModeData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_MODE_ID;
    }
  }

  /**
   * 更新模式基础数据（不更新filletIcon，roundIcon�?
   *
   * @param modeData 模式数据
   * @returns 更新成功，返回模式id；更新失败返�?1
   */
  async updateModeDataBaseProperty(modeData: ModeData): Promise<string> {
    LogUtil.showInfo(TAG, `updateModeDataBaseProperty: ${modeData.modeId}`);
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(MODE_DATA_TABLE);
      predicates.equalTo(DB_CONFIG.MODE_DATA.modeId, modeData.modeId);

      const updateValueBucket: relationalStore.ValuesBucket = {
        'modeName': modeData.modeName,
        'iconId': modeData.iconId,
        'iconColor': modeData.iconColor,
        'modePriority': modeData?.modePriority ?? Number(modeData.modeId),
        'updateTime': DateTimeUtil.getCurrentTimeStamp(),
      };

      let result = await this.rdbStoreHelper.update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateModeDataBaseProperty changeRows: ${result}`);
      return result >= 0 ? modeData.modeId : INVALID_MODE_ID;
    } catch (error) {
      LogUtil.showError(TAG, `updateModeDataBaseProperty error:${error?.code}, msg: ${error?.message}`);
      return INVALID_MODE_ID;
    }
  }

  /**
   * 查询所有模式数�?
   *
   * @returns 模式数据数组
   */
  async queryAllModeData(): Promise<ModeData[]> {
    let result: ModeData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      resultSet = await this.rdbStoreHelper.queryAll(MODE_DATA_TABLE);
      result = await this.convertResultToModeList(resultSet);
    } catch (err) {
      LogUtil.showError(TAG, `queryAllModeData error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  /**
   * 根据模式id查询模式数据
   *
   * @param modeId 模式id
   * @returns 查询成功返回模式数据；查询失败返回undefined
   */
  async queryModeDataById(modeId: string): Promise<ModeData | undefined> {
    let result: ModeData[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_DATA_TABLE);
      predicates.equalTo(DB_CONFIG.MODE_DATA.modeId, modeId);
      resultSet = await this.rdbStoreHelper.query(predicates);
      result = await this.convertResultToModeList(resultSet);
      if (result.length > 0) {
        return result[0];
      }
    } catch (err) {
      LogUtil.showError(TAG, `queryModeDataById error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return undefined;
  }

  /**
   * 根据模式id查询单模式数�?
   *
   * @param modeId 模式id
   * @returns 查询成功返回模式数据；查询失败返回undefined
   */
  queryModeDataByIdSync(modeId: string): ModeData | undefined {
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(MODE_DATA_TABLE);
      predicates.equalTo(DB_CONFIG.MODE_DATA.modeId, modeId);
      resultSet = this.rdbStoreHelper.querySync(predicates);
      return this.convertResultToModeData(resultSet);
    } catch (err) {
      LogUtil.showError(TAG, `queryModeDataByIdSync error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return undefined;
  }

  protected convertResultToModeData(resultSet: relationalStore.ResultSet | undefined): ModeData | undefined {
    let result: ModeData | undefined = undefined;
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToModeList result is empty');
      return result;
    }
    try {
      while (resultSet.goToNextRow()) {
        const modeId = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeId));
        const modeName = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeName));
        const iconId = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconId));
        const iconColor = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconColor));
        const isSupportDelete = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.isSupportDelete)) > 0;
        result = {
          modeId: modeId,
          modeName: modeName,
          iconId: iconId,
          iconColor: iconColor,
          isSupportDelete: isSupportDelete
        };
      }
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.QUERY_FAIL, err?.code, err?.message, 'convertResultToModeData');
      LogUtil.showError(TAG, `convertResultToModeData error: ${err?.code} ${err?.message}`);
    }
    return result;
  }

  protected async convertResultToModeList(resultSet: relationalStore.ResultSet | undefined): Promise<ModeData[]> {
    let result: ModeData[] = [];
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToModeList result is empty');
      return result;
    }
    try {
      while (resultSet.goToNextRow()) {
        const modeId = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeId));
        const modeName = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeName));
        const iconId = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconId));
        const iconColor = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconColor));
        const updateTime = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.updateTime));
        const createTime = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.createTime));
        const isSupportDelete = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.isSupportDelete)) > 0;
        const priority = resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modePriority));
        const filletIconStr = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.filletIcon));
        const roundIconStr = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.roundIcon));
        result.push({
          modeId,
          modeName,
          iconId,
          iconColor,
          updateTime,
          createTime,
          isSupportDelete,
          modePriority: priority,
          roundIconStr,
          filletIconStr,
        });
      }
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.QUERY_FAIL, err?.code, err?.message, 'convertResultToModeList');
      LogUtil.showError(TAG, `convertResultToModeList error: ${err?.code} ${err?.message}`);
    }
    return result;
  }
}
