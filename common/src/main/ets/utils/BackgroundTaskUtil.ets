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

import lazy { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { osAccount } from '@kit.BasicServicesKit';
import { LogUtil } from './LogUtil';

const TAG: string = 'BackgroundTaskUtil: ';
const DEFAULT_APPLY_TIME: number = 10000;

export class BackgroundTaskUtil {
  /**
   * 申请服务保护
   */
  public static applyResource(time?: number): void {
    const request: backgroundTaskManager.EfficiencyResourcesRequest = {
      resourceTypes: backgroundTaskManager.ResourceType.CPU, // 资源类型是CPU资源，保证进程不被挂起
      isApply: true, // 申请资源
      timeOut: time ?? DEFAULT_APPLY_TIME, // 超时时间，超过超时时间后资源自动释放
      reason: 'apply', // 申请原因
      isPersist: false, // 永久持有资源
      isProcess: false, // 在应用级别申请
    };
    try {
      backgroundTaskManager.applyEfficiencyResources(request);
    } catch (e) {
      LogUtil.showInfo(TAG, `applyResource error, ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 系统是否解锁
   *
   * @returns true: 已解锁
   */
  public static async isOsUnlock(): Promise<boolean> {
    let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
    try {
      const isVerified: boolean = await accountManager.isOsAccountUnlocked();
      LogUtil.showInfo(TAG,`isOsAccountUnlocked successfully, isVerified=${isVerified}`);
      return isVerified;
    } catch (err) {
      LogUtil.showError(TAG,`invoke isOsAccountUnlocked failed, error code: ${err?.code}, message: ${err?.message}`);
    }
    return false;
  }
}