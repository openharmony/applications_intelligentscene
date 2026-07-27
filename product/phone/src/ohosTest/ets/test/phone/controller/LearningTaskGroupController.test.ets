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
import { CompCtrlParam } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil'
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { LearningPlan } from '@ohos/scene.datamanage/src/main/ets/model/LearningPlan'
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import {
  LearningTaskGroupController,
} from '../../../../../main/ets/pages/learning/controller/LearningTaskGroupController'

const TAG: string = 'LearningTaskGroupControllerTest: ';

export default function LearningTaskGroupControllerTest() {
  describe('LearningTaskGroupControllerTest', () => {
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

    it('LearningTaskGroupControllerTest_getLearningItemId', 0, async () => {
      await getLearningItemId();
    });

    it('LearningTaskGroupControllerTest_refreshFooterText', 0, refreshFooterText);

    it('LearningTaskGroupControllerTest_addPlanTaskItem', 0, addPlanTaskItem);

    it('LearningTaskGroupControllerTest_hideAddPlanBtn', 0, hideAddPlanBtn);

    it('LearningTaskGroupControllerTest_addTaskBtnMenu', 0, addTaskBtnMenu);

    it('LearningTaskGroupControllerTest_updateLearningModeLiveView', 0, updateLearningModeLiveView);
  })
}

async function getLearningItemId() {
  let processResult: boolean = false;
  try {
    const controller: LearningTaskGroupController = new LearningTaskGroupController();
    const func: Function = Reflect.get(controller, 'getLearningItemId');
    const plan: LearningPlan = {
      planName: 'test',
      id: '1',
      status: 1,
      createTime: DateTimeUtil.getCurrentTimeStamp(),
      updateTime: DateTimeUtil.getCurrentTimeStamp()
    };
    const ret: string = await func(plan);
    LogUtil.showInfo(TAG, `getLearningItemId: ${ret}`);
    expect(ret.length > 0).assertTrue();
    processResult = true;
  } catch (e) {
    LogUtil.showError(TAG, `getLearningItemId error: ${e?.message}`);
    processResult = false;
  }
  expect(processResult).assertTrue();
}

function refreshFooterText() {
  let processResult: boolean = false;
  try {
    const controller: LearningTaskGroupController = new LearningTaskGroupController();
    const compParam: CompCtrlParam = {
      compId: 'LearningTaskGroupController_test',
      component: {
        id: ''
      }
    };
    controller.init(compParam);
    (controller as object)['refreshFooterText'](true);
    (controller as object)['refreshFooterText'](false);
    processResult = true;
  } catch (e) {
    LogUtil.showError(TAG, `refreshFooterText error: ${e?.message}`);
    processResult = false;
  }
  expect(processResult).assertTrue();
}

function initController(): LearningTaskGroupController {
  const controller: LearningTaskGroupController = new LearningTaskGroupController();
  const compParam: CompCtrlParam = {
    compId: 'LearningTaskGroupControllerCompId',
    component: {
      id: 'LearningTaskGroupControllerId'
    }
  };
  controller.init(compParam);
  return controller;
}

function addPlanTaskItem() {
  let processResult: boolean = false;
  try {
    const controller: LearningTaskGroupController = initController();
    const plan: LearningPlan = {
      planName: 'test',
      id: '1',
      status: 1,
      createTime: DateTimeUtil.getCurrentTimeStamp(),
      updateTime: DateTimeUtil.getCurrentTimeStamp()
    };
    (controller as object)['addPlanTaskItem'](plan);
    LogUtil.showInfo(TAG, 'addPlanTaskItem success');
    processResult = true;
  } catch (e) {
    LogUtil.showError(TAG, `addPlanTaskItem error: ${e?.message}`);
    processResult = false;
  }
  expect(processResult).assertTrue();
}

function hideAddPlanBtn() {
  let processResult: boolean = false;
  try {
    const controller: LearningTaskGroupController = initController();
    (controller as object)['hideAddPlanBtn']();
    controller.destroy();
    processResult = true;
  } catch (e) {
    LogUtil.showError(TAG, `hideAddPlanBtn error: ${e?.message}`);
    processResult = false;
  }
  expect(processResult).assertTrue();
}

function addTaskBtnMenu() {
  let process: boolean = false;
  try {
    const controller: LearningTaskGroupController = initController();
    (controller as object)['addTaskBtnMenu']();
    process = true;
  } catch (e) {
    LogUtil.showError(TAG, `addTaskBtnMenu error: ${e?.message}`);
    process = false;
  }
  expect(process).assertTrue();
}

function updateLearningModeLiveView() {
  let processResult: boolean  =false;
  try {
    const controller: LearningTaskGroupController = new LearningTaskGroupController();
    (controller as object)['updateLearningModeLiveView']();
    processResult = true;
  } catch (e) {
    LogUtil.showError(TAG, `updateLearningModeLiveView error: ${e?.message}`);
    processResult = false;
  }
  expect(processResult).assertTrue();
}
