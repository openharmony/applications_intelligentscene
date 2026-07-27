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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { ChangeHelperFactory } from '@ohos/scene.datasync/src/main/ets/template/ChangeHelperFactory';
import { DB_CONFIG } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { ChangeInfoHelper } from '@ohos/scene.datasync/src/main/ets/template/ChangeInfoHelper';

export default function ChangeInfoHelperTest() {
  describe('ChangeInfoHelperTest', () => {
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

    it('ChangeInfoHelperTest_getChangeHelper', 0, async (done: Function) => {
      let changeHelper: ChangeInfoHelper | undefined =
        ChangeHelperFactory.getChangeHelper(DB_CONFIG.MODE_DATA.TABLE_NAME);
      expect(changeHelper).not().assertUndefined();
      done();
    });

    it('ChangeInfoHelperTest_getChangeHelper_invalid', 0, async (done: Function) => {
      let changeHelper: ChangeInfoHelper | undefined =
        ChangeHelperFactory.getChangeHelper('test');
      expect(changeHelper).assertUndefined();
      done();
    });

    it('ChangeInfoHelperTest_cleanDirtyData', 0, async (done: Function) => {
      let configHelper: ChangeInfoHelper | undefined =
        ChangeHelperFactory.getChangeHelper(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
      const isSuccess: boolean | undefined = await configHelper?.cleanDirtyData(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
      expect(isSuccess !== undefined).assertEqual(true);
      done();
    });

  })
}