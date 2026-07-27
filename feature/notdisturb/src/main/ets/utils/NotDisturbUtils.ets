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

import I18n from '@ohos.i18n';
import i18n from '@ohos.i18n';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { TimeUtil } from '@ohos/scene.common/src/main/ets/utils/TimeUtil';

/* instrument ignore file */
const TAG: string = 'NotDisturbUtils';
export const ONE_DAY = 1;
const HOUR_TO_MIN: number = 60;
const INDEX_HOUR: number = 0;
const INDEX_MIN: number = 1;
const DEFAULT_LOCALE_DAYS: number[] = [1, 2, 3, 4, 5, 6, 7];
export const FOCUS_MODE_REPEATE_CALLERS_ENABLE: string = 'focus_mode_repeate_callers_enable';
export const FOCUS_MODE_CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy';
export const FOCUS_MODE_ENABLED: string = 'focus_mode_enable';
export const FOCUS_MODE_MANUAL_ENABLE: string = 'focus_mode_manual_enable';
export const NOT_DISTURB_VALUE_ERROR: string = '-1';
export const NOT_DISTURB_VALUE_DISABLE: string = '0';
export const NOT_DISTURB_VALUE_ENABLE: string = '1';
export const NOT_DISTURB_VALUE_FORBID: string = '2'
export const ALLOW_FAVORITE_CONTACTS: string = '4';
export const NOT_DISTURB_NUMBER_MINUS: number = -1;
export const NOT_DISTURB_NUMBER_DEFAULT: number = 0;
export const NOT_DISTURB_NUMBER_ONE: number = 1;

export class NotDisturbUtils {

  /**
   * 格式化time的字符串
   *
   * @param timeStr 待格式化的字符串
   * @returns 小时和分钟
   */
  static forMatTime(timeStr: string): Array<number> {
    LogUtil.showInfo(TAG, `timeStr: ${timeStr}`);
    if (CheckEmptyUtils.checkStrIsEmpty(timeStr)) {
      return [0, 0];
    }
    if (timeStr.length > 5) {
      timeStr = timeStr.slice(2, 7);
    }
    let timeArray: string[] = timeStr.split(':');
    const hour: number = Number(timeArray[0]);
    const minute: number = Number(timeArray[1]);
    return [hour, minute];
  }

  public static getFormat(): Intl.DateTimeFormat {
    return new Intl.DateTimeFormat(
      new Intl.Locale(I18n.System.getSystemLanguage()).toString(),
      {
        timeStyle: 'short',
        hour12: !I18n.System.is24HourClock(),
        timeZone: i18n.getTimeZone().getID()
      });
  }

  public static getTimerSummary(format: Intl.DateTimeFormat, startTime: string, endTime: string): string {
    if (CheckEmptyUtils.isEmpty(format) || CheckEmptyUtils.isEmpty(startTime) || CheckEmptyUtils.isEmpty(endTime)) {
      return '';
    }
    LogUtil.showInfo(TAG, `getTimerSummary startTime:${startTime}-endTime:${endTime}`);
    const timeStart: number[] = NotDisturbUtils.forMatTime(startTime);
    const timeEnd: number[] = NotDisturbUtils.forMatTime(endTime);
    return NotDisturbUtils.getSummary(format, timeStart, timeEnd);
  }

  private static getSummary(format: Intl.DateTimeFormat, timeStart: number[], timeEnd: number[]): string {
    try {
      const startString: string = NotDisturbUtils.getTimeFormatString(format, timeStart);
      const endString: string = NotDisturbUtils.getTimeFormatString(format, timeEnd);
      if (NotDisturbUtils.isNextDay(timeStart, timeEnd)) {
        return ResourceUtil.getAnyStrFormatStringSync(
          $r('app.string.zen_mode_ruletime_nextday'), startString, endString);
      } else {
        return ResourceUtil.getAnyStrFormatStringSync(
          $r('app.string.timer_between'), startString, endString);
      }
    } catch (err) {
      LogUtil.showInfo(TAG, `getSummary error:${err?.message}`);
      return '';
    }
  }

  public static getTimeFormatString(format: Intl.DateTimeFormat, timeArray: number[]): string {
    try {
      const currentDate: Date = new Date();
      currentDate.setHours(timeArray[0], timeArray[1]);
      let formatString = TimeUtil.formatTime(currentDate, {
        hour: '2-digit',
        minute: '2-digit',
        dayPeriod: 'long',
      });
      return formatString;
    } catch (err) {
      LogUtil.showError(TAG, `getSummary error:${err?.message}`);
      return '';
    }
  }

  public static isNextDay(timeStart: number[], timeEnd: number[]): boolean {
    const startMin: number = HOUR_TO_MIN * timeStart[INDEX_HOUR] + timeStart[INDEX_MIN];
    const endMin: number = HOUR_TO_MIN * timeEnd[INDEX_HOUR] + timeEnd[INDEX_MIN];
    return startMin >= endMin;
  }

  /**
   * 获取当前需要展示的系统时间
   *
   * @param startTime 开始时间，永远是24小时制时间
   * @param endTime 结束时间，永远是24小时制时间
   * @returns 需要展示的系统时间字符串
   */
  public static getEndTimeSummary(startTime: string, endTime: string): string {
    const timeStart: number[] = NotDisturbUtils.forMatTime(startTime);
    const timeEnd: number[] = NotDisturbUtils.forMatTime(endTime);

    if (NotDisturbUtils.isNextDay(timeStart, timeEnd)) {
      return ResourceUtil.getFormatStringSync($r('app.string.not_disturb_nextday'),
        NotDisturbUtils.getSysFormatTime(endTime));
    }
    return NotDisturbUtils.getSysFormatTime(endTime);
  }

  /**
   * 获取和系统时间设置一致的时间格式
   *
   * @param time 待格式化的时间
   * @returns 系统格式化后的时间
   */
  public static getSysFormatTime(time: string) {
    const timeNumber: number[] = NotDisturbUtils.forMatTime(time);
    return NotDisturbUtils.getTimeFormatString(NotDisturbUtils.getFormat(), timeNumber);
  }

  public static getDateFromTime(time: string) {
    const timeNumber: number[] = NotDisturbUtils.forMatTime(time);
    const currentDate: Date = new Date();
    currentDate.setHours(timeNumber[0], timeNumber[1]);
    return currentDate;
  }
}