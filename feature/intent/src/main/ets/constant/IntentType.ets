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

export enum IntentType {
  ACTIVATE_MODE = 'ActivateMode',
  DEACTIVATE_MODE = 'DeactivateMode',
  ACTIVATE_MODE_BY_TIMER = 'ActivateModeByTimer',
  ACTIVATE_MODE_BY_END_TIME = 'ActivateModeByEndTime',
  MODIFY_MODE_ADD_NEW_PERIOD = 'ModifyModeAddNewPeriod',
  MODIFY_MODE_PERIOD = 'ModifyModePeriod',
  MODIFY_MODE_SWITCH = 'ModifyModeSwitch',
  MODIFY_MODE_SYNC_SWITCH = 'ModifyModeSyncSwitch',
  MODIFY_MODE_ASSOCIATED_SWITCH = 'ModifyModeAssociatedSwitch',
  CREATE_SCENARIO_MODE = 'CreateMode',
  QUERY_MODE_LIST = 'QueryModeList',
  QUERY_MODE = 'QueryMode',
  MODIFY_MODE_CALL_ALLOW_POLICY = 'ModifyModeCallAllowPolicy',
  MODIFY_MODE_NOTIFY_ALLOW_APP_POLICY = 'ModifyModeNotifyAllowPolicy',
}

export enum ModeListChangeType {
  ADD_MODE = 'add_',
  REFRESH_MODE = 'refresh_',
}