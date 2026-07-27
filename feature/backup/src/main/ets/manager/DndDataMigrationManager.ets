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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { notificationManager } from '@kit.NotificationKit';
import settings from '@ohos.settings';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { ConfigConstant } from '@ohos/scene.common/src/main/ets/constant/ConfigConstant';
import { PhoneNumberUtil } from '@ohos/scene.common/src/main/ets/utils/PhoneNumberUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { NO_SCENE, SCENE_DISABLE, SCENE_ENABLE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigData, EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { AllowAppData } from '@ohos/scene.datamanage/src/main/ets/model/AllowDisturbData';
import { AppData} from '@ohos/scene.datamanage/src/main/ets/model/AppData';
import { ContactData } from '@ohos/scene.datamanage/src/main/ets/model/base/ContactModel';
import { ContactLabel } from '@ohos/scene.datamanage/src/main/ets/model/base/ContactModel';
import { ContactManager } from '@ohos/scene.datamanage/src/main/ets/manager/ContactManager';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { ContactsColumns } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { AllowDisturbDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import { CurrentOpenedMode } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { El1CallConfigManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1CallConfigManager';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { DndDataModel } from '../model/DndDataModel';
import { UI_REFRESH_MSG_KEY } from '../constant/BackupRestoreConstant';

/* instrument ignore file */
export const FOCUS_MODE_TIMER: string = 'focus_mode_timer';
export const TRANSFER_SETTING_DND_DATA: string = 'transfer_setting_dnd_data';
export const HAS_TRANSFER_DND_DATA: string = '1';
export const PHONE_TYPE_NUMBER: number = 5;
const NOT_DISTURB_MODE: number = 1;
const EVERY_DAY_LENGTH: number = 7;
const NUMBER_ONE: number = 1;
const FOCUS_MODE_CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy';
const FOCUS_MODE_REPEAT_CALLERS_ENABLE: string = 'focus_mode_repeate_callers_enable';
const ON: string = '1';
const TAG: string = 'DndDataMigrationManager: ';

export class DndDataMigrationManager {
  private static instance?: DndDataMigrationManager;

  public static getInstance(): DndDataMigrationManager {
    if (!DndDataMigrationManager.instance) {
      DndDataMigrationManager.instance = new DndDataMigrationManager();
    }
    return DndDataMigrationManager.instance;
  }

  public async transferSettingDndData(): Promise<boolean> {
    let isDndDataTransfer: string = SettingsDataUtils.getSettingsData(TRANSFER_SETTING_DND_DATA, '');
    LogUtil.showInfo(TAG, `setting dnd data transfer: ${isDndDataTransfer}`);
    if (isDndDataTransfer === HAS_TRANSFER_DND_DATA) {
      return false;
    }
    let intelligenceSceneEnabled: string = SystemParamUtil.getParam(ConfigConstant.CONST_INTELLIGENT_SCENE_ENABLE, '');
    LogUtil.showInfo(TAG, `transfer intelligenceSceneEnabled: ${intelligenceSceneEnabled}`);
    if (intelligenceSceneEnabled !== 'true') {
      return false;
    }
    const isNeedUpdateRules: boolean = await this.transferDndTimerData();
    await this.transferNotificationData();
    await this.transferContactData();
    await this.resetControlCenterInfoIfNeed();
    SettingsDataUtils.setSettingsData(TRANSFER_SETTING_DND_DATA, HAS_TRANSFER_DND_DATA);
    LogUtil.showInfo(TAG, 'transferSettingDndData end');
    return isNeedUpdateRules;
  }

  public isNeedRestoreSettingDataFocusMode(isCloneSettings?: boolean): boolean {
    // 如果是迁移设置免打扰数据场景，并且新设备支持情景模式，需要恢复新设备settingdata模式状态信息
    LogUtil.showInfo(TAG, 'isNeedResetFocusModeEnable');
    return isCloneSettings === true &&
      SystemParamUtil.getParam(ConfigConstant.CONST_INTELLIGENT_SCENE_ENABLE, '') === 'true';
  }

  public async transferDndTimerData(isCloneSettings?: boolean): Promise<boolean> {
    try {
      LogUtil.showInfo(TAG, 'transferDndTimerData');
      if (this.isNeedRestoreSettingDataFocusMode(isCloneSettings)) {
        LogUtil.showInfo(TAG, 'is isCloneSettings, reset focus_mode_enable');
        let configData: ConfigData | undefined = await ConfigDataManager.getInstance()
          .queryConfigDataById(ConfigType.CURRENT_OPENED_MODE.toString());
        let openMode: CurrentOpenedMode = JsonUtil.fromJson(configData?.configValue) as CurrentOpenedMode;
        if (openMode.modeId === ModeType.NO_MODE || openMode.modeId === INVALID_MODE_ID) {
          // 新机情景模式应用 本身没有模式开启，需要将设置迁移过来的状态数据重置，迁移免打扰数据时，状态不同步
          SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, SCENE_DISABLE);
          SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, ModeType.NO_MODE);
          SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, ModeType.NO_MODE);
        } else {
          // 新机情景模式 本身已开启模式，恢复profile，enable数据
          SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, SCENE_ENABLE);
          SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, openMode.modeId);
          SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, openMode.modeId);
        }
      }
      let modeEnable: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '');
      if (modeEnable === ModeType.NO_MODE) {
        LogUtil.showInfo(TAG, 'reset focus mode profile');
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, ModeType.NO_MODE);
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, ModeType.NO_MODE);
      }
      let focusModeTimer: string = SettingsDataUtils.getSettingsData(FOCUS_MODE_TIMER, '',
        settings.domainName.USER_PROPERTY);
      if (!focusModeTimer) {
        LogUtil.showInfo(TAG, 'focusModeTimer is empty');
        return false;
      }
      let dndDataList: DndDataModel[] = JsonUtil.fromJson(focusModeTimer) as DndDataModel[];
      if (!(dndDataList && dndDataList.length > 0)) {
        LogUtil.showInfo(TAG, 'dndDataList is empty');
        return false;
      }
      LogUtil.showInfo(TAG, `dndDataList ${JsonUtil.stringify(dndDataList)}`);
      let configDataList: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.TRIGGER_CONDITION_TIME);
      let insertDataList: ConfigData[] = [];
      for (let dndData of dndDataList) {
        if (this.hasSameTimeCondition(dndData, configDataList)) {
          LogUtil.showInfo(TAG, `has same time condition dndData, ${dndData.id}`);
          continue;
        }
        let timeCondition: TimeCondition = this.dndDataModel2TimeCondition(dndData);
        let configData: ConfigData = {
          configId: '',
          modeId: ModeType.DND_MODE,
          configType: ConfigType.TRIGGER_CONDITION_TIME,
          configValue: JsonUtil.stringify(timeCondition)
        };
        insertDataList.push(configData);
      }
      LogUtil.showInfo(TAG, `insert data list ${JsonUtil.stringify(insertDataList)}`);
      await ConfigDataManager.getInstance().batchInsertConfigData(insertDataList);
      return true;
    } catch (e) {
      LogUtil.showError(TAG, `transferDndTimerData error ${e?.code}, ${e?.message}`);
    }
    return false;
  }

  public async resetControlCenterInfoIfNeed(): Promise<void> {
    const sceneEnable: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_ENABLED,
      SCENE_DISABLE);
    const scene: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, NO_SCENE);
    LogUtil.showInfo(TAG, `resetControlCenterInfoIfNeed sceneEnable ${sceneEnable}, scene ${scene}`);
    if (sceneEnable === SCENE_ENABLE && scene === ModeType.DND_MODE) {
      const lastIntelligentSceneId: string = SettingsDataUtils
        .getSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, '');
      if (lastIntelligentSceneId !== ModeType.DND_MODE) {
        LogUtil.showInfo(TAG, 'reset control center');
        const modeData: ModeData | undefined =
          await El1ModeDataManager.getInstance().queryModeDataById(ModeType.DND_MODE);
        const modeName: string = modeData?.modeName || '$string:DND_mode';
        const modeIcon: string = modeData?.iconId || 'moon_fill';
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, ModeType.DND_MODE);
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_NAME, modeName);
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_ICON, modeIcon);
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, ModeType.DND_MODE);
      }
    }
  }

  public async transferNotificationData(): Promise<void> {
    let dndNtfConfigData: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.NOTIFICATION_NOT_DISTURB_POLICY);
    if (this.isDndModeHasConfigNotifyApp(dndNtfConfigData)) {
      LogUtil.showInfo(TAG, 'dnd mode already config allow app');
      return;
    }
    let appDataList: AppData[] = await this.queryTrustAppDataInfo();
    if (appDataList.length <= 0) {
      LogUtil.showInfo(TAG, 'no need transfer');
      return;
    }
    LogUtil.showInfo(TAG, 'transfer notification data');
    if (!dndNtfConfigData?.length) {
      LogUtil.showError(TAG, 'config data is empty');
      return;
    }
    let configData: ConfigData = dndNtfConfigData[0];
    let allowAppData: AllowAppData = {
      selectedAppList: appDataList
    };
    configData.configValue = JsonUtil.stringify(allowAppData);
    LogUtil.showInfo(TAG, `data ${configData.configValue}`);
    await ConfigDataManager.getInstance().updateConfigData(configData);
  }

  public async transferContactData(): Promise<void> {
    await this.migrationRepeat();
    await this.migrationContact();
  }

  public async migrationRepeat(): Promise<void> {
    try {
      let repeatStatus: boolean = this.getRepeatStatus();
      let repeatConfigData: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.REPEATED_CALL_RING_SWITCH);
      if (!repeatConfigData?.length) {
        LogUtil.showError(TAG, 'repeatConfigData list is empty');
        return;
      }
      let configData: ConfigData = repeatConfigData[0];
      if (configData.createTime !== configData.updateTime) {
        LogUtil.showWarn(TAG, 'repeat has update, no need transfer');
        return;
      }
      let enableStatus: EnableState = JsonUtil.fromJson(configData.configValue) as EnableState;
      if (enableStatus.enable !== repeatStatus) {
        LogUtil.showInfo(TAG, 'update repeat');
        enableStatus.enable = repeatStatus;
        configData.configValue = JsonUtil.stringify(enableStatus);
        await ConfigDataManager.getInstance().updateConfigData(configData);
        SettingsDataUtils.setSecureValue(UI_REFRESH_MSG_KEY, EventBusNameConstant.DB_MODE_DATA_REFRESH);
      }
    } catch (e) {
      LogUtil.showError(TAG, `migration repeat error ${e?.code}, ${e?.message}`);
    }
  }

  private getRepeatStatus(): boolean {
    LogUtil.showInfo(TAG, 'getRepeatStatus');
    return SettingsDataUtils.getSettingsData(FOCUS_MODE_REPEAT_CALLERS_ENABLE,
      ON, settings.domainName.USER_PROPERTY) === ON;
  }

  public async migrationContact(): Promise<void> {
    try {
      let contactPolicy: string = await this.migrationContactPolicy();
      if (contactPolicy !== ContactPolicy.ALLOW_SPECIFIED_CONTACTS) {
        LogUtil.showInfo(TAG, 'migration contact, no need transfer contact');
        return;
      }
      let contactDataList: ContactData[] = await this.getSettingSelectContacts();
      let needInsertContactData: ContactData[] = [];
      for (let contactData of contactDataList) {
        let isContactExists: boolean = await ContactManager.getInstance().isContactExists(contactData);
        if (!isContactExists) {
          LogUtil.showInfo(TAG, 'not exists contact add');
          needInsertContactData.push(contactData);
        }
      }
      LogUtil.showInfo(TAG, `insert contact data length ${needInsertContactData.length}`);
      await ContactManager.getInstance().batchInsertContactData(needInsertContactData);
    } catch (e) {
      LogUtil.showError(TAG, `migration contact error ${e?.code}, ${e?.message}`);
    }
  }

  public async getSettingSelectContacts(): Promise<ContactData[]> {
    let contactDataList: ContactData[] = [];
    let resultSet: DataShareResultSet | undefined = undefined;
    try {
      let daHelper: dataShare.DataShareHelper = await dataShare
        .createDataShareHelper(AbilityContextManager.getContext() as Context, ContactsColumns.CONTENT_URI, {});
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(ContactsColumns.FOCUS_MODE_LIST, ContactLabel.WHITE_LIST);
      condition.equalTo(ContactsColumns.TYPE_ID, PHONE_TYPE_NUMBER);
      let columns: string[] = [ContactsColumns.ID, ContactsColumns.DETAIL_INFO,
        ContactsColumns.DISPLAY_NAME, ContactsColumns.FOCUS_MODE_LIST];
      resultSet = await daHelper
        .query(ContactsColumns.CONTENT_URI + '/contacts/contact_data', condition, columns);
      while (resultSet.goToNextRow()) {
        let phoneNumber: string = resultSet.getString(resultSet.getColumnIndex(ContactsColumns.DETAIL_INFO));
        let contactData: ContactData = {
          modeId: ModeType.DND_MODE,
          detailInfo: phoneNumber,
          formatPhoneNumber: await PhoneNumberUtil.formatPhoneNumber(phoneNumber),
          focusModeList: ContactLabel.WHITE_LIST
        };
        contactDataList.push(contactData);
      }
    } catch (e) {
      LogUtil.showError(TAG, `getSelectContacts error ${e?.code}, ${e?.message}`);
    } finally {
      resultSet?.close();
    }
    return contactDataList;
  }

  private isDndModeHasConfigNotifyApp(dndNtfConfigData: ConfigData[]): boolean {
    if (!(dndNtfConfigData && dndNtfConfigData.length > 0)) {
      return false;
    }
    let configData: ConfigData = dndNtfConfigData[0];
    let allowAppData: AllowAppData = JsonUtil.fromJson(configData.configValue) as AllowAppData;
    return allowAppData?.selectedAppList?.length > 0;
  }

  public async queryTrustAppDataInfo(): Promise<AppData[]> {
    let appDataList: AppData[] = [];
    try {
      let profile: notificationManager.DoNotDisturbProfile = await notificationManager
        .getDoNotDisturbProfile(NOT_DISTURB_MODE);
      if (!profile || !profile.trustlist) {
        LogUtil.showError(TAG, 'profile trust list is empty');
        return appDataList;
      }
      for (let i = 0; i < profile.trustlist.length; i++) {
        let itemInfo: notificationManager.BundleOption = profile.trustlist[i];
        if (!itemInfo || !itemInfo.bundle || !itemInfo.uid) {
          continue;
        }
        if (await AllowDisturbDataManager.isNotDisturbWhiteApp(itemInfo.bundle)) {
          continue;
        }
        appDataList.push({
          bundleName: itemInfo.bundle,
          uid: itemInfo.uid as number,
          index: 0
        });
      }
    } catch (err) {
      LogUtil.showError(TAG, `queryTrustAppDataInfo error: ${err?.code}, ${err?.message}`);
    }
    return appDataList;
  }

  public hasSameTimeCondition(dndData: DndDataModel, timeConfigDataList: ConfigData[]): boolean {
    for (let configData of timeConfigDataList) {
      if (this.isSameTimeConditionData(dndData, configData)) {
        return true;
      }
    }
    return false;
  }

  public dndDataModel2TimeCondition(dndData: DndDataModel): TimeCondition {
    let loopType: number = LoopType.ONE_TIME;
    let repeatDays: string[] = [];
    if (dndData.repeatType !== 0 && dndData.repeat) {
      repeatDays = dndData.repeat.split(',');
      loopType = repeatDays.length === EVERY_DAY_LENGTH ? LoopType.EVERY_DAY : LoopType.EVERY_WEEK;
    }
    return {
      enable: dndData.isOpen ?? false,
      loopType: loopType,
      timeStart: dndData.startTime ?? '',
      timeEnd: dndData.endTime ?? '',
      loopDays: loopType === LoopType.EVERY_WEEK ? this.covet2TimeLoopDays(dndData.repeat) : '',
      configId: '',
      configType: ConfigType.TRIGGER_CONDITION_TIME
    };
  }

  public covet2TimeLoopDays(repeat?: string): string {
    if (!repeat) {
      return '';
    }
    try {
      let repeatDays: string[] = repeat.split(',');
      let result: string[] = [];
      for (let day of repeatDays) {
        let dayNumber: number = parseInt(day) - NUMBER_ONE;
        if (dayNumber === 0) {
          result.push(EVERY_DAY_LENGTH.toString());
        } else {
          result.push(dayNumber.toString());
        }
      }
      return result.join(',');
    } catch (e) {
      LogUtil.showError(TAG, `covet2TimeLoopDays fail: ${e?.code}, ${e?.message}`);
    }
    return '';
  }

  public isSameTimeConditionData(dndData: DndDataModel, configData: ConfigData): boolean {
    let dndDataTimer: TimeCondition = this.dndDataModel2TimeCondition(dndData);
    let configDataTime: TimeCondition = JsonUtil.fromJson(configData.configValue) as TimeCondition;
    return configDataTime.timeStart === dndDataTimer.timeStart && configDataTime.timeEnd === dndDataTimer.timeEnd &&
      this.isSameLoopDays(this.covet2TimeLoopDays(dndData.repeat), configData);
  }

  public isSameLoopDays(dndLoopDays: string, configData: ConfigData): boolean {
    try {
      let configDataTime: TimeCondition = JsonUtil.fromJson(configData.configValue) as TimeCondition;
      if (!dndLoopDays) {
        // 免打扰 单次
        return configDataTime.loopType === LoopType.ONE_TIME;
      }
      // 免打扰 每周
      let dndLoopDayArray: string[] = dndLoopDays.split(',').sort();
      let dndLoopDayCount: number = dndLoopDayArray.join('').length;
      if (dndLoopDayCount === EVERY_DAY_LENGTH) {
        return configDataTime.loopType === LoopType.EVERY_DAY;
      }
      let configLoopDayArray: string[] = configDataTime.loopDays.split(',').sort();
      return dndLoopDayArray.join('') === configLoopDayArray.join('');
    } catch (e) {
      LogUtil.showError(TAG, `isSameLoopDays error ${e?.code}, ${e?.message}`);
    }
    return true;
  }

  public async migrationContactPolicy(): Promise<string> {
    let contactPolicy: string = SettingsDataUtils
      .getSettingsData(FOCUS_MODE_CALL_MESSAGE_POLICY, '', settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `contactPolicy ${contactPolicy}`);
    let configDataList: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.CALL_NOT_DISTURB_POLICY);
    if (!configDataList?.length) {
      LogUtil.showError(TAG, 'migration contact, config data is error');
      return contactPolicy;
    }
    let configData: ConfigData = configDataList[0];
    if (configData.configValue !== contactPolicy && contactPolicy && configData.createTime === configData.updateTime) {
      configData.configValue = contactPolicy;
      const ret: string = await ConfigDataManager.getInstance().updateConfigData(configData);
      if (ret) {
        await El1CallConfigManager.insertCallConfig(configData);
      }
    }
    return contactPolicy;
  }
}