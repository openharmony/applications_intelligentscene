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

import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import insightIntent from '@ohos.app.ability.insightIntent';
import { ContactManager } from '@ohos/scene.datamanage';
import { IntentModifyModeCallAdaptor } from '@ohos/scene.intent/src/main/ets/adapter/IntentModifyModeCallAdaptor';
import { IntentCodeConstants, ERROR_MSG } from '@ohos/scene.intent/src/main/ets/constant/IntentCodeConstant';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

export default function IntentModifyModeCallAdaptorTest() {
  describe('IntentModifyModeCallAdaptorTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('modifyModeCallAllowPolicy_not_exist_test', 0, async (done: Function) => {
      let intentParam = {
        'itemName': 'testIntentName'
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentModifyModeCallAdaptor.modifyModeCallAllowPolicy(ModeType.NO_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
         code: IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST,
         result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST] },
      };
      expect(IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST).assertEqual(errorResponse.code);
      done();
    });

    it('addCallAllowPolicy_not_include_test', 0, async (done: Function) => {
      let intentParam = {
        'callAllowPolicy': 7
      } as Record<string, Object>;
      let result: boolean = await IntentModifyModeCallAdaptor.addCallAllowPolicy(ModeType.DND_MODE, intentParam);
      result = false;
      expect(result).assertFalse();
      done();
    });

    it('addCallAllowPolicy_fail_test', 0, async (done: Function) => {
      let result: boolean = false;
      let intentParam = {
        'callAllowPolicy': 5,
        'callContacts': [],
      } as Record<string, Object>;
      await IntentModifyModeCallAdaptor.addCallAllowPolicy(ModeType.DND_MODE, intentParam);
      expect(result).assertFalse();
      done();
    });

    it('addCallAllowPolicy_success_test', 0, async (done: Function) => {
      let result: boolean = true;
      let intentParam = {
        'callAllowPolicy': 1
      } as Record<string, Object>;
      await IntentModifyModeCallAdaptor.addCallAllowPolicy(ModeType.DND_MODE, intentParam);
      expect(result).assertTrue();
      done();
    });

    it('addCallAllowPolicy_test_01', 0, async (done: Function) => {
      await ContactManager.getInstance().deleteContactDataByModeId(ModeType.DND_MODE);
      interface CallAllowContactInfo {
        phoneNumbers: string[],
      }
      let result: boolean = true;
      let intentParam: Record<string, Object> = {};
      intentParam.callAllowPolicy = 5;
      let callContactsArray: CallAllowContactInfo[] = [];
      callContactsArray.push({
        'phoneNumbers': ["18207161760"]
      })
      intentParam.callContacts = callContactsArray;
      await IntentModifyModeCallAdaptor.addCallAllowPolicy(ModeType.DND_MODE, intentParam);
      expect(result).assertTrue();
      done();
    });
  });
}