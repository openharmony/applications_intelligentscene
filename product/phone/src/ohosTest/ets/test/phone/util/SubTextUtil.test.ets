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
  it,
  expect,
} from '@ohos/hypium'
import { LogUtil } from '@ohos/scene.common'
import { SubTextUtil } from '../../../../../main/ets/pages/controlcenter/utils/SubTextUtil';

const TAG: string = 'SubTextUtilTest: ';

export default function SubTextUtilTest() {
  describe('SubTextUtilTest', () => {
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

    it('SubTextUtilTest_getOpenToTimeText', 0, getOpenToTimeText);

    it('SubTextUtilTest_getTimeSegmentText', 0, getTimeSegmentText);

    it('SubTextUtilTest_getToTonightText', 0, getToTonightText);

    it('SubTextUtilTest_getMinutesByDate', 0, getMinutesByDate);

    it('SubTextUtilTest_isShowTonight', 0, isShowTonight);
  })
}

function getOpenToTimeText() {
  const text: string = SubTextUtil.getOpenToTimeText(new Date());
  LogUtil.showInfo(TAG, `getOpenToTimeText: ${text}`);
  SubTextUtil.getOpenToTimeText(new Date('2026-01-26 23:59:59'));
  expect(text !== undefined).assertTrue();
}

function getTimeSegmentText() {
  const startTimeDate = SubTextUtil.getDateByTimeStr('07:00');
  const endTimeDate = SubTextUtil.getDateByTimeStr('12:00');
  const timeText: string = SubTextUtil.getTimeSegmentText(startTimeDate, endTimeDate);
  LogUtil.showInfo(TAG, `getTimeSegmentText: ${timeText}`);
  const startTimeDate2 = SubTextUtil.getDateByTimeStr('23:59');
  SubTextUtil.getTimeSegmentText(startTimeDate2, endTimeDate);
  expect(timeText !== undefined).assertTrue();
}

function getToTonightText() {
  const text: string = SubTextUtil.getToTonightText();
  LogUtil.showInfo(TAG, `getToTonightText: ${text}`);
  expect(text !== undefined).assertTrue();
}

function getMinutesByDate() {
  const text: number = SubTextUtil.getMinutesByDate(new Date());
  expect(text > 0).assertTrue();
}

function isShowTonight() {
  const date: Date = new Date();
  date.setHours(17, 0, 0, 0);
  const isShowTonight: boolean = SubTextUtil.isShowTonight(date);
  expect(isShowTonight).assertTrue();
}
