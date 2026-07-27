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

import settings from '@ohos.settings';
import { BusinessError } from '@ohos.base';
import notificationManager from '@ohos.notificationManager';
import bundleManager from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import {
  DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES,
} from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import {
  ALLOW_FAVORITE_CONTACTS,
  FOCUS_MODE_CALL_MESSAGE_POLICY,
  FOCUS_MODE_MANUAL_ENABLE,
  FOCUS_MODE_REPEATE_CALLERS_ENABLE,
  NOT_DISTURB_VALUE_DISABLE,
  NOT_DISTURB_VALUE_ENABLE
} from './utils/NotDisturbUtils';
import { NotDisturbTimerPararm } from './model/NotDisturbTimerPararm';

/* instrument ignore file */
const TAG: string = 'NotDisturbTimerManager';

export const DISTURB_MODE_TRIGGER_START_TIME = 'disturb_mode_trigger_start_time';

export const DISTURB_MODE_TRIGGER_END_TIME = 'disturb_mode_trigger_end_time';

export const FOCUS_MODE_TIMER = 'focus_mode_timer';

const FOCUS_MODE_PROFILE = 'focus_mode_profile';

/**
 * 免打扰的定时规则处理
 */
export class NotDisturbTimerManager {
  private static menuManager: NotDisturbTimerManager | undefined = undefined;

  public static getInstance(): NotDisturbTimerManager {
    if (NotDisturbTimerManager.menuManager) {
      return NotDisturbTimerManager.menuManager;
    }
    NotDisturbTimerManager.menuManager = new NotDisturbTimerManager();
    return NotDisturbTimerManager.menuManager;
  }

  /**
   * 获取定时规则列表
   *
   * @param context
   * @returns 返回所有的定时规则列表
   */
  getTimers(context: Context): Array<NotDisturbTimerPararm> {
    let zenTimersArrays: NotDisturbTimerPararm[] = [];
    let savedTimers = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_TIMER, '', settings.domainName.USER_PROPERTY);
    if (savedTimers === '') {
      zenTimersArrays.push({
        id: 1,
        startTime: '22:00',
        endTime: '07:00',
        repeat: '1,7',
        isOpen: false,
        repeatType: 1,
        skipEndTime: 0
      });
      SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_TIMER, JSON.stringify(zenTimersArrays),
        settings.domainName.USER_PROPERTY);
      let isSet = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_MANUAL_ENABLE,
        NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_ENABLE;
      if (!isSet) {
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_MANUAL_ENABLE, NOT_DISTURB_VALUE_DISABLE,
          settings.domainName.USER_PROPERTY);
      }
      this.initOtherConfig(context);
      return zenTimersArrays;
    }
    LogUtil.showInfo(TAG, `getTimers getSettingsData ${savedTimers}`);
    try {
      zenTimersArrays = JSON.parse(savedTimers);
    } catch (e) {
      LogUtil.showError(TAG, 'zenTimersArrays parse error');
    }
    return zenTimersArrays;
  }

  /**
   * 初始化模式类型，以及默认运行打扰的通知应用列表
   *
   * @param context 上下文
   * @param forRestore 是否用于数据恢复，默认false
   */
  async initOtherConfig(context: Context, forRestore: boolean = false): Promise<void> {
    let isSet = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_PROFILE, NOT_DISTURB_VALUE_DISABLE,
      settings.domainName.USER_SECURITY) === NOT_DISTURB_VALUE_ENABLE;
    if (!isSet) {
      if (!forRestore) {
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_CALL_MESSAGE_POLICY, ALLOW_FAVORITE_CONTACTS,
          settings.domainName.USER_PROPERTY);
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_REPEATE_CALLERS_ENABLE,
          NOT_DISTURB_VALUE_ENABLE,
          settings.domainName.USER_PROPERTY);
      }
      let appFlags = bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT;
      let trustList: notificationManager.BundleOption[] = [];
      for (let whiteAppName of DEFAULT_ALLOW_DISTURB_BUNDLE_NAMES) {
        try {
          let appInfo: bundleManager.ApplicationInfo = await bundleManager.getApplicationInfo(whiteAppName, appFlags);
          if (appInfo && appInfo.systemApp) {
            trustList.push({ bundle: whiteAppName, uid: appInfo.uid });
          }
        } catch (error) {
          LogUtil.showError(TAG, `get appInfo failed : ${error?.code} ${error?.message}`);
        }
      }
      let templates: notificationManager.DoNotDisturbProfile[] = [
        {
          id: 1,
          name: 'Not disturb',
          trustlist: trustList
        }
      ]
      try {
        notificationManager.addDoNotDisturbProfile(templates).then(() => {
          SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_PROFILE, NOT_DISTURB_VALUE_ENABLE,
            settings.domainName.USER_SECURITY);
          LogUtil.showInfo(TAG, 'addDoNotDisturbProfile success.');
        }).catch((error: BusinessError) => {
          LogUtil.showError(TAG, `addDoNotDisturbProfile fail: ${error?.message}`);
        });
      } catch (error) {
        LogUtil.showError(TAG, `addDoNotDisturbProfile failed : ${error?.code} ${error?.message}`);
      }
    }
  }
}
