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
import { StaticSubscriberUtil } from '@ohos/scene.common/src/main/ets/utils/StaticSubscriberUtil';
import { SubscriberConstant } from '@ohos/scene.common/src/main/ets/constant/SubscriberConstant';
import { DndDataMigrationManager } from '@ohos/scene.backup/src/main/ets/manager/DndDataMigrationManager';
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager';

/* instrument ignore file */
const TAG = 'SettingDataTimeRestoreFinishSubscriber : ';
const OHOS_CLONE_NEXT: string = 'ohos_clone_next';
const NEXT_CLONE_NEXT: string = 'next_clone_next';
const OHOS_TO_NEXT: string = 'ohos_to_next';

export default class SettingDataTimeRestoreFinishSubscriber extends StaticSubscriberExtensionAbility {
  async onReceiveEvent(event: commonEventManager.CommonEventData): Promise<void> {
    LogUtil.showInfo(TAG, 'onReceiveEvent');
    if (!event?.event) {
      LogUtil.showError(TAG, 'onReceiveEvent occurs error');
      return;
    }
    LogUtil.showInfo(TAG, `onReceiveEvent ${event?.data}`);
    if (event?.data && StaticSubscriberUtil.isActionNeedStartService(event?.data)) {
      StaticSubscriberUtil.startActionServiceAbility(this.context, event?.data, event?.parameters);
      return;
    }
    AbilityContextManager.addContext(this.context);
    if (this.isCloneScene(event?.data)) {
      await PreloadManager.getInstance().initData(this.context, true);
    }
    await DndDataMigrationManager.getInstance().transferDndTimerData(this.isCloneScene(event?.data));
    await DndDataMigrationManager.getInstance().migrationContactPolicy();
    await DndDataMigrationManager.getInstance().migrationRepeat();
    StaticSubscriberUtil.startActionServiceAbility(this.context, SubscriberConstant.ACTION_UPDATE_RULE_SET);
    AbilityContextManager.removeContext(this.context);
  }

  private isCloneScene(action?: string): boolean {
    return action === NEXT_CLONE_NEXT || action === OHOS_CLONE_NEXT;
  }
}