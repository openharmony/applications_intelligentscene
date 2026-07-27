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
import settings from '@ohos.settings';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { TimeCondition, LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { TimePickerUtil, WeekDayFormat } from '@ohos/scene.configmanage/src/main/ets/utils/TimePickerUtil';
import { NotDisturbUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/NotDisturbUtils';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { ConfigData, EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import {
  SCHEDULED_POWER_ON_OFF_CALENDAR_DATA,
  SCHEDULED_POWER_TIME_NOT_SET
} from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import { FreeWorkDayData, MinDifMinutesInfo } from '../model/FormControlData';

const TAG: string = 'RecentTimeConditionCalUtils: ';
const DAY_HOUR: number = 24;
const HOUR_MINUTE: number = 60;
const WORK_DAY: number[] = [1, 2, 3, 4, 5];
const FREE_DAY: number[] = [0, 6];
const MAX_WEEK_FREE_DAY: number = 30;
const MONTH_HUNDRED: number = 100;
const MAX_MINUTE: number = Number.MAX_VALUE;
const MAX_WEEK_INDEX: number = 6;
const WEEK_DAY: number = 7;

export class RecentTimeConditionCalUtils {
  /**
   * 获取距离当前时间最近且已开启的时间围栏
   * @param modeId 模式ID
   * @returns 周一23:00-周二07:00
   */
  static async getRecentEnableTimeConditionDescription(modeId: string, language: string | undefined): Promise<string> {
    LogUtil.showInfo(TAG, `getRecentEnableTimeConditionDescription modeId ${modeId} language ${language}`);
    if (!modeId) {
      return '';
    }
    // 获取已开启的时间围栏
    const enableTimeConditions: TimeCondition[] = await RecentTimeConditionCalUtils.getEnableTimeConditions(modeId);
    if (!enableTimeConditions?.length) {
      return '';
    }
    const curDate: Date = new Date();
    LogUtil.showInfo(TAG, `newFormModeData timeConditions ${enableTimeConditions.length}`);
    let minDifMinutesInfo: MinDifMinutesInfo = {
      curDay: curDate.getDay(),
      curMinutes: curDate.getHours() * HOUR_MINUTE + curDate.getMinutes(),
      minDifMinutes: MAX_MINUTE,
      startMinutes: 0,
      curDate: curDate
    };
    // 获取已开启围栏中距离当前时间最近的一次时间围栏（开始时间相同取结束时间最晚的一条记录）
    let laterTimeCondition: TimeCondition | undefined =
      RecentTimeConditionCalUtils.getRecentTimeCondition(enableTimeConditions, minDifMinutesInfo);
    if (!laterTimeCondition) {
      return '';
    }
    // 将最近的时间围栏信息转换为周几加时间的格式 示例（周一23:00-周二07:00）
    return RecentTimeConditionCalUtils.getFormatTimeCondition(laterTimeCondition, language);
  }

  static getRecentTimeCondition(timeConditions: TimeCondition[],
    minDifMinutesInfo: MinDifMinutesInfo): TimeCondition | undefined {
    LogUtil.showInfo(TAG, 'getLaterTimeConditions');
    let laterTimeConditions: TimeCondition[] = [];
    let freeWorkDayMap: HashMap<number, FreeWorkDayData> = RecentTimeConditionCalUtils.getWorkFreeDay(timeConditions);
    timeConditions.forEach(timeCondition => {
      let timeArray: string[] = timeCondition.timeStart.split(':');
      let startMinutes: number = Number(timeArray[0]) * HOUR_MINUTE + Number(timeArray[1]);
      minDifMinutesInfo.startMinutes = startMinutes;
      switch (timeCondition.loopType) {
        case LoopType.ONE_TIME:
        case LoopType.EVERY_DAY:
          // 获取 单次/每天 最近的时间围栏数据
          RecentTimeConditionCalUtils.getTimeConditionByDay(minDifMinutesInfo, laterTimeConditions, timeCondition);
          break;
        case LoopType.EVERY_WEEK:
          // 获取 每周 最近的时间围栏数据
          RecentTimeConditionCalUtils.getTimeConditionByWeek(minDifMinutesInfo, laterTimeConditions, timeCondition);
          break;
        case LoopType.WORKDAY:
          // 获取 法定工作日 最近的时间围栏数据
          RecentTimeConditionCalUtils.getTimeConditionByWorkDay(minDifMinutesInfo, laterTimeConditions, timeCondition,
            freeWorkDayMap);
          break;
        case LoopType.HOLIDAY:
          // 获取 法定休息日 最近的时间围栏数据
          RecentTimeConditionCalUtils.getTimeConditionByFreeDay(minDifMinutesInfo, laterTimeConditions, timeCondition,
            freeWorkDayMap);
          break;
        default:
          break;
      }
    });
    LogUtil.showInfo(TAG, `getLaterTimeConditions laterTimeConditions ${laterTimeConditions.length}`);
    if (laterTimeConditions.length === 0) {
      return undefined;
    }
    // 存在多条最近的时间围栏时，取结束时间最晚的一条记录
    let laterTimeCondition: TimeCondition = laterTimeConditions[0];
    for (let index: number = 1; index < laterTimeConditions.length; index++) {
      if (!RecentTimeConditionCalUtils.isNextDay(laterTimeCondition.timeEnd, laterTimeConditions[index].timeEnd)) {
        laterTimeCondition = laterTimeConditions[index];
      }
    }
    return laterTimeCondition;
  }

  /**
   * 将最近的时间围栏信息转换为周几加时间的格式 示例（周一23:00-周二07:00）
   */
  static getFormatTimeCondition(timeCondition: TimeCondition, language: string | undefined): string {
    LogUtil.showInfo(TAG, 'getCardTimeCondition');
    const weekDayFormat = WeekDayFormat.Short;
    const timeStart: string = timeCondition.timeStart;
    const timeEnd: string = timeCondition.timeEnd;
    const startDay: number = Number(timeCondition.loopDays);
    let endDay: number = startDay;
    if (RecentTimeConditionCalUtils.isNextDay(timeStart, timeEnd)) {
      endDay = (startDay + 1) > MAX_WEEK_INDEX ? 0 : (startDay + 1);
    }
    let startWeekDay: string;
    let endWeekDay: string;
    if (language) {
      startWeekDay = TimePickerUtil.getDayOfWeekByLanguage(startDay, weekDayFormat, language);
      endWeekDay = TimePickerUtil.getDayOfWeekByLanguage(endDay, weekDayFormat, language);
    } else {
      startWeekDay = TimePickerUtil.getDayOfWeek(startDay, weekDayFormat);
      endWeekDay = TimePickerUtil.getDayOfWeek(endDay, weekDayFormat);
    }
    const startTime: string = startWeekDay + timeStart;
    const endTime: string = endWeekDay + timeEnd;
    return ResourceUtil.getAnyStrFormatStringSync($r('app.string.timer_between'), startTime, endTime);
  }

  static isNextDay(startTime: string, endTime: string): boolean {
    LogUtil.showInfo(TAG, 'isNextDay');
    const timeStart: number[] = NotDisturbUtils.forMatTime(startTime);
    const timeEnd: number[] = NotDisturbUtils.forMatTime(endTime);
    return NotDisturbUtils.isNextDay(timeStart, timeEnd);
  }

  /**
   * 获取睡眠模式已开启的时间围栏
   */
  static async getEnableTimeConditions(modeId: string): Promise<TimeCondition[]> {
    LogUtil.showInfo(TAG, 'getEnableTimeConditions');
    let timeConditions: TimeCondition[] = [];
    let configDataList: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndType(modeId, ConfigType.TRIGGER_CONDITION_TIME);
    LogUtil.showInfo(TAG, `configDataList configDataList ${configDataList.length}`);
    if (!configDataList?.length) {
      return timeConditions;
    }
    configDataList.forEach(configData => {
      let enableStatus: EnableState = JsonUtil.fromJson(configData.configValue) as EnableState;
      if (!enableStatus.enable) {
        return;
      }
      let timeCondition: TimeCondition = JsonUtil.fromJson(configData.configValue) as TimeCondition;
      timeConditions.push(timeCondition);
    });
    return timeConditions;
  }

  /**
   * 获取法定工作日/休息日
   */
  static getWorkFreeDay(timeConditions: TimeCondition[]): HashMap<number, FreeWorkDayData> {
    LogUtil.showInfo(TAG, 'getWorkDay');
    const freeWorkDayMap: HashMap<number, FreeWorkDayData> = new HashMap();
    let hasWorkFreeDay: boolean = false;
    timeConditions.forEach(timeCondition => {
      if (timeCondition.loopType === LoopType.WORKDAY || timeCondition.loopType === LoopType.HOLIDAY) {
        hasWorkFreeDay = true;
      }
    });
    let calendarData: string = '';
    if (!hasWorkFreeDay) {
      return freeWorkDayMap;
    }
    calendarData =
      SettingsDataUtils.getSettingsData(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.USER_PROPERTY);
    try {
      const freeWorkDayDatas: FreeWorkDayData[] = JSON.parse(calendarData) as FreeWorkDayData[];
      for (let freeWorkDay of freeWorkDayDatas) {
        freeWorkDayMap.set(freeWorkDay.year, freeWorkDay);
      }
    } catch (error) {
      LogUtil.showError(TAG, `getWorkFreeDay json parse fail: ${error?.code}, ${error?.message}`);
    }
    return freeWorkDayMap;
  }

  /**
   * 获取 法定工作日 最近的时间围栏数据
   */
  static getTimeConditionByWorkDay(minDifMinutesInfo: MinDifMinutesInfo, laterTimeConditions: TimeCondition[],
    timeCondition: TimeCondition, freeWorkDayMap: HashMap<number, FreeWorkDayData>): void {
    LogUtil.showInfo(TAG, 'getTimeConditionByWorkDay');
    let curDate: Date = new Date(minDifMinutesInfo.curDate);
    const startMinutes: number = minDifMinutesInfo.startMinutes;
    const curMinutes: number = minDifMinutesInfo.curMinutes;
    let minDifMinutes: number = minDifMinutesInfo.minDifMinutes;
    const curIsWorkDay: boolean = RecentTimeConditionCalUtils.checkIsWorkDay(curDate, freeWorkDayMap);
    let difMinutes: number = 0;
    LogUtil.showInfo(TAG, `getTimeConditionByWorkDay curIsWorkDay ${curIsWorkDay}`);
    if (curIsWorkDay && startMinutes > curMinutes) {
      difMinutes = startMinutes - curMinutes;
    } else {
      const daysAfter: number = RecentTimeConditionCalUtils.getNextWorkDay(curDate, freeWorkDayMap);
      difMinutes = startMinutes + (daysAfter * DAY_HOUR * HOUR_MINUTE) - curMinutes;
      curDate.setDate(curDate.getDate() + daysAfter);
    }
    let day: number = curDate.getDay();
    timeCondition.loopDays = day.toString();
    minDifMinutes =
      RecentTimeConditionCalUtils.getRecentTimeFence(difMinutes, minDifMinutes, laterTimeConditions, timeCondition);
    minDifMinutesInfo.minDifMinutes = minDifMinutes;
  }

  /**
   * 格式化月份和日期  (2025-12-01) -> 1201
   */
  static getMonthDay(date: Date): number {
    return (date.getMonth() + 1) * MONTH_HUNDRED + date.getDate();
  }

  static getNextWorkDay(date: Date, freeWorkDayMap: HashMap<number, FreeWorkDayData>): number {
    LogUtil.showInfo(TAG, 'getNextWorkDay');
    let nextDate: Date = new Date(date);
    let isWork: boolean = false;
    let daysAfter: number = 0;
    while (!isWork) {
      daysAfter++;
      nextDate.setDate(nextDate.getDate() + 1);
      let isWorkDay: boolean = RecentTimeConditionCalUtils.checkIsWorkDay(nextDate, freeWorkDayMap);
      if (isWorkDay || daysAfter > MAX_WEEK_FREE_DAY) {
        isWork = true;
      }
    }
    return daysAfter;
  }

  static checkIsWorkDay(date: Date, freeWorkDayMap: HashMap<number, FreeWorkDayData>): boolean {
    const day: number = date.getDay();
    const fullYear: number = date.getFullYear();
    const curMonthDay: number = RecentTimeConditionCalUtils.getMonthDay(date);
    const curYearFreeWorkDay: FreeWorkDayData = freeWorkDayMap.get(fullYear);
    if (!curYearFreeWorkDay) {
      return WORK_DAY.includes(day);
    }
    const curYearFreeDays: number[] = curYearFreeWorkDay.freeday;
    const curYearWorkDays: number[] = curYearFreeWorkDay.workday;
    return (WORK_DAY.includes(day) && !curYearFreeDays.includes(curMonthDay)) ||
    curYearWorkDays.includes(curMonthDay);
  }

  /**
   * 获取 每周 最近的时间围栏数据
   */
  static getTimeConditionByWeek(minDifMinutesInfo: MinDifMinutesInfo, laterTimeConditions: TimeCondition[],
    timeCondition: TimeCondition): void {
    LogUtil.showInfo(TAG, 'getTimeConditionByWeek');
    let curDay: number = minDifMinutesInfo.curDay;
    let startMinutes: number = minDifMinutesInfo.startMinutes;
    let curMinutes: number = minDifMinutesInfo.curMinutes;
    let minDifMinutes: number = minDifMinutesInfo.minDifMinutes;
    let loopDays: string[] = timeCondition.loopDays.split(',');
    // 判断当天是否生效
    if (loopDays.includes(curDay.toString()) && startMinutes > curMinutes) {
      let difMinutes = startMinutes - curMinutes;
      timeCondition.loopDays = curDay.toString();
      minDifMinutes =
        RecentTimeConditionCalUtils.getRecentTimeFence(difMinutes, minDifMinutes, laterTimeConditions, timeCondition);
      minDifMinutesInfo.minDifMinutes = minDifMinutes;
      return;
    }
    for (let num = 1; num <= WEEK_DAY; num++) {
      let nextDay: number = curDay + num;
      if (nextDay > WEEK_DAY) {
        nextDay -= WEEK_DAY;
      }
      if (loopDays.includes(nextDay.toString())) {
        let difMinutes: number = startMinutes + (num * DAY_HOUR * HOUR_MINUTE) - curMinutes;
        timeCondition.loopDays = nextDay.toString();
        if (nextDay === WEEK_DAY) {
          timeCondition.loopDays = '0';
        }
        minDifMinutes =
          RecentTimeConditionCalUtils.getRecentTimeFence(difMinutes, minDifMinutes, laterTimeConditions, timeCondition);
        break;
      }
    }
    minDifMinutesInfo.minDifMinutes = minDifMinutes;
  }

  /**
   * 获取 单次/每天 最近的时间围栏数据
   */
  static getTimeConditionByDay(minDifMinutesInfo: MinDifMinutesInfo, laterTimeConditions: TimeCondition[],
    timeCondition: TimeCondition): void {
    LogUtil.showInfo(TAG, 'getTimeConditionByDay');
    let minDifMinutes: number = minDifMinutesInfo.minDifMinutes;
    if (minDifMinutesInfo.startMinutes > minDifMinutesInfo.curMinutes) {
      timeCondition.loopDays = minDifMinutesInfo.curDay.toString();
      let difMinutes: number = minDifMinutesInfo.startMinutes - minDifMinutesInfo.curMinutes;
      minDifMinutes =
        RecentTimeConditionCalUtils.getRecentTimeFence(difMinutes, minDifMinutes, laterTimeConditions, timeCondition);
    } else {
      let loopDay: number = (minDifMinutesInfo.curDay + 1) > MAX_WEEK_INDEX ? 0 :
        (minDifMinutesInfo.curDay + 1);
      timeCondition.loopDays = loopDay.toString();
      let difMinutes: number = minDifMinutesInfo.startMinutes + (DAY_HOUR * HOUR_MINUTE) - minDifMinutesInfo.curMinutes;
      minDifMinutes =
        RecentTimeConditionCalUtils.getRecentTimeFence(difMinutes, minDifMinutes, laterTimeConditions, timeCondition);
    }
    minDifMinutesInfo.minDifMinutes = minDifMinutes;
  }

  static getRecentTimeFence(difMinutes: number, minDifMinutes: number, laterTimeConditions: TimeCondition[],
    timeCondition: TimeCondition): number {
    if (difMinutes < minDifMinutes) {
      minDifMinutes = difMinutes;
      laterTimeConditions.splice(0, laterTimeConditions?.length);
      laterTimeConditions.push(timeCondition);
    } else if (difMinutes === minDifMinutes) {
      laterTimeConditions.push(timeCondition);
    }
    return minDifMinutes;
  }

  /**
   * 获取 法定休息日 最近的时间围栏数据
   */
  static getTimeConditionByFreeDay(minDifMinutesInfo: MinDifMinutesInfo, laterTimeConditions: TimeCondition[],
    timeCondition: TimeCondition, freeWorkDayMap: HashMap<number, FreeWorkDayData>): void {
    LogUtil.showInfo(TAG, 'getTimeConditionByFreeDay');
    let curDate: Date = new Date(minDifMinutesInfo.curDate);
    let startMinutes: number = minDifMinutesInfo.startMinutes;
    let curMinutes: number = minDifMinutesInfo.curMinutes;
    let minDifMinutes: number = minDifMinutesInfo.minDifMinutes;
    const curIsFreeDay: boolean = RecentTimeConditionCalUtils.checkIsFreeDay(curDate, freeWorkDayMap);
    LogUtil.showInfo(TAG, `getTimeConditionByFreeDay curIsFreeDay ${curIsFreeDay}`);
    let difMinutes: number = 0;
    if (curIsFreeDay && startMinutes > curMinutes) {
      difMinutes = startMinutes - curMinutes;
      minDifMinutes =
        RecentTimeConditionCalUtils.getRecentTimeFence(difMinutes, minDifMinutes, laterTimeConditions, timeCondition);
    } else {
      const daysAfter: number = RecentTimeConditionCalUtils.getNextFreeDay(curDate, freeWorkDayMap);
      difMinutes = startMinutes + (daysAfter * DAY_HOUR * HOUR_MINUTE) - curMinutes;
      curDate.setDate(curDate.getDate() + daysAfter);
    }
    let day: number = curDate.getDay();
    timeCondition.loopDays = day.toString();
    minDifMinutes =
      RecentTimeConditionCalUtils.getRecentTimeFence(difMinutes, minDifMinutes, laterTimeConditions, timeCondition);
    minDifMinutesInfo.minDifMinutes = minDifMinutes;
  }

  static checkIsFreeDay(date: Date, freeWorkDayMap: HashMap<number, FreeWorkDayData>): boolean {
    const day: number = date.getDay();
    const fullYear: number = date.getFullYear();
    let curMonthDay: number = RecentTimeConditionCalUtils.getMonthDay(date);
    const curYearFreeWorkDay: FreeWorkDayData = freeWorkDayMap.get(fullYear);
    if (!curYearFreeWorkDay) {
      return FREE_DAY.includes(day);
    }
    const curYearFreeDays: number[] = curYearFreeWorkDay.freeday;
    const curYearWorkDays: number[] = curYearFreeWorkDay.workday;
    return (FREE_DAY.includes(day) && !curYearWorkDays.includes(curMonthDay)) ||
    curYearFreeDays.includes(curMonthDay);
  }

  static getNextFreeDay(date: Date, freeWorkDayMap: HashMap<number, FreeWorkDayData>): number {
    LogUtil.showInfo(TAG, 'getNextFreeDay');
    let nextDate: Date = new Date(date);
    let isFree: boolean = false;
    let daysAfter: number = 0;
    while (!isFree) {
      daysAfter++;
      nextDate.setDate(nextDate.getDate() + 1);
      let isFreeDay: boolean = RecentTimeConditionCalUtils.checkIsFreeDay(nextDate, freeWorkDayMap);
      if (isFreeDay || daysAfter > MAX_WEEK_FREE_DAY) {
        isFree = true;
      }
    }
    return daysAfter;
  }
}
