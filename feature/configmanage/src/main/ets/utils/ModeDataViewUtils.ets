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

import notificationManager from '@ohos.notificationManager';
import { HiSysEventUtil, ModeParams } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { BackgroundTaskUtil } from '@ohos/scene.common/src/main/ets/utils/BackgroundTaskUtil';
import { HiSysIntelligentSceneEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { ActionType } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ConfigData, EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { AppData } from '@ohos/scene.datamanage/src/main/ets/model/AppData';
import { AllowAppData } from '@ohos/scene.datamanage/src/main/ets/model/AllowDisturbData';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { ContactData, ContactLabel } from '@ohos/scene.datamanage/src/main/ets/model/base/ContactModel';
import { ContactManager } from '@ohos/scene.datamanage/src/main/ets/manager/ContactManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';
import { ModeData, ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ModeDetailAdapter, ParsedConfigData } from '../adapter/ModeDetailAdapter';
import { AllowDisturbManager } from '../manager/AllowDisturbManager';

const TAG: string = 'ModeDataViewUtils: ';
const NOT_EXIST: string = '0';
const EXIST: string = '1';

export const DEVICE_LOCKED: string = '1';
const DEVICE_UNLOCKED: string = '0';
const AFTER: string = '1';

export class ModeDataViewUtils {
  /**
   * 开启、关闭当前模式数据打点
   *
   * @param modeId 实时的模式id
   * @param isOpen 是否开启
   * @param source 来源
   * @param isAfter 状态变更前/后
   * @param currentModeId 当前操作时的模式id
   */
  public static async hiViewWhenOpenOrClose(modeId: string, isOpen: boolean, source: number,
    isAfter?: boolean, currentModeId?: string): Promise<void> {
    let timer: string = '';
    let params: ModeParams = {};
    const res = ModeDetailAdapter.getInstance() as ModeDetailAdapter;
    modeId = modeId === ModeType.NO_MODE && currentModeId ? currentModeId : modeId;
    params.MODE_NAME = ModeUtil.isCustomMode(modeId) ? '-1' : modeId;
    params.STATUS = isOpen ? ActionType.SWITCH_ON : ActionType.SWITCH_OFF;
    params.SOURCES = source;
    const isLocked: string = await BackgroundTaskUtil.isOsUnlock() ? DEVICE_UNLOCKED : DEVICE_LOCKED;
    if (isAfter) {
      SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.IS_STARTED_IN_LOCK, isLocked);
    }
    params.IS_LOCKED = isLocked;
    let callPolicy: string = '';
    params.ACTION_TYPE = isAfter ? AFTER : '0';

    // 重启未解锁场景下，获取不到el2下数据，仅查询el1目录数据
    if (isLocked === DEVICE_LOCKED) {
      LogUtil.showInfo(TAG, 'device is locked');
      if(modeId !== ModeType.NO_MODE){
        callPolicy = await ModeDataViewUtils.initEl1ContactPolicyValue(modeId);
        params.CALL_POLICY = await ModeDataViewUtils.initCallPolicy(callPolicy, modeId);
      }
      HiSysEventUtil.reportModeChangeOrCloseBehaviorEvent(HiSysIntelligentSceneEvent.CURRENT_MODE_DATA, params);
      return;
    }
    if (modeId !== ModeType.NO_MODE) {
      const trustList: AppData[] = await ModeDataViewUtils.initNotificationApps(modeId);
      timer = await ModeDataViewUtils.initTimer(modeId, res);
      params.TIMERS = timer;
      callPolicy = await ModeDataViewUtils.initConfigValue(modeId, res, ConfigType.CALL_NOT_DISTURB_POLICY);
      params.CALL_POLICY = await ModeDataViewUtils.initCallPolicy(callPolicy, modeId);
      params.RING_STATUS = await ModeDataViewUtils.initSwitchEnable(modeId, res, ConfigType.REPEATED_CALL_RING_SWITCH);
      params.PKGSUM = trustList.length;
      params.PKGNAME = ModeDataViewUtils.initPackageName(trustList);
      params.SMART_ENABLE = await ModeDataViewUtils.initSwitchEnable(modeId, res,
        ConfigType.INTELLIGENT_EXPERIENCE_SWITCH);
      params.APP_ENABLED = await ModeDataViewUtils.initAppEnable(modeId, res);
      params.DARK_MODE = await ModeDataViewUtils.initConfigValue(modeId, res, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      params.EYE_PROTECT = await ModeDataViewUtils.initConfigValue(modeId, res,
        ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      const customModeList: string[] = await ModeDataViewUtils.queryCustomModeList();
      params.CURRENT_CUSTOM_MODE = modeId;
      params.EXISTS_CUSTOM_MODE_SIZE = `${customModeList.length}`;
      params.EXISTS_CUSTOM_MODE_DETAIL = customModeList.toString();
      params.FOCUS_PROFILE_ID = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '');
      params.FOCUS_MODE_ENABLE = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '');
      params.ANS_PKGSUM = await ModeDataViewUtils.getAnsPkgSum(modeId);
      params.IMPORTANT_MESSAGE = await ModeDataViewUtils.initSwitchEnable(modeId, res,
        ConfigType.IMPORTANT_MESSAGE_REMINDER);
      await ModeDataViewUtils.initHolidayAndWorkDayCount(params, modeId, res);
    }
    HiSysEventUtil.reportModeChangeOrCloseBehaviorEvent(HiSysIntelligentSceneEvent.CURRENT_MODE_DATA, params);
    LogUtil.showInfo(TAG, `reportModeChangeEvent mode: ${modeId},isStart: ${isOpen},source: ${source},isAfterStart: ${isAfter}`);
  }

  public static async initCallPolicy(callPolicy: string, modeId: string): Promise<string> {
    if (callPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ||
      callPolicy === ContactPolicy.FORBID_SPECIFIED_CONTACTS) {
      const focusModeList: string = callPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ?
      ContactLabel.WHITE_LIST : ContactLabel.BLACK_LIST;
      const contactDataList: ContactData[] = await ContactManager.getInstance().queryModeDataByIdAndLabel(modeId,
        focusModeList);
      const result: string = `${callPolicy}:${contactDataList.length}`;
      LogUtil.showInfo(TAG, `initCallPolicy ${result}`);
      return result;
    }
    return callPolicy || '0';
  }

  public static async initTimer(modeId: string, res: ModeDetailAdapter): Promise<string> {
    let timer: string = '';
    if (res.getParsedConfigDataByType([ConfigType.TRIGGER_CONDITION_TIME])?.length) {
      res.getParsedConfigDataByType([ConfigType.TRIGGER_CONDITION_TIME])?.forEach(configData => {
        timer += JsonUtil.stringify(configData?.parsedValue);
      })
    }
    if (!timer) {
      const configDataList: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(modeId, ConfigType.TRIGGER_CONDITION_TIME);
      for (let configData of configDataList) {
        timer += configData.configValue;
      }
    }
    return timer;
  }

  public static async initNotificationApps(modeId: string): Promise<AppData[]> {
    const allowAppData: AllowAppData = await AllowDisturbManager.getInstance().getAllowNotificationData(modeId);
    LogUtil.showInfo(TAG, `initNotificationApps: ${allowAppData?.selectedAppList?.length}`);
    return allowAppData?.selectedAppList || [];
  }

  public static initPackageName(appDataList: AppData[]): string {
    return `${appDataList.length}`;
  }

  public static async initSwitchEnable(modeId: string, res: ModeDetailAdapter,
    configType: ConfigType): Promise<string> {
    let smartEnable: string = res
      .getParsedConfigDataByType([configType])?.[0]?.configValue;
    if (!smartEnable) {
      const configDataList: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(modeId, configType);
      if (!configDataList.length) {
        return ActionType.SWITCH_OFF;
      }
      smartEnable = configDataList[0]?.configValue;
    }
    if (smartEnable) {
      let enableState: EnableState = JsonUtil.fromJson(smartEnable) as EnableState;
      return enableState?.enable ? ActionType.SWITCH_ON : ActionType.SWITCH_OFF;
    }
    return ActionType.SWITCH_OFF;
  }

  public static async initAppEnable(modeId: string, res: ModeDetailAdapter): Promise<number> {
    const parseConfigDataList: ParsedConfigData[] = res.getParsedConfigDataByType([ConfigType.TRIGGER_CONDITION_APP]);
    if (parseConfigDataList && parseConfigDataList.length > 0) {
      return parseConfigDataList.length;
    }
    const configDataList: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndType(modeId, ConfigType.TRIGGER_CONDITION_APP);
    return configDataList.length;
  }

  public static async initConfigValue(modeId: string, res: ModeDetailAdapter, configType: ConfigType): Promise<string> {
    let configValue: string = res.getParsedConfigDataByType([configType])?.[0]?.configValue;
    if (configValue) {
      return configValue;
    }
    const configDataList: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(modeId,
      configType);
    return configDataList.length > 0 ? configDataList[0].configValue : '';
  }

  /**
   * 打点工具获取模式El1目录下来电策略
   *
   * @param modeId 模式id
   * @returns 配置项值
   */
  public static async initEl1ContactPolicyValue(modeId: string): Promise<string> {
    return await AllowDisturbManager.getInstance().getEl1ContactPolicy(modeId);
  }

  /**
   * 获取自定义模式列表数据
   *
   * @returns 自定义模式列表
   */
  public static async queryCustomModeList(): Promise<string[]> {
    let customModeList: string[] = [];
    const modeList: ModeData[] = await ModeDataManager.getInstance().queryAllModeData();
    modeList.forEach(item => {
      if (ModeUtil.isCustomMode(item.modeId)) {
        customModeList.push(item.modeId);
      }
    });
    return customModeList;
  }

  public static async getAnsPkgSum(modeId: string): Promise<string> {
    if (modeId === '0') {
      LogUtil.showInfo(TAG, 'getAnsPkgSum mode closed');
      return '0';
    }
    try {
      const profile: notificationManager.DoNotDisturbProfile = await notificationManager
        .getDoNotDisturbProfile(parseInt(modeId));
      LogUtil.showInfo(TAG, `getAnsPkgSum length is: ${profile?.trustlist?.length}`);
      return `${profile?.trustlist?.length ?? 0}`;
    } catch (error) {
      LogUtil.showError(TAG, `getAnsPkgSum err code:${error?.code} message:${error?.message}`);
    }
    return '0';
  }

  public static async initHolidayAndWorkDayCount(params: ModeParams, modeId: string,
    res: ModeDetailAdapter): Promise<void> {
    let holidayCount: number = 0;
    let workingDayCount: number = 0;
    let configDataList: ConfigData[] = [];
    if (res.getParsedConfigDataByType([ConfigType.TRIGGER_CONDITION_TIME])?.length) {
      configDataList = res.getParsedConfigDataByType([ConfigType.TRIGGER_CONDITION_TIME]);
    } else {
      configDataList = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(modeId, ConfigType.TRIGGER_CONDITION_TIME);
    }
    for (let configData of configDataList) {
      const condition: TimeCondition | undefined = JsonUtil.parse<TimeCondition>(configData.configValue);
      if (condition?.loopType === LoopType.HOLIDAY) {
        holidayCount++;
      } else if (condition?.loopType === LoopType.WORKDAY) {
        workingDayCount++;
      }
    }
    params.HOLIDAY_TIMES = `${holidayCount}`;
    params.WORKING_DAY_TIMES = `${workingDayCount}`;
    LogUtil.showInfo(TAG, `holidayCount: ${holidayCount}, workingDayCount: ${workingDayCount}`);
  }
}