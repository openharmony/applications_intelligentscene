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
import { relationalStore } from '@kit.ArkData';
import { BASE_TABLE_NAMES, INVALID_DB_VERSION } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { RDB_CORRUPTION_ERROR_CODE, RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { RawFileUtil } from '@ohos/scene.common/src/main/ets/utils/RawFileUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { UpgradeManager } from './UpgradeManager';
import { PHONE_UPGRADE_CONFIGS, UpgradeConfig } from '../upgrade/UpgradeConfig';

const TAG: string = 'DbBaseManager';
const SQLITE_MASTER_TABLE: string = 'sqlite_master';
const NO_NEED_EXECUTE_SQL: string = 'NO_NEED_EXECUTE_SQL';
const NEED_RETRY_ERRCODE: number[] = [14800024, 14800025, 14800015];
const MAX_RETRY_NUMBER: number = 3;

export enum UpgradeState {
  UPGRADE_FAIL = 0,
  UPGRADE_SUCCESS = 1,
  UPGRADE_FROM_BASE_VERSION = 2,
  NO_NEED_UPGRADE = 3
}

// 升级脚本
export class DbUpgradeRecord {
  public version: number = 0;
  public scripts: string[] = [];
}

export class DbUpgrade {
  public latestVersion: number = 0;
  public upgrades: DbUpgradeRecord[] = [];
}

export class DbBaseManager {
  /**
   * 数据库结构升级和数据初始化
   *
   * @returns 升级结果
   */
  static async initDatabase(upgradeConfigs?: UpgradeConfig[]): Promise<UpgradeState[]> {
    LogUtil.showInfo(TAG, 'init database');
    let result: UpgradeState[] = [];
    for (let config of (upgradeConfigs ?? PHONE_UPGRADE_CONFIGS)) {
      let upgradeResult: UpgradeState = await DbBaseManager.initAreaDatabase(config);
      result.push(upgradeResult);
      LogUtil.showInfo(TAG, `init database, EL${config.area} upgrade result: ${upgradeResult}`);
    }
    return result;
  }

  static async initAreaDatabase(config: UpgradeConfig): Promise<UpgradeState> {
    let upgrades: DbUpgrade | undefined = await DbBaseManager.loadUpgrades(config.scriptsPath);
    const latestVersion: number = upgrades?.latestVersion ?? 0;
    if (!upgrades || latestVersion === 0) {
      LogUtil.showError(TAG, `initDatabase ${config.area} failed, upgrade config is empty`);
      return UpgradeState.UPGRADE_FAIL;
    }

    let currentVersion: number = await config.getRdbStore().getDbVersion();
    LogUtil.showInfo(TAG, `initDatabase ${config.area} version: ${currentVersion} latestVersion: ${latestVersion}`);
    if (currentVersion === INVALID_DB_VERSION) {
      return UpgradeState.UPGRADE_FAIL;
    }
    if (config.area === contextConstant.AreaMode.EL2 && await DbBaseManager.isDbBaseTableMiss()) {
      // 查询基础表是否存在，如果数据表缺失，走一遍升级逻辑
      LogUtil.showInfo(TAG, `initDatabase ${config.area} Base table not exist, need upgrade`);
      await DbBaseManager.upgradeDb(config, upgrades.upgrades, 0, latestVersion);
      return UpgradeState.UPGRADE_FROM_BASE_VERSION;
    }
    if (currentVersion >= latestVersion) {
      LogUtil.showInfo(TAG, `initDatabase ${config.area}, not need upgrade`);
      return UpgradeState.NO_NEED_UPGRADE;
    }

    if (currentVersion > 0) {
      await config.getRdbStore().backupRdbStore();
    }
    const isUpgrade: boolean =
      await DbBaseManager.upgradeDb(config, upgrades.upgrades, currentVersion, latestVersion);
    return isUpgrade ? UpgradeState.UPGRADE_SUCCESS : UpgradeState.UPGRADE_FAIL;
  }

  static async isDbBaseTableMiss(): Promise<boolean> {
    let tableNames: string[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(SQLITE_MASTER_TABLE);
      predicates.equalTo('type', 'table');
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'query tables: resultSet is empty.');
        return true;
      }
      while (resultSet.goToNextRow()) {
        tableNames.push(resultSet.getString(resultSet.getColumnIndex('name')));
      }
      LogUtil.showInfo(TAG, `query tables len: ${tableNames.length}`);
      return DbBaseManager.isBaseTableMiss(tableNames);
    } catch (err) {
      LogUtil.showError(TAG, `query tables error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return DbBaseManager.isBaseTableMiss(tableNames);
  }

  static isBaseTableMiss(tableNames: string[]): boolean {
    if (tableNames.length === 0) {
      return true;
    }
    let isMiss: boolean = false;
    for (let tableName of BASE_TABLE_NAMES) {
      if (!tableNames.includes(tableName)) {
        isMiss = true;
        LogUtil.showInfo(TAG, `${StringUtil.getAnonymizedTableName(tableName)} table not exist`);
      }
    }
    return isMiss;
  }

  static async loadUpgrades(fileName: string): Promise<DbUpgrade | undefined> {
    try {
      LogUtil.showInfo(TAG, 'loadUpgrades');
      let rawContent: string = await RawFileUtil.getStringByFile(
        AbilityContextManager.getContext()?.resourceManager, fileName);
      LogUtil.showInfo(TAG, 'getStringByFile success');
      const dbUpgrade: DbUpgrade = JsonUtil.fromJson(rawContent) as DbUpgrade;
      LogUtil.showInfo(TAG, 'fromJson success');
      return dbUpgrade;
    } catch (err) {
      LogUtil.showError(TAG, `Failed to load upgrades: ${err?.code} ${err?.message}`);
      return undefined;
    }
  }

  static async upgradeDb(config: UpgradeConfig, upgrades: DbUpgradeRecord[], oldVersion: number,
    newVersion: number): Promise<boolean> {
    if (CheckEmptyUtils.isEmptyArr(upgrades)) {
      LogUtil.showError(TAG, 'Upgrade fail, record is empty');
      return false;
    }
    let rdbHelper: RdbStoreHelper = config.getRdbStore();
    let upgradedVersion: number = oldVersion;
    const pendingUpgrades: DbUpgradeRecord[] = upgrades
      .filter(u => (u.version > oldVersion && u.version <= newVersion))
      .sort((a, b) => (a.version - b.version));
    let store: relationalStore.RdbStore | undefined = await rdbHelper.getRdbStore();
    if (!store) {
      LogUtil.showError(TAG, 'Upgrade fail ,rdbStore is undefined');
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.RDB_ERROR, FaultSubScene.UPDATE_FAIL, '', '', 'upgradeDb', 'rdbUndefined');
      return false;
    }

    for (const upgrade of pendingUpgrades) {
      let isUpgradeSuccess: boolean = await DbBaseManager.upgradeDbSchema(upgrade, store);
      if (!isUpgradeSuccess) {
        LogUtil.showError(TAG, `Upgrade db schema ${upgrade.version} failed, updated to ${upgradedVersion}`);
        return upgradedVersion === newVersion;
      }
      isUpgradeSuccess = await UpgradeManager.upgradeData(config, upgrade.version);
      if (!isUpgradeSuccess) {
        LogUtil.showError(TAG, `Upgrade data ${upgrade.version} failed, updated to ${upgradedVersion}`);
        return upgradedVersion === newVersion;
      }
      try {
        store.version = upgrade.version;
        upgradedVersion = upgrade.version;
        LogUtil.showInfo(TAG, `Upgrade to version ${upgradedVersion} successful`);
      } catch (err) {
        if (err?.code === RDB_CORRUPTION_ERROR_CODE) {
          await rdbHelper.restoreRdb();
        }
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.UPDATE_FAIL, err?.code, err?.message, 'setDbVersion');
        LogUtil.showError(TAG, `Upgrade version ${upgrade.version} failed: ${err?.code} ${err?.message}`);
        return upgradedVersion === newVersion;
      }
    }
    if (await rdbHelper.setDbVersion(newVersion)) {
      upgradedVersion = newVersion;
    }
    LogUtil.showInfo(TAG, `Upgrade successful count: ${pendingUpgrades.length} version: ${upgradedVersion}`);
    return upgradedVersion === newVersion;
  }

  static async upgradeDbSchema(upgrade: DbUpgradeRecord, store: relationalStore.RdbStore): Promise<boolean> {
    let transaction: relationalStore.Transaction | undefined = undefined;
    for (let attempt = 1; attempt <= MAX_RETRY_NUMBER; attempt++) {
      try {
        transaction = await store.createTransaction();
        for (const sql of upgrade.scripts) {
          if (sql === NO_NEED_EXECUTE_SQL) {
            continue;
          }
          await transaction.execute(sql);
        }
        await transaction.commit();
        return true;
      } catch (err) {
        LogUtil.showError(TAG, `execute sql transaction failed: ${err?.code} ${err?.message}, attempt ${attempt}`);
        await transaction?.rollback();
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
          FaultScene.RDB_ERROR, FaultSubScene.UPDATE_FAIL, err?.code, err?.message, 'upgradeDbSchema',
          `attemptTimes:${attempt}`);
        if (!NEED_RETRY_ERRCODE.includes(err?.code)) {
          return false;
        }
      }
    }
    return false;
  }
}
