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

import PromptAction from '@ohos.promptAction';
import { LogUtil } from '../../utils/LogUtil';

/* instrument ignore file */
const DURATION_TIME: number = 2000;

const TAG: string = 'PromptManager:';

/**
 * Prompt管理类
 */
export class PromptManager {
  private static singleInstance: PromptManager;
  private toastTimerId?: number;

  /**
   * 单例
   */
  public static getInstance(): PromptManager {
    if (!PromptManager.singleInstance) {
      PromptManager.singleInstance = new PromptManager();
    }
    return PromptManager.singleInstance;
  }

  /**
   * 弹出toast（节流）
   */
  public showToastWithThrottle(message: ResourceStr, showMode?: PromptAction.ToastShowMode): void {
    if (this.toastTimerId) {
      return;
    }
    this.toastTimerId = setTimeout(() => {
      this.toastTimerId = undefined;
    }, DURATION_TIME);
    this.showToast(message, showMode);
  }

  /**
   * 弹出toast
   */
  public showToast(message: ResourceStr, showMode?: PromptAction.ToastShowMode): void {
    try {
      PromptAction.showToast({
        message: message,
        duration: DURATION_TIME,
        showMode: showMode ?? PromptAction.ToastShowMode.DEFAULT,
      });
    } catch (error) {
      LogUtil.showError(TAG, `showToast catch error. code:${error?.code} message:${error?.message}`);
    }
  }
}

