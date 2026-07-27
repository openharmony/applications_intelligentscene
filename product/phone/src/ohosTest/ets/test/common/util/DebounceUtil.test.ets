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
  beforeEach,
  afterEach,
  it,
  expect
} from '@ohos/hypium';
import { Driver } from '@ohos.UiTest';
import { DebounceUtil } from '@ohos/scene.common/src/main/ets/utils/DebounceUtil';
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

const driver: Driver = Driver.create();
const COMMON_DELAY: number = 1000;
let testDebounce: number = 1;

export default function DebounceUtilTest() {
  describe('DebounceUtilTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('sleep', 0, async (done: Function) => {
      let time: number = DateTimeUtil.getCurrentTimeStamp();
      DebounceUtil.sleep(COMMON_DELAY).then(() => {
        let sleepTime: number = DateTimeUtil.getCurrentTimeStamp();
        expect(sleepTime - time >= COMMON_DELAY).assertTrue();
      });
      done();
    });

    it('debounce', 0, async (done: Function) => {
      testDebounce = 1;
      DebounceUtil.debounce(debounceTest, 0);
      DebounceUtil.debounce(debounceTest, 0);
      driver.delayMs(COMMON_DELAY)
      expect(testDebounce).assertLessOrEqual(2);
      done();
    });

    it('debouncePromise', 0, async (done: Function) => {
      testDebounce = 1;
      await DebounceUtil.debouncePromise(debounceTest);
      await DebounceUtil.debouncePromise(debounceTest);
      driver.delayMs(COMMON_DELAY)
      expect(testDebounce).assertLessOrEqual(2);
      done();
    });

    it('DebounceUtilTest_test', 0, test);
  });
}

export function debounceTest(a: string, b: string): void {
  testDebounce++;
}

export function debounceTest2(a: string): void {
}

function test() {
  DebounceUtil.debounce(debounceTest2, 1000);
  DebounceUtil.debounce(debounceTest, 1000);
  DebounceUtil.debouncePromise(debounceTest2);
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
}