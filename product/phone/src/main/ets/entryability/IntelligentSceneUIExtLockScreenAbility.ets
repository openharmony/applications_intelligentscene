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

import Want from '@ohos.app.ability.Want';
import uiAppearance from '@ohos.uiAppearance';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { AppStorageKey } from '@ohos/scene.common/src/main/ets/constant/AppStorageConsts';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';

/* instrument ignore file */
const TAG: string = 'IntelligentSceneUIExtLockScreenAbility : ';

const INVALID_CALLBACK_ID: number = -1;

export default class IntelligentSceneUIExtLockScreenAbility extends UIExtensionAbility {
  private storage: LocalStorage = new LocalStorage();
  private environmentCallbackId: number = INVALID_CALLBACK_ID;

  onCreate(): void {
    LogUtil.showInfo(TAG, 'onCreate.');
    AbilityContextManager.addContext(this.context);
    this.initColorMode();
    this.registerEnvironmentChange();
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.showInfo(TAG, 'onSessionCreate.');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device');
      return;
    }
    if (!session) {
      LogUtil.showError(TAG, 'session is invalid');
      return;
    }
    this.storage.setOrCreate<UIExtensionContentSession>('ExtensionContentSession', session);
    try {
      session.loadContent('pages/screenlock/LearningMode', this.storage);
      session.setWindowBackgroundColor('#00FFFFFF')
    } catch (err) {
      LogUtil.showError(TAG, `session.loadContent catch err. code:${err?.code} message:${err?.message}`);
    }
  }

  onSessionDestroy(): void {
    LogUtil.showInfo(TAG, 'onSessionDestroy.');
    this.storage.clear();
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy.');
    this.unRegisterEnvironmentChange();
    AbilityContextManager.removeContext(this.context);
  }

  /**
   * 初始化深浅色状态
   */
  private initColorMode(): void {
    try {
      const colorMode: uiAppearance.DarkMode = uiAppearance.getDarkMode();
      LogUtil.showInfo(TAG, `initColorMode. colorMode:${colorMode}`);
      AppStorage.setOrCreate<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE, colorMode);
    } catch (err) {
      LogUtil.showError(TAG, `initColorMode. code:${err?.code} message:${err?.message}`);
    }
  }

  /**
   * 注册监听
   */
  private registerEnvironmentChange(): void {
    LogUtil.showInfo(TAG, 'registerEnvironmentChange.');
    try {
      this.environmentCallbackId = this.context.getApplicationContext().on('environment', {
        onConfigurationUpdated(config): void {
          LogUtil.showInfo(TAG, 'onConfigurationUpdated start.');
          if (config) {
            if (config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
              LogUtil.showInfo(TAG, `onConfigurationUpdated. config.colorMode is invalid`);
              return;
            }
            const newColorMode: uiAppearance.DarkMode =
              config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ?
              uiAppearance.DarkMode.ALWAYS_DARK : uiAppearance.DarkMode.ALWAYS_LIGHT;
            let oldColorMode: uiAppearance.DarkMode | undefined =
              AppStorage.get<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE);
            LogUtil.showInfo(TAG, `onConfigurationUpdated. newColorMode:${newColorMode} oldColorMode:${oldColorMode}`);
            if (newColorMode !== oldColorMode) {
              AppStorage.setOrCreate<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE, newColorMode);
              // 通过事件总线通知应用
              EventBus.getInstance().emit(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, newColorMode);
            }
          }
          LogUtil.showInfo(TAG, 'onConfigurationUpdated end.');
        },
        onMemoryLevel(level): void {
          LogUtil.showInfo(TAG, `onMemoryLevel. level:${level}`);
        }
      });
      LogUtil.showInfo(TAG, `registerEnvironmentChange. environmentCallbackId:${this.environmentCallbackId}`);
    } catch (err) {
      LogUtil.showError(TAG, `registerEnvironmentChange catch err. code:${err?.code} message:${err?.message}`);
    }
  }

  /**
   * 卸载监听
   */
  private unRegisterEnvironmentChange(): void {
    LogUtil.showInfo(TAG, 'unRegisterEnvironmentChange.');
    if (this.environmentCallbackId !== INVALID_CALLBACK_ID) {
      this.context.getApplicationContext().off('environment', this.environmentCallbackId, (err) => {
        if (err) {
          LogUtil.showError(TAG, `unRegisterEnvironmentChange catch err. code:${err.code} message:${err.message}`);
        }
      });
    }
  }
}