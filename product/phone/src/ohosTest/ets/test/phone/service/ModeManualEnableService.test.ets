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
import { Response } from '@ohos/scene.common/src/main/ets/constant/Response';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil'
import { ModeType } from '@ohos/scene.datamanage';
import { OpenType } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';
import { ModeManualEnableService } from '../../../../../main/ets/stub/service/ModeManualEnableService';

const TAG: string = 'ModeManualEnableServiceTest: ';

export default function ModeManualEnableServiceTest() {
  describe('ModeManualEnableServiceTest', () => {
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

    it('ModeManualEnableServiceTest_onCall_method', 0, async (done: Function) => {
      try {
        const modeManualEnableService: ModeManualEnableService = new ModeManualEnableService();
        const jsonStr: string = '{"method": "", extra: {}}';
        const result: string = await modeManualEnableService.onCall(jsonStr);
        expect(result).assertEqual(Response.UNKNOWN_METHOD);
      } catch (e) {
        LogUtil.showError(TAG, `ModeManualEnableServiceTest_onCall_method error: ${e?.code}, ${e?.message}`);
      }
      done();
    });

    it('ModeManualEnableServiceTest_onCall_method_not_null', 0, async (done: Function) => {
      try {
        const modeManualEnableService: ModeManualEnableService = new ModeManualEnableService();
        const jsonStr: string = '{"method": "modeManualEnable", extra: {modeId: 0}}';
        const result: string = await modeManualEnableService.onCall(jsonStr);
        expect(result).assertEqual(Response.UNKNOWN_METHOD);
      } catch (e) {
        LogUtil.showError(TAG, `ModeManualEnableServiceTest_onCall_method_not_null error: ${e?.code}, ${e?.message}`);
      }
      done();
    });

    it('ModeManualEnableServiceTest_closeMode_other', 0, closeOtherMode);

    it('ModeManualEnableServiceTest_enableMode_other', 0, enableModeOhter);

  })
}

function closeOtherMode() {
  let processResult: boolean = false;
  try {
    const modeManualEnableService: ModeManualEnableService = new ModeManualEnableService();
    (modeManualEnableService as object)['closeMode']();
    processResult = true;
  } catch (e) {
    LogUtil.showError(TAG, `closeOtherMode error: ${e?.code}, ${e?.message}`);
    processResult = false;
  }
  expect(processResult).assertTrue();
}

function enableModeOhter() {
  let processResult: boolean = false;
  try {
    const modeManualEnableService: ModeManualEnableService = new ModeManualEnableService();
    (modeManualEnableService as object)['enableMode'](ModeType.DND_MODE, OpenType.TURN_ON_NOW, false);
    processResult = true;
  } catch (e) {
    LogUtil.showError(TAG, `enableModeOhter error: ${e?.code}, ${e?.message}`);
    processResult = false;
  }
  expect(processResult).assertTrue();
}
