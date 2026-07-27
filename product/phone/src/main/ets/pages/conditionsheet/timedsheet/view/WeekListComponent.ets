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

import i18n from '@ohos.i18n';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { PADDING_2, PADDING_4 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { SettingItemModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingSelectMenuState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import {
  TimePickerUtil,
  WeekListField,
  MAX_INDEX_OF_WEEK,
  DAYS_OF_WEEK_COUNT
} from '@ohos/scene.configmanage/src/main/ets/utils/TimePickerUtil';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { AccessibilityUtils } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import { WeekListController } from './controller/WeekListController';

/* instrument ignore file */
const WEEK_BUTTON_ID_PREFIX: string = 'week_button_loop_';
const TAG: string = 'WeekListComponent: ';

@Component
export struct WeekListComponent {
  public item?: SettingItemModel;
  private compControl?: WeekListController;
  private selectIndex: number = 0;
  @State @Watch('updateWeekMapList') weekListMap: string = '{}';

  private updateWeekMapList() {
  }

  private daysOfWeekLabels: string[] = [];

  @Builder
  buildAlarmButton(item: WeekListField, index: number) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Text(i18n.getSystemLanguage().startsWith('zh') ? item.label.split('')[1] : item.label)
        .textAlign(TextAlign.Center)
        .fontSize('12vp')
        .fontWeight(item.selected ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(item.selected ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'))
        .focusable(true)
        .padding({
          top: PADDING_4,
          bottom: PADDING_4
        })
    }
    .clip(true)
    .id(`${WEEK_BUTTON_ID_PREFIX}${index}`)
    .accessibilityDescription(item.selected ? $r('app.string.be_chosen') : $r('app.string.not_selected_click_tips'))
    .backgroundColor(item.selected ? $r('sys.color.font_emphasize') : $r('sys.color.comp_background_tertiary'))
    .constraintSize({
      minWidth: '40vp',
      minHeight: '40vp',
    })
    .margin({
      top: PADDING_2,
      bottom: PADDING_2
    })
    .controlSize(ControlSize.SMALL)
    .onClick(() => {
      const customId: string = `${WEEK_BUTTON_ID_PREFIX}${index}`;
      LogUtil.showInfo(TAG, `click week list item: ${customId}`);
      AccessibilityUtils.requestFocusAccessibilityDelay(customId);
      let _weekList: WeekListField[] = JsonUtil.fromJson(this.weekListMap) as WeekListField[];
      if (CheckEmptyUtils.isEmpty(_weekList) || CheckEmptyUtils.isEmptyArr(_weekList)) {
        LogUtil.showError(TAG, 'weekList is empty.');
        return;
      }
      _weekList[index].selected = !item.selected;
      this.weekListMap = JsonUtil.stringify(_weekList);
      let daysNumArr: number[] = [];
      _weekList.map((item: WeekListField, index: number) => {
        if (item.selected) {
          daysNumArr.push(item.value);
        }
      })
      this.compControl?.updateRepeatText(daysNumArr.toString());
      this.compControl?.getRepeatType();
      if (daysNumArr.length === DAYS_OF_WEEK_COUNT) {
        this.compControl?.updateRepeatType(LoopType.EVERY_DAY);
        this.compControl?.updateRepeatText('');
        let hasHolidayInfo: boolean = DateTimeUtil.hasHolidayInfo();
        notifyCompStateChange(`home_standard_page.timed_sheet.repeat_group.repeat_select_${hasHolidayInfo}`,
          new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_MENU,
            { selectIndex: LoopType.EVERY_DAY - 1 } as SettingSelectMenuState
          ]])
        );
      }
    })
  }

  aboutToAppear(): void {
    if (this.item?.compControl instanceof WeekListController) {
      this.compControl = this.item?.compControl as WeekListController;
    }
    this.daysOfWeekLabels = TimePickerUtil.getDaysOfWeekLabels();
    let weekListArr: WeekListField[] = [];
    this.selectIndex = this.compControl === undefined ? 0 : this.compControl.getRepeatType();

    if (this.selectIndex == LoopType.EVERY_WEEK) {
      let text = String(this.compControl?.getRepeatText());
      // 重复天数可以不选 dataArray可以是一个空数组
      let dataArray: string[] = [];
      if (!CheckEmptyUtils.checkStrIsEmpty(text)) {
        dataArray = text.split(',');
      }
      // 周天是7，映射索引为0，周一到周六是1~6，
      this.daysOfWeekLabels.map((label: string, index: number) => {
        weekListArr.push({
          label: label,
          value: (index + MAX_INDEX_OF_WEEK) % DAYS_OF_WEEK_COUNT + 1,
          selected: dataArray.some(day => Number(day) === (index + MAX_INDEX_OF_WEEK) % DAYS_OF_WEEK_COUNT + 1),
        })
      });
    } else {
      this.daysOfWeekLabels.map((label: string, index: number) => {
        weekListArr.push({
          label: label,
          value: index,
          selected: false
        })
      });
    }
    this.weekListMap = JSON.stringify(weekListArr);
  }

  build() {
    Column() {
      Row({}) {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap }) {
          ForEach(JSON.parse(this.weekListMap), (item: WeekListField, index: number) => {
            this.buildAlarmButton(item, index);
          })
        }
      }
      .width('100%')
      .constraintSize({
        minHeight: 60
      })
      .justifyContent(FlexAlign.Center)
    }
    .padding($r('sys.float.padding_level4'))
  }
}
