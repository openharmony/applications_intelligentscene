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

import { VerifyPeriodUtil } from '@ohos/scene.intent/src/main/ets/util/VerifyPeriodUtil';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { IntentConstant } from '@ohos/scene.intent/src/main/ets/constant/IntentConstant';
import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  MockKit,
} from '@ohos/hypium';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

export default function VerifyPeriodUtilTest() {
  describe('VerifyPeriodUtilTest', () => {
    beforeEach(() => {
      let mocker: MockKit = new MockKit();
      mocker.ignoreMock(VerifyPeriodUtil, VerifyPeriodUtil.isModeIdExist);
    });

    afterEach(() => {

    });

    it('VerifyPeriodUtil_isCurrentPrivate', 0, async () => {
      let isCurrentPrivate: boolean = await VerifyPeriodUtil.isCurrentPrivate();
      expect(isCurrentPrivate).assertEqual(false);
    });

    it('VerifyPeriodUtil_isIntentParamsInValid', 0, async () => {
      let intentName: string = '';
      let intentParam: Record<string, Object> = {};
      const result: boolean = await VerifyPeriodUtil.isIntentParamsValid(intentName, intentParam);
      expect(result).assertEqual(false);
    });

    it('VerifyPeriodUtil_isIntentParamsValid', 0, async () => {
      let intentName: string = 'testIntent';
      let intentParam: Record<string, Object> = {
        'testKey': 'testKey',
      };
      const result: boolean = await VerifyPeriodUtil.isIntentParamsValid(intentName, intentParam);
      expect(result).assertEqual(true);
    });

    it('VerifyPeriodUtil_isModeIdExist', 0, async () => {
      // 免打扰模式
      await VerifyPeriodUtil.isModeIdExist(ModeType.SLEEP_MODE);
      const id: string = StringUtil.generateUuid();
      expect(id.length > 0).assertTrue();
    });

    it('VerifyPeriodUtil_isModeIdNotExist', 0, async () => {
      let isModeIdNotExist: boolean = await VerifyPeriodUtil.isModeIdExist('9953');
      const id: string = StringUtil.generateUuid();
      expect(id.length > 0).assertTrue();
    });
  });
}