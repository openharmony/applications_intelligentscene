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
import { RuleFeedbackManager } from '@ohos/scene.datamanage/src/main/ets/manager/RuleFeedbackManager';
import { RuleFeedBack } from '@ohos/scene.datamanage/src/main/ets/model/base/RuleFeedback';

export default function RuleFeedbackManagerTest() {
  describe('RuleFeedbackManagerTest', () => {
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

    it('RuleFeedbackManagerTest_updateRuleFeedback', 0, async (done: Function) => {
      const feedBack: RuleFeedBack = {
        id: 5,
        ruleId: 'recommend_1',
        modeId: '5',
        latitude: '30',
        longitude: '114',
        timeRange: '',
        createTime: 1744065666758,
      };
      const result: number = await RuleFeedbackManager.getInstance().updateRuleFeedback(feedBack);
      expect(result).assertLargerOrEqual(0);
      done();
    });

    it('RuleFeedbackManagerTest_updateRuleFeedbackByRule', 0, async (done: Function) => {
      const feedBack: RuleFeedBack = {
        id: 5,
        ruleId: 'recommend_1',
        modeId: '5',
        latitude: '30',
        longitude: '114',
        timeRange: '',
        createTime: 1744065666758,
      };
      const result: number = await RuleFeedbackManager.getInstance().updateRuleFeedbackByRuleId(feedBack.ruleId, feedBack);
      expect(result).assertLargerOrEqual(0);
      done();
    });

    it('RuleFeedbackManagerTest_updateFeedbackByModeId', 0, async (done: Function) => {
      const result: number = await RuleFeedbackManager.getInstance().updateFeedbackByModeId('5', 'feedBack');
      expect(result).assertLargerOrEqual(0);
      done();
    });

    it('RuleFeedbackManagerTest_queryFeedback', 0, async (done: Function) => {
      await RuleFeedbackManager.getInstance().queryFeedback('5');
      await RuleFeedbackManager.getInstance().queryOtherUsingRuleFeedback('1');
      await RuleFeedbackManager.getInstance().queryRuleFeedbackByRuleId('rule_2_uu12314_198554548');
      await RuleFeedbackManager.getInstance().batchDeleteRuleFeedbackByRuleIds([]);
      const ruleIds: string[] = ['rule_2_uu12314_198554548', 'rule_2_uu12313_198554549'];
      await RuleFeedbackManager.getInstance().batchDeleteRuleFeedbackByRuleIds(ruleIds);
      const ruleFeedbackList: RuleFeedBack[] = await RuleFeedbackManager.getInstance().queryAllRuleFeedback();
      expect(ruleFeedbackList.length).assertLargerOrEqual(0);
      done();
    });

  })
}