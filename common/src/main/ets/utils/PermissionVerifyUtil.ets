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

import { bundleManager } from '@kit.AbilityKit';
import { LogUtil } from './LogUtil';

const TAG: string = 'PermissionVerifyUtil';

/**
 * 外部调用校验工具�?
 */
export class PermissionVerifyUtil {
  /**
   * 调用Service和IPC通信的包名白名单
   */
  private static readonly trustedCallerSet: Set<string> = new Set(
    [
      // 情景模式自身
      'com.ohos.intelligentscene',
      // 大桌�?
      'com.ohos.sceneboard',
      // 智慧生活
      'com.openharmony.ohos.ailifesvc',
      // 哆啦决策引擎
      'com.openharmony.ohos.ecaengine',
      // 游戏助手
      'com.openharmony.ohos.gameservice',
      // 直播助手
      'com.openharmony.ohos.hwliveassistant',
      // 演示应用
      'com.openharmony.ohos.retaildemo',
    ]
  );

  /**
   * 调用情景模式接口和IPC通信的SA UID白名�?
   */
  private static readonly trustedCallerSaSet: Set<number> = new Set(
    [
      // GameService SA
      7011,
      // 太行引擎 SA
      1096,
    ]
  );

  public static isCallerBundleTrusted(bundleName: string): boolean {
    return PermissionVerifyUtil.trustedCallerSet.has(bundleName);
  }

  public static isCallerSaTrusted(uid: number): boolean {
    return PermissionVerifyUtil.trustedCallerSaSet.has(uid);
  }

  public static isCallerTrusted(callerUid: number): boolean {
    if (PermissionVerifyUtil.isCallerSaTrusted(callerUid)) {
      LogUtil.showInfo(TAG, 'isCallerTrusted verify success: trusted sa');
      return true;
    }
    try {
      const callerName: string = bundleManager.getBundleNameByUidSync(callerUid);
      const isTrusted: boolean = PermissionVerifyUtil.isCallerBundleTrusted(callerName);
      if (!isTrusted) {
        LogUtil.showError(TAG, `isCallerTrusted verify fail,  ${callerName} is not trusted`);
      }
      return isTrusted;
    } catch (error) {
      LogUtil.showError(TAG, `isCallerTrusted verify fail, get bundle error: ${error?.code} ${error?.message}`);
    }
    return false;
  }

  /**
   * 是否本地设备调用(用于区分分布式调�?
   *
   * @param deviceId 设备参数
   * @returns true: �?false: �?
   */
  public static isLocalDevice(deviceId?: string): boolean {
    return deviceId === '' || deviceId === undefined;
  }
}