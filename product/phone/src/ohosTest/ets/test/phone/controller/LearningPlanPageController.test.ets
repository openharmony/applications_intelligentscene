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
import { SettingGroupModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { LearningPageController } from '../../../../../main/ets/pages/learning/controller/LearningPlanPageController';

const TAG: string = 'LearningPlanPageControllerTest: ';
const group: SettingGroupModel[] = [];
const compParam: CompCtrlParam = {
  compId: 'LearningPlanPageControllerTest',
  component: {
    id: 'LearningPlanPageControllerTest_comp',
    groups: group,
  } as SettingPageModel
};

export default function LearningPlanPageControllerTest() {
  describe('LearningPlanPageControllerTest', () => {
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

    it('LearningPlanPageControllerTest_init', 0, init);

    it('LearningPlanPageControllerTest_initMenus', 0, initMenus);

    it('LearningPlanPageControllerTest_addLearningPlanGroup', 0, addLearningPlanGroup);

    it('LearningPlanPageControllerTest_destroy', 0, destroy);
  })
}

/**
 * 初始化
 */
function init() {
  try {
    const learningPageController: LearningPageController = new LearningPageController();
    learningPageController.init(compParam);
    const compId: string = (learningPageController as object)['compId'];
    expect(compId === 'LearningPlanPageControllerTest').assertTrue();
    LogUtil.showInfo(TAG, `init success: ${compId}`);
  } catch (e) {
    LogUtil.showError(TAG, `init error: ${e?.code}, ${e?.message}`);
  }
}

/**
 * 菜单初始化
 */
function initMenus() {
  try {
    const learningPageController: LearningPageController = new LearningPageController();
    (learningPageController as object)['initMenus']();
    const pageModel: SettingPageModel = (learningPageController as object)['settingPageModel'];
    expect(pageModel === undefined).assertTrue();
    LogUtil.showInfo(TAG, 'initMenus success');
  } catch (e) {
    LogUtil.showError(TAG, `initMenus error: ${e?.code}, ${e?.message}`);
  }
}

/**
 * 添加菜单组调用
 */
function addLearningPlanGroup() {
  try {
    const learningPageController: LearningPageController = new LearningPageController();
    learningPageController.init(compParam);
    (learningPageController as object)['addLearningPlanGroup']();
    const settingPageModel: SettingPageModel = (learningPageController as object)['settingPageModel'];
    const addCount: number = settingPageModel.groups ? settingPageModel.groups.length : 0;
    expect(addCount > 0).assertTrue();
    LogUtil.showInfo(TAG, `addLearningPlanGroup success addCount ${addCount}`);
  } catch (e) {
    LogUtil.showError(TAG, `addLearningPlanGroup error: ${e?.code}, ${e?.message}`);
  }
}

/**
 * 销毁
 */
function destroy() {
  try {
    const learningPageController: LearningPageController = new LearningPageController();
    learningPageController.destroy();
    const compId: string = (learningPageController as object)['compId'];
    expect(compId === '').assertTrue();
    LogUtil.showInfo(TAG, `destroy success,compId ${compId}`);
  } catch (e) {
    LogUtil.showError(TAG, `destroy error: ${e?.code}, ${e?.message}`);
  }
}
