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
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';

/* instrument ignore file */
const TAG: string = 'SceneGreetUIExtAbility : ';
const WINDOW_BACKGROUND_COLOR: string = '#00ffffff';
const SLEEP_GREET_COMPONENT: string = 'pages/screenlock/SleepGreetComponent';

export default class SceneGreetUIExtAbility extends UIExtensionAbility {
  private storage: LocalStorage = new LocalStorage();

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.showInfo(TAG, 'onSessionCreate is called');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device');
      return;
    }
    this.storage.setOrCreate<UIExtensionContentSession>('GreetContentSession', session);
    AbilityContextManager.addContext(this.context);
    try {
      session.loadContent(SLEEP_GREET_COMPONENT, this.storage);
      session.setWindowBackgroundColor(WINDOW_BACKGROUND_COLOR);
    } catch (e) {
      LogUtil.showError(TAG, `UIextension content session failed: ${e?.message}`);
    }
  }

  onSessionDestroy(): void {
    LogUtil.showInfo(TAG, 'onSessionDestroy is called');
    AbilityContextManager.removeContext(this.context);
  }
}