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
import insightIntent from '@ohos.app.ability.insightIntent';
import { IntentModifyModeAppAdaptor } from '@ohos/scene.intent/src/main/ets/adapter/IntentModifyModeAppAdaptor';
import { IntentCodeConstants, ERROR_MSG } from '@ohos/scene.intent/src/main/ets/constant/IntentCodeConstant';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

export default function IntentModifyModeAppAdaptorTest() {
  describe('IntentModifyModeAppAdaptorTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('modifyModeAddNotifyAllowByApp_not_exist_test', 0, async (done: Function) => {
      let intentParam = {
        'itemName': 'testIntentName'
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult =
        await IntentModifyModeAppAdaptor.modifyModeAddNotifyAllowByApp(ModeType.NO_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST,
        result: {
          'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST]
        },
      };
      expect(IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeAddNotifyAllowByApp_fail_test', 0, async (done: Function) => {
      let intentParam = {
        'notifyAllowPolicy': 6
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult =
        await IntentModifyModeAppAdaptor.modifyModeAddNotifyAllowByApp(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_CALL_APP_FAIL_CODE,
        result: {
          'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_CALL_APP_FAIL_CODE]
        },
      };
      expect(IntentCodeConstants.MODIFY_CALL_APP_FAIL_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeAddNotifyAllowByApp_success_test', 0, async (done: Function) => {
      let intentParam = {
        'notifyAllowPolicy': 1
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult =
        await IntentModifyModeAppAdaptor.modifyModeAddNotifyAllowByApp(ModeType.DND_MODE, intentParam);
      let successResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_CALL_APP_SUCCESS_CODE,
      };
      expect(IntentCodeConstants.MODIFY_CALL_APP_SUCCESS_CODE).assertEqual(successResponse.code);
      done();
    });

    it('addNotifyAllowByApp_false_test', 0, async (done: Function) => {
      let intentParam = {
        'notifyAllowPolicy': 6
      } as Record<string, Object>;
      let result: boolean = await IntentModifyModeAppAdaptor.addNotifyAllowByApp(ModeType.DND_MODE, intentParam);
      result = false;
      expect(result).assertFalse();
      done();
    });

    it('addNotifyAllowByApp_false1_test', 0, async (done: Function) => {
      let intentParam = {
        'notifyAllowPolicy': 3,
        'notifyAllowApps': []
      } as Record<string, Object>;
      let result: boolean = await IntentModifyModeAppAdaptor.addNotifyAllowByApp(ModeType.DND_MODE, intentParam);
      result = false;
      expect(result).assertFalse();
      done();
    });

    it('addNotifyAllowByApp_false2_test', 0, async (done: Function) => {
      let intentParam = {
        'notifyAllowPolicy': 3,
        'notifyAllowApps': [undefined],
      } as Record<string, Object>;
      let result: boolean = await IntentModifyModeAppAdaptor.addNotifyAllowByApp(ModeType.DND_MODE, intentParam);
      result = false;
      expect(result).assertFalse();
      done();
    });

    it('addNotifyAllowByApp_success_test', 0, async (done: Function) => {
      let intentParam = {
        'notifyAllowPolicy': 1,
      } as Record<string, Object>;
      let result: boolean = await IntentModifyModeAppAdaptor.addNotifyAllowByApp(ModeType.DND_MODE, intentParam);
      result = true;
      expect(result).assertTrue();
      done();
    });

    it('modifyModeNotifyAllowByPolicy_test01', 0, async (done: Function) => {
      let intentParam = {
        'notifyAllowPolicy': 1,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult =
        await IntentModifyModeAppAdaptor.modifyModeNotifyAllowByPolicy('-932145', intentParam);
      expect(result.code).assertEqual(IntentCodeConstants.MODIFY_NOT_DISTURB_POLICY_NOT_EXIST);
      done();
    });
  });
}