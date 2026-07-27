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

import process from '@ohos.process';
import { bundleManager } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SCENE_DISABLE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneEvent, HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ConfigDataManager } from './ConfigDataManager';
import { AllowAppData, SoundWhiteListData } from '../model/AllowDisturbData';
import { AppData } from '../model/AppData';
import { ConfigData } from '../model/base/ConfigModel';
import { ConfigType } from '../model/base/ConfigType';
import { El1ModeDataManager } from './El1ModeDataManager';
import { ModeData } from '../model/base/ModeModel';
import { ModeUtil } from '../utils/ModeUtil';

const TAG: string = 'AllowDisturbDataManager:';
const INVALID_UID: number = -1;
const DEFAULT_UID: number = 0;
const FOUNDATION_PACKAGE: string = 'foundation';
const DEFAULT_APP_INDEX: number = 0;
const MEETING_BUNDLE_NAME: string = 'com.openharmony.ohos.meetime';
// 通知勿扰白名单列�?
export const DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES: string[] = [
  'com.openharmony.ohos.clock',
  'com.ohos.callui',
  'com.ohos.intelligentscene',
];
// 声音振动白名�?
export const ALLOW_SOUND_VIBRATION_BUNDLE_NAMES: string[] = [
  ...DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES,
  MEETING_BUNDLE_NAME,
  'com.ohos.sceneboard',
];

/*
 * 通知勿扰App数据工具�?
 */
export class AllowDisturbDataManager {
  /**
   * 从数据库获取指定模式的允许通知打扰的app数据
   *
   * @param modeId 模式id
   * @returns 允许通知打扰的app数据
   */
  public static async getAllowNotificationData(modeId: string): Promise<AllowAppData> {
    LogUtil.showInfo(TAG, 'start getAllowNotificationData.');
    let defaultAllowData: AllowAppData = {
      selectedAppList: [],
    };
    let configs: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(modeId,
      ConfigType.NOTIFICATION_NOT_DISTURB_POLICY);
    if (configs.length === 0) {
      LogUtil.showWarn(TAG, 'get allow notification data is null.');
      return defaultAllowData;
    }
    if (!configs[0].configValue.includes('selectedAppList')) {
      LogUtil.showError(TAG, 'get allow notification data is invalid.');
      return defaultAllowData;
    }
    return JsonUtil.fromJson(configs[0].configValue) as AllowAppData;
  }

  /**
   * 重置全部模式的ans数据
   *
   */
  public static async resetAnsData(): Promise<void> {
    const data: ModeData[] = await El1ModeDataManager.getInstance().queryAllModeData();
    for (const modeData of data) {
      if (modeData) {
        await AllowDisturbDataManager.removeAllowDisturbAppList(modeData.modeId);
      }
    }
  }

  /**
   * 允许通知打扰的app数据下发给通知管理
   *
   * @param modeId 模式id
   * @returns 下发成功返回true, 下发异常返回false
   */
  public static async setAllowDisturbAppList(modeId: string): Promise<boolean> {
    LogUtil.showInfo(TAG, `start setTrustAppList: ${modeId}`);
    if (modeId === SCENE_DISABLE) {
      return false;
    }
    let trustList: notificationManager.BundleOption[] = [];
    const defaultAllowApp: notificationManager.BundleOption[] =
      await AllowDisturbDataManager.getNotificationDefaultAllowApp();
    trustList = trustList.concat(defaultAllowApp);

    const data: AllowAppData = await AllowDisturbDataManager.getAllowNotificationData(modeId);
    const bundleOptions: notificationManager.BundleOption[] =
      await AllowDisturbDataManager.transAppDataToBundleOption(data);
    trustList = trustList.concat(bundleOptions);

    let templates: notificationManager.DoNotDisturbProfile[] = [
      {
        id: Number.parseInt(modeId),
        name: 'Not disturb',
        trustlist: trustList,
      }
    ];
    try {
      await notificationManager.addDoNotDisturbProfile(templates);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysIntelligentSceneEvent.NOTIFY_LIVE_CHANGE,
        ModeUtil.isCustomMode(modeId) ? '-1' : modeId);
      LogUtil.showInfo(TAG, 'addDoNotDisturbProfile success.');
      return true;
    } catch (error) {
      LogUtil.showError(TAG, `addDoNotDisturbProfile fail: ${error?.message}`);
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
        FaultScene.TRUST_LIST_FAIL, FaultSubScene.TRUST_LIST_FAIL, String(error?.code), error?.message,
        'setTrustAppList', JsonUtil.stringify(trustList));
    }
    return false;
  }

  /**
   * 修改已开启情景模式声音振动白名单
   *
   * @param targetModeId 模式id
   */
  public static async setSoundAndVibrationWhiteListAsNeeded(targetModeId: string): Promise<void> {
    let nowMode: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '0');
    LogUtil.showInfo(TAG, `setSoundAndVibrationWhiteListAsNeeded, nowMode: ${nowMode}, targetModeId: ${targetModeId}`);
    if (nowMode !== targetModeId) {
      return;
    }
    AllowDisturbDataManager.setSoundAndVibrationWhiteList(targetModeId);
  }

  /**
   * 设置声音振动白名�?
   *
   * @param modeId 模式id
   */
  public static async setSoundAndVibrationWhiteList(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `start setSoundAndVibrationWhiteList modeId: ${modeId}`);
    let trustList: SoundWhiteListData[] = [];
    const defaultAllowApp: SoundWhiteListData[] = await AllowDisturbDataManager.getSoundAndVibrationAllowApp();
    trustList = trustList.concat(defaultAllowApp);
    const bundleOptions: notificationManager.BundleOption[] =
      await AllowDisturbDataManager.getNotDisturbBundleOption(Number(modeId));
    for (let item of bundleOptions) {
      if (item.bundle !== MEETING_BUNDLE_NAME) {
        let uid: number = item.uid ?? 0;
        let appIndex: number = await AllowDisturbDataManager.getAppIndexByUid(uid);
        trustList.push({
          bundle: item.bundle,
          uid: uid,
          appIndex: appIndex,
        });
        LogUtil.showInfo(TAG, `sound white list item: ${item.bundle}, ${item.uid}, ${appIndex}`);
      }
    }
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.NOT_DISTURB_SOUND_VIBRATION_WHITE_LIST,
      JsonUtil.stringify(trustList));
    LogUtil.showInfo(TAG, `setSoundAndVibrationWhiteList success.`);
  }

  /**
   * 从通知管理删除模式的允许通知app数据
   *
   * @param modeId 模式id
   * @returns 删除成功返回true, 删除异常返回false
   */
  public static async removeAllowDisturbAppList(modeId: string): Promise<boolean> {
    LogUtil.showInfo(TAG, `start removeAllowDisturbAppList: ${modeId}`);
    try {
      await notificationManager.removeDoNotDisturbProfile([{
        id: Number.parseInt(modeId),
        name: 'Not disturb',
      }]);
      LogUtil.showInfo(TAG, `removeAllowDisturbAppList success: ${modeId}`);
      return true;
    } catch (error) {
      LogUtil.showError(TAG, `removeDoNotDisturbProfile fail: ${error?.message}`);
    }
    return false;
  }

  /**
   * 获取默认的允许通知打扰app数据：闹钟、通话
   *
   * @returns Bundle信息
   */
  public static async getNotificationDefaultAllowApp(): Promise<notificationManager.BundleOption[]> {
    LogUtil.showInfo(TAG, 'start getNotificationDefaultAllowApp');
    let appFlags = bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT;
    let trustList: notificationManager.BundleOption[] = [];
    for (let i = 0; i < DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES.length; i++) {
      let appInfo: undefined | bundleManager.ApplicationInfo;
      try {
        appInfo = await bundleManager.getApplicationInfo(DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES[i], appFlags);
      } catch (error) {
        LogUtil.showError(TAG, `getApplicationInfo error: ${error?.code} message: ${error?.message}`);
      }
      if (appInfo && appInfo.systemApp) {
        trustList.push({ bundle: DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES[i], uid: appInfo.uid });
      }
    }
    LogUtil.showInfo(TAG, `getNotificationDefaultAllowApp: ${trustList.length}`);
    return trustList;
  }

  /**
   * 获取声音振动白名单的数据
   *
   * @returns SoundWhiteListData信息
   */
  public static async getSoundAndVibrationAllowApp(): Promise<SoundWhiteListData[]> {
    LogUtil.showInfo(TAG, 'start getSoundAndVibrationAllowApp: ');
    let appFlags: number = bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT;
    let trustList: SoundWhiteListData[] = [];
    for (let i = 0; i < ALLOW_SOUND_VIBRATION_BUNDLE_NAMES.length; i++) {
      let appInfo: undefined | bundleManager.ApplicationInfo;
      try {
        appInfo = await bundleManager.getApplicationInfo(ALLOW_SOUND_VIBRATION_BUNDLE_NAMES[i], appFlags);
      } catch (error) {
        LogUtil.showError(TAG, `getApplicationInfo error: ${error?.code} message: ${error?.message}`);
      }
      if (appInfo && appInfo.systemApp) {
        trustList.push({
          bundle: ALLOW_SOUND_VIBRATION_BUNDLE_NAMES[i],
          uid: appInfo.uid,
          appIndex: appInfo.appIndex,
        });
      }
    }
    AllowDisturbDataManager.addFoundationToWhiteList(trustList);
    LogUtil.showInfo(TAG, `getSoundAndVibrationAllowApp: ${trustList.length}`);
    return trustList;
  }

  /**
   * 数据库保存的appData格式[bundleName, index]转为通知管理的格式[bundle, uid]
   *
   * @param appData 数据库获取的允许通知打扰app数据
   * @returns BundleOption类型数组
   */
  public static async transAppDataToBundleOption(appData: AllowAppData): Promise<notificationManager.BundleOption[]> {
    LogUtil.showInfo(TAG, 'start transAppDataToBundleOption');
    let appDataList: AppData[] = await AllowDisturbDataManager.transFormAppData(appData);
    let result: notificationManager.BundleOption[] = [];
    for (let item of appDataList) {
      result.push({
        bundle: item.bundleName,
        uid: item.uid,
      });
    }
    LogUtil.showInfo(TAG, `transAppDataToBundleOption end ${result.length}`);
    return result;
  }

  /**
   * 从picker选择的AllowAppData数据转化为数据库保存的格�? 由于云同步各设备同应用uid不同，不能保存uid, uid改成默认�?1.
   *
   * @param appData 带uid的AllowAppData
   * @returns 不带uid的AllowAppData
   */
  public static getSavedAllowAppData(appData: AllowAppData): AllowAppData {
    let newData: AppData[] = [];
    appData?.selectedAppList.forEach((app: AppData) => {
      newData.push({ bundleName: app.bundleName, uid: INVALID_UID, index: app.index });
    });
    const result: AllowAppData = {
      selectedAppList: newData,
    };
    return result;
  }

  /**
   * 获取情景模式带uid的通知数据
   *
   * @param modeId 模式id
   * @returns BundleOption
   */
  public static async getNotDisturbBundleOption(modeId: number): Promise<notificationManager.BundleOption[]> {
    LogUtil.showInfo(TAG, `getNotDisturbBundleOption start: ${modeId}`);
    let profile: notificationManager.DoNotDisturbProfile;
    try {
      profile = await notificationManager.getDoNotDisturbProfile(modeId);
      LogUtil.showInfo(TAG, `trustlist length is: ${profile.trustlist?.length}`);
      if (!profile || !profile.trustlist) {
        return [];
      }
      return profile.trustlist.filter((item) => {
        return !DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES.includes(item.bundle);
      })
    } catch (error) {
      LogUtil.showError(TAG, `getDoNotDisturbProfile catch err. code:${error?.code} message:${error?.message}`);
    }
    return [];
  }

  /**
   * 转换已选择的应用通知数据，转换后，列表数据会携带uid信息
   *
   * @param appData 不带uid的应用通知数据
   * @returns 带uid的应用数�?
   */
  public static async transFormAppData(appData: AllowAppData): Promise<AppData[]> {
    if (!appData || !appData.selectedAppList) {
      LogUtil.showWarn(TAG, 'transFormAppData failed, input is empty.');
      return [];
    }
    LogUtil.showInfo(TAG, 'transFormAppData start');
    let bundleFlags: number = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
    for (let item of appData.selectedAppList) {
      let bundleInfo: bundleManager.BundleInfo | undefined = undefined;
      try {
        if (AllowDisturbDataManager.isCloneBundle(item.index)) {
          bundleInfo = await bundleManager.getAppCloneBundleInfo(item.bundleName, item.index, bundleFlags);
        } else {
          bundleInfo = bundleManager.getBundleInfoSync(item.bundleName, bundleFlags);
        }
      } catch (err) {
        LogUtil.showError(TAG, `isBundleExist err, errcode:${err?.code}, errmessage:${err?.message}`);
      }
      item.uid = bundleInfo?.appInfo.uid ?? INVALID_UID;
    }
    if (appData.selectedAppList.length === 0) {
      return [];
    }
    let bundles: notificationManager.BundleOption[] = [];
    try {
      bundles = await notificationManager.getAllNotificationEnabledBundles();
    } catch (error) {
      LogUtil.showError(TAG, `getAllNotificationEnabledBundle fail, error: ${error?.code} message: ${error?.message}`);
    }
    let result: AppData[] = [];
    for (let bundlesElement of bundles) {
      for (let item of appData.selectedAppList) {
        if (item.uid === bundlesElement.uid && item.bundleName === bundlesElement.bundle) {
          result.push(item);
        }
      }
    }
    return result;
  }

  private static isCloneBundle(appIndex?: number) : boolean {
    return appIndex !== undefined && appIndex > 0;
  }

  public static async isNotDisturbWhiteApp(bundleName: string): Promise<boolean> {
    let isInWhiteList: boolean = DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES.includes(bundleName);
    if (!isInWhiteList) {
      return false;
    }
    try {
      let bundleInfo: bundleManager.ApplicationInfo = await bundleManager
        .getApplicationInfo(bundleName, bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT);
      return bundleInfo && bundleInfo.systemApp;
    } catch (e) {
      LogUtil.showError(TAG, `isNotDisturbWhiteApp fail: ${e?.code}, ${e?.message}`);
    }
    return false;
  }

  private static addFoundationToWhiteList(trustList: SoundWhiteListData[]): void {
    let uid: number = DEFAULT_UID;
    try {
      uid = new process.ProcessManager().getUidForName(FOUNDATION_PACKAGE);
    } catch (error) {
      LogUtil.showError(TAG, `addFoundationToWhiteList failed: ${error?.code}, ${error?.message}`);
    }
    trustList.push({
      bundle: FOUNDATION_PACKAGE,
      uid: uid,
      appIndex: DEFAULT_APP_INDEX,
    });
  }

  private static async getAppIndexByUid(uid: number): Promise<number> {
    try {
      const identity: bundleManager.AppCloneIdentity = await bundleManager.getAppCloneIdentity(uid);
      LogUtil.showInfo(TAG, `getAppIndexByUid: ${identity.bundleName}, ${identity.appIndex}, ${uid}`);
      return identity.appIndex;
    } catch (error) {
      LogUtil.showError(TAG, `getAppIndexByUid fail: ${error?.code}, ${error?.message}`);
    }
    return DEFAULT_APP_INDEX;
  }
}