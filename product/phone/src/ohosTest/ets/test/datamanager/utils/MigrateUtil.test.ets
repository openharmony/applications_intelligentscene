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
  expect
} from '@ohos/hypium';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { MigrateUtil } from '@ohos/scene.datamanage/src/main/ets/utils/MigrateUtil';

export default function MigrateUtilTest() {
  describe('MigrateUtilTest', () => {
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

    it('MigrateUtilTest_isHistoryDataMigrated', 0, async (done: Function) => {
      const result: boolean = ModeUtil.isPrecastMode('1');
      expect(result).assertTrue();
      MigrateUtil.isHistoryDataMigrated();
      done();
    });

    it('MigrateUtilTest_setHistoryDataMigrated', 0, async (done: Function) => {
      const result: boolean = ModeUtil.isPrecastMode('12345');
      expect(result).assertFalse();
      MigrateUtil.setHistoryDataMigrated(true);
      done();
    });

    it('MigrateUtilTest_isNeedUpdateRule', 0, async (done: Function) => {
      const result: boolean = ModeUtil.isPrecastMode('-1');
      expect(result).assertFalse();
      MigrateUtil.isNeedUpdateRule();
      done();
    });

    it('MigrateUtilTest_setNeedUpdateRule', 0, () => {
      const result = ModeUtil.isCustomMode('-1');
      expect(result).assertEqual(true);
      MigrateUtil.setNeedUpdateRule(false);
    });
  })
}