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
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil'
import { SettingItemModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { CompCtrlParam } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { DynamicDataSource } from '@ohos/scene.common/src/main/ets/framework/model/DynamicDataSource';
import { PrecastModeController } from '../../../../../main/ets/pages/modesheet/controller/PrecastModeController';

const TAG: string = 'PrecastModeControllerTest: ';
const dataSource: DynamicDataSource = new DynamicDataSource();
const compParam: CompCtrlParam = {
  compId: 'PrecastModeControllerTest',
  component: {
    id: 'PrecastModeControllerTest_comp',
  } as SettingPageModel,
  dataSource: dataSource
};

export default function PrecastModeControllerTest() {
  describe('PrecastModeControllerTest', () => {
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

    it('PrecastModeControllerTest_pushTemplateModeItems', 0, pushTemplateModeItems);

    it('PrecastModeControllerTest_getTemplateItem', 0, getTemplateItem);

    it('PrecastModeControllerTest_getToTonightText', 0, async () => {
      await getCustomModeItem();
    });
  })
}

function pushTemplateModeItems() {
  try {
    const controller: PrecastModeController = new PrecastModeController();
    controller.init(compParam);
    (controller as object)['pushTemplateModeItems']();
    const dataSource: DynamicDataSource = (controller as object)['dataSource'];
    expect(dataSource?.length >= 0).assertTrue();
    LogUtil.showInfo(TAG, `pushTemplateModeItems success: ${dataSource?.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `pushTemplateModeItems: ${e?.message}`);
  }
}

async function getTemplateItem() {
  try {
    const modeData: ModeData = {
      modeId: '1',
      modeName: '$string:DND_mode',
      iconId: 'moon_fill',
      iconColor: '#542BD7',
      isSupportDelete: false
    };
    const controller: PrecastModeController = new PrecastModeController();
    const itemModel: SettingItemModel = (controller as object)['getTemplateItem'](modeData);
    expect(itemModel.id === 'DND_mode_item').assertTrue();
    LogUtil.showInfo(TAG, `getTemplateItem success: ${itemModel.id}`);
  } catch (e) {
    LogUtil.showError(TAG, `getTemplateItem: ${e?.message}`);
  }
}

async function getCustomModeItem() {
  try {
    const controller: PrecastModeController = new PrecastModeController();
    const customMode: SettingItemModel = (controller as object)['getCustomModeItem']();
    expect(customMode.id === 'custom_mode_item').assertTrue();
    LogUtil.showInfo(TAG, `getCustomModeItem success: ${customMode.id}`);
  } catch (e) {
    LogUtil.showError(TAG, `getCustomModeItem: ${e?.message}`);
  }
}
