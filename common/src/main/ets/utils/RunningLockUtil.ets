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

import runningLock from '@ohos.runningLock';
import { LogUtil } from './LogUtil';

const TAG: string = 'RunningLockUtil';

/**
 * RunningLock锁工具类
 *
 * @since 2025-06-17
 */
export class RunningLockUtil {
  private static instance: RunningLockUtil;
  private recordLock: runningLock.RunningLock | undefined;

  public static getInstance(): RunningLockUtil {
    if (!RunningLockUtil.instance) {
      RunningLockUtil.instance = new RunningLockUtil();
    }
    return RunningLockUtil.instance;
  }

  /**
   * 上锁
   *
   * @param time ms
   */
  public keepLockOn(time: number): void {
    if (!this.recordLock) {
      runningLock.create('IntelligentSceneRunningLock', runningLock.RunningLockType.BACKGROUND,
        (error: Error, lock: runningLock.RunningLock) => {
          if (error) {
            LogUtil.showError(TAG, `An unexpected error in runningLock. message: ${error?.message}`);
            return;
          }
          this.recordLock = lock;
        });
    }
    try {
      this.recordLock?.hold(time);
      LogUtil.showInfo(TAG, 'recordLock is holding');
    } catch (error) {
      LogUtil.showError(TAG, `recordLock hold error, code: ${error?.code}, message: ${error?.message}`);
    }
  }

  /**
   * 释放休眠锁
   */
  public cancelKeepLockOn(): void {
    if (!this.recordLock) {
      LogUtil.showWarn(TAG, 'lock is null');
      return;
    }
    try {
      if (this.recordLock.isHolding()) {
        this.recordLock.unhold();
        LogUtil.showInfo(TAG, 'lock is unHold');
      }
    } catch (error) {
      LogUtil.showError(TAG, `cancel running lock error, code: ${error?.code}, message: ${error?.message}`);
    }
  }
}