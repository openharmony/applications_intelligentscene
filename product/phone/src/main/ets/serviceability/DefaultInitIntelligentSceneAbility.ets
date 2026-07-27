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
import { TraceConstant } from '@ohos/scene.common/src/main/ets/constant/TraceConstant';
import { TraceUtil } from '@ohos/scene.common/src/main/ets/utils/TraceUtil';
import { BackgroundTaskUtil } from '@ohos/scene.common/src/main/ets/utils/BackgroundTaskUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';

/* instrument ignore file */
const TAG: string = 'DefaultInitIntelligentSceneAbility: ';
// 服务最大保活时长
const SERVICE_MAX_KEEP_ALIVE_TIME: number = 300 * 1000;
// 延迟自身销毁
const TERMITE_SELF_DELAY: number = 5000;

/**
 * OTA升级时拉起，负责初始化情景模式数据
 */
export default class DefaultInitIntelligentSceneAbility extends ServiceExtensionAbility {
  // 延迟销毁定时器
  private timerId?: number;

  async onCreate(want: Want) {
    LogUtil.showWarn(TAG, 'onCreate');
    if (!SystemParamUtil.isSupportIntelligentScene()) {
      LogUtil.showInfo(TAG, 'device not support intelligent scene');
      return;
    }
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device');
      return;
    }
    TraceUtil.start(TraceConstant.INIT_INTELLIGENT_SCENE_ABILITY);
    let isOsUnlocked: boolean = await BackgroundTaskUtil.isOsUnlock();
    if (!isOsUnlocked) {
      LogUtil.showError(TAG, 'system locked, not init data');
      return;
    }
    BackgroundTaskUtil.applyResource(SERVICE_MAX_KEEP_ALIVE_TIME);
    AbilityContextManager.addContext(this.context);
    TraceUtil.end(TraceConstant.INIT_INTELLIGENT_SCENE_ABILITY);
    this.termiteAbilityDelay();
  }

  onRequest(want: Want, startId: number) {
    LogUtil.showInfo(TAG, `onRequest abilityName:${want?.abilityName} bundleName:${want?.bundleName} startId:${startId}`);
  }

  onDisconnect(want: Want): void | Promise<void> {
    LogUtil.showInfo(TAG, 'onDisconnect');
  }

  onDestroy(): void {
    LogUtil.showWarn(TAG, 'onDestroy');
    AbilityContextManager.removeContext(this.context);
    this.clearTimer();
  }

  /**
   * 流程处理完后延迟销毁
   */
  private termiteAbilityDelay() : void {
    LogUtil.showWarn(TAG, 'termite default ability');
    this.timerId = setTimeout(() => {
      try {
        this.context.terminateSelf();
        LogUtil.showWarn(TAG, 'termite self success');
      } catch (e) {
        LogUtil.showError(TAG, `termiteAbility code: ${e?.code}, msg: ${e?.message}`);
      }
    }, TERMITE_SELF_DELAY);
  }

  /**
   * 销毁定时任务
   */
  private clearTimer(): void {
    if (this.timerId) {
      LogUtil.showInfo(TAG, 'clearTimer');
      clearTimeout(this.timerId);
      this.timerId = undefined;
    }
  }
}