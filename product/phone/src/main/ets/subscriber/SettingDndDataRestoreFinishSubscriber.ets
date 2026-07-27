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

import StaticSubscriberExtensionAbility from '@ohos.application.StaticSubscriberExtensionAbility';
import commonEventManager from '@ohos.commonEventManager';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { DndDataMigrationManager } from '@ohos/scene.backup/src/main/ets/manager/DndDataMigrationManager';

/* instrument ignore file */
const TAG = 'SettingDndDataRestoreFinishSubscriber : ';
const CONTACT_TYPE: string = 'com.ohos.contactsdataability';

export default class SettingDndDataRestoreFinishSubscriber extends StaticSubscriberExtensionAbility {
  async onReceiveEvent(event: commonEventManager.CommonEventData): Promise<void> {
    LogUtil.showInfo(TAG, 'onReceiveEvent');
    if (!event?.event) {
      LogUtil.showError(TAG, 'onReceiveEvent occurs error');
      return;
    }
    LogUtil.showInfo(TAG, `onReceiveEvent ${event?.data}`);
    AbilityContextManager.addContext(this.context);
    if (event?.data === CONTACT_TYPE) {
      await DndDataMigrationManager.getInstance().transferContactData();
    }
    AbilityContextManager.removeContext(this.context);
  }
}