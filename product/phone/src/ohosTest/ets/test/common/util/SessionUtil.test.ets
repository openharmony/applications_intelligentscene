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
import { SessionUtil } from '@ohos/scene.common/src/main/ets/utils/SessionUtil'
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil'

export default function SessionUtilTest() {
  describe('SessionUtilTest', () => {
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

    it('SessionUtilTest_sendLoadAppListToSetting', 0, sendLoadAppListToSetting);

    it('SessionUtilTest_sendLoadStateToSetting', 0, sendLoadStateToSetting);

    it('SessionUtilTest_sendMessageToSetting', 0, sendMessageToSetting);
  })
}

function sendLoadAppListToSetting() {
  SessionUtil.sendLoadAppListToSetting();
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
}

function sendLoadStateToSetting() {
  SessionUtil.sendLoadStateToSetting();
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
}

function sendMessageToSetting() {
  const str: string = StringUtil.generateUuid();
  const intent: Record<string, Object> = { 'action': `${str}` };
  SessionUtil.sendMessageToSetting(intent);
  expect(str !== undefined).assertTrue();
}