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
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { LearningPlan } from '@ohos/scene.datamanage/src/main/ets/model/LearningPlan';

export default function LearningPlanManagerTest() {
  describe('LearningPlanManagerTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('add_learning_plan', 0, async (done: Function) => {
      let plan: LearningPlan = {
        planName: 'testPlan'
      } as LearningPlan;
      let res: string = await LearningPlanManager.getInstance().addLearningPlan(plan);
      expect(res !== '-1').assertTrue();
      done();
    });


    it('get_all_learning_plans', 0, async (done: Function) => {
      let plans: LearningPlan[] = await LearningPlanManager.getInstance().getAllLearningPlans();
      expect(plans.length).assertLargerOrEqual(0);
      done();
    });

    it('update_learning_plan_status', 0, async (done: Function) => {
      expect(LearningPlanManager.getInstance().updateLearningPlanStatus('1', 1)).assertPromiseIsResolved();
      done();
    });

    it('update_learning_plan_name', 0, async (done: Function) => {
      expect(LearningPlanManager.getInstance().updateLearningPlanName('1', 'testPlan2')).assertPromiseIsResolved();
      done();
    });

    it('reset_all_learning_plan_status', 0, async (done: Function) => {
      expect(LearningPlanManager.getInstance().resetAllLearningPlanStatus()).assertPromiseIsResolved();
      done();
    });

    it('delete_learning_plan', 0, async (done: Function) => {
      let res: boolean = await LearningPlanManager.getInstance().deleteLearningPlan('1');
      expect(res).assertTrue();
      done();
    });

    it('clear_learning_plans', 0, async (done: Function) => {
      expect(LearningPlanManager.getInstance().clearLearningPlans()).assertPromiseIsResolved();
      done();
    });
  });
}