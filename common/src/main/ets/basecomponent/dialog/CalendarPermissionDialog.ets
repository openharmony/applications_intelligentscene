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

import lazy { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import { CheckEmptyUtils } from '../../utils/CheckEmptyUtils';
import { AbilityContextManager } from '../../ability/AbilityContextManager';
import { notifyCompStateChange, SettingDialogState, SettingStateType } from '../../framework/model/SettingStateModel';
import { SettingDialogModel } from '../../framework/model/SettingItemModel';
import { LogUtil } from '../../utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'CalendarPermissionDialog';
const CALENDAR_PERMISSION: Permissions[] = ['ohos.permission.READ_WHOLE_CALENDAR'];
const AT_MANAGER = abilityAccessCtrl.createAtManager();

export const CALENDAR_GUIDE_DIALOG: string = 'calendar_guide_dialog';

interface GuideDialogParam {
  title?: Resource;
  message?: Resource;
  action?: () => void;
}

export function getCalendarPermissionStatus(): abilityAccessCtrl.PermissionStatus {
  let permissionStatus: abilityAccessCtrl.PermissionStatus = abilityAccessCtrl.PermissionStatus.INVALID;
  try {
    permissionStatus = AT_MANAGER.getSelfPermissionStatus(CALENDAR_PERMISSION[0]);
  } catch (error) {
    LogUtil.showError(TAG, `Cannot get calendar permission, status return INVALID. Code is ${error?.code}, message is ${error?.message}`);
  }
  return permissionStatus;
}

async function requestCalendarPermission(context: common.Context): Promise<boolean> {
  if (CheckEmptyUtils.isEmpty(context)) {
    return false;
  }
  const permission: Permissions = CALENDAR_PERMISSION[0];
  let tokenId: number = -1;
  try {
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
  } catch (error) {
    LogUtil.showError(TAG, `Failed to check access token. Code is ${error?.code}, message is ${error?.message}`);
  }
  if (tokenId === -1) {
    LogUtil.showInfo(TAG, 'Invalid tokenID');
    return false;
  }
  try {
    const grantStatus = await AT_MANAGER.checkAccessToken(tokenId, permission);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      LogUtil.showInfo(TAG, 'Permission already granted');
      return true;
    }
    LogUtil.showInfo(TAG, 'Requesting permission...');
    await AT_MANAGER.requestPermissionsFromUser(context, [permission]);
    const newGrantStatus = await AT_MANAGER.checkAccessToken(tokenId, permission);
    const isGranted = newGrantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    LogUtil.showInfo(TAG, `Final permission status: ${isGranted}`);
    return isGranted;
  } catch (err) {
    LogUtil.showInfo(TAG, `Request calendar permission fail, error code: ${err?.code}, message: ${err?.message}`);
    return false;
  }
}

export async function calendarGuide(context: common.Context, callback: () => void) {
  try {
    const status = AT_MANAGER.getSelfPermissionStatus(CALENDAR_PERMISSION[0]);
    if (status === abilityAccessCtrl.PermissionStatus.GRANTED) {
      callback();
    } else if (status === abilityAccessCtrl.PermissionStatus.DENIED) {
      let permissionParam: GuideDialogParam = buildCalendarAuthGuideDialog(CALENDAR_PERMISSION, callback);
      openCalendarGuideDialog(permissionParam);
    } else if (status === abilityAccessCtrl.PermissionStatus.NOT_DETERMINED) {
      const permissionState = await requestCalendarPermission(context)
      if (permissionState) {
        callback();
      } else {
        let permissionParam: GuideDialogParam = buildCalendarAuthGuideDialog(CALENDAR_PERMISSION, callback);
        openCalendarGuideDialog(permissionParam);
      }
    } else {
      LogUtil.showError(TAG, 'Cannot handle calendar permission state');
    }
  } catch (error) {
    LogUtil.showError(TAG, `Cannot get calendar permission, Code is ${error?.code}, message is ${error?.message}`);
  }
}

function openCalendarGuideDialog(guideDialogParam: GuideDialogParam): void {
  notifyCompStateChange(`home_standard_page.modal_group.${CALENDAR_GUIDE_DIALOG}`,
    new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
      title: guideDialogParam.title,
      message: guideDialogParam.message,
      isShowInSubWindow: true,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            closeCalendarGuideDialog();
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

function closeCalendarGuideDialog(): void {
  notifyCompStateChange(`home_standard_page.modal_group.${CALENDAR_GUIDE_DIALOG}`,
    new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {} as SettingDialogState]]));
}

function buildCalendarAuthGuideDialog(permissions: Permissions[], callback: () => void): GuideDialogParam {
  return {
    title: $r('app.string.permission_calendar_read_title', $r('app.string.intelligent_scene')),
    message: $r('app.string.permission_reason_calendar'),
    action: async () => {
      closeCalendarGuideDialog();
      try {
        const grantStatus: Array<abilityAccessCtrl.GrantStatus> =
          await AT_MANAGER.requestPermissionOnSetting(AbilityContextManager.getContext(), permissions);
        if (grantStatus.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
          callback();
        }
      } catch (err) {
        LogUtil.showError(TAG, `requestPermissionOnSetting err. code: ${err?.code}, msg: ${err?.message}`);
      }
    }
  };
}

