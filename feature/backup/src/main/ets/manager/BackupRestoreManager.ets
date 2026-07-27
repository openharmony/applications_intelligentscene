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

import fs from '@ohos.file.fs';
import preferences from '@ohos.data.preferences';
import { BackupExtensionContext } from '@kit.CoreFileKit';
import relationalStore from '@ohos.data.relationalStore';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { DebounceUtil } from '@ohos/scene.common/src/main/ets/utils/DebounceUtil';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { SearchUtil } from '@ohos/scene.common/src/main/ets/utils/SearchUtil';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { StaticSubscriberUtil } from '@ohos/scene.common/src/main/ets/utils/StaticSubscriberUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { DB_CONFIG, RDB_STORE_CONFIG } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PRIVATE_STATEMENT_STATUS } from '@ohos/scene.common/src/main/ets/utils/PrivacyStatementUtil';
import { PreferencesUtil, APP_CONFIG } from '@ohos/scene.common/src/main/ets/utils/PreferencesUtil';
import { ConfigConstant } from '@ohos/scene.common/src/main/ets/constant/ConfigConstant';
import { SubscriberConstant } from '@ohos/scene.common/src/main/ets/constant/SubscriberConstant';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { PhoneEl2Adapter } from '@ohos/scene.datamanage/src/main/ets/upgrade/PhoneEl2Adapter';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType} from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { CurrentOpenedMode } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeType, ModeSearchName } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { El1CallConfigManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1CallConfigManager';
import {
  BACKUP_RESTORE_TABLES,
  BACK_UP_PREFERENCES_NAME,
  BACK_UP_PREFERENCES_PATH,
  INTELLIGENT_SCENE_BACKUP_DB,
  INTELLIGENT_SCENE_BACKUP_DB_SHM,
  INTELLIGENT_SCENE_BACKUP_DB_WAL,
  INTELLIGENT_SCENE_DB,
  INTELLIGENT_SCENE_DB_PATH,
  INTELLIGENT_SCENE_DB_SHM,
  INTELLIGENT_SCENE_DB_WAL,
  RESTORE_DIR,
  RESTORE_FAIL,
  RESTORE_SUCCESS,
  UI_REFRESH_MSG_KEY,
} from '../constant/BackupRestoreConstant';

/* instrument ignore file */
const TAG: string = 'BackupRestoreManager: ';
const NEED_TRANSFER_PREFERENCES: string[] = [
  PRIVATE_STATEMENT_STATUS
];
const TIME_DELAY: number = 2000;
const REFRESH_UI_DELAY: number = 50;

export class BackupRestoreManager {
  private static instance?: BackupRestoreManager;

  public static getInstance(): BackupRestoreManager {
    if (!BackupRestoreManager.instance) {
      BackupRestoreManager.instance = new BackupRestoreManager();
    }
    return BackupRestoreManager.instance;
  }

  public async transferDbFile(): Promise<void> {
    try {
      LogUtil.showInfo(TAG, 'transferDbFile');
      fs.copyFileSync(INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_DB,
        INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB);
      fs.copyFileSync(INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_DB_SHM,
        INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_SHM);
      fs.copyFileSync(INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_DB_WAL,
        INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_WAL);
    } catch (err) {
      LogUtil.showError(TAG, `transferDbFile errCode: ${err?.code}, errMessage: ${err?.message}`);
    }
  }

  public async restoreDb(context: BackupExtensionContext): Promise<number> {
    let intelligenceSceneEnabled: string = SystemParamUtil.getParam(ConfigConstant.CONST_INTELLIGENT_SCENE_ENABLE, '');
    LogUtil.showInfo(TAG, `restoreDb intelligenceSceneEnabled: ${intelligenceSceneEnabled}`);
    if (intelligenceSceneEnabled !== 'true') {
      return RESTORE_SUCCESS;
    }
    this.doReadCloneRdb(context);
    let isSupportBackup: boolean = this.copyBackupDbFile2RestoreDir(context);
    if (!isSupportBackup) {
      LogUtil.showWarn(TAG, 'old device not support backup');
      return RESTORE_SUCCESS;
    }
    let coverResult: number = await this.coverRdbData(context);
    SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.IS_UI_APPEARANCE_FROM_CLONE, 'true');
    SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_CLONE_TIME, `${new Date().getTime()}`);
    this.clearBackupFile();
    return coverResult;
  }

  public clearBackupFile(): void {
    try {
      LogUtil.showInfo(TAG, 'start clear backup');
      fs.unlinkSync(INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB);
      fs.unlinkSync(INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_SHM);
      fs.unlinkSync(INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_WAL);
    } catch (err) {
      LogUtil.showError(TAG, `clearBackupFile errCode: ${err?.code}, errMessage: ${err?.message}`);
    }
  }

  public async coverRdbData(context: BackupExtensionContext): Promise<number> {
    let rdbStore: relationalStore.RdbStore | undefined = await this.getRdbStore(context);
    try {
      let restoreRdbStore: relationalStore.RdbStore | undefined = await this.getBackupRestoreRdbStore(context);
      if (!rdbStore || !restoreRdbStore) {
        LogUtil.showError(TAG, 'coverRdbData rdbStore or restoreRdbStore is empty');
        return RESTORE_FAIL;
      }
      // 克隆时 旧设备备份表增加 roundIcon字段
      const isAlterRoundIcon: boolean = await this.isBackDbAlterRoundIcon(restoreRdbStore);
      LogUtil.showInfo(TAG, `isAlterRoundIcon ${isAlterRoundIcon}`);
      let modeDataResult: relationalStore.ValuesBucket[] = await this.queryAllModeData(restoreRdbStore);
      if (modeDataResult.length <= 0) {
        LogUtil.showWarn(TAG, 'mode data is invalid, no coverRdbData');
        return RESTORE_SUCCESS;
      }
      await this.processStopScene(modeDataResult);
      rdbStore.beginTransaction();
      await this.processTableData(rdbStore, restoreRdbStore, modeDataResult);
      rdbStore.commit();
      if (isAlterRoundIcon) {
        await PhoneEl2Adapter.generateRoundIcon();
      }
      await this.restorePreferencesIfNeed(context);
      await PhoneEl2Adapter.splitIntelligentExperienceSwitch();
      StaticSubscriberUtil.publishEvent(SubscriberConstant.ACTION_CLONE_FINISHED);
      const isModeIdExist: boolean = await El1ModeDataManager.getInstance().isModeIdExist(ModeType.WORKING_MODE);
      SearchUtil.handleSearchItem([ModeSearchName.WORKING_MODE], isModeIdExist);
      await this.refreshUIDelay();
      LogUtil.showInfo(TAG, 'coverRdbData success');
      return RESTORE_SUCCESS;
    } catch (e) {
      try {
        rdbStore?.rollBack();
      } catch (err) {
        LogUtil.showError(TAG, ` rollback error: ${err?.message}, code: ${err?.code}`);
      }
      LogUtil.showError(TAG, `restoreDb errCode: ${e?.code}, errMessage: ${e?.message}`);
      return RESTORE_FAIL;
    }
  }

  private async processStopScene(modeDataResult: relationalStore.ValuesBucket[]): Promise<void> {
    let configData: ConfigData | undefined = await ConfigDataManager.getInstance()
      .queryConfigDataById(ConfigType.CURRENT_OPENED_MODE.toString());
    let openMode: CurrentOpenedMode = JsonUtil.fromJson(configData?.configValue) as CurrentOpenedMode;
    LogUtil.showInfo(TAG, `current mode: ${openMode?.modeId}`);
    const isStopScene: boolean = await this.isStopScene(openMode);
    if (isStopScene) {
      await DebounceUtil.sleep(TIME_DELAY);
    }
    if (isStopScene && this.isModeDelete(openMode.modeId, modeDataResult)) {
      // 关闭的模式被删除后 需要处理控制中心数据
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, NO_SCENE);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, NO_SCENE);
    }
  }

  private async processTableData(rdbStore: relationalStore.RdbStore, restoreRdbStore: relationalStore.RdbStore,
    modeDataResult: relationalStore.ValuesBucket[]): Promise<void> {
    for (let tableName of BACKUP_RESTORE_TABLES) {
      let predicates = new relationalStore.RdbPredicates(tableName);
      try {
        rdbStore.deleteSync(predicates);
      } catch (e) {
        LogUtil.showError(TAG, `delete exception, ${StringUtil.getAnonymizedTableName(tableName)}, ${e?.code}, ${e?.message}`);
        continue;
      }
      switch (tableName) {
        case DB_CONFIG.MODE_DATA.TABLE_NAME:
          await this.patchInsertModeData(rdbStore, modeDataResult, tableName);
          break;
        case DB_CONFIG.CONFIG_DATA.TABLE_NAME:
          let configDataResult: relationalStore.ValuesBucket[] = await this.queryAllConfigData(restoreRdbStore);
          if (configDataResult && configDataResult.length > 0) {
            await this.patchInsertModeConfigData(rdbStore, tableName, configDataResult);
          }
          break;
        case DB_CONFIG.CONTACT_DATA.TABLE_NAME:
          let result: relationalStore.ValuesBucket[] = await this.queryAllContactData(restoreRdbStore);
          if (result && result.length > 0) {
            await rdbStore.batchInsert(tableName, result);
          }
          break;
        case DB_CONFIG.LEARNING_PLAN.TABLE_NAME:
          let learnData: relationalStore.ValuesBucket[] = await this.queryAllLearnPlanData(restoreRdbStore);
          if (learnData && learnData.length > 0) {
            await rdbStore.batchInsert(tableName, learnData);
          }
          break;
        default:
          break;
      }
    }
  }

  private async patchInsertModeData(rdbStore: relationalStore.RdbStore,
    modeDataResult: relationalStore.ValuesBucket[], tableName: string): Promise<void> {
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      await rdbStore.batchInsert(tableName, modeDataResult);
      resultSet = await El1RdbStoreHelper.getInstance().queryAll(DB_CONFIG.MODE_DATA.TABLE_NAME);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'patchInsertModeData resultSet is empty');
        return;
      }
      while (resultSet.goToNextRow()) {
        const modeId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeId));
        if (!ModeConfigAdapter.getInstance().getConfigByModeId(modeId).isSupportCloudSync) {
          let valuesBucket: relationalStore.ValuesBucket | undefined =
            El1ModeDataManager.getInstance().convertResultToValuesBucket(resultSet);
          if (valuesBucket) {
            modeDataResult.push(valuesBucket);
          }
        }
      }
    } catch (error) {
      LogUtil.showError(TAG, `restoreDb errCode: ${error?.code}, errMessage: ${error?.message}`);
    } finally {
      resultSet?.close();
    }
    await El1RdbStoreHelper.getInstance().deleteTableData(DB_CONFIG.MODE_DATA.TABLE_NAME);
    await El1ModeDataManager.getInstance().batchInsertValue(modeDataResult);
  }

  private async patchInsertModeConfigData(rdbStore: relationalStore.RdbStore, tableName: string,
    configDataResult: relationalStore.ValuesBucket[]): Promise<void> {
    let resultSet: relationalStore.ResultSet | undefined;
    let el1ValuesBuckets: relationalStore.ValuesBucket[] = [];
    try {
      await rdbStore.batchInsert(tableName, configDataResult);
      resultSet = await El1RdbStoreHelper.getInstance().queryAll(DB_CONFIG.CONFIG_DATA.TABLE_NAME);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'patchInsertModeConfigData resultSet is empty');
        return;
      }
      while (resultSet.goToNextRow()) {
        const modeId: string = resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.modeId));
        if (!ModeConfigAdapter.getInstance().getConfigByModeId(modeId).isSupportCloudSync) {
          let valuesBucket: relationalStore.ValuesBucket | undefined =
            El1ConfigDataManager.getInstance().convertResultToValueBucket(resultSet);
          if (valuesBucket) {
            el1ValuesBuckets.push(valuesBucket);
          }
        }
      }
    } catch (error) {
      LogUtil.showError(TAG, `restoreDb errCode: ${error?.code}, errMessage: ${error?.message}`);
    } finally {
      resultSet?.close();
    }
    await El1RdbStoreHelper.getInstance().deleteTableData(DB_CONFIG.CONFIG_DATA.TABLE_NAME);
    await El1CallConfigManager.batchInsertCallConfigValues(configDataResult);
    if (el1ValuesBuckets.length > 0) {
      await El1ConfigDataManager.getInstance().batchInsertConfigByValueBuckets(el1ValuesBuckets);
    }
  }

  public async refreshUIDelay(): Promise<void> {
    await DebounceUtil.sleep(REFRESH_UI_DELAY);
    SettingsDataUtils.setSecureValue(UI_REFRESH_MSG_KEY, EventBusNameConstant.DB_MODE_DATA_REFRESH);
    await DebounceUtil.sleep(REFRESH_UI_DELAY);
    SettingsDataUtils.setSecureValue(UI_REFRESH_MSG_KEY, EventBusNameConstant.DB_CONFIG_DATA_REFRESH);
    await DebounceUtil.sleep(REFRESH_UI_DELAY);
    SettingsDataUtils.setSecureValue(UI_REFRESH_MSG_KEY, EventBusNameConstant.DB_CONTACT_DATA_REFRESH);
  }

  public async isStopScene(openMode: CurrentOpenedMode): Promise<boolean> {
    if (openMode === undefined || openMode.modeId === ModeType.NO_MODE || openMode.modeId === INVALID_MODE_ID) {
      return false;
    }
    if (!ModeConfigAdapter.getInstance().getConfigByModeId(openMode.modeId).isSupportCloudSync) {
      LogUtil.showWarn(TAG, 'current mode is not support sync, no need to stop scene.');
      return false;
    }
    StaticSubscriberUtil.publishEvent(SubscriberConstant.ACTION_STOP_SCENE);
    return true;
  }

  public isModeDelete(modeId: string, modeDataResult: relationalStore.ValuesBucket[]): boolean {
    return modeDataResult.filter(item => item['modeId'] === modeId).length === 0;
  }

  public async isBackDbAlterRoundIcon(restoreRdbStore: relationalStore.RdbStore): Promise<boolean> {
    try {
      if (!restoreRdbStore) {
        LogUtil.showError(TAG, 'restoreRdbStore is undefined');
        return false;
      }
      await restoreRdbStore.executeSql('ALTER TABLE MODE_DATA_TABLE ADD COLUMN roundIcon TEXT;');
    } catch (error) {
      LogUtil.showError(TAG, `isBackDbAlterRoundIcon faild. code: ${error?.code}, message: ${error?.message}`);
      return false;
    }
    return true;
  }

  public async queryAllModeData(rdbStore: relationalStore.RdbStore): Promise<relationalStore.ValuesBucket[]> {
    let result: relationalStore.ValuesBucket[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(DB_CONFIG.MODE_DATA.TABLE_NAME);
      resultSet = await rdbStore.query(predicates);
      result = this.resultSet2ModeDataValuesBuckets(resultSet);
    } catch (e) {
      LogUtil.showError(TAG, `queryAllModeData errCode: ${e?.code}, errMessage: ${e?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  public async queryAllConfigData(rdbStore: relationalStore.RdbStore): Promise<relationalStore.ValuesBucket[]> {
    let result: relationalStore.ValuesBucket[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(DB_CONFIG.CONFIG_DATA.TABLE_NAME);
      resultSet = await rdbStore.query(predicates);
      result = this.resultSet2ConfigDataValuesBuckets(resultSet);
    } catch (e) {
      LogUtil.showError(TAG, `queryAllConfigData errCode: ${e?.code}, errMessage: ${e?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  public async queryAllLearnPlanData(rdbStore: relationalStore.RdbStore): Promise<relationalStore.ValuesBucket[]> {
    let result: relationalStore.ValuesBucket[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(DB_CONFIG.LEARNING_PLAN.TABLE_NAME);
      resultSet = await rdbStore.query(predicates);
      result = this.resultSet2LearnPlanValuesBuckets(resultSet);
    } catch (e) {
      LogUtil.showError(TAG, `queryAllLearnPlanData error ${e?.code}, ${e?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  public async queryAllContactData(rdbStore: relationalStore.RdbStore): Promise<relationalStore.ValuesBucket[]> {
    let result: relationalStore.ValuesBucket[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
      resultSet = await rdbStore.query(predicates);
      result = this.resultSet2ContactDataValuesBuckets(resultSet);
    } catch (e) {
      LogUtil.showError(TAG, `queryAllContactData error ${e?.code}, ${e?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  public copyBackupDbFile2RestoreDir(context: BackupExtensionContext): boolean {
    try {
      fs.copyFileSync(context.backupDir + RESTORE_DIR + INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB,
        INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB);
      fs.copyFileSync(context.backupDir + RESTORE_DIR + INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_SHM,
        INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_SHM);
      fs.copyFileSync(context.backupDir + RESTORE_DIR + INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_WAL,
        INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB_WAL);
      LogUtil.showInfo(TAG, 'doCopyDirCloneRDB copy directory succeed');
      return true;
    } catch (e) {
      LogUtil.showError(TAG, `doCopyDirCloneRDB copy directory failed with error message: ${e?.message}, ${e?.code}`);
      return false;
    }
  }

  private doReadCloneRdb(context: BackupExtensionContext): void {
    try {
      let stat = fs.statSync(context.backupDir + RESTORE_DIR + INTELLIGENT_SCENE_DB_PATH + INTELLIGENT_SCENE_BACKUP_DB);
      LogUtil.showInfo(TAG, `doReadCloneRdb ${stat.size}`);
    } catch (e) {
      LogUtil.showError(TAG, `doReadCloneRdb errCode: ${e?.code}, errMessage: ${e?.message}`);
    }
  }

  public async getBackupRestoreRdbStore(context: BackupExtensionContext):
    Promise<relationalStore.RdbStore | undefined> {
    try {
      return await relationalStore.getRdbStore(context, {
        name: INTELLIGENT_SCENE_BACKUP_DB,
        securityLevel: relationalStore.SecurityLevel.S1,
      });
    } catch (error) {
      LogUtil.showError(TAG, `getBackupRestoreRdbStore error, ${error?.code}, ${error?.message}`);
      return undefined;
    }
  }

  public async getRdbStore(context: BackupExtensionContext): Promise<relationalStore.RdbStore | undefined> {
    try {
      return await relationalStore.getRdbStore(context, RDB_STORE_CONFIG);
    } catch (e) {
      LogUtil.showError(TAG, `getRdbStore error, ${e?.code}, ${e?.message}`);
      return undefined;
    }
  }

  private resultSet2ConfigDataValuesBuckets(resultSet: relationalStore.ResultSet): relationalStore.ValuesBucket[] {
    let configDataList: relationalStore.ValuesBucket[] = [];
    try {
      while (resultSet.goToNextRow()) {
        let item: relationalStore.ValuesBucket = {
          'configId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configId)),
          'modeId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.modeId)),
          'configType': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configType)),
          'configValue': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configValue)),
          'updateTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.updateTime)),
          'createTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.createTime)),
        };
        configDataList.push(item);
      }
    } catch (e) {
      LogUtil.showError(TAG, `resultSet2ConfigDataValuesBuckets error, ${e?.code}, ${e?.message}`);
    }
    return configDataList;
  }

  private resultSet2ModeDataValuesBuckets(resultSet: relationalStore.ResultSet): relationalStore.ValuesBucket[] {
    let modeDataList: relationalStore.ValuesBucket[] = [];
    try {
      while (resultSet.goToNextRow()) {
        let valuesBucket: relationalStore.ValuesBucket = {
          'modeId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeId)),
          'modeName': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modeName)),
          'iconId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconId)),
          'iconColor': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.iconColor)),
          'filletIcon': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.filletIcon)),
          'roundIcon': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.roundIcon)),
          'modePriority': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.modePriority)),
          'updateTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.updateTime)),
          'createTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.createTime)),
          'isSupportDelete': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.MODE_DATA.isSupportDelete))
        };
        modeDataList.push(valuesBucket);
      }
    } catch (e) {
      LogUtil.showError(TAG, `resultSet2ModeDataValuesBuckets error, ${e?.code}, ${e?.message}`);
    }
    return modeDataList;
  }

  private resultSet2LearnPlanValuesBuckets(resultSet: relationalStore.ResultSet): relationalStore.ValuesBucket[] {
    let list: relationalStore.ValuesBucket[] = [];
    try {
      while (resultSet.goToNextRow()) {
        let valuesBucket: relationalStore.ValuesBucket = {
          'id': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.LEARNING_PLAN.id)),
          'planName': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.LEARNING_PLAN.planName)),
          'status': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.LEARNING_PLAN.status)),
          'createTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.LEARNING_PLAN.createTime)),
          'updateTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.LEARNING_PLAN.updateTime))
        };
        list.push(valuesBucket);
      }
    } catch (e) {
      LogUtil.showError(TAG, `resultSet2LearnPlanValuesBuckets error, ${e?.code}, ${e?.message}`);
    }
    return list;
  }

  private resultSet2ContactDataValuesBuckets(resultSet: relationalStore.ResultSet): relationalStore.ValuesBucket[] {
    let list: relationalStore.ValuesBucket[] = [];
    try {
      while (resultSet.goToNextRow()) {
        let valuesBucket: relationalStore.ValuesBucket = {
          'contactId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONTACT_DATA.contactId)),
          'modeId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONTACT_DATA.modeId)),
          'detail_info': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONTACT_DATA.detailInfo)),
          'format_phone_number': resultSet
            .getString(resultSet.getColumnIndex(DB_CONFIG.CONTACT_DATA.formatPhoneNumber)),
          'focus_mode_list': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONTACT_DATA.focusModeList)),
          'updateTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONTACT_DATA.updateTime))
        };
        list.push(valuesBucket);
      }
    } catch (e) {
      LogUtil.showError(TAG, `resultSet2ContactDataValuesBuckets error, ${e?.code}, ${e?.message}`);
    }
    return list;
  }

  public transferPreferences(): void {
    LogUtil.showInfo(TAG, 'transferPreferences');
    try {
      fs.copyFileSync(`${BACK_UP_PREFERENCES_PATH}${APP_CONFIG}`,
        `${BACK_UP_PREFERENCES_PATH}${BACK_UP_PREFERENCES_NAME}`);
    } catch (err) {
      LogUtil.showError(TAG, `transferPreferences errCode: ${err?.code}, errMessage: ${err?.message}`);
    }
  }

  private copyBackupPreferencesFile2RestoreDir(context: BackupExtensionContext): boolean {
    try {
      fs.copyFileSync(`${context.backupDir}${RESTORE_DIR}${BACK_UP_PREFERENCES_PATH}${BACK_UP_PREFERENCES_NAME}`,
        `${BACK_UP_PREFERENCES_PATH}${BACK_UP_PREFERENCES_NAME}`);
      LogUtil.showInfo(TAG, 'copyBackupPreferencesFile2RestoreDir copy directory succeed');
      return true;
    } catch (e) {
      LogUtil.showError(TAG, `copyBackupPreferencesFile2RestoreDir copy directory failed with error message: ${e.message}, ${e.code}`);
      return false;
    }
  }

  public async restorePreferencesIfNeed(context: BackupExtensionContext): Promise<void> {
    LogUtil.showInfo(TAG, 'restorePreferencesIfNeed');
    const isNeedRestorePreferences: boolean = this.copyBackupPreferencesFile2RestoreDir(context);
    if (!isNeedRestorePreferences) {
      LogUtil.showWarn(TAG, 'no need restorePreferences');
      return;
    }
    try {
       const backUpPreferences: preferences.Preferences = await preferences.getPreferences(context,
         BACK_UP_PREFERENCES_NAME);
      for (let key of NEED_TRANSFER_PREFERENCES) {
        const value = backUpPreferences.getSync(key, false);
        PreferencesUtil.putSync(key, value);
        LogUtil.showInfo(TAG, `restorePreferences ${key}, ${value}`);
      }
    } catch (e) {
      LogUtil.showError(TAG, `restorePreferencesIfNeed errCode: ${e?.code}, message: ${e?.message}`);
    }
  }
}