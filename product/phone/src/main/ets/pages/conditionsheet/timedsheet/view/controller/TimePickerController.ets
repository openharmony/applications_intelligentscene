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

import { TimeConstant } from '@ohos/scene.common/src/main/ets/constant/TimeConstant';
import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { NotDisturbUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/NotDisturbUtils';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

/* instrument ignore file */
const TAG: string = 'TimePickerController';

/**
 * 免打扰定时规则时间选择控制器
 */
export class TimePickerController implements ComponentControl {
  private timer: TimeCondition;
  private isStartTime: boolean = true;
  private finalTime: string = '';

  constructor(param: TimeCondition, isStartTime: boolean) {
    this.timer = param;
    this.isStartTime = isStartTime;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, 'init');
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'destroy');
  }

  onConfirmClick(): void {
    if (this.finalTime === '') {
      LogUtil.showInfo(TAG, 'has not edit time.');
      return;
    }
    if (this.isStartTime) {
      this.timer.timeStart = this.finalTime;
    } else {
      this.timer.timeEnd = this.finalTime;
    }
    LogUtil.showInfo(TAG, `onConfirmClick. finalTime:${this.finalTime}`);
    if (this.getMorning()) {
      notifyCompStateChange('home_standard_page.timed_sheet.time_group.time_start',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: this.getStartTime()
            }
          } as SettingResultState
        ]])
      );

      // 结束时间要随着开始时间变化，判断是否要加次日
      notifyCompStateChange('home_standard_page.timed_sheet.time_group.time_end',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: this.getEndTime()
            }
          } as SettingResultState
        ]])
      );
    } else {
      notifyCompStateChange('home_standard_page.timed_sheet.time_group.time_end',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: this.getEndTime()
            }
          } as SettingResultState
        ]])
      );
    }
  }

  /**
   * 根据 Date 生成 时间字串 xx:xx (24小时制/数字形式)
   */
  updateTime(date: Date): void {
    this.finalTime = TimeConstant.zhTimeFormat.format(date);
  }

  // 从24小时 HH:mm 转为date
  getCurrentTime(): Date {
    let currentTime: string = this.isStartTime ? this.timer.timeStart : this.timer.timeEnd;
    return StringUtil.isEmpty(currentTime) ? new Date() : NotDisturbUtils.getDateFromTime(currentTime);
  }

  getMorning(): boolean {
    return this.isStartTime;
  }

  getStartTime(): string {
    return NotDisturbUtils.getSysFormatTime(this.timer.timeStart);
  }

  // 获取当前系统时间制下的时间
  getEndTime(): string {
    return NotDisturbUtils.getEndTimeSummary(this.timer.timeStart, this.timer.timeEnd);
  }

  getTitle(): string {
    if (this.isStartTime) {
      return ResourceUtil.getStringSync($r('app.string.timer_start_time'));
    } else {
      return ResourceUtil.getStringSync($r('app.string.timer_end_time'));
    }
  }
}


