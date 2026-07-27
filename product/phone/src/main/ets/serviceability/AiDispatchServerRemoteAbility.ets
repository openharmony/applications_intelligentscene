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

import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import Want from '@ohos.app.ability.Want';
import rpc from '@ohos.rpc';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';

/* instrument ignore file */
const TAG: string = 'AiDispatchServerRemoteAbility: ';

/**
 * AiSDK统一消息分发服务
 */
export default class AiDispatchServerRemoteAbility extends ServiceExtensionAbility {

  onCreate(want: Want): void {
    LogUtil.showInfo(TAG, 'onCreate');
    AbilityContextManager.addContext(this.context);
  }

  onRequest(want: Want, startId: number): void {
    LogUtil.showInfo(TAG, 'onRequest');
  }

  onConnect(want: Want): rpc.RemoteObject | Promise<rpc.RemoteObject> {
    LogUtil.showInfo(TAG, 'onConnect');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device, reject connect');
      return new rpc.RemoteObject('not local device, reject connect');
    }
    return new rpc.RemoteObject(TAG);
  }

  onDisconnect(want: Want): void | Promise<void> {
    LogUtil.showInfo(TAG, 'onDisconnect');
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    AbilityContextManager.removeContext(this.context);
  }
}
