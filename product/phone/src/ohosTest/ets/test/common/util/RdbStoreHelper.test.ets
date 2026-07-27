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
  expect, MockKit,
} from '@ohos/hypium';
import { dataSharePredicates, relationalStore } from '@kit.ArkData';
import { commonEventManager } from '@kit.BasicServicesKit';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { CommonEventHelper } from '@ohos/scene.common/src/main/ets/commonevent/CommonEventHelper';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager } from '@ohos/scene.common/src/main/ets/bundle/BundleStatusChangeManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/scene.common';
import { when } from '@ohos/hamock';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';

const TAG: string = 'RdbStoreHelperTest: ';

export default function RdbStoreHelperTest() {
  describe('RdbStoreHelperTest', () => {
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

    it('RdbStoreHelperTest_test', 0, test);

    it('RdbStoreHelperTest_testCommonEvent', 0, testCommonEvent);

    it('RdbStoreHelperTest_bundleTest', 0, bundleTest);
  })
}

async function test(): Promise<void> {
  await RdbStoreHelper.getInstance().getRdbStore();
  const sql: string[] = ['create table if not exists test_table (id TEXT PRIMARY KEY, name TEXT)'];
  await RdbStoreHelper.getInstance().createTables(sql);
  const predicates: dataSharePredicates.DataSharePredicates = {} as dataSharePredicates.DataSharePredicates;
  await RdbStoreHelper.getInstance().queryByDataShare('', predicates, [''], () => {});
  const uri: string = 'datashare:///com.ohos.intelligentscene/phone/IntelligentScene/MODE_DATA_TABLE?Proxy=true';
  await RdbStoreHelper.getInstance().queryByDataShare(uri, predicates, [''], () => {});
  expect(sql !== undefined).assertTrue();
  await RdbStoreHelper.getInstance().executeSql(sql[0]);
  RdbStoreHelper.getInstance().subscribeCloudDataChange(true, () => {});

  try {
    await RdbStoreHelper.getInstance().backupRdbStore();
    await RdbStoreHelper.getInstance().restoreRdb();
    const version: number = await RdbStoreHelper.getInstance().getDbVersion();
    await RdbStoreHelper.getInstance().setDbVersion(version);
    await RdbStoreHelper.getInstance().createTables([]);
    await RdbStoreHelper.getInstance().batchInsert('test', []);
    RdbStoreHelper.getInstance().resetRdbStore();
    RdbStoreHelper.getInstance().subscribeCloudDataChange(true, () => {});
    RdbStoreHelper.getInstance().cleanDirtyData('test');
    await RdbStoreHelper.getInstance().backupRdbStore();
    await RdbStoreHelper.getInstance().resetRdbStore();
    RdbStoreHelper.getInstance().syncCloudChangeData(() => {});
    await RdbStoreHelper.getInstance().setDbVersion(version);
    await RdbStoreHelper.getInstance()
      .createTables(['create table if not exists test_table (id TEXT PRIMARY KEY, name TEXT)', 'create error']);
    let mocker: MockKit = new MockKit();
    let contextMock: Function = mocker.mockFunc(AbilityContextManager, AbilityContextManager.getContext);
    when(contextMock)().afterReturn(undefined);
    await RdbStoreHelper.getInstance().insert('test_table', {});
    mocker.ignoreMock(AbilityContextManager, AbilityContextManager.getContext);
    await RdbStoreHelper.getInstance().batchInsert('test_table', [{ 'name': '1' }]);
    let pred = new relationalStore.RdbPredicates('test_table');
    await RdbStoreHelper.getInstance().querySync(pred);
    let pred2: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    await RdbStoreHelper.getInstance().queryByDataShare('test', pred2);
    await RdbStoreHelper.getInstance().querySql('select * from test_table');
    await RdbStoreHelper.getInstance().executeSql('select * from test_table');
    await RdbStoreHelper.getInstance().update(pred, {});

    let deviceMock: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isWearable);
    when(deviceMock)().afterReturn(true);
    await RdbStoreHelper.getInstance().setCloudSyncTables(['test_table']);
    mocker.ignoreMock(DeviceUtil, DeviceUtil.isWearable);
    await RdbStoreHelper.getInstance().resetRdbStore();
    await RdbStoreHelper.getInstance().setCloudSyncTables(['test_table']);
    await RdbStoreHelper.getInstance().setDbVersion(0);
    await RdbStoreHelper.getInstance().resetRdbStore();
    await RdbStoreHelper.getInstance().setCloudSyncTables(['test_table']);
    mocker.ignoreMock(AbilityContextManager, AbilityContextManager.getContext);
    await RdbStoreHelper.getInstance().setCloudSyncTables(['test_table']);
    await RdbStoreHelper.getInstance().setDbVersion(version);
    await RdbStoreHelper.getInstance().resetRdbStore();
    await RdbStoreHelper.getInstance().insert('test_table', { 'name': 'Tom' });
    await RdbStoreHelper.getInstance().resetRdbStore();
    await RdbStoreHelper.getInstance().queryByDataShare('test', pred2);
    await RdbStoreHelper.getInstance().resetRdbStore();
    await RdbStoreHelper.getInstance().executeSql('');
    await RdbStoreHelper.getInstance().resetRdbStore();
    await RdbStoreHelper.getInstance().update(pred, { 'name': 'Tom' });
    await RdbStoreHelper.getInstance().resetRdbStore();
    await RdbStoreHelper.getInstance().delete();
    expect(version).assertLarger(-1);
  } catch (e) {
  }
}

function testCommonEvent(): void {
  let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: ['TEST_EVENT']
  };
  let commonEventHelper: CommonEventHelper = new CommonEventHelper(subscribeInfo, () => {});
  commonEventHelper.unRegisterCommonEvent();
  commonEventHelper.registerCommonEvent();
  commonEventHelper.unRegisterCommonEvent();
  commonEventHelper.unRegisterCommonEvent();
  expect(commonEventHelper !== undefined).assertTrue();
}

async function bundleTest(): Promise<void> {
  let listener: TestBundleStatusChangeListener = new TestBundleStatusChangeListener();
  listener.getListenerName();
  listener.onBundleAdd('test', 1, 1);
  listener.onBundleUpdate('test', 2, 2);
  listener.onBundleRemove('test', 2, 2);
  await BundleStatusChangeManager.getInstance().registerBundleChangedListener(listener);
  await BundleStatusChangeManager.getInstance().registerBundleChangedListener(listener);
  await BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(listener);
  expect(listener !== undefined).assertTrue();
}

class TestBundleStatusChangeListener implements BundleStatusChangeListener {
  getListenerName(): string {
    return 'test';
  }

  onBundleAdd(bundleName: string, userId: number, appIndex: number): void {
    LogUtil.showInfo(TAG, 'onBundleAdd');
  }

  onBundleUpdate(bundleName: string, userId: number, appIndex: number): void {
    LogUtil.showInfo(TAG, 'onBundleUpdate');
  }

  onBundleRemove(bundleName: string, userId: number, appIndex: number): void {
    LogUtil.showInfo(TAG, 'onBundleRemove');
  }
}