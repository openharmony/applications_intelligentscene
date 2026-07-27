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
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';
import { El1ModeDataManager } from '@ohos/scene.datamanage';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';

export default function ModeDataManagerTest() {
  describe('ModeDataManagerTest', () => {
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

    it('ModeDataManagerTest_queryModeDataByIdSync_success', 0, (done: Function) => {
      let modeDataManager: ModeDataManager = new ModeDataManager();
      const result = modeDataManager.queryModeDataByIdSync('1');
      if (result !== undefined) {
        expect(!result).assertFalse();
      } else {
        expect(result).assertUndefined();
      }
      done();
    });

    it('ModeDataManagerTest_queryModeDataByIdSync_fail', 0, (done: Function) => {
      let modeDataManager: ModeDataManager = new ModeDataManager();
      const result = modeDataManager.queryModeDataByIdSync('-1');
      expect(result).assertUndefined();
      done();
    });

    it('ModeDataManagerTest_queryModeCount', 0, async (done: Function) => {
      let modeDataManager: ModeDataManager = new ModeDataManager();
      const result = await modeDataManager.queryModeCount();
      expect(result >= 0).assertTrue();
      done();
    });

    it('ModeDataManagerTest_queryModeDataByInvalidId', 0, async (done: Function) => {
      let modeDataManager: ModeDataManager = new ModeDataManager();
      const result: ModeData | undefined = await modeDataManager.queryModeDataById('0');
      expect(result).assertUndefined();
      done();
    });

    it('ModeDataManagerTest_isModeNameExists_true', 0, async (done: Function) => {
      let modeDataManager: ModeDataManager = new ModeDataManager();
      const count = await modeDataManager.queryModeCount();
      let result: boolean = await ModeDataManager.getInstance().isModeNameExists('$string:sleep_mode');
      if (count > 0) {
        expect(result).assertTrue();
      } else {
        expect(result).assertFalse();
      }
      done();
    });

    it('ModeDataManagerTest_isModeNameExists_false', 0, async (done: Function) => {
      let result: boolean = await ModeDataManager.getInstance().isModeNameExists('test');
      expect(result).assertFalse();
      done();
    });

    it('ModeDataManagerTest_deleteModeDataById', 0, async (done: Function) => {
      let result: number = await ModeDataManager.getInstance().deleteModeDataById('100');
      expect(result).assertLargerOrEqual(0);
      done();
    });

    it('ModeDataManagerTest_updateModeData', 0, async (done: Function) => {
      const data: ModeData = {
        modeId: '1',
        modeName: 'mode101u',
        iconId: 'ebook',
        iconColor: '#542BD7',
        isSupportDelete: true,
      };
      let result: string = await ModeDataManager.getInstance().updateModeData(data);
      expect(result).assertEqual('1');
      done();
    });

    it('ModeDataManagerTest_EL1_insertMode_fail', 0, async (done: Function) => {
      const data: ModeData = {
        modeId: '-1',
        modeName: 'mode101u',
        iconId: 'ebook',
        iconColor: '#542BD7',
        isSupportDelete: true,
      };
      const result: string = await El1ModeDataManager.getInstance().insertModeData(data);
      expect(result !== '1').assertTrue();
      done();
    });

    it('ModeDataManagerTest_isModeNameExists_fail', 0, async (done: Function) => {
      let notExistModeName: string = 'testNotExistModeName';
      const isModeNameExists: boolean = await ModeDataManager.getInstance().isModeNameExists(notExistModeName);
      expect(isModeNameExists).assertFalse();
      done();
    });

    it('ModeDataManagerTest_El1_isModeNameExists_fail', 0, async (done: Function) => {
      let notExistModeName: string = 'testNotExistModeName';
      const isModeNameExists: boolean = await El1ModeDataManager.getInstance().isModeNameExists(notExistModeName);
      expect(isModeNameExists).assertFalse();
      done();
    });
  })
}