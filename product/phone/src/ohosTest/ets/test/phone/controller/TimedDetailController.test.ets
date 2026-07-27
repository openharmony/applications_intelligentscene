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
import { SettingItemModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil'
import {
  TimedDetailController
} from '../../../../../main/ets/pages/conditionsheet/timedsheet/controller/TimedDetailController';

const TAG: string = 'TimedDetailController: ';
const compParam: CompCtrlParam = {
  compId: 'TimedDetailControllerTest',
  component: {
    id: 'TimedDetailControllerTest_comp'
  },
  dataSource: new OrderedDataSource()
};

export default function TimedDetailControllerTest() {
  describe('TimedDetailControllerTest', () => {
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

    it('TimedDetailControllerTest_init', 0, init);
    it('TimedDetailControllerTest_getStartTimeItem', 0, getStartTimeItem);
  })
}

function init() {
  try {
    const controller: TimedDetailController = new TimedDetailController();
    (controller as object)['init'](compParam);
    const dataSource: OrderedDataSource = (controller as object)['dataSource'] as OrderedDataSource;
    expect(dataSource.totalCount() >= 0).assertTrue();
    LogUtil.showInfo(TAG, `init success ${dataSource.totalCount()}`);
  } catch (e) {
    LogUtil.showError(TAG, `init error: ${e?.code}, ${e?.message}`);
  }
}

function getStartTimeItem() {
  try {
    const controller: TimedDetailController = new TimedDetailController();
    const mode: SettingItemModel = (controller as object)['getStartTimeItem']();
    if (mode) {
      expect(mode.id).assertEqual('time_start');
    } else {
      expect(mode === undefined).assertTrue();
    }
  } catch (e) {
    LogUtil.showError(TAG, `getStartTimeItem error: ${e?.code}, ${e?.message}`);
  }
}

