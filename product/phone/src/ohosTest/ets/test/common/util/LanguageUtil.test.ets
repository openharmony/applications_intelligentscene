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
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils'
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil'

export default function LanguageUtilTest() {
  describe('LanguageUtilTest', () => {
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

    it('LanguageUtilTest_test', 0, test);

    it('LanguageUtilTest_test2', 0, () => {
      const flag: boolean = LanguageUtils.isSystemLanguageBo();
      expect(flag !== undefined).assertTrue();
    });

    it('LanguageUtilTest_getLocalLanguage', 0, () => {
      const language: string = LanguageUtils.getLocalLanguage();
      LanguageUtils.getSystemLanguage();
      expect(language.length >= 0).assertTrue();
    });
  })
}

function test() {
  LanguageUtils.isRtlDirection();
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
}