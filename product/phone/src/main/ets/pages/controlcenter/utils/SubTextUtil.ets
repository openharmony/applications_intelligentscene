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
import Intl from '@ohos.intl';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';

const TAG: string = 'SubTextUtil:';

/**
 * 控制中心辅助文本工具类
 */
export class SubTextUtil {
  /**
   * 专门用于控制中心时间展示的 timeFormat 对象
   */
  public static timeFormat: Intl.DateTimeFormat = new Intl.DateTimeFormat(
    '',
    {
      hour: '2-digit', // 保留2位
      minute: '2-digit', // 保留2位
      hourCycle: I18n.System.is24HourClock() ? 'h23' : 'h12',
      dayPeriod: 'long', // 区分上午/下午
    },
  );

  /**
   * 获取[开启至13:00]文本字串
   */
  static getOpenToTimeText(date: Date): string {
    const nowMinutes: number = SubTextUtil.getMinutesByDate(new Date());
    const endMinutes: number = SubTextUtil.getMinutesByDate(date);
    if (nowMinutes < endMinutes) {
      return ResourceUtil.getFormatStringSync($r('app.string.open_to_time'), SubTextUtil.timeFormat.format(date));
    } else {
      return ResourceUtil.getFormatStringSync($r('app.string.open_to_next_day_time'),
        SubTextUtil.timeFormat.format(date));
    }
  }

  /**
   * 获取[1:00-2:00]文本字串
   */
  static getTimeSegmentText(startDate: Date, endDate: Date): string {
    const startMinutes: number = SubTextUtil.getMinutesByDate(startDate);
    const nowMinutes: number = SubTextUtil.getMinutesByDate(new Date());
    const endMinutes: number = SubTextUtil.getMinutesByDate(endDate);
    if (nowMinutes < startMinutes) {
      return ResourceUtil.getAnyStrFormatStringSync($r('app.string.yesterday_time_range'),
        SubTextUtil.timeFormat.format(startDate), SubTextUtil.timeFormat.format(endDate));
    } else {
      return nowMinutes < endMinutes ?
        `${SubTextUtil.timeFormat.format(startDate)}-${SubTextUtil.timeFormat.format(endDate)}` :
      ResourceUtil.getAnyStrFormatStringSync($r('app.string.zen_mode_ruletime_nextday'),
        SubTextUtil.timeFormat.format(startDate), SubTextUtil.timeFormat.format(endDate));
    }
  }

  /**
   * 获取[下午7:00前保持打开]文本字串
   */
  static getToTonightText(): string {
    const nowDate = new Date();
    nowDate.setHours(19, 0, 0, 0);
    return ResourceUtil.getFormatStringSync($r('app.string.to_tonight_hint'), SubTextUtil.timeFormat.format(nowDate));
  }

  /**
   * 根据日期对象获取当前一天的分钟数
   */
  static getMinutesByDate(date: Date): number {
    const hours = date.getHours();
    const minutes = date.getMinutes();
    return hours * 60 + minutes;
  }

  /**
   * 根据时间字串获取 Date 对象
   *
   * @param timeStr xx:xx (24小时制/数字形式)
   * @returns Date 对象
   */
  static getDateByTimeStr(timeStr: string): Date {
    LogUtil.showInfo(TAG, `getDateByTimeStr. timeStr:${timeStr}`);
    const arr = timeStr?.split(':') || [];
    const hours = Number.parseInt(arr[0] || '0');
    const min = Number.parseInt(arr[1] || '0');
    const nowDate = new Date();
    nowDate.setHours(hours, min, 0, 0);
    return nowDate;
  }

  /**
   * 是否显示至今晚的选项
   */
  static isShowTonight(date: Date = new Date()): boolean {
    const startDate = new Date();
    startDate.setHours(0, 0, 0, 0);
    const endDate = new Date();
    endDate.setHours(19, 0, 0, 0);
    LogUtil.showInfo(TAG, `isShowTonight. startDate:${startDate} date:${date} endDate:${endDate}`);
    return date >= startDate && date < endDate;
  }
}

