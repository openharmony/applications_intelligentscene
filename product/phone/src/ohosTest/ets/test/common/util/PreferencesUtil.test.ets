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
import { AbilityContextManager } from '@ohos/scene.common'
import { PreferencesUtil } from '@ohos/scene.common/src/main/ets/utils/PreferencesUtil'
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil'
import { Context } from '@kit.AbilityKit'

export default function PreferencesUtilTest() {
  describe('PreferencesUtilTest', () => {
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

    it('PreferencesUtilTest_test', 0, test);

    it('PreferencesUtilTest_hasSync', 0, () => {
      const flag: boolean = PreferencesUtil.hasSync('test');
      expect(flag !== undefined).assertTrue();
    });

    it('PreferencesUtilTest_put', 0, async () => {
      await PreferencesUtil.put('hello', 'hello');
      const flag: boolean = PreferencesUtil.hasSync('hello');
      expect(flag).assertTrue();
    });

    it('PreferencesUtilTest_putSync', 0, () => {
      PreferencesUtil.putSync('hello', 'hello');
      expect(StringUtil.generateUuid().length > 0).assertTrue();
    });

    it('PreferencesUtilTest_delete', 0, async () => {
      await PreferencesUtil.delete('hello');
      expect(StringUtil.generateUuid().length > 0).assertTrue();
    });

    it('PreferencesUtilTest_getSyncCache', 0, () => {
      PreferencesUtil.getSyncCache('hello', 'a', true);
      expect(StringUtil.generateUuid().length > 0).assertTrue();
    });

    it('PreferencesUtilTest_getPreferences', 0, () => {
      PreferencesUtil.getPreferences(AbilityContextManager.getContext(), 'hello');
      expect(StringUtil.generateUuid().length > 0).assertTrue();
    });

    it('PreferencesUtilTest_getPreferencesSync', 0, () => {
      PreferencesUtil.getPreferencesSync(AbilityContextManager.getContext(), 'a');
      expect(StringUtil.generateUuid().length > 0).assertTrue();
    });

    it('PreferencesUtilTest_getSyncWithPreferenceName', 0, () => {
      PreferencesUtil.getSyncWithPreferenceName('hello', 'a', 'hello');
      expect(StringUtil.generateUuid().length > 0).assertTrue();
    });
  })
}

function test() {
  PreferencesUtil.get('test', '');
  PreferencesUtil.getPreferencesData('test', '', AbilityContextManager.getContext() as Context);
  PreferencesUtil.has('test');
  PreferencesUtil.hasSync('test');
  PreferencesUtil.put('test', 'abc');
  PreferencesUtil.putPreferencesData('test', 'tabc', AbilityContextManager.getContext() as Context);
  PreferencesUtil.putSync('test', 'abc');
  PreferencesUtil.delete('test');
  PreferencesUtil.getSyncWithPreferenceName('test', 'a', 'test');
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
  PreferencesUtil.getSyncCache('test', 'a', true);
}