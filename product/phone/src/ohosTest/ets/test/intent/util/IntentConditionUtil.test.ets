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
import { ConfigData, ConfigDataManager, ConfigType } from '@ohos/scene.datamanage';
import { CONDITION_LIST } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { IntentConditionUtil } from '@ohos/scene.intent/src/main/ets/util/IntentConditionUtil';

export default function IntentConditionUtilTest() {
  describe('IntentConditionUtilTest', () => {
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

    it('IntentConditionUtil_isConditionCountValid_true', 0, async (done: Function) => {
      const result: boolean = await IntentConditionUtil.isConditionCountValid('1');
      expect(result).assertTrue();
      await IntentConditionUtil.isConditionCountValid('99');
      done();
    });

    it('IntentConditionUtil_getFirstSingleAndCloseCondition_inValid', 0, async (done: Function) => {
      const configData: ConfigData | undefined = await IntentConditionUtil.getFirstSingleAndCloseCondition('-1');
      expect(configData).assertUndefined();
      await generateConfigData();
      await IntentConditionUtil.getFirstSingleAndCloseCondition('1');
      done();
    });
  })
}

async function generateConfigData(): Promise<void> {
  let configValue: string =
    '{"enable":false,"configType":3,"loopType":1,"loopDays":"2025-05-17","timeStart":"22:00","timeEnd":"7:00"}';
  let configData: ConfigData = {
    configId: '',
    modeId: '1',
    configType: ConfigType.TRIGGER_CONDITION_TIME,
    configValue: configValue
  };
  await ConfigDataManager.getInstance().insertConfigData(configData);
}