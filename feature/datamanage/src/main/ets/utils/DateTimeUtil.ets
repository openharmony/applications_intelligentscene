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

import { settings } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';

const TAG = 'DateTimeUtil';
/**
 * 时间未设置
 */
export const SCHEDULED_POWER_TIME_NOT_SET: string = '-1';
/**
 * 日历信息（法定工作日）
 */
export const SCHEDULED_POWER_ON_OFF_CALENDAR_DATA: string = 'recessInfo';

/*
 * 日期时间工具类
 */
export class DateTimeUtil {
  static getCurrentTimeStamp(): number {
    return new Date().getTime();
  }

  /**
   * 日期转换为yyyy-mm-dd格式
   * @param Date 对象
   * @returns 返回对应的 dateString 日期字符串
   */
  static formatDateToString(date: Date): string {
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const formattedDate = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
    return formattedDate;
  }

  /**
   * 时间字符串hh:mm格式检验
   * @param string 对象
   * @returns 返回对应的 boolean 日期字符串
   */
  static validateTimeFormat(timeStr: string): boolean {
    // 定义正则表达式来匹配 HH:MM 格式
    const pattern = /^([01]?[0-9]|2[0-3]):([0-5][0-9])$/;
    return pattern.test(timeStr);
  }

  /**
   * 将 YYYY-MM-DD 格式的字符串日期转换为 Date 对象
   * @param dateString 日期字符串，格式为 "YYYY-MM-DD"
   * @returns 返回对应的 Date 对象
   */
  static parseStringToDate(dateString: string): Date {
    const date: Date = new Date(dateString);
    // 检查日期是否有效
    if (isNaN(date.getTime())) {
      LogUtil.showError(TAG, 'Invalid date string. Expected format: YYYY-MM-DD');
      return new Date();
    }
    return date;
  }

  /**
   * 将时间段字符串转为Date时间段
   * @param 基线Date，时间段字符串 startTime, endTime
   * @returns 返回对应的 Date 时间段对象 startDate, endDate
   */
  static parseTimeRange(baseDate: Date, startTime: string, endTime: string): Date[] {
    if (!DateTimeUtil.validateTimeFormat(startTime) || !DateTimeUtil.validateTimeFormat(endTime)) {
      LogUtil.showError(TAG, 'Invalid time string. Expected format: hh:mm');
      return [new Date(), new Date()];
    }
    const startParts: string[] = startTime.split(':');
    const startHour: number = parseInt(startParts[0], 10);
    const startMinute: number = parseInt(startParts[1], 10);

    const endParts: string[] = endTime.split(':');
    const endHour: number = parseInt(endParts[0], 10);
    const endMinute: number = parseInt(endParts[1], 10);

    let startDate: Date = new Date(baseDate);
    startDate.setHours(startHour, startMinute, 0, 0);
    let endDate: Date = new Date(baseDate);
    endDate.setHours(endHour, endMinute, 0, 0);

    // 判断时间段是否跨天
    if (endDate <= startDate) {
      // 时间段跨天，结束时间需要加一天
      endDate.setDate(endDate.getDate() + 1);
    }
    return [startDate, endDate];
  }

  /**
   * 获取离指定时间段最近的一天的日期
   * @param startTime 开始时间，格式为 "HH:mm"（例如 "18:00"）
   * @param endTime 结束时间，格式为 "HH:mm"（例如 "21:00"）
   * @returns 返回最近的一天的日期，格式为 "YYYY-MM-DD"
   */
  static getNearestDateInRange(startTime: string, endTime: string): string {
    if (!DateTimeUtil.validateTimeFormat(startTime) || !DateTimeUtil.validateTimeFormat(endTime)) {
      LogUtil.showError(TAG, 'Invalid time string. Expected format: hh:mm');
      return DateTimeUtil.formatDateToString(new Date());
    }
    // 获取当前时间
    const now: Date = new Date();
    const dateRange: Date[] = DateTimeUtil.parseTimeRange(now, startTime, endTime);
    const startDate: Date = dateRange[0];
    const endDate: Date = dateRange[1];

    // 判断时间段是否跨天
    if (endDate < startDate) {
      // 时间段跨天，输出今天的日期
      return DateTimeUtil.formatDateToString(now);
    } else {
      // 时间段没有跨天
      if (now > endDate) {
        // 当前时间在结束时间之后，输出明天的日期
        let tomorrow: Date = new Date(now);
        tomorrow.setDate(now.getDate() + 1);
        return DateTimeUtil.formatDateToString(tomorrow);
      } else {
        // 当前时间在结束时间之前或等于结束时间，输出今天的日期
        return DateTimeUtil.formatDateToString(now);
      }
    }
  }

  public static hasHolidayInfo(): boolean {
    return DateTimeUtil.getHolidayInfo() !== SCHEDULED_POWER_TIME_NOT_SET;
  }

  public static getHolidayInfo(): string {
    LogUtil.showInfo(TAG, 'getHolidayInfo start.');
    const calendarData: string =
      SettingsDataUtils.getSettingsData(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `getHolidayInfo end ${calendarData}`);
    return calendarData;
  }

  public static setHolidayInfo(holidayInfo: string): void {
    LogUtil.showInfo(TAG, 'setHolidayInfo start.');
    if (!holidayInfo) {
      LogUtil.showWarn(TAG, 'invalid holidayInfo');
      return;
    }
    SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA, holidayInfo,
      settings.domainName.USER_PROPERTY);
  }
}