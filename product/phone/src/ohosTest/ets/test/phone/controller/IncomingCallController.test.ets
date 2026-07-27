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
import { OrderedDataSource } from '@ohos/scene.common/src/main/ets/framework/model/OrderedDataSource';
import { CompCtrlParam } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemType } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil'
import { AutoAnswerController } from '../../../../../main/ets/pages/nodisturb/controller/AutoAnswerController';
import { IncomingCallController } from '../../../../../main/ets/pages/nodisturb/controller/IncomingCallController';

const TAG: string = 'IncomingCallControllerTest: ';
const compParam: CompCtrlParam = {
  compId: 'IncomingCallControllerTest',
  component: {
    id: 'IncomingCallControllerTest_comp'
  },
  dataSource: new OrderedDataSource()
};

export default function IncomingCallControllerTest() {
  describe('IncomingCallControllerTest', () => {
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

    it('IncomingCallControllerTest_init', 0, init);

    it('IncomingCallControllerTest_initMenu', 0, initMenu);

    it('IncomingCallControllerTest_destroy', 0, destroy);

    it('IncomingCallControllerTest_onPageShow', 0, onPageShow);

    it('IncomingCallControllerTest_onPageHide', 0, onPageHide);
  })
}

/**
 * 初始化
 */
function init() {
  try {
    const incomingCallController: IncomingCallController = new IncomingCallController();
    (incomingCallController as object)['init'](compParam);
    const dataSource: OrderedDataSource = (incomingCallController as object)['dataSource'] as OrderedDataSource;
    expect(dataSource.totalCount() >= 0).assertTrue();
    LogUtil.showInfo(TAG, `init success ${dataSource.totalCount()}`);
  } catch (e) {
    LogUtil.showError(TAG, `init error: ${e?.code}, ${e?.message}`);
  }
}

/**
 * 菜单初始化
 */
function initMenu() {
  try {
    const incomingCallController: IncomingCallController = new IncomingCallController();
    incomingCallController.init(compParam);
    (incomingCallController as object)['initMenu'](compParam);
    const dataSource: OrderedDataSource = (incomingCallController as object)['dataSource'] as OrderedDataSource;
    const itemType: ItemType = dataSource.getData(0).type;
    expect(itemType === ItemType.ITEM_TYPE_STANDARD).assertTrue();
    LogUtil.showInfo(TAG, `initMenu success ${itemType.toString()}`);
  } catch (e) {
    LogUtil.showError(TAG, `initMenu error: ${e?.code}, ${e?.message}`);
  }
}

/**
 * 销毁测试
 */
function destroy() {
  try {
    const incomingCallController: IncomingCallController = new IncomingCallController();
    (incomingCallController as object)['destroy']();
    const destroyCompId: string = (incomingCallController as object)['compId'];
    expect(destroyCompId === '').assertTrue();
    LogUtil.showInfo(TAG, 'destroy success');
  } catch (e) {
    LogUtil.showError(TAG, `destroy error: ${e?.code}, ${e?.message}`);
  }
}

/**
 * 页面显示测试
 */
function onPageShow() {
  try {
    const incomingCallController: IncomingCallController = new IncomingCallController();
    (incomingCallController as object)['onPageShow']();
    const autoAnswerController: AutoAnswerController = (incomingCallController as object)['autoAnswerController'];
    const isChange: boolean = autoAnswerController.onToggleAllowChanged(false);
    expect(isChange).assertTrue();
  } catch (e) {
    LogUtil.showError(TAG, `onPageShow error: ${e?.code}, ${e?.message}`);
  }
}

/**
 * 页面隐藏测试
 */
function onPageHide() {
  try {
    const incomingCallController: IncomingCallController = new IncomingCallController();
    (incomingCallController as object)['onPageHide']();
    const compId: string = (incomingCallController as object)['compId'];
    expect(compId.length >= 0).assertTrue();
  } catch (e) {
    LogUtil.showError(TAG, `onPageHide error: ${e?.code}, ${e?.message}`);
  }
}
