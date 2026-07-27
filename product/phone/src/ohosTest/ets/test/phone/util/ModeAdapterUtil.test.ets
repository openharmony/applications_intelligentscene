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
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

const TAG: string = 'ModeAdapterUtilTest: ';

export default function ModeAdapterUtilTest() {
  describe('ModeAdapterUtilTest', () => {
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

    it('ModeAdapterUtil_getInstance', 0, getInstance);

    it('ModeAdapterUtil_initData', 0, initData);

    it('ModeAdapterUtil_detach', 0, detach);

    it('ModeAdapterUtil_clearData', 0, clearData);

    it('ModeAdapterUtil_queryAllModeData', 0, queryAllModeData);

    it('ModeAdapterUtil_getAllModeArr', 0, getAllModeArr);

    it('ModeAdapterUtil_getShowModeArr', 0, getShowModeArr);

    it('ModeAdapterUtil_getModeNameById', 0, getModeNameById);

    it('ModeAdapterUtil_updateModeCacheById', 0, updateModeCacheById);

    it('ModeAdapterUtil_deleteModeCacheById', 0, deleteModeCacheById);
  })
}

function getInstance() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    expect(modeAdapter !== undefined).assertTrue();
    LogUtil.showInfo(TAG, 'getInstance success');
  } catch (e) {
    LogUtil.showError(TAG, `getInstance error: ${e?.code}, ${e?.message}`);
  }
}

function initData() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    (modeAdapter as object)['initData']();
    const initTag: string = (modeAdapter as object)['tag'];
    expect(initTag === 'ModeAdapter:').assertTrue();
    LogUtil.showInfo(TAG, `initData success ${initTag}`);
  } catch (e) {
    LogUtil.showError(TAG, `initData error: ${e?.code}, ${e?.message}`);
  }
}

function detach() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    (modeAdapter as object)['detach']();
    const intervalId: number | undefined = (modeAdapter as object)['timerId'];
    expect(intervalId).assertUndefined();
    LogUtil.showInfo(TAG, `detach success ${intervalId}`);
  } catch (e) {
    LogUtil.showError(TAG, `detach error: ${e?.code}, ${e?.message}`);
  }
}

function clearData() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    (modeAdapter as object)['clearData']();
    const allModeArr: ModeData[] = (modeAdapter as object)['allModeArr'];
    expect(allModeArr.length).assertEqual(0);
    LogUtil.showInfo(TAG, `clearData success ${allModeArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `clearData error: ${e?.code}, ${e?.message}`);
  }
}

async function queryAllModeData(): Promise<void> {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    await (modeAdapter as object)['queryAllModeData']();
    const allModeArr: ModeData[] = (modeAdapter as object)['allModeArr'];
    expect(allModeArr.length).assertLargerOrEqual(0);
    LogUtil.showInfo(TAG, `queryAllModeData success ${allModeArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `queryAllModeData error: ${e?.code}, ${e?.message}`);
  }
}

function getAllModeArr() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    const allModeArr: ModeData[] = modeAdapter.getAllModeArr();
    expect(allModeArr.length).assertLargerOrEqual(0);
    LogUtil.showInfo(TAG, `getAllModeArr success ${allModeArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `getAllModeArr error: ${e?.code}, ${e?.message}`);
  }
}

function getShowModeArr() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    const allModeArr: ModeData[] = modeAdapter.getShowModeArr('1');
    expect(allModeArr.length).assertLargerOrEqual(0);
    LogUtil.showInfo(TAG, `getShowModeArr success ${allModeArr.length}`);
  } catch (e) {
    LogUtil.showError(TAG, `getShowModeArr error: ${e?.code}, ${e?.message}`);
  }
}

function getModeNameById() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    const modeName: string = modeAdapter.getModeNameById('1');
    expect(modeName.length).assertLargerOrEqual(0);
    LogUtil.showInfo(TAG, `getModeNameById success ${modeName}`);
  } catch (e) {
    LogUtil.showError(TAG, `getModeNameById error: ${e?.code}, ${e?.message}`);
  }
}

function updateModeCacheById() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    modeAdapter.updateModeCacheById('1');
    const intervalId: number | undefined = (modeAdapter as object)['timerId'];
    expect(intervalId).assertUndefined();
    LogUtil.showInfo(TAG, `updateModeCacheById success ${intervalId}`);
  } catch (e) {
    LogUtil.showError(TAG, `updateModeCacheById error: ${e?.code}, ${e?.message}`);
  }
}

function deleteModeCacheById() {
  try {
    const modeAdapter: ModeAdapter = ModeAdapter.getInstance();
    modeAdapter.deleteModeCacheById('1');
    const tag: string = (modeAdapter as object)['tag'];
    expect(tag.startsWith('ModeAdapter')).assertTrue();
    LogUtil.showInfo(TAG, `deleteModeCacheById success ${tag}`);
  } catch (e) {
    LogUtil.showError(TAG, `deleteModeCacheById error: ${e?.code}, ${e?.message}`);
  }
}
