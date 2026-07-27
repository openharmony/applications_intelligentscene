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

import lazy { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { notifyCompStateChange, SettingDialogState, SettingStateType } from '../../framework/model/SettingStateModel';
import { SettingDialogModel } from '../../framework/model/SettingItemModel';
import { LogUtil } from '../../utils/LogUtil';
import { AbilityContextManager } from '../../ability/AbilityContextManager';

/* instrument ignore file */
const TAG = 'LocationCheckDialog';
const ALL_LOCATION_PERMISSION: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
const LOCATION_PERMISSION: Permissions[] = ['ohos.permission.LOCATION'];
const atManager = abilityAccessCtrl.createAtManager();
export const LOCATION_GUIDE_DIALOG = 'location_guide_dialog';

/**
 * 引导弹框参数，引导弹框用于引导用户授予定位权限或打开定位开关，其中定位权限和定位开关均涉及到系统弹框的拉起
 */
interface GuideDialogParam {
  title?: Resource;
  message?: Resource;
  action?: () => void;
}

/**
 * 引导定位能力开启与授权，引导成功后执行callback业务
 */
export async function locationGuide(callback: () => void): Promise<void> {
  let isEnable: boolean = geoLocationManager.isLocationEnabled();

  // 获取精确定位权限状态
  let isAuthPermission: boolean =
    await getPermissionGrantStatus('ohos.permission.LOCATION') === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  if (isEnable && isAuthPermission) {
    callback();
  } else if (!isEnable) {
    checkAndEnableLocation(callback);
  } else if (!isAuthPermission) {
    checkAndAuthAllLocation(callback);
  }
}

/**
 * 获取用户授权状态
 */
export async function getPermissionGrantStatus(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
  let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

  // 获取应用程序的accessTokenID
  let tokenId: number = 0;
  try {
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
  } catch (error) {
    LogUtil.showError(TAG, `Failed to check access token. Code is ${error?.code}, message is ${error?.message}`);
  }

  // 校验应用是否被授予权限
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission);
  } catch (error) {
    LogUtil.showError(TAG, `Failed to check access token. Code is ${error?.code}, message is ${error?.message}`);
  }

  return grantStatus;
}

/**
 * 定位开关校验与开启弹框拉起
 */
function checkAndEnableLocation(callback: () => void): void {
  let enableParam: GuideDialogParam = buildLocationEnableGuideDialog(callback);
  openLocationGuideDialog(enableParam);
}

/**
 * 定位权限校验与授权弹框拉起，包括精确定位与模糊定位
 */
function checkAndAuthAllLocation(callback: () => void): void {
  atManager.requestPermissionsFromUser(AbilityContextManager.getContext(), ALL_LOCATION_PERMISSION)
    .then(permissionRes => {
      const isAuthApproximateLocation: boolean =
        permissionRes?.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ?? false;
      const isAuthLocation: boolean =
        permissionRes?.authResults[1] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ?? false;
      if (isAuthApproximateLocation && isAuthLocation) {
        locationGuide(callback);
      } else if (isAuthApproximateLocation && !isAuthLocation) {
        checkAndAuthLocation(callback);
      } else {
        let permissionParam: GuideDialogParam = buildLocationAuthGuideDialog(ALL_LOCATION_PERMISSION, callback);
        openLocationGuideDialog(permissionParam);
      }
    })
    .catch((err: BusinessError) => {
      LogUtil.showError(TAG, `checkAllLocationPermission err. code: ${err?.code}, message: ${err?.message}`);
    });
}

/**
 * 精确定位权限校验与授权弹框拉起，需要确保与模糊定位权限申请一起使用
 */
function checkAndAuthLocation(callback: () => void): void {
  atManager.requestPermissionsFromUser(AbilityContextManager.getContext(), LOCATION_PERMISSION)
    .then(permissionRes => {
      const isAuthLocation: boolean =
        permissionRes?.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ?? false;
      if (isAuthLocation) {
        locationGuide(callback);
      } else {
        let permissionParam: GuideDialogParam = buildLocationAuthGuideDialog(LOCATION_PERMISSION, callback);
        openLocationGuideDialog(permissionParam);
      }
    })
    .catch((err: BusinessError) => {
      LogUtil.showError(TAG, `checkLocationPermission err. code: ${err?.code}, message: ${err?.message}`);
    });
}

/**
 * 构建定位开关引导弹框参数
 */
function buildLocationEnableGuideDialog(callback: () => void): GuideDialogParam {
  return {
    title: $r('app.string.location_permission_dialog_title'),
    message: $r('app.string.permission_reason_location_permission'),
    action: async () => {
      closeLocationGuideDialog();
      try {
        const isGlobalSwitchGranted: boolean =
          await atManager.requestGlobalSwitch(AbilityContextManager.getContext(),
            abilityAccessCtrl.SwitchType.LOCATION);
        if (isGlobalSwitchGranted) {
          locationGuide(callback);
        }
      } catch (err) {
        LogUtil.showError(TAG, `requestGlobalSwitch err. code: ${err?.code}, msg: ${err?.message}`);
      }
    }
  };
}

/**
 * 构建定位授权引导弹框参数
 */
function buildLocationAuthGuideDialog(permissions: Permissions[], callback: () => void): GuideDialogParam {
  return {
    title: $r('app.string.location_services_dialog_title_default'),
    message: $r('app.string.permission_reason_location_permission'),
    action: async () => {
      closeLocationGuideDialog();
      try {
        const grantStatus: Array<abilityAccessCtrl.GrantStatus> =
          await atManager.requestPermissionOnSetting(AbilityContextManager.getContext(), permissions);
        if (grantStatus.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
          locationGuide(callback);
        }
      } catch (err) {
        LogUtil.showError(TAG, `requestPermissionOnSetting err. code: ${err?.code}, msg: ${err?.message}`);
      }
    }
  };
}

/**
 * 拉起定位引导弹框
 */
function openLocationGuideDialog(guideDialogParam: GuideDialogParam): void {
  notifyCompStateChange(`home_standard_page.modal_group.${LOCATION_GUIDE_DIALOG}`,
    new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
      title: guideDialogParam.title,
      message: guideDialogParam.message,
      isShowInSubWindow: true,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            closeLocationGuideDialog();
          }
        },
        {
          value: $r('app.string.location_services_dialog_goto_setting'),
          action: guideDialogParam.action,
        }
      ],
      style: {
        titleStyle: {
          wordBreak: WordBreak.BREAK_WORD
        },
        contentStyle: {
          wordBreak: WordBreak.BREAK_WORD
        },
        autoCancel: true,
      }
    } as SettingDialogState
    ]])
  );
}

/**
 * 关闭定位引导弹框
 */
function closeLocationGuideDialog(): void {
  notifyCompStateChange(`home_standard_page.modal_group.${LOCATION_GUIDE_DIALOG}`,
    new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {} as SettingDialogState]]));
}