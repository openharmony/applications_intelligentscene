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

import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it, expect,
} from '@ohos/hypium'
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil'
import { TimeUtil, TimeFormat } from '@ohos/scene.common/src/main/ets/utils/TimeUtil'
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil'

export default function TimeUtilTest() {
  describe('TimeUtilTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('TimeUtilTest_test', 0, test);
  })
}

function test() {
  let time: string = DateTimeUtil.getCurrentTimeStamp().toString();
  TimeUtil.getTimeStr(time);
  TimeUtil.getTimeStr('1630');

  TimeUtil.obtainFormatTime(time, TimeFormat.MONTH_DAY_NUMERIC);
  TimeUtil.obtainFormatTime(time, TimeFormat.HOUR_MINUTE);
  TimeUtil.obtainFormatTime(time, TimeFormat.MOTH_DAY_HOUR_MINUTE_SYSTEM);
  TimeUtil.obtainFormatTime(time, TimeFormat.HALF_BLOCK_HOUR_MINUTE);
  TimeUtil.obtainFormatTime(time, TimeFormat.YEAR_MONTH);

  TimeUtil.getTimeZone();
  TimeUtil.parseZoneNumberToStr(TimeUtil.getTimeZone());
  TimeUtil.isToday(DateTimeUtil.getCurrentTimeStamp());

  TimeUtil.getDateByTimeStr('1230');
  TimeUtil.getDateByTimeStr('12');

  TimeUtil.getDateByDateStr('20250331');
  TimeUtil.getDateByDateStr('202503');

  TimeUtil.getTimeStrByDate(new Date());

  TimeUtil.minutesToDate(0);
  TimeUtil.minutesToDate(420);
  TimeUtil.remainHourAndMinute('');
  TimeUtil.remainHourAndMinute('12:30:50');
  TimeUtil.remainHourAndMinute('12:30');
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
  TimeUtil.formatTimeMinute(-1);
  TimeUtil.fillTime(-1);
  TimeUtil.toMinutes('');
  TimeUtil.toMinutes('12:00:00');
  TimeUtil.formatTime('', { month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' });
  TimeUtil.toMinutes(':');
  TimeUtil.formatTimeMinute(420);
  TimeUtil.fillTime(9);
  TimeUtil.fillTime(19);
  TimeUtil.getDeviceBootTime();
  TimeUtil.isDateInWeek('1750064534570');
  TimeUtil.toMinutes('12:30');
  TimeUtil.isDateInWeek('');
  TimeUtil.isDateInWeek('-1');
}