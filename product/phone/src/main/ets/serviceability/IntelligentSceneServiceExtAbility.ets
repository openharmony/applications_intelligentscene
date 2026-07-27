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

import rpc from '@ohos.rpc';
import { ServiceExtensionAbility, Want } from '@kit.AbilityKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { BackgroundTaskUtil } from '@ohos/scene.common/src/main/ets/utils/BackgroundTaskUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';
import { IntelligentSceneServiceStub } from '../stub/IntelligentSceneServiceStub';

/* instrument ignore file */
const TAG: string = 'IntelligentSceneServiceExtAbility';

export default class IntelligentSceneServiceExtAbility extends ServiceExtensionAbility {
  private readonly intelligentSceneServiceStub = new IntelligentSceneServiceStub(TAG);
  onCreate(want: Want): void {
    LogUtil.showInfo(TAG, 'onCreate');
    if (!SystemParamUtil.isSupportIntelligentScene()) {
      LogUtil.showInfo(TAG, 'device not support intelligent scene');
      return;
    }
    AbilityContextManager.setExtContext(this.context);
    El1RdbStoreHelper.getInstance().getRdbStore();
    StateManager.getInstance().init();
    const currentScene: string = StateManager.getInstance().getCurrentScene();
    // 初始化生效当前模式的关联配置项状态机
    SettingLinkageManager.getInstance().init(currentScene);
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    SettingLinkageManager.getInstance().deInit();
    StateManager.getInstance().deInit();
    AbilityContextManager.setExtContext(undefined);
  }

  async onRequest(want: Want) {
    // 优化适配服务保活期间重新连接手表后消息未注册接收
    LogUtil.showInfo(TAG, 'onRequest');
    if (!SystemParamUtil.isSupportIntelligentScene()) {
      LogUtil.showInfo(TAG, 'device not support intelligent scene');
      return;
    }
    BackgroundTaskUtil.applyResource();
    await RdbStoreHelper.getInstance().getRdbStore();
    await El1RdbStoreHelper.getInstance().getRdbStore();
  }

  onConnect(want: Want): rpc.RemoteObject | Promise<rpc.RemoteObject> {
    LogUtil.showInfo(TAG, 'onConnect');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device, reject connect');
      return new rpc.RemoteObject('not local device, reject connect');
    }
    return this.intelligentSceneServiceStub;
  }

  onDisconnect(want: Want): void | Promise<void> {
    LogUtil.showInfo(TAG, 'onDisconnect');
  }
}