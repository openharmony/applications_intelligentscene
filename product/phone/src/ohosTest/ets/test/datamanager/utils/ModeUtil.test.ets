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

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

export default function ModeUtilTest() {
  describe('ModeUtilTest', () => {
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

    it('ModeUtil_isPrecastMode_true', 0, async (done: Function) => {
      const result: boolean = ModeUtil.isPrecastMode('1');
      expect(result).assertTrue();
      done();
    });

    it('ModeUtil_isPrecastMode_false', 0, async (done: Function) => {
      const result: boolean = ModeUtil.isPrecastMode('12345');
      expect(result).assertFalse();
      done();
    });

    it('ModeUtil_isPrecastMode_invalid', 0, async (done: Function) => {
      const result: boolean = ModeUtil.isPrecastMode('-1');
      expect(result).assertFalse();
      done();
    });

    it('should_return_true_when_id_is_minus_one', 0, () => {
      const result = ModeUtil.isCustomMode('-1');
      expect(result).assertEqual(true);
    });

    it('should_return_true_when_id_is_greater_than_MODE_TYPE_MAX_ID', 0, () => {
      const result = ModeUtil.isCustomMode(('51'));
      expect(result).assertEqual(true);
    });

    it('should_return_false_when_id_is_within_MODE_TYPE_MIN_ID_and_MODE_TYPE_MAX_ID', 0, () => {
      const result = ModeUtil.isCustomMode(('2'));
      expect(result).assertEqual(false);
    });

    it('should_return_false_when_id_is_MODE_TYPE_MIN_ID', 0, () => {
      const result = ModeUtil.isCustomMode('1');
      expect(result).assertEqual(false);
    });

    it('should_return_false_when_id_is_MODE_TYPE_MAX_ID', 0, () => {
      const result = ModeUtil.isCustomMode('50');
      expect(result).assertEqual(false);
    });

    it('should_return_false_when_id_is_invalid_number', 0, () => {
      const result = ModeUtil.isCustomMode("invalid");
      expect(result).assertEqual(false);
    });

    it('ModeUtil_generateConfigId_openMode', 0, async (done: Function) => {
      const result: string = ModeUtil.generateConfigId('1', 1);
      expect(result).assertEqual('1');
      done();
    });

    it('ModeUtil_generateConfigId_AppCondition', 0, async (done: Function) => {
      const result: string = ModeUtil.generateConfigId('1', 5);
      expect(result).assertEqual('1_5');
      done();
    });

    it('ModeUtil_getModeIdFromConfigId', 0, async (done: Function) => {
      const result: string = ModeUtil.getModeIdFromConfigId('1_5');
      expect(result).assertEqual('1');
      done();
    });

    it('ModeUtil_getTypeFromConfigId', 0, async (done: Function) => {
      const result: ConfigType = ModeUtil.getTypeFromConfigId('1_5');
      expect(result).assertEqual(ConfigType.TRIGGER_CONDITION_APP);
      done();
    });

    it('ModeUtil_getModeNameResourceStr', 0, async (done: Function) => {
      const data: ModeData = {
        modeId: '1111',
        modeName: 'mode101u',
        iconId: 'ebook',
        iconColor: '#542BD7',
        isSupportDelete: true,
      };
      let result: ResourceStr = ModeUtil.getModeNameResourceStr(data);
      expect(result).assertEqual(data.modeName);

      result = ModeUtil.getModeNameStr(data);
      expect(result).assertEqual(data.modeName);
      done();
    });

    it('ModeUtil_generateConditionByEndTime', 0, async (done: Function) => {
      const result = ModeUtil.isCustomMode('1');
      ModeUtil.generateConditionByEndTime('', '09:11');
      expect(result).assertFalse();
      done();
    });

    it('ModeUtil_getTimeConditionByMinute', 0, async (done: Function) => {
      const result = ModeUtil.isCustomMode('1');
      ModeUtil.generateConditionByMinute('', 120);
      expect(result).assertFalse();
      done();
    });

    it('ModeUtil_getTypeFromConfigId_invalid', 0, async (done: Function) => {
      const result = ModeUtil.isCustomMode('1');
      ModeUtil.getTypeFromConfigId('');
      expect(result).assertFalse();
      done();
    });
  })
}