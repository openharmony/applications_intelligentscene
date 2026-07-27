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

import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { DynamicDataSource } from '@ohos/scene.common/src/main/ets/framework/model/DynamicDataSource';
import {
  DialogButton,
  DialogLayoutStyle,
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingDialogModel,
  SettingItemDetailModel,
  SettingItemModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { NotDisturbUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/NotDisturbUtils';
import { TimeManager } from '../manager/TimeManager';
import { TimePickerController } from '../view/controller/TimePickerController';
import { timerPickerComponentBuilder } from '../view/TimerPickerComponent';

/* instrument ignore file */
const TAG: string = 'TimedDetailController';

/**
 * 定时条件详情控制器
 */
export class TimedDetailController implements ComponentControl {
  private compId?: string;
  private dataSource?: DynamicDataSource;
  private timeInfo: TimeCondition = TimeManager.getInstance().getInfo();

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, `init, id: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    this.timeInfo = TimeManager.getInstance().getInfo();
    // 条件启用状态由首页根据当前时间段判断，半模态内不再展示「打开」开关
    this.timeInfo.enable = true;
    this.dataSource?.push(this.getStartTimeItem());
    this.dataSource?.push(this.getEndTimeItem());
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'destroy');
  }

  private getStartTimeItem(): SettingItemModel {
    const controller: TimePickerController = new TimePickerController(this.timeInfo, true);
    return {
      id: 'time_start',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.timer_start_time') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: NotDisturbUtils.getSysFormatTime(this.timeInfo.timeStart) },
      },
      detail: this.buildTimePickerDialog(controller),
      compControl: controller,
    };
  }

  private getEndTimeItem(): SettingItemModel {
    const controller: TimePickerController = new TimePickerController(this.timeInfo, false);
    return {
      id: 'time_end',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.timer_end_time') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: NotDisturbUtils.getEndTimeSummary(this.timeInfo.timeStart, this.timeInfo.timeEnd),
        },
      },
      detail: this.buildTimePickerDialog(controller),
      compControl: controller,
    };
  }

  private buildTimePickerDialog(controller: TimePickerController): SettingItemDetailModel {
    const cancelButton: DialogButton = {
      value: $r('app.string.cancel'),
      action: (_component: SettingItemModel) => {
      },
    };
    const confirmButton: DialogButton = {
      value: $r('app.string.dialog_submit'),
      action: (_component: SettingItemModel) => {
        controller.onConfirmClick();
      },
    };
    const dialogButtons: DialogButton[] = [cancelButton, confirmButton];
    const dialogStyle: DialogLayoutStyle = {
      autoCancel: true,
    };
    const dialog: SettingDialogModel = {
      title: controller.getTitle(),
      contentBuilder: wrapBuilder(timerPickerComponentBuilder),
      buttons: dialogButtons,
      style: dialogStyle,
    };
    const detail: SettingItemDetailModel = {
      type: ItemDetailType.DETAIL_TYPE_DIALOG,
      dialog: dialog,
    };
    return detail;
  }
}
