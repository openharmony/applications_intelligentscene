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

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';
import { CursorDataManager } from '@ohos/scene.datamanage';
import { DB_CONFIG } from '@ohos/scene.common';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';

export default function CursorDataManagerTest() {
  describe('CursorDataManagerTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(async () => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
      await new RdbStoreHelper().deleteTableData(DB_CONFIG.CURSOR_DATA.TABLE_NAME);
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

    it('CursorDataManagerTest_insert', 0, async (done: Function) => {
      let result: number = await new CursorDataManager().insertCursorData(DB_CONFIG.OPERATION_DATA.TABLE_NAME, 100);
      expect(result > 0).assertTrue();
      done();
    });

    it('CursorDataManagerTest_update01', 0, async (done: Function) => {
      const result: number = await new CursorDataManager().updateCursor(DB_CONFIG.HISTORY_DATA.TABLE_NAME, 101);
      expect(result > 0).assertTrue();
      done();
    });

    it('CursorDataManagerTest_update02', 0, async (done: Function) => {
      await new CursorDataManager().initCursorData();
      let result: number = await new CursorDataManager().updateCursor(DB_CONFIG.CONTACT_DATA.TABLE_NAME, 102);
      expect(result > 0).assertTrue();
      done();
    });
  })
}