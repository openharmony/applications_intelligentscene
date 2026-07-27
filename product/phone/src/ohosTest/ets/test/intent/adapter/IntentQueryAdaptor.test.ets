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
  afterEach,
  ArgumentMatchers,
  beforeEach,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import insightIntent from '@ohos.app.ability.insightIntent';
import { IntentCodeConstants } from '@ohos/scene.intent/src/main/ets/constant/IntentCodeConstant';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { IntentQueryModeAdaptor } from '@ohos/scene.intent/src/main/ets/adapter/IntentQueryModeAdaptor';

export default function IntentQueryAdaptorTest() {
  describe('IntentQueryAdaptorTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('queryMode_test01', 0, async (done: Function) => {
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.QUERY_MODE_LIST_SUCCESS_CODE,
        result: { 'errMsg': '' },
      };
      let result: insightIntent.ExecuteResult = await IntentQueryModeAdaptor.queryModeList();
      expect(IntentCodeConstants.QUERY_MODE_LIST_SUCCESS_CODE).assertEqual(errorResponse.code);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);
      when(mockFunc)().afterReturn([]);
      await IntentQueryModeAdaptor.queryModeList();
      mocker.ignoreMock(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);
      done();
    });

    it('queryMode_test02', 0, async (done: Function) => {
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.QUERY_MODE_LIST_SUCCESS_CODE,
        result: { 'errMsg': '' },
      };
      let result: insightIntent.ExecuteResult = await IntentQueryModeAdaptor.queryModeConfig(ModeType.DND_MODE);
      expect(IntentCodeConstants.QUERY_MODE_LIST_SUCCESS_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('queryMode_test03', 0, async (done: Function) => {
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.QUERY_MODE_FAIL_CODE,
        result: { 'errMsg': '' },
      };
      let notExistModeId: string = '1231234564567';
      let result: insightIntent.ExecuteResult = await IntentQueryModeAdaptor.queryModeConfig(notExistModeId);
      expect(IntentCodeConstants.QUERY_MODE_FAIL_CODE).assertEqual(errorResponse.code);
      done();
    });
  });
}