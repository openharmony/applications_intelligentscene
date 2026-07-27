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

export enum ActionType {
  SWITCH_ON = 'on',
  SWITCH_OFF = 'off',
}

export enum FaultConsts {
  SET_DARK = 'set_dark',
  GET_DARK = 'get_dark',
  SET_PROTECT = 'set_protect',
  GET_PROTECT = 'get_protect',
}

export enum FaultScene {
  WEAR_SYNC_ERROR = 'WEAR_SYNC_ERROR',
  FACTOR_START_ERROR = 'FACTOR_START_ERROR',
  DOWN_APP_PULL_ERROR = 'DOWN_APP_PULL_ERROR',
  PERMISSION_CHECK_ERROR = 'PERMISSION_CHECK_ERROR',
  RDB_ERROR = 'RDB_ERROR',
  CONTROL_START_FAIL = 'CONTROL_START_FAIL',
  UPDATE_CONDITION_PARAM_FAIL = 'UPDATE_CONDITION_PARAM_FAIL',
  MODE_CHANGE_ERROR = 'MODE_CHANGE_ERROR',
  LINKAGE_MODE_ERROR = 'LINKAGE_MODE_ERROR',
  TRUST_LIST_FAIL = 'TRUST_LIST_FAIL',
  SEND_MESSAGE_FAIL = 'SEND_MESSAGE_FAIL',
  AI_SDK_DISPATCH_ERROR = 'AI_SDK_DISPATCH_ERROR',
}

// 故障描述
export enum FaultSubScene {
  WEAR_PHONE = 'phone-to-watch synchronization failure',
  WEAR_WATCH = 'watch-to-phone synchronization failure',
  INPUT_ERROR = 'Conditional startup input parameter error',
  DISPENSING_ERROR = 'DUO LA delivery failure (failed to start the decision-making capability)',
  OUT_PULL_ERROR = 'The scenario mode service verification fails to be started externally',
  SELF_DAMAGE = 'The database is damaged',
  QUERY_FAIL = 'Database query error',
  UPDATE_FAIL = 'Database update exception',
  RESTORE_FAIL = 'Failed to restore the database',
  BACKUP_FAIL = 'Database Backup Exception',
  SET_DISTRIBUTED_TABLE = 'An exception occurred when setting the distributed table in the database',
  CLEAN_DIRTY_DATA = 'Failed to delete dirty data from the database',
  LISTEN_CHANGE = 'The database listener changes abnormally',
  PARAMS_ERROR = 'The params parameter is incorrect',
  METHOD_ERROR = 'Incorrect parameter method',
  ID_NOTFOUND = 'The parameter ID is incorrect.',
  PARAMS_MISS = 'Mandatory parameters are missing',
  DIALOG_ERROR = 'The control center fails to start the dialog box',
  MODE_CHANGE_ERROR = 'Mode Start/Stop Fault',
  LINKAGE_MODE_ERROR = 'Scene mode start/stop, linkage with dark color and eye protection mode faults',
  TRUST_LIST_FAIL = 'Failed to write to the trustlist',
  SEND_MESSAGE_FAIL = 'Failed to send the profile notification'
}

export const NO_NEED_REPORT: number = -1;