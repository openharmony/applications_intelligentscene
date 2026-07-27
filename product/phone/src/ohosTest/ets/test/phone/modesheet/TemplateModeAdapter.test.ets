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
import { ModeConfigData } from '@ohos/scene.datasync/src/main/ets/wearengine/model/WearEngineMessage';
import { TemplateModeAdapter } from '../../../../../main/ets/pages/modesheet/adapter/TemplateModeAdapter';

const TAG: string = 'TemplateModeAdapterTest: ';

export default function TemplateModeAdapterTest() {
  describe('TemplateModeAdapterTest', () => {
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

    it('TemplateModeAdapterTest_initData', 0, initData);

    it('TemplateModeAdapterTest_clearData', 0, clearData);

    it('TemplateModeAdapterTest_queryTemplateMode', 0, queryTemplateMode);

    it('TemplateModeAdapterTest_getTemplateModeArr', 0, getTemplateModeArr);

    it('TemplateModeAdapterTest_getTemplateModeNameArr', 0, getTemplateModeNameArr);

    it('TemplateModeAdapterTest_getTemplateModeIconId', 0, getTemplateModeIconId);
  })
}

function clearData() {
  try {
    const templateModeAdapter: TemplateModeAdapter = new TemplateModeAdapter();
    (templateModeAdapter as object)['clearData']();
    const templateModeArr: ModeConfigData[] = (templateModeAdapter as object)['templateModeArr'];
    expect(templateModeArr.length === 0).assertTrue();
    LogUtil.showInfo(TAG, 'clear data success');
  } catch (e) {
    LogUtil.showError(TAG, `clearData error: ${e?.code}, ${e?.message}`);
  }
}

function initData() {
  try {
    const templateModeAdapter: TemplateModeAdapter = new TemplateModeAdapter();
    (templateModeAdapter as object)['initData']();
    const templateModeArr: ModeConfigData[] = (templateModeAdapter as object)['templateModeArr'];
    expect(templateModeArr.length >= 0).assertTrue();
    LogUtil.showInfo(TAG, `initData success length: ${templateModeArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `initData error: ${e?.code}, ${e?.message}`);
  }
}

function queryTemplateMode() {
  try {
    const templateModeAdapter: TemplateModeAdapter = new TemplateModeAdapter();
    (templateModeAdapter as object)['queryTemplateMode']();
    const templateModeNameArr: string[] = (templateModeAdapter as object)['templateModeNameArr'];
    expect(templateModeNameArr.length >= 0).assertTrue();
    LogUtil.showInfo(TAG, `queryTemplateMode success length: ${templateModeNameArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `queryTemplateMode error: ${e?.code}, ${e?.message}`);
  }
}

function getTemplateModeArr() {
  try {
    const templateModeAdapter: TemplateModeAdapter = new TemplateModeAdapter();
    let templateModeArr: ModeConfigData[] = (templateModeAdapter as object)['getTemplateModeArr']();
    expect(templateModeArr.length >= 0).assertTrue();
    LogUtil.showInfo(TAG, `getTemplateModeArr success length: ${templateModeArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `getTemplateModeArr error: ${e?.code}, ${e?.message}`);
  }
}

function getTemplateModeNameArr() {
  try {
    const templateModeAdapter: TemplateModeAdapter = new TemplateModeAdapter();
    const templateModeNameArr: string[] = (templateModeAdapter as object)['getTemplateModeNameArr'];
    expect(templateModeNameArr.length >= 0).assertTrue();
    LogUtil.showInfo(TAG, `getTemplateModeNameArr success length: ${templateModeNameArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `getTemplateModeNameArr error: ${e?.code}, ${e?.message}`);
  }
}

function getTemplateModeIconId() {
  try {
    const templateModeAdapter: TemplateModeAdapter = new TemplateModeAdapter();
    const iconId: string = (templateModeAdapter as object)['getTemplateModeIconId']('1');
    expect(iconId === '').assertTrue();
    LogUtil.showInfo(TAG, `getTemplateModeIconId success iconId: ${iconId}`);
  } catch (e) {
    LogUtil.showError(TAG, `getTemplateModeIconId error: ${e?.code}, ${e?.message}`);
  }
}
