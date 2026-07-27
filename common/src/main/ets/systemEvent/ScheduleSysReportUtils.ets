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

import { HiSysEventUtil, ScheduleActionType } from './HiSysEventUtilsByTs'

/* instrument ignore file */
export interface ScheduleParams {
  PNAMEID: string;
  PVERSIONID: string;
  ACTION_TYPE: ScheduleActionType;
  NUM_CURRENT?: number;
}

export interface ScheduleFunctionParams {
  actionType: ScheduleActionType,
  numberCurrent?: number,
}

export class ScheduleSysReportUtil {
  static async reportAddEvent() {
    const params: ScheduleFunctionParams = {
      actionType: ScheduleActionType.ADD
    }
    HiSysEventUtil.reportScheduleEvent(params);
  }

  static async reportUpdateEvent() {
    const params: ScheduleFunctionParams = {
      actionType: ScheduleActionType.UPDATE,
    }
    HiSysEventUtil.reportScheduleEvent(params);
  }

  static async reportDeleteEvent() {
    const params: ScheduleFunctionParams = {
      actionType: ScheduleActionType.DELETE,
    }
    HiSysEventUtil.reportScheduleEvent(params);
  }

  static async reportDisableEvent(numberOfSchedulesCurrently: number) {
    const params: ScheduleFunctionParams = {
      actionType: ScheduleActionType.DISABLE,
      numberCurrent: numberOfSchedulesCurrently
    }
    HiSysEventUtil.reportScheduleEvent(params);
  }

  static async reportEnableEvent(numberOfSchedulesCurrently: number) {
    const params: ScheduleFunctionParams = {
      actionType: ScheduleActionType.ENABLE,
      numberCurrent: numberOfSchedulesCurrently
    }
    HiSysEventUtil.reportScheduleEvent(params);
  }
}
