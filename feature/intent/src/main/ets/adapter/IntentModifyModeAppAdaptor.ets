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

import insightIntent from '@ohos.app.ability.insightIntent';
import osAccount from '@ohos.account.osAccount';
import notificationManager from '@ohos.notificationManager';
import { AppData } from '@ohos/scene.datamanage/src/main/ets/model/AppData';
import launcherBundleResource from '@ohos.bundle.launcherBundleManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { AllowDisturbDataManager,
  DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES } from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { AllowAppData } from '@ohos/scene.datamanage/src/main/ets/model/AllowDisturbData';
import { ERROR_MSG, IntentCodeConstants } from '../constant/IntentCodeConstant';
import { IntentUtil } from '../util/IntentUtil';
import { VerifyPeriodUtil } from '../util/VerifyPeriodUtil';
import { IntentConstant, AppAllowPolicy } from '../constant/IntentConstant';
import { ModeListChangeType } from '../constant/IntentType';

const TAG: string = 'IntentModifyModeAppAdaptor: ';

const SCENE_BOARD: string = 'com.ohos.sceneboard';

interface notifyAllowApp {
  bundleName: string;
  uid: number;
}

/**
 * 意图框架修改允许应用策略转接类
 */
export class IntentModifyModeAppAdaptor {
  /**
   * 根据模式id修改模式的通知允许策略入口
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async modifyModeNotifyAllowByPolicy(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showError(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_NOT_DISTURB_POLICY_NOT_EXIST);
    }
    if (!IntentConstant.APP_ALLOW_POLICY.includes(intentParam.notifyAllowPolicy as number)) {
      LogUtil.showError(TAG, 'modifyModeNotifyAllowByPolicy, notifyAllowPolicy is invalid.');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_NOT_DISTURB_POLICY_PARAM_ERROR);
    }
    let modifyResult: boolean = await IntentModifyModeAppAdaptor.addNotifyAllowByApp(modeId, intentParam);
    if (!modifyResult) {
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_NOT_DISTURB_POLICY_FAILED);
    }
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE,
      `${ModeListChangeType.REFRESH_MODE}${modeId}_${IntentConstant.NOTIFICATION}`);
    HiSysEventUtil.reportIntentModifyNotificationAppBehaviorEvent(modeId);
    return IntentUtil.successResponse(IntentCodeConstants.MODIFY_NOT_DISTURB_POLICY_SUCCESS,
      ERROR_MSG[IntentCodeConstants.MODIFY_NOT_DISTURB_POLICY_SUCCESS]);
  }

  /**
   * 根据模式id修改模式的通知允许策略（追加指定应用）
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async modifyModeAddNotifyAllowByApp(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showError(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST);
    }
    let addNotifyResult: boolean = await IntentModifyModeAppAdaptor.addNotifyAllowByApp(modeId, intentParam);
    if (addNotifyResult) {
      return IntentUtil.successResponse(IntentCodeConstants.MODIFY_CALL_APP_SUCCESS_CODE,
        ERROR_MSG[IntentCodeConstants.MODIFY_CALL_APP_SUCCESS_CODE]);
    }
    return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_CALL_APP_FAIL_CODE);
  }

  /**
   * 根据模式id修改模式的通知允许应用
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 修改模式通知允许应用成功 or 失败
   */
  static async addNotifyAllowByApp(modeId: string, intentParam: Record<string, Object>): Promise<boolean> {
    let notifyAllowPolicy: number = Number(intentParam.notifyAllowPolicy);
    LogUtil.showInfo(TAG, `add allow notify, notifyAllowPolicy is: ${notifyAllowPolicy}`);
    if (!IntentConstant.APP_ALLOW_POLICY.includes(notifyAllowPolicy)) {
      LogUtil.showError(TAG, 'add allow notify, notifyAllowPolicy is invalid.');
      return false;
    }
    let trustList: AllowAppData = {
      selectedAppList: [],
    };
    if (notifyAllowPolicy === AppAllowPolicy.FORBIDDEN_ALL_APP_POLICY) {
      trustList.selectedAppList = [];
      await AllowDisturbManager.getInstance().updateAllowNotificationList(trustList, modeId);
    } else if (notifyAllowPolicy === AppAllowPolicy.ALLOW_SPECIFY_APP_POLICY) {
      let allSelectedAppList: AppData[] | undefined =
        await IntentModifyModeAppAdaptor.allowSpecifiedApp(intentParam, trustList);
      if (!allSelectedAppList) {
        return false;
      }
      await IntentModifyModeAppAdaptor.appendApplication(allSelectedAppList, modeId);
    } else if (notifyAllowPolicy === AppAllowPolicy.ALLOW_ALL_APP_POLICY) {
      let appList: AppData[] = await IntentModifyModeAppAdaptor.queryAllAllowNotifyApps();
      trustList.selectedAppList.push(...appList);
      await AllowDisturbManager.getInstance().updateAllowNotificationList(trustList, modeId);
    } else {
      LogUtil.showWarn(TAG, 'add allow notify fail, notifyAllowPolicy is invalid.');
    }
    await AllowDisturbDataManager.setAllowDisturbAppList(modeId);
    AllowDisturbDataManager.setSoundAndVibrationWhiteListAsNeeded(modeId);
    return true;
  }

  private static async allowSpecifiedApp(intentParam: Record<string, Object>, trustList: AllowAppData):
    Promise<AppData[] | undefined> {
    let notifyAllowApps = intentParam.notifyAllowApps as notifyAllowApp[];
    if (CheckEmptyUtils.isEmptyArr(notifyAllowApps)) {
      LogUtil.showError(TAG, 'add specified app allow notify fail, notifyAllowApps is invalid.');
      return undefined;
    }
    let inputBundles: string[] = [];
    for (let notifyAllowApp of notifyAllowApps) {
      if (!notifyAllowApp) {
        LogUtil.showError(TAG, 'add specified app allow notify, notifyAllowApp is invalid.');
        continue;
      }
      LogUtil.showInfo(TAG, `user input bundle: ${notifyAllowApp.bundleName}`);
      inputBundles.push(notifyAllowApp.bundleName);
    }
    let allAllowNotifyApps: AppData[] = await IntentModifyModeAppAdaptor.queryAllAllowNotifyApps();
    let hasMatchInputBundles: boolean = false;
    for (let item of allAllowNotifyApps) {
      if (inputBundles.includes(item.bundleName)) {
        hasMatchInputBundles = true;
        trustList.selectedAppList.push({
          bundleName: item.bundleName,
          index: item.index,
          uid: item.uid,
        })
      }
    }
    // 用户语音输入的允许通知应用不在通知列表内
    if (!hasMatchInputBundles) {
      LogUtil.showError(TAG, 'input bundles has not been found.');
      return undefined;
    }
    return trustList.selectedAppList;
  }

  private static async appendApplication(selectedAppList: AppData[], modeId: string): Promise<void> {
    let currentData: AllowAppData = await AllowDisturbDataManager.getAllowNotificationData(modeId);
    currentData.selectedAppList.push(...selectedAppList);
    let uniqueList : AppData[] = currentData.selectedAppList.filter((item, index, array) => {
      let findIndex = array.findIndex((value: AppData) => {
        return value.bundleName === item.bundleName && value.index === item.index;
      })
      return findIndex === index;
    });
    currentData.selectedAppList = uniqueList;
    await AllowDisturbManager.getInstance().updateAllowNotificationList(currentData, modeId);
  }

  private static async queryAllAllowNotifyApps(): Promise<AppData[]> {
    let trustList: AppData[] = [];
    let allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] = [];
    // Step 1:请求userid
    const userID: number = await IntentModifyModeAppAdaptor.getActivatedAccountLocalId();
    // Step 2:请求全部桌面应用的信息getAllLauncherAbilityInfo
    allLauncherBundleLabelList = await IntentModifyModeAppAdaptor.getAllLauncherAbilityInfo(userID);
    // Step 3:获取allNotificationBundleInfos
    let allNotificationBundleInfos: notificationManager.BundleOption[] = [];
    let bundles: notificationManager.BundleOption[] =
      await IntentModifyModeAppAdaptor.getAllNotificationEnabledBundles();
    bundles.forEach(element => {
      let bundleName: string = JSON.stringify(element.bundle).replace(/"/g, '');
      let uid: number = parseInt(JSON.stringify(element.uid).replace(/"/g, ''));
      allNotificationBundleInfos.push({ bundle: bundleName, uid: uid });
    });
    // Step 4:获取所有桌面已开启通知权限的应用（不包括元服务）
    for (let element of allLauncherBundleLabelList) {
      let name: string = element.applicationInfo.name;
      let uid: number = element.applicationInfo.uid;
      if (DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES.includes(name) || name === SCENE_BOARD) {
        continue;
      }
      let findIndex: number = -1;
      for (let i: number = 0; i < allNotificationBundleInfos.length; i++) {
        if (allNotificationBundleInfos[i].bundle === name && allNotificationBundleInfos[i].uid === uid) {
          findIndex = i;
          break;
        }
      }
      if (findIndex === -1) {
        continue;
      }
      trustList.push({
        bundleName: name,
        index: element.applicationInfo.appIndex,
        uid: uid,
      });
    }
    return trustList;
  }

  private static async getActivatedAccountLocalId(): Promise<number> {
    let accountId: number = 100;
    try {
      let osAccountManager = osAccount.getAccountManager();
      LogUtil.showInfo(TAG, 'start getActivatedOsAccountLocalIds');
      const accountIds: number[] = await osAccountManager.getActivatedOsAccountLocalIds();
      if (accountIds.length > 0) {
        accountId = accountIds[0];
      }
    } catch (error) {
      LogUtil.showError(TAG, `getActivatedOsAccountLocalIds failed: ${error?.code}, ${error?.message}`);
    }
    return accountId;
  }

  private static async getAllLauncherAbilityInfo(userID: number):
    Promise<launcherBundleResource.LauncherAbilityInfo[]> {
    let allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] = [];
    try {
      allLauncherBundleLabelList = await launcherBundleResource.getAllLauncherAbilityInfo(userID);
    } catch (error) {
      LogUtil.showInfo(TAG, `getAllLauncherAbilityInfo catch error: ${error?.code} ${error?.message}`);
    }
    allLauncherBundleLabelList = await IntentModifyModeAppAdaptor.deduplicate(allLauncherBundleLabelList);

    return allLauncherBundleLabelList;
  }

  private static async deduplicate(arr: Array<launcherBundleResource.LauncherAbilityInfo>):
    Promise<Array<launcherBundleResource.LauncherAbilityInfo>> {
    let newArr: launcherBundleResource.LauncherAbilityInfo[] = [];
    let bundleNameSet: Set<string> = new Set();
    arr.forEach((item) => {
      let launcherBundleKey: string = `${item.elementName.bundleName},${item.applicationInfo.appIndex ?? 0}`;
      if (!bundleNameSet.has(launcherBundleKey)) {
        bundleNameSet.add(launcherBundleKey);
        newArr.push(item);
      }
    })
    bundleNameSet.clear();
    return newArr;
  }

  private static async getAllNotificationEnabledBundles(): Promise<notificationManager.BundleOption[]> {
    try {
      return await notificationManager.getAllNotificationEnabledBundles();
    } catch (error) {
      LogUtil.showError(TAG, `getAllNotificationEnabledBundles occurs exception: ${error?.code} ${error?.message}`);
    }
    return [];
  }
}