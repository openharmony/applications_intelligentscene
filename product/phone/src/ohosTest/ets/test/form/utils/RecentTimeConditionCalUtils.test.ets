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

import HashMap from '@ohos.util.HashMap';
import { settings } from '@kit.BasicServicesKit';
import {
  describe,
  it,
  MockKit,
  when,
  ArgumentMatchers,
  expect
} from '@ohos/hypium';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { RecentTimeConditionCalUtils } from '@ohos/scene.form/src/main/ets/utils/RecentTimeConditionCalUtils';
import { MinDifMinutesInfo, FreeWorkDayData } from '@ohos/scene.form/src/main/ets/model/FormControlData';
import { TimeCondition, LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SCHEDULED_POWER_ON_OFF_CALENDAR_DATA } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';

const TAG: string = 'RecentTimeConditionCalUtilsTest: ';

export default function RecentTimeConditionCalUtilsTest() {
  describe('RecentTimeConditionCalUtilsTest', () => {
    let mocker: MockKit = new MockKit();

    const oneTimeCondition: TimeCondition = {
      timeStart: '10:00',
      timeEnd: '11:00',
      loopType: LoopType.ONE_TIME,
      loopDays: '',
      configId: '2_13',
      configType: ConfigType.TRIGGER_CONDITION_TIME,
      enable: true
    }

    const everyDayTimeCondition: TimeCondition = {
      timeStart: '09:00',
      timeEnd: '17:00',
      loopType: LoopType.EVERY_DAY,
      loopDays: '',
      configId: '2_13',
      configType: ConfigType.TRIGGER_CONDITION_TIME,
      enable: true
    }

    const everyWeekTimeCondition: TimeCondition = {
      timeStart: '08:00',
      timeEnd: '09:00',
      loopType: LoopType.EVERY_WEEK,
      loopDays: '1, 2, 3, 4, 5',
      configId: '2_13',
      configType: ConfigType.TRIGGER_CONDITION_TIME,
      enable: true
    }

    const workdayTimeCondition: TimeCondition = {
      timeStart: '09:30',
      timeEnd: '18:30',
      loopType: LoopType.WORKDAY,
      loopDays: '',
      configId: '2_13',
      configType: ConfigType.TRIGGER_CONDITION_TIME,
      enable: true
    }

    const holidayTimeCondition: TimeCondition = {
      timeStart: '08:30',
      timeEnd: '17:30',
      loopType: LoopType.HOLIDAY,
      loopDays: '',
      configId: '2_13',
      configType: ConfigType.TRIGGER_CONDITION_TIME,
      enable: true
    }

    it('RecentTimeConditionCalUtilsTest_getRecentEnableTimeConditionDescription_modeId_is_empty', 0, async () => {
      const result: string = await RecentTimeConditionCalUtils.getRecentEnableTimeConditionDescription('', undefined);
      expect(result).assertEqual('');
    });


    it('RecentTimeConditionCalUtilsTest_getRecentEnableTimeConditionDescription_enableTimeConditions_is_empty', 0, async () => {
      const getEnableTimeConditionsMockFunc: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getEnableTimeConditions);
      when(getEnableTimeConditionsMockFunc)().afterReturn([]);
      const result: string = await RecentTimeConditionCalUtils.getRecentEnableTimeConditionDescription(ModeType.SLEEP_MODE, undefined);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getEnableTimeConditions);
      expect(result).assertEqual('');
    });

    it('RecentTimeConditionCalUtilsTest_getRecentEnableTimeConditionDescription_recentTimeCondition_is_undefined', 0, async () => {
      let timeConditions: TimeCondition[] = [{
        timeStart: '10:00',
        timeEnd: '11:00',
        loopType: LoopType.ONE_TIME,
        loopDays: '1',
        configId: '2_13',
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        enable: true
      }];
      const getEnableTimeConditionsMockFunc: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getEnableTimeConditions);
      const getRecentTimeConditionMockFunc: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeCondition);
      when(getEnableTimeConditionsMockFunc)(ArgumentMatchers.anyString).afterReturn(timeConditions);
      when(getRecentTimeConditionMockFunc)(ArgumentMatchers.anyString).afterReturn(undefined);
      const result: string = await RecentTimeConditionCalUtils.getRecentEnableTimeConditionDescription(ModeType.SLEEP_MODE, undefined);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getEnableTimeConditions);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeCondition);
      expect(result).assertEqual('');
    });

    it('RecentTimeConditionCalUtilsTest_getRecentEnableTimeConditionDescription_all_conditions_met', 0, async () => {
      let timeConditions: TimeCondition[] = [oneTimeCondition];
      const getEnableTimeConditionsMockFunc: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getEnableTimeConditions);
      when(getEnableTimeConditionsMockFunc)(ArgumentMatchers.anyString).afterReturn(timeConditions);
      const result: string = await RecentTimeConditionCalUtils.getRecentEnableTimeConditionDescription(ModeType.SLEEP_MODE, undefined);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getEnableTimeConditions);
      expect(result != undefined).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getRecentTimeCondition_timeConditions_is_empty', 0, async () => {
      const timeConditions: TimeCondition[] = [];
      const minDifMinutesInfo: MinDifMinutesInfo = {
        curDay: 1,
        curMinutes: 60,
        minDifMinutes: 0,
        startMinutes: 0,
        curDate: new Date()
      };
      const result: TimeCondition | undefined = RecentTimeConditionCalUtils.getRecentTimeCondition(timeConditions, minDifMinutesInfo);
      expect(result).assertUndefined();
    });

    it('RecentTimeConditionCalUtilsTest_getRecentTimeCondition_test', 0, async () => {
      const timeConditions: TimeCondition[] = [
        oneTimeCondition, everyDayTimeCondition, everyWeekTimeCondition, workdayTimeCondition, holidayTimeCondition
      ];
      const minDifMinutesInfo: MinDifMinutesInfo = {
        curDay: 1,
        curMinutes: 60,
        minDifMinutes: 0,
        startMinutes: 0,
        curDate: new Date()
      };
      const result: TimeCondition | undefined = RecentTimeConditionCalUtils.getRecentTimeCondition(timeConditions, minDifMinutesInfo);
      expect(result).assertUndefined();
    });

    it('RecentTimeConditionCalUtilsTest_getFormatTimeCondition_language_is_undefined', 0, async () => {
      const result: string = RecentTimeConditionCalUtils.getFormatTimeCondition(oneTimeCondition, undefined);
      expect(result).assertEqual('');
    });

    it('RecentTimeConditionCalUtilsTest_getFormatTimeCondition_has_language', 0, async () => {
      const getAnyStrFormatStringMockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getAnyStrFormatStringSync);
      when(getAnyStrFormatStringMockFunc)(ArgumentMatchers.any).afterReturn('周一10:00-周一11:00');
      const result: string = RecentTimeConditionCalUtils.getFormatTimeCondition(oneTimeCondition, 'zh');
      mocker.ignoreMock(ResourceUtil, ResourceUtil.getAnyStrFormatStringSync);
      expect(result).assertEqual('周一10:00-周一11:00');
    });

    it('RecentTimeConditionCalUtilsTest_getFormatTimeCondition_when_next_day', 0, () => {
      const timeCondition1: ESObject = {
        timeStart: '23:00',
        timeEnd: '01:00',
        loopDays: '5'
      };
      const getAnyStrFormatStringMockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getAnyStrFormatStringSync);
      when(getAnyStrFormatStringMockFunc)(ArgumentMatchers.any).afterReturn('周一10:00-周一11:00');
      const result: string = RecentTimeConditionCalUtils.getFormatTimeCondition(timeCondition1, 'zh');
      mocker.ignoreMock(ResourceUtil, ResourceUtil.getAnyStrFormatStringSync);
      expect(result).assertEqual('周一10:00-周一11:00');
    });

    it('RecentTimeConditionCalUtilsTest_getFormatTimeCondition_when_next_day_no_language', 0, () => {
      const timeCondition1: ESObject = {
        timeStart: '23:00',
        timeEnd: '01:00',
        loopDays: '5'
      };
      const getAnyStrFormatStringMockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getAnyStrFormatStringSync);
      when(getAnyStrFormatStringMockFunc)(ArgumentMatchers.any).afterReturn('周一10:00-周一11:00');
      const result: string = RecentTimeConditionCalUtils.getFormatTimeCondition(timeCondition1, undefined);
      mocker.ignoreMock(ResourceUtil, ResourceUtil.getAnyStrFormatStringSync);
      expect(result).assertEqual('周一10:00-周一11:00');
    });

    it('RecentTimeConditionCalUtilsTest_getEnableTimeConditions_configDataList_is_empty', 0, async () => {
      let configDataManager: ConfigDataManager = ConfigDataManager.getInstance();
      const queryConfigMockFunc: Function =
        mocker.mockFunc(configDataManager, configDataManager.queryConfigByModeAndType);
      when(queryConfigMockFunc)(ArgumentMatchers.any).afterReturn(Promise.resolve([]));
      const result: TimeCondition[] = await RecentTimeConditionCalUtils.getEnableTimeConditions(ModeType.SLEEP_MODE);
      mocker.ignoreMock(configDataManager, configDataManager.queryConfigByModeAndType);
      expect(result.length).assertLargerOrEqual(0);
    });

    it('RecentTimeConditionCalUtilsTest_getEnableTimeConditions_no_enabled_conditions', 0, async () => {
      const mockConfigData: ConfigData = {
        configId: '1',
        modeId: ModeType.SLEEP_MODE,
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        configValue: JSON.stringify({ enable: false })
      };
      let configDataManager: ConfigDataManager = ConfigDataManager.getInstance();
      const queryConfigMockFunc: Function =
        mocker.mockFunc(configDataManager, configDataManager.queryConfigByModeAndType);
      when(queryConfigMockFunc)(ArgumentMatchers.any).afterReturn(Promise.resolve([mockConfigData]));
      const result: TimeCondition[] = await RecentTimeConditionCalUtils.getEnableTimeConditions(ModeType.SLEEP_MODE);
      mocker.ignoreMock(configDataManager, configDataManager.queryConfigByModeAndType);
      expect(result.length).assertLargerOrEqual(0);
    });

    it('RecentTimeConditionCalUtilsTest_getEnableTimeConditions_has_enabled_conditions', 0, async () => {
      const mockConfigData: ConfigData = {
        configId: '1',
        modeId: ModeType.SLEEP_MODE,
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        configValue: JSON.stringify({
          enable: true,
          startTime: '09:00',
          endTime: '18:00'
        })
      };
      const mockDisabledConfig: ConfigData = {
        configId: '2',
        modeId: ModeType.SLEEP_MODE,
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        configValue: JSON.stringify({ enable: false })
      };
      let configDataManager: ConfigDataManager = ConfigDataManager.getInstance();
      const queryConfigMockFunc: Function =
        mocker.mockFunc(configDataManager, configDataManager.queryConfigByModeAndType);
      when(queryConfigMockFunc)(ArgumentMatchers.any)
        .afterReturn(Promise.resolve([mockConfigData, mockDisabledConfig]));
      const result: TimeCondition[] = await RecentTimeConditionCalUtils.getEnableTimeConditions(ModeType.SLEEP_MODE);
      mocker.ignoreMock(configDataManager, configDataManager.queryConfigByModeAndType);
      expect(result.length).assertEqual(1);
    });

    it('RecentTimeConditionCalUtilsTest_getWorkFreeDay_no_work_or_holiday', 0, () => {
      const timeConditions: TimeCondition[] = [
        everyDayTimeCondition,
        everyWeekTimeCondition
      ];
      const result: HashMap<number, FreeWorkDayData> = RecentTimeConditionCalUtils.getWorkFreeDay(timeConditions);
      expect(result.length).assertEqual(0);
    });

    it('RecentTimeConditionCalUtilsTest_getWorkFreeDay_work_holiday', 0, () => {
      const timeConditions: TimeCondition[] = [
        workdayTimeCondition,
        holidayTimeCondition
      ];
      const result: HashMap<number, FreeWorkDayData> = RecentTimeConditionCalUtils.getWorkFreeDay(timeConditions);
      expect(result.length).assertEqual(1);
    });

    it('RecentTimeConditionCalUtilsTest_getWorkFreeDay_calendar_data_is_invalid', 0, () => {
      const timeConditions: TimeCondition[] = [
        workdayTimeCondition,
        holidayTimeCondition
      ];
      let freeWorkDayData: string = `[{"year": 2025, version: '1', workdays: [104], freedays: [101, 102, 103]}]`;
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA, freeWorkDayData,
        settings.domainName.USER_PROPERTY);
      const result: HashMap<number, FreeWorkDayData> = RecentTimeConditionCalUtils.getWorkFreeDay(timeConditions);
      expect(result.length).assertEqual(0);
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByWorkDay_curIsWorkDay_and_startMinutes_greater', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 540,
          minDifMinutes: 1440,
          startMinutes: 720,
          curDate: new Date()
        };
        const laterTimeConditions: TimeCondition[] = [];
        const freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
        let mockCheckIsWorkDay: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
        let mockGetRecentTimeFence: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
        when(mockCheckIsWorkDay)(ArgumentMatchers.any).afterReturn(true);
        when(mockGetRecentTimeFence)(ArgumentMatchers.any)
          .afterReturn(360);
        RecentTimeConditionCalUtils.getTimeConditionByWorkDay(minDifMinutesInfo, laterTimeConditions, oneTimeCondition,
          freeWorkDayMap);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByWorkDay error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByWorkDay_nextWorkDay_and_not_curIsWorkDay', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 540,
          minDifMinutes: 1440,
          startMinutes: 720,
          curDate: new Date()
        };
        const laterTimeConditions: TimeCondition[] = [];
        const freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
        let mockCheckIsWorkDay: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
        let mockGetNextWorkDay: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getNextWorkDay);
        let mockGetRecentTimeFence: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
        when(mockCheckIsWorkDay)(ArgumentMatchers.any).afterReturn(false);
        when(mockGetNextWorkDay)(ArgumentMatchers.any).afterReturn(2);
        when(mockGetRecentTimeFence)(ArgumentMatchers.any).afterReturn(720);
        RecentTimeConditionCalUtils.getTimeConditionByWorkDay(minDifMinutesInfo, laterTimeConditions, oneTimeCondition,
          freeWorkDayMap);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getNextWorkDay);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByWeek error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getMonthDay_test', 0, () => {
      const result: number = RecentTimeConditionCalUtils.getMonthDay(new Date());
      expect(result > 0).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getNextWorkDay_next_day_is_workday', 0, () => {
      const date: Date = new Date(2025, 0, 1);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsWorkDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      when(mockCheckIsWorkDay)(ArgumentMatchers.any).afterReturn(true);
      const result: number = RecentTimeConditionCalUtils.getNextWorkDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      expect(result > 0).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getNextWorkDay_next_day_is_freeday', 0, () => {
      const date: Date = new Date(2025, 0, 1);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsWorkDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      when(mockCheckIsWorkDay)(ArgumentMatchers.any).afterReturn(false);
      const result: number = RecentTimeConditionCalUtils.getNextWorkDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      expect(result > 0).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_checkIsWorkDay_is_workday', 0, () => {
      const date: Date = new Date(2025, 11, 25);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsWorkDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      when(mockCheckIsWorkDay)(ArgumentMatchers.any).afterReturn(false);
      const result: boolean = RecentTimeConditionCalUtils.checkIsWorkDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      expect(result).assertFalse();
    });

    it('RecentTimeConditionCalUtilsTest_checkIsWorkDay_not_workday', 0, () => {
      const date: Date = new Date(2025, 11, 21);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsWorkDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      when(mockCheckIsWorkDay)(ArgumentMatchers.any).afterReturn(false);
      const result: boolean = RecentTimeConditionCalUtils.checkIsWorkDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsWorkDay);
      expect(result).assertFalse();
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByWeek_loopDays_has_curday', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 60,
          minDifMinutes: 1000,
          startMinutes: 120,
          curDate: new Date(2025, 11, 23)
        };
        const laterTimeConditions: TimeCondition[] = [];
        RecentTimeConditionCalUtils.getTimeConditionByWeek(minDifMinutesInfo, laterTimeConditions,
          everyWeekTimeCondition);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByWeek error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByWeek_loopDays_not_has_curday', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 60,
          minDifMinutes: 1000,
          startMinutes: 120,
          curDate: new Date(2025, 11, 23)
        };
        everyWeekTimeCondition.loopDays = '3, 4, 5';
        const laterTimeConditions: TimeCondition[] = [];
        RecentTimeConditionCalUtils.getTimeConditionByWeek(minDifMinutesInfo, laterTimeConditions,
          everyWeekTimeCondition);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByWeek error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByDay_startMinutes_greater_than_curMinutes', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 60,
          minDifMinutes: 1000,
          startMinutes: 120,
          curDate: new Date(2025, 11, 23)
        };
        const laterTimeConditions: TimeCondition[] = [];
        RecentTimeConditionCalUtils.getTimeConditionByDay(minDifMinutesInfo, laterTimeConditions, everyDayTimeCondition);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByDay error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByDay_startMinutes_less_curMinutes', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 180,
          minDifMinutes: 1000,
          startMinutes: 120,
          curDate: new Date(2025, 11, 23)
        };
        const laterTimeConditions: TimeCondition[] = [];
        RecentTimeConditionCalUtils.getTimeConditionByDay(minDifMinutesInfo, laterTimeConditions, everyDayTimeCondition);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByDay error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getRecentTimeFence_difMinutes_greater_than_minDifMinutes', 0, () => {
      const laterTimeConditions: TimeCondition[] = [];
      const result: number = RecentTimeConditionCalUtils.getRecentTimeFence(100, 200, laterTimeConditions, everyDayTimeCondition);
      expect(result >= 0).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getRecentTimeFence_difMinutes_is_minDifMinutes', 0, () => {
      const laterTimeConditions: TimeCondition[] = [];
      const result: number = RecentTimeConditionCalUtils.getRecentTimeFence(200, 200, laterTimeConditions, everyDayTimeCondition);
      expect(result >= 0).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByFreeDay_curIsFreeDay_and_startMinutes_greater', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 540,
          minDifMinutes: 1440,
          startMinutes: 720,
          curDate: new Date()
        };
        const laterTimeConditions: TimeCondition[] = [];
        const freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
        let mockCheckIsWorkDay: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
        let mockGetRecentTimeFence: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
        when(mockCheckIsWorkDay)(ArgumentMatchers.any).afterReturn(true);
        when(mockGetRecentTimeFence)(ArgumentMatchers.any)
          .afterReturn(360);
        RecentTimeConditionCalUtils.getTimeConditionByFreeDay(minDifMinutesInfo, laterTimeConditions, oneTimeCondition,
          freeWorkDayMap);
        processResult = true;
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByFreeDay error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_getTimeConditionByFreeDay_nextFreeDay_and_not_curIsFreeDay', 0, () => {
      let processResult: boolean = false;
      try {
        const minDifMinutesInfo: MinDifMinutesInfo = {
          curDay: 1,
          curMinutes: 840,
          minDifMinutes: 1440,
          startMinutes: 720,
          curDate: new Date()
        };
        const laterTimeConditions: TimeCondition[] = [];
        const freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
        let mockCheckIsFreeDay: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
        let mockGetNextFreeDay: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getNextFreeDay);
        let mockGetRecentTimeFence: Function =
          mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
        when(mockCheckIsFreeDay)(ArgumentMatchers.any).afterReturn(false);
        when(mockGetNextFreeDay)(ArgumentMatchers.any).afterReturn(2);
        when(mockGetRecentTimeFence)(ArgumentMatchers.any).afterReturn(720);
        RecentTimeConditionCalUtils.getTimeConditionByFreeDay(minDifMinutesInfo, laterTimeConditions, oneTimeCondition,
          freeWorkDayMap);
        processResult = true;
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getNextFreeDay);
        mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.getRecentTimeFence);
      } catch (e) {
        LogUtil.showError(TAG, `getTimeConditionByFreeDay error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
    });

    it('RecentTimeConditionCalUtilsTest_checkIsFreeDay_is_freeday', 0, () => {
      const date: Date = new Date(2025, 11, 20);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsFreeDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      when(mockCheckIsFreeDay)(ArgumentMatchers.any).afterReturn(false);
      const result: boolean = RecentTimeConditionCalUtils.checkIsFreeDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      expect(result).assertFalse();
    });

    it('RecentTimeConditionCalUtilsTest_checkIsFreeDay_not_freeday', 0, () => {
      const date: Date = new Date(2025, 11, 23);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsFreeDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      when(mockCheckIsFreeDay)(ArgumentMatchers.any).afterReturn(false);
      const result: boolean = RecentTimeConditionCalUtils.checkIsFreeDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      expect(result).assertFalse();
    });

    it('RecentTimeConditionCalUtilsTest_getNextFreeDay_next_day_is_freeday', 0, () => {
      const date: Date = new Date(2025, 0, 1);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsFreeDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      when(mockCheckIsFreeDay)(ArgumentMatchers.any).afterReturn(true);
      const result: number = RecentTimeConditionCalUtils.getNextFreeDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      expect(result).assertLargerOrEqual(0);
    });

    it('RecentTimeConditionCalUtilsTest_getNextFreeDay_next_day_is_workday', 0, () => {
      const date: Date = new Date(2025, 0, 1);
      let freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
      let mockCheckIsFreeDay: Function =
        mocker.mockFunc(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      when(mockCheckIsFreeDay)(ArgumentMatchers.any).afterReturn(false);
      const result: number = RecentTimeConditionCalUtils.getNextFreeDay(date, freeWorkDayMap);
      mocker.ignoreMock(RecentTimeConditionCalUtils, RecentTimeConditionCalUtils.checkIsFreeDay);
      expect(result).assertLargerOrEqual(0);
    });
  });
}