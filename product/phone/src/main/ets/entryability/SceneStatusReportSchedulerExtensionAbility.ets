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

import WorkSchedulerExtensionAbility from '@ohos.WorkSchedulerExtensionAbility';
import workScheduler from '@ohos.resourceschedule.workScheduler';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';

const TAG: string = 'SceneStatusReportSchedulerExtensionAbility : ';

export default class SceneStatusReportSchedulerExtensionAbility extends WorkSchedulerExtensionAbility {
  onWorkStart(workInfo?: workScheduler.WorkInfo) {
    LogUtil.showInfo(TAG, `onWorkStart, workInfo is ${workInfo}`);
    AbilityContextManager.addContext(this.context);
  }

  onWorkStop(workInfo: workScheduler.WorkInfo) {
    AbilityContextManager.removeContext(this.context);
    LogUtil.showInfo(TAG, `onWorkStop, workInfo is ${workInfo}`);
  }
}