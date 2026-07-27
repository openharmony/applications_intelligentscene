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
import type common from '@ohos.app.ability.common';
import { AsyncCallback, BusinessError, Callback } from '@ohos.base';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import rdb from '@ohos.data.relationalStore';
import { SystemParamUtil } from '../utils/SystemParamUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import {
  CLOUD_SYNC_TABLES,
  DB_CONFIG,
  INVALID_DB_VERSION,
  INVALID_VALUE,
  RDB_STORE_CONFIG
} from '../constant/DbConfig';
import { HiSysIntelligentSceneErrorEvent } from '../systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '../systemEvent/EventRsultConstsByTs';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtilsByTs';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { DeviceUtil } from '../utils/DeviceUtil';
import { LogUtil } from '../utils/LogUtil';
import { StringUtil } from '../utils/StringUtil';

export const RDB_CORRUPTION_ERROR_CODE: number = 14800011;
export const GET_RDB_TIME_WARNING: number = 5000;

/**
 * 数据库操作帮助类：包括数据库实例获取、恢复和重置；数据库记录的增删改查.
 */
export class RdbStoreHelper {
  protected static instance: RdbStoreHelper;
  protected tag: string = 'El2RdbStoreHelper :';
  protected rdbStore?: rdb.RdbStore;
  protected dbName: string = DB_CONFIG.DB_NAME;
  protected backupDbName: string = DB_CONFIG.BACKUP_DB_NAME;
  protected area: contextConstant.AreaMode = contextConstant.AreaMode.EL2;
  protected rdbStoreConfig: rdb.StoreConfig = RDB_STORE_CONFIG;

  /**
   * Rdb helper instance
   *
   * @return rdbStoreHelper instance
   */
  public static getInstance(): RdbStoreHelper {
    if (RdbStoreHelper.instance == null) {
      RdbStoreHelper.instance = new RdbStoreHelper();
    }
    return RdbStoreHelper.instance;
  }

  /**
   * 获取关系数据库存储rdbStore句柄对象
   * 如果已初始化过，则直接返回保存的对象；如果没有初始化过，则调用rdb接口获取rdbStore句柄对象
   *
   * @return 关系数据库存储rdbStore句柄对象
   */
  async getRdbStore(): Promise<rdb.RdbStore | undefined> {
    try {
      if (!this.rdbStore) {
        LogUtil.showInfo(this.tag, 'getRdbStore begin');
        const startTime: number = new Date().getTime();
        const context: common.Context | undefined = AbilityContextManager.getContext();
        if (!context) {
          LogUtil.showError(this.tag, `getRdbStore faild. context undefined`);
          return this.rdbStore;
        }
        let areaContext: common.ExtensionContext = AbilityContextManager.getAreaContext(context, this.area);
        this.rdbStore = await rdb.getRdbStore(areaContext, this.rdbStoreConfig);
        const cost: number = new Date().getTime() - startTime;
        LogUtil.showInfo(this.tag, `getRdbStore successfully, rdb version: ${this.rdbStore?.version} cost: ${cost}ms`);
        if (cost > GET_RDB_TIME_WARNING) {
          LogUtil.showWarn(this.tag, `getRdbStore takes long time: ${cost}ms`);
        }
      }
    } catch (error) {
      LogUtil.showError(this.tag, `getRdbStore faild. code: ${error?.code}, message: ${error?.message}`);
    }
    return this.rdbStore;
  }

  async getDbVersion(): Promise<number> {
    let version: number = 0;
    if (!this.rdbStore) {
      await this.getRdbStore();
    }
    try {
      version = this.rdbStore?.version ?? version;
      LogUtil.showInfo(this.tag, `getDbVersion successfully, rdb version: ${version}`);
    } catch (error) {
      LogUtil.showError(this.tag, `getDbVersion faild. code: ${error?.code}, message: ${error?.message}`);
      version = INVALID_DB_VERSION;
    }
    return version;
  }

  async setDbVersion(version: number): Promise<boolean> {
    if (!this.rdbStore) {
      await this.getRdbStore();
    }
    try {
      if (this.rdbStore) {
        this.rdbStore.version = version;
      }
      LogUtil.showInfo(this.tag, `setDbVersion successfully. rdb version: ${this.rdbStore?.version}`);
      return true;
    } catch (error) {
      LogUtil.showError(this.tag, `setDbVersion faild. code: ${error?.code}, message: ${error?.message}`);
    }
    return false;
  }

  async createTables(createSqlArray: string[]): Promise<void> {
    if (CheckEmptyUtils.isEmptyArr(createSqlArray)) {
      LogUtil.showError(this.tag, 'createTables failed. table names array is empty');
      return;
    }
    if (!this.rdbStore) {
      await this.getRdbStore();
    }
    for (let index = 0; index < createSqlArray.length; index++) {
      await this.rdbStore?.executeSql(createSqlArray[index]).catch((error: BusinessError) => {
        LogUtil.showError(this.tag, `createTable ${index} faild. code: ${error?.code}, message: ${error?.message}`);
      });
    }
    LogUtil.showInfo(this.tag, `createTables successfully`);
  }

  /**
   * Context变化，重置rdbStore
   */
  public resetRdbStore(): void {
    this.rdbStore = undefined;
  }

  /**
   * 插入数据
   *
   * @param tableName 表名
   * @param valuesBucket 数据
   * @returns 插入行数
   */
  public async insert(tableName: string, valuesBucket: rdb.ValuesBucket): Promise<number> {
    let context: Context | undefined = AbilityContextManager.getContext();
    if (!context) {
      LogUtil.showWarn(this.tag, 'insert failed, rdbStore undefined');
      return INVALID_VALUE;
    }
    if (!this.rdbStore) {
      await this.getRdbStore();
    }

    try {
      return await this.rdbStore?.insert(tableName, valuesBucket, rdb.ConflictResolution.ON_CONFLICT_REPLACE) ??
        INVALID_VALUE;
    } catch (error) {
      LogUtil.showError(this.tag, `insert error ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'insert');
      }
    }

    return INVALID_VALUE;
  }

  /**
   * 批量插入
   *
   * @param context context上下文
   * @param tableName 表名
   * @param insertBucketList 插入到表中的一组数据
   * @param isReplaceIfExists 已存在相同数据插入时是否替换新数据
   * @returns 返回插入的数据个数
   */
  public async batchInsert(tableName: string, insertBucketList: Array<rdb.ValuesBucket>,
    isReplaceIfExists?: boolean): Promise<number> {
    let context: Context | undefined = AbilityContextManager.getContext();
    if (CheckEmptyUtils.isEmptyArr(insertBucketList) || !context) {
      LogUtil.showWarn(this.tag, 'empty valuesBucket while batchInsert or context undefined');
      return INVALID_VALUE;
    }
    if (!this.rdbStore) {
      await this.getRdbStore();
    }

    try {
      if (isReplaceIfExists) {
        return await this.rdbStore?.batchInsertWithConflictResolution(tableName, insertBucketList,
          rdb.ConflictResolution.ON_CONFLICT_REPLACE) ?? INVALID_VALUE;
      } else {
        return await this.rdbStore?.batchInsert(tableName, insertBucketList) ?? INVALID_VALUE;
      }
    } catch (error) {
      LogUtil.showError(this.tag, `insertBatch error ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'batchInsert');
      }
    }

    return INVALID_VALUE;
  }

  /**
   * 查询某张表所有数据
   *
   * @param tableName 表的名称
   * @return 查询结果集
   */
  public async queryAll(tableName: string): Promise<rdb.ResultSet | undefined> {
    return await this.query(new rdb.RdbPredicates(tableName), []);
  }

  /**
   * 查询某张表所有数据
   *
   * @param tableName 表的名称
   * @return 查询结果集
   */
  public async queryAllByPredicates(predicates: rdb.RdbPredicates): Promise<rdb.ResultSet | undefined> {
    return await this.query(predicates, []);
  }

  /**
   * 同步查询某张表所有数据
   *
   * @param tableName 表的名称
   * @return 查询结果集
   */
  public queryAllByPredicatesSync(predicates: rdb.RdbPredicates): rdb.ResultSet | undefined {
    return this.querySync(predicates, []);
  }

  /**
   * 根据指定条件查询数据
   *
   * @param predicates 查询条件
   * @param columns 字段列表
   * @return 查询结果集
   */
  public async query(predicates: rdb.RdbPredicates, columns?: Array<string>): Promise<rdb.ResultSet | undefined> {
    if (!this.rdbStore) {
      await this.getRdbStore();
    }

    try {
      return await this.rdbStore?.query(predicates, columns);
    } catch (error) {
      LogUtil.showError(this.tag, `query error ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'query');
      }
    }

    return undefined;
  }

  /**
   * 根据指定条件同步查询数据
   *
   * @param predicates 查询条件
   * @param columns 字段列表
   * @return 查询结果集
   */
  public querySync(predicates: rdb.RdbPredicates, columns?: Array<string>): rdb.ResultSet | undefined {
    if (!this.rdbStore) {
      LogUtil.showError(this.tag, 'query error because rdbStore is null');
      return undefined;
    }

    try {
      return this.rdbStore?.querySync(predicates, columns);
    } catch (error) {
      LogUtil.showError(this.tag, `query sync error ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'query');
      }
    }
    return undefined;
  }

  /**
   * 根据指定条件通过data share查询数据
   *
   * @param predicates 查询条件
   * @param columns 字段列表
   * @return 查询结果集
   */
  public async queryByDataShare(uri: string, predicates: dataSharePredicates.DataSharePredicates,
    columns?: Array<string>, callback?: AsyncCallback<Object>): Promise<void> {
    LogUtil.showInfo(this.tag, 'queryByDataShare');
    if (!this.rdbStore) {
      LogUtil.showInfo(this.tag, 'rdbStore is null');
      await this.getRdbStore();
    }
    try {
      const tableName: string = StringUtil.getTableNameFromUri(uri);
      this.rdbStore?.query(tableName, predicates, columns, (err: BusinessError, resultSet: rdb.ResultSet) => {
        if (resultSet.goToFirstRow()) {
          LogUtil.showInfo(this.tag, `query result from datashare: ${resultSet.rowCount} - ${StringUtil.getAnonymizedTableName(tableName)}`);
          callback?.(err, resultSet);
          return;
        } else {
          LogUtil.showWarn(this.tag, `query result from datashare: empty! ${StringUtil.getAnonymizedTableName(tableName)} error:${err?.message}`);
          callback?.(err, INVALID_VALUE);
        }
      });
    } catch (err) {
      LogUtil.showError(this.tag, `query result from datashare: exception. message: ${err?.message}, code: ${err?.code}`);
      callback?.(err, INVALID_VALUE);
    }
  }

  /**
   * 通过 sql 查询数据
   *
   * @param sql 待查询的 sql
   * @returns 查询后的结果集
   */
  public async querySql(sql: string): Promise<rdb.ResultSet | undefined> {
    if (!this.rdbStore) {
      await this.getRdbStore();
    }

    try {
      return await this.rdbStore?.querySql(sql);
    } catch (error) {
      LogUtil.showError(this.tag, `query by sql error: ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'querySql');
      }
    }

    return undefined;
  }

  /**
   * 执行sql语句
   *
   * @param sql  sql语句
   * @returns 查询后的结果集
   */
  public async executeSql(sql: string, bindArgs?: Array<rdb.ValueType>): Promise<void> {
    if (!this.rdbStore) {
      await this.getRdbStore();
    }

    try {
      return await this.rdbStore?.executeSql(sql, bindArgs);
    } catch (error) {
      LogUtil.showError(this.tag, `execute sql error: ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'executeSql');
      }
    }

    return undefined;
  }

  /**
   * 根据条件更新数据库
   *
   * @param predicates 更新条件
   * @param valueBucket 更新的数据
   * @return 受影响的行数
   */
  public async update(predicates: rdb.RdbPredicates, valuesBucket: rdb.ValuesBucket): Promise<number> {
    if (CheckEmptyUtils.isEmpty(valuesBucket)) {
      LogUtil.showWarn(this.tag, 'empty valuesBucket while update or rdbStore undefined');
      return INVALID_VALUE;
    }

    if (!this.rdbStore) {
      await this.getRdbStore();
    }

    try {
      return await this.rdbStore?.update(valuesBucket, predicates) ?? INVALID_VALUE;
    } catch (error) {
      LogUtil.showError(this.tag, `update failed, message: ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'update');
      }
    }
    return INVALID_VALUE;
  }

  /**
   * 根据条件删除数据
   *
   * @param rdbStore 数据库存储对象
   * @param predicates 删除条件
   * @return 受影响的行数
   */
  public async delete(predicates?: rdb.RdbPredicates): Promise<number> {
    if (CheckEmptyUtils.isEmpty(predicates)) {
      LogUtil.showWarn(this.tag, 'empty predicates while delete or rdbStore undefined');
      return INVALID_VALUE;
    }

    if (!this.rdbStore) {
      await this.getRdbStore();
    }

    try {
      this.rdbStore?.beginTransaction();
      const result: number = await this.rdbStore?.delete(predicates) ?? INVALID_VALUE;
      this.rdbStore?.commit();
      return result;
    } catch (error) {
      LogUtil.showError(this.tag, `delete error: ${error?.message}, code: ${error?.code}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.SELF_DAMAGE, error?.code, error?.message, 'delete');
      }
      try {
        this.rdbStore?.rollBack();
      } catch (error) {
        LogUtil.showError(this.tag, `delete rollback error: ${error?.message}, code: ${error?.code}`);
      }
    }

    return INVALID_VALUE;
  }

  /**
   * 根据指定名称的数据表所有数据
   *
   * @param tableName 数据库表名称
   * @return 受影响的行数
   */
  public async deleteTableData(tableName: string): Promise<number> {
    const predicates = new rdb.RdbPredicates(tableName);
    return await this.delete(predicates);
  }

  public async setCloudSyncTables(tableNames: string[], isSyncOn?: boolean): Promise<void> {
    if (DeviceUtil.isWearable()) {
      LogUtil.showInfo(this.tag, 'wearable no need setCloudSyncTables');
      return;
    }

    if (!SystemParamUtil.isSupportIntelligentScene()) {
      LogUtil.showInfo(this.tag, 'device no need setCloudSyncTables');
      return;
    }

    if (!this.rdbStore) {
      LogUtil.showError(this.tag, 'setCloudSyncTables fail, rdbStore is undefined');
      return;
    }
    const config: rdb.DistributedConfig = {
      autoSync: isSyncOn ?? true
    };

    try {
      if (this.rdbStore.version <= 0) {
        LogUtil.showError(this.tag, 'not setCloudSyncTables, database has no tables');
        return;
      }
      await this.rdbStore?.setDistributedTables(tableNames, rdb.DistributedType.DISTRIBUTED_CLOUD, config);
      LogUtil.showInfo(this.tag, `setCloudSyncTables success, sync on: ${isSyncOn}`);
    } catch (err) {
      LogUtil.showError(this.tag, `setCloudSyncTables fail, code is ${err?.code},message is ${err?.message}`);
    }
  }

  public subscribeCloudDataChange(isOn: boolean, callback: Callback<rdb.ChangeInfo[]>): void {
    LogUtil.showInfo(this.tag, 'subscribeCloudDataChange');
    if (this.rdbStore) {
      this.subscribeDataChange(isOn, rdb.SubscribeType.SUBSCRIBE_TYPE_CLOUD_DETAILS, callback);
    } else {
      this.getRdbStore().then(()=> {
        this.subscribeDataChange(isOn, rdb.SubscribeType.SUBSCRIBE_TYPE_CLOUD_DETAILS, callback);
      });
    }
  }

  public syncCloudChangeData(progressCallback: Callback<rdb.ProgressDetails>): void {
    LogUtil.showInfo(this.tag, 'syncCloudChangeData');
    this.cloudSyncByType(rdb.SyncMode.SYNC_MODE_TIME_FIRST, progressCallback);
  }

  public async cleanDirtyData(tableName: string, cursor?: number): Promise<boolean> {
    LogUtil.showInfo(this.tag, `cleanDirtyData ${StringUtil.getAnonymizedTableName(tableName)} cursor: ${cursor}`);
    if (!this.rdbStore) {
      await this.getRdbStore();
    }
    if (!this.rdbStore) {
      return false;
    }
    let isSuccess: boolean = false;
    try {
      if (cursor) {
        await this.rdbStore.cleanDirtyData(tableName, cursor);
      } else {
        await this.rdbStore.cleanDirtyData(tableName);
      }
      isSuccess = true;
      LogUtil.showInfo(this.tag, `cleanDirtyData ${StringUtil.getAnonymizedTableName(tableName)} successful`);
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.CLEAN_DIRTY_DATA, err?.code, err?.message, 'cleanDirtyData');
      LogUtil.showError(this.tag, `cleanDirtyData fail, code is ${err?.code},message is ${err?.message}`);
    }
    return isSuccess;
  }

  private subscribeDataChange(isOn: boolean, type: rdb.SubscribeType, callback: Callback<rdb.ChangeInfo[]>): void {
    LogUtil.showInfo(this.tag, `subscribeDataChange is on: ${isOn} type: ${type}`);
    try {
      if (isOn) {
        this.rdbStore?.on('dataChange', type, callback);
      } else {
        this.rdbStore?.off('dataChange', type, callback);
      }
      LogUtil.showInfo(this.tag, `subscribeDataChange is on: ${isOn} success`);
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.LISTEN_CHANGE, err?.code, err?.message, 'subscribeDataChange');
      LogUtil.showError(this.tag, `subscribeDataChange fail, code is ${err?.code},message is ${err?.message}`);
    }
  }

  public async backupRdbStore(): Promise<void> {
    LogUtil.showInfo(this.tag, 'start backup rdb');
    if (!this.rdbStore) {
      await this.getRdbStore();
    }
    try {
      await this.rdbStore?.backup(this.backupDbName);
      LogUtil.showInfo(this.tag, 'rdb backup success');
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.BACKUP_FAIL, err?.code, err?.message, 'backupRdbStore');
      LogUtil.showError(this.tag, `rdb backup faild. code: ${err?.code}, message: ${err?.message}`);
    }
  }

  public async restoreRdb(): Promise<void> {
    LogUtil.showInfo(this.tag, 'start restore rdb');
    if (!this.rdbStore) {
      await this.getRdbStore();
    }
    try {
      await this.rdbStore?.restore(this.backupDbName);
      LogUtil.showInfo(this.tag, 'rdb restore success');
    } catch (err) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.RESTORE_FAIL, err?.code, err?.message, 'restoreRdb');
      LogUtil.showError(this.tag, `rdb restore faild. code: ${err?.code}, message: ${err?.message}`);
    }
  }

  private cloudSyncByType(type: rdb.SyncMode, progressCallback: Callback<rdb.ProgressDetails>): void {
    LogUtil.showInfo(this.tag, 'start cloudSync');
    try {
      if (this.rdbStore) {
        this.rdbStore.cloudSync(type, progressCallback);
      } else {
        this.getRdbStore().then(()=> {
          this.rdbStore?.cloudSync(type, progressCallback);
        });
      }
    } catch (err) {
      LogUtil.showError(this.tag, `cloudSync fail, code is ${err?.code},message is ${err?.message}`);
    }
  }

}
