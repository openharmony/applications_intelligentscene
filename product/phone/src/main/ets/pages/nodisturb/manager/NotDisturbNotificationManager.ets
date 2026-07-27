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

import notificationManager from '@ohos.notificationManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';

const TAG: string = 'NotDisturbNotificationManager';

export class NotDisturbNotificationManager {
  private static manager: NotDisturbNotificationManager;
  private allowAppData?: notificationManager.BundleOption[];

  public static getInstance(): NotDisturbNotificationManager {
    if (NotDisturbNotificationManager.manager) {
      return NotDisturbNotificationManager.manager;
    }
    NotDisturbNotificationManager.manager = new NotDisturbNotificationManager();
    return NotDisturbNotificationManager.manager;
  }

  public setCurrentNotificationWhiteList(allowAppData: notificationManager.BundleOption[]): void {
    LogUtil.showInfo(TAG, `setCurrentNotificationWhiteList aloowAppData length: ${allowAppData.length}`);
    this.allowAppData = allowAppData;
  }

  public getCurrentNotificationWhiteList(): notificationManager.BundleOption [] | undefined {
    return this.allowAppData;
  }

  public hasSetNotificationWhiteList(): boolean {
    if (!this.allowAppData) {
      return false;
    }
    return this.allowAppData.length > 0;
  }
}