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

import settings from '@ohos.settings';
import { DynamicDataSource } from '@ohos/scene.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { LoopType, TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import {
  DateTimeUtil,
  SCHEDULED_POWER_ON_OFF_CALENDAR_DATA
} from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import { LOOP_TYPE, LOOP_TYPE_CONTENT } from '../../../settinghome/constant/HomeConstant';
import { TimeManager } from '../manager/TimeManager';
import { WeekListComponent } from '../view/WeekListComponent';
import { WeekListController } from '../view/controller/WeekListController';

/* instrument ignore file */
const TAG: string = 'TimedRepeatController';

export class TimedRepeatController implements ComponentControl {
  public compId?: string;
  public dataSource?: DynamicDataSource;
  public timeInfo: TimeCondition = TimeManager.getInstance().getInfo();
  private hasHolidayInfo: boolean = false;
  private onHolidayDataChange = () => {
    LogUtil.showInfo(TAG, 'onHolidayDataChange');
    this.hasHolidayInfo = DateTimeUtil.hasHolidayInfo();
    this.dataSource?.splice(0, this.dataSource?.length);
    this.dataSource?.pushData(this.setTimeRepeatItem());
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, `init, id: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    this.hasHolidayInfo = DateTimeUtil.hasHolidayInfo();
    this.dataSource?.pushData(this.setTimeRepeatItem());
    this.refreshWeekRepeatItem();
    SettingsDataUtils.registerKeyObserverWithDomain(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA,
      settings.domainName.USER_PROPERTY, this.onHolidayDataChange);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'destroy');
    SettingsDataUtils.unregisterKeyObserverWithDomain(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA,
      settings.domainName.USER_PROPERTY);
  }

  refreshWeekRepeatItem(): void {
    this.dataSource?.removeData(this.setWeekRepeatItem());
    if (this.timeInfo.loopType === LoopType.EVERY_WEEK) {
      this.dataSource?.pushData(this.setWeekRepeatItem());
    }
  }

  private setTimeRepeatItem(): SettingItemModel {
    let items: MenuItemOptions[] = [];
    if (this.hasHolidayInfo) {
      for (let i = 0; i < LOOP_TYPE_CONTENT.length; i++) {
        items.push({ content: LOOP_TYPE_CONTENT[i] });
      }
    } else {
      // 隐藏节假日信息菜单
      items.push({ content: LOOP_TYPE_CONTENT[0] });
      items.push({ content: LOOP_TYPE_CONTENT[1] });
      items.push({ content: LOOP_TYPE_CONTENT[2] });
    }
    return {
      id: `repeat_select_${this.hasHolidayInfo}`,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.timer_repeat') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: LOOP_TYPE_CONTENT[this.timeInfo.loopType - 1] }
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('app.media.ic_arrow_pull'),
        style: {
          width: 12,
          height: 18,
          fillColor: $r('sys.color.icon_fourth')
        },
        menu: {
          items: items,
          onSelected: (index) => {
            this.timeInfo.loopType = LOOP_TYPE[index];
            this.refreshWeekRepeatItem();
          },
          selectIndex: this.timeInfo.loopType - 1
        }
      }
    }
  }

  private setWeekRepeatItem(): SettingItemModel {
    return {
      id: 'week_repeat',
      type: ItemType.ITEM_TYPE_CUSTOM,
      compControl: new WeekListController(this.timeInfo as TimeCondition),
      builder: wrapBuilder(weekBuilder)
    }
  }
}

@Builder
function weekBuilder(args: object): void {
  WeekListComponent({ item: (args as SettingItemModel) });
}