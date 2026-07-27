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

import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { AllowAppData } from '@ohos/scene.datamanage/src/main/ets/model/AllowDisturbData';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { AllowDisturbDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';
import { El1CallConfigManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1CallConfigManager';
import { SceneBaseDataManager } from '../manager/SceneBaseDataManager';

/* instrument ignore file */
const TAG: string = 'AllowDisturbManager';

/**
 * 允许打扰数据管理类
 */
export class AllowDisturbManager {
  private static singleInstance: AllowDisturbManager;

  public static getInstance(): AllowDisturbManager {
    if (!AllowDisturbManager.singleInstance) {
      AllowDisturbManager.singleInstance = new AllowDisturbManager();
    }
    return AllowDisturbManager.singleInstance;
  }

  public async updateContactPolicy(modeId: string, contactPolicy: string): Promise<string> {
    LogUtil.showInfo(TAG, `updateContactPolicy, modeId: ${modeId}, contactPolicy: ${contactPolicy}`);
    let configData: ConfigData = {
      configId: '',
      modeId: modeId,
      configType: ConfigType.CALL_NOT_DISTURB_POLICY,
      configValue: contactPolicy,
    };
    let ret: string = await ConfigDataManager.getInstance().insertConfigData(configData);
    if (ret) {
      await El1CallConfigManager.insertCallConfig(configData);
    }
    SceneBaseDataManager.setIntelligentUsedState();
    return ret;
  }

  public async updateRepeatCallRing(modeId: string, enable: boolean): Promise<string> {
    LogUtil.showInfo(TAG, `updateRepeatCallRing, modeId: ${modeId}, enable: ${enable}`);
    let enableStatus: EnableState = {
      enable: enable
    };
    let configData: ConfigData = {
      configId: '',
      modeId: modeId,
      configType: ConfigType.REPEATED_CALL_RING_SWITCH,
      configValue: JsonUtil.stringify(enableStatus),
    };
    const repeatConfig: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndType(modeId, ConfigType.REPEATED_CALL_RING_SWITCH);
    let ret: string = '';
    if (repeatConfig.length > 0) {
      configData = repeatConfig[0];
      configData.configValue = JsonUtil.stringify(enableStatus);
      ret = await ConfigDataManager.getInstance().updateConfigData(configData);
      LogUtil.showInfo(TAG, 'updateRepeatCallRing, update repeat config');
    } else {
      ret = await ConfigDataManager.getInstance().insertConfigData(configData);
      LogUtil.showInfo(TAG, 'updateRepeatCallRing, insert repeat config in abnormal scenarios');
    }
    SceneBaseDataManager.setIntelligentUsedState();
    return ret;
  }

  public async getRepeatCallRingState(modeId: string): Promise<boolean> {
    let configData: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(modeId,
      ConfigType.REPEATED_CALL_RING_SWITCH);
    if (CheckEmptyUtils.isEmptyArr(configData)) {
      LogUtil.showError(TAG, 'getRepeatCallRingState failed, query result is empty.');
      return true;
    }
    let configValue: EnableState = (JsonUtil.fromJson(configData[0].configValue) as EnableState);
    LogUtil.showInfo(TAG, `getRepeatCallRingState: modeId: ${modeId}, enable: ${configValue.enable}`);
    return configValue.enable;
  }

  public async getImportantMessageState(modeId: string): Promise<boolean> {
    let configData: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(modeId,
      ConfigType.IMPORTANT_MESSAGE_REMINDER);
    if (CheckEmptyUtils.isEmptyArr(configData)) {
      LogUtil.showError(TAG, 'getIntelligentExperience failed, query result is empty.');
      return false;
    }
    let configValue: EnableState = (JsonUtil.fromJson(configData[0].configValue) as EnableState);
    LogUtil.showInfo(TAG, `getIntelligentExperience: modeId: ${modeId}, enable: ${configValue.enable}`);
    return configValue.enable;
  }

  public async getContactPolicy(modeId: string): Promise<string> {
    let configData: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(modeId,
      ConfigType.CALL_NOT_DISTURB_POLICY);
    LogUtil.showInfo(TAG, `configData len: ${configData.length}`);
    if (CheckEmptyUtils.isEmptyArr(configData)) {
      LogUtil.showError(TAG, 'getContactPolicy failed, query result is empty.');
      return ContactPolicy.ALLOW_FAVORITE_CONTACTS;
    }
    LogUtil.showInfo(TAG, `getContactPolicy: modeId: ${modeId}, configValue: ${configData[0].configValue}`);
    return configData[0].configValue;
  }

  public async getEl1ContactPolicy(modeId: string): Promise<string> {
    let configData: ConfigData | undefined =
      await El1ConfigDataManager.getInstance().queryConfigDataById(`${modeId}_${ConfigType.CALL_NOT_DISTURB_POLICY}`);
    if (!configData) {
      LogUtil.showError(TAG, 'getEl1ContactPolicy failed, query result is empty.');
      return ContactPolicy.ALLOW_FAVORITE_CONTACTS;
    }
    LogUtil.showInfo(TAG, `getEl1ContactPolicy: modeId: ${modeId}, configValue: ${configData.configValue}`);
    return configData.configValue;
  }

  public async getAllowNotificationData(modeId: string): Promise<AllowAppData> {
    return await AllowDisturbDataManager.getAllowNotificationData(modeId);
  }

  public async updateAllowNotificationList(newData: AllowAppData, newModeId?: string): Promise<void> {
    LogUtil.showInfo(TAG, 'start updateAllowNotificationList');
    if (!newData?.selectedAppList) {
      LogUtil.showError(TAG, 'updateAllowNotificationList failed');
      return;
    }
    let modeId: string = newModeId as string;
    let configType: number = ConfigType.NOTIFICATION_NOT_DISTURB_POLICY;
    let configId: string = ModeUtil.generateConfigId(modeId, configType);
    if (newData.selectedAppList.length === 0) {
      LogUtil.showInfo(TAG, 'delete notification data.');
      await ConfigDataManager.getInstance().deleteConfigDataById(configId);
      return;
    }
    let currentData: AllowAppData = await AllowDisturbDataManager.getAllowNotificationData(modeId);
    let savedAppData: AllowAppData = AllowDisturbDataManager.getSavedAllowAppData(newData);
    let configData: ConfigData = {
      configId: configId,
      modeId: modeId,
      configType: configType,
      configValue: JsonUtil.stringify(savedAppData),
    };
    if (currentData?.selectedAppList?.length === 0) {
      await ConfigDataManager.getInstance().insertConfigData(configData);
    } else {
      await ConfigDataManager.getInstance().updateConfigData(configData);
    }
    SceneBaseDataManager.setIntelligentUsedState();
  }
}