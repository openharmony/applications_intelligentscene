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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { PageStartReason, UiExtensionConstant } from '@ohos/scene.common/src/main/ets/constant/UiExtensionConstant';
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager';

/* instrument ignore file */
const TAG: string = 'EntryAbility:';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.showInfo(TAG, 'onCreate.');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device');
      return;
    }
    AbilityContextManager.addContext(this.context);
    PreloadManager.getInstance().initData(this.context, true);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LogUtil.showInfo(TAG, `onWindowStageCreate.`);
    try {
      windowStage.loadContent('pages/settinghome/HomeWindowSettings', (err) => {
        if (err?.code) {
          LogUtil.showError(TAG, `windowStage.loadContent catch err. code:${err?.code} message:${err?.message}`);
          return;
        }
      });
    } catch (error) {
      LogUtil.showError(TAG, `windowStage loadContent err: ${error?.code} message:${error?.message}`);
    }
    AppStorage.setOrCreate(UiExtensionConstant.START_REASON, PageStartReason.FROM_STABILITY);
  }

  onForeground(): void {
    LogUtil.showInfo(TAG, 'onForeground.');
  }

  onBackground(): void {
    LogUtil.showInfo(TAG, 'onBackground.');
  }

  onWindowStageDestroy(): void {
    LogUtil.showInfo(TAG, 'onWindowStageDestroy.');
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy.');
    AbilityContextManager.removeContext(this.context);
  }
}
