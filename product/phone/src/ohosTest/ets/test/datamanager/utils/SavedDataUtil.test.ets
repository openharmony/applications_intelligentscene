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

import Settings from '@ohos.settings';
import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  MockKit,
  expect,
} from '@ohos/hypium'
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils'
import { dataShare } from '@kit.ArkData';
import { when } from '@ohos/hamock';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

export default function SavedDataUtilTest() {
  describe('SavedDataUtilTest', () => {
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

    it('SavedDataUtilTest_test', 0, async () => { await savedTest1() });

    it('SavedDataUtilTest_test2', 0, async () => { await savedTest2() });
  })
}

async function savedTest1() {
  SettingsDataUtils.getSettingsData('', '');
  SettingsDataUtils.getSettingsData('test', '');
  SettingsDataUtils.getSettingsData('test', '', Settings.domainName.USER_PROPERTY);

  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();

  const context: Context = AbilityContextManager.getContext() as Context;
  SettingsDataUtils.getSettingsDataWithContext(context, '', '');
  SettingsDataUtils.getSettingsDataWithContext(context, 'test', '');
  SettingsDataUtils.getSettingsDataWithContext(context, 'test', '',
    Settings.domainName.USER_PROPERTY);

  SettingsDataUtils.getSettingsDataAsync('', '');
  SettingsDataUtils.getSettingsDataAsync('test', '');
  SettingsDataUtils.getSettingsDataAsync('test', '', Settings.domainName.USER_PROPERTY);

  SettingsDataUtils.setSettingsDataAsync('test', 'test');
  SettingsDataUtils.setSettingsDataAsync('', '');
  SettingsDataUtils.setSettingsDataAsync('test', 'test', Settings.domainName.USER_PROPERTY);

  SettingsDataUtils.setSettingsDataAsyncWithContext(context, '', '');
  SettingsDataUtils.setSettingsDataAsyncWithContext(context, 'test', '1');
  SettingsDataUtils.setSettingsDataAsyncWithContext(context, 'test', '1',
    Settings.domainName.USER_PROPERTY);

  SettingsDataUtils.setSettingsDataDomain('test', 'test', Settings.domainName.USER_PROPERTY);

  SettingsDataUtils.registerKeyObserver('test', () => {});
  SettingsDataUtils.unregisterKeyObserver('test');

  SettingsDataUtils.getSupport('test', '');

  SettingsDataUtils.getSettingsUserUri('test');

  let dataHelper: dataShare.DataShareHelper | undefined = await SettingsDataUtils
    .createDataHelper(SettingsDataKeyConstant.INTELLIGENT_REFRESH_CONFIG_DATA) as dataShare.DataShareHelper;
  if (dataHelper) {
    let uri = SettingsDataUtils.getSettingsUri(SettingsDataKeyConstant.INTELLIGENT_REFRESH_CONFIG_DATA);
    dataHelper.on('dataChange', uri, () => {});
    SettingsDataUtils.unRegisterUserDataChange(dataHelper, SettingsDataKeyConstant.INTELLIGENT_REFRESH_CONFIG_DATA);
  }

  let dataHelperUndefined: dataShare.DataShareHelper =
    await SettingsDataUtils.createDataHelper('1111') as dataShare.DataShareHelper;
  SettingsDataUtils.registerSecurityDataChange(dataHelperUndefined, 'test', () => {});
  SettingsDataUtils.unRegisterSecurityDataChange(dataHelperUndefined, 'test');
  SettingsDataUtils.unRegisterSecurityDataChange(dataHelper, 'test');

  SettingsDataUtils.registerUserDataChange(dataHelper as dataShare.DataShareHelper, 'test', () => {});
  SettingsDataUtils.registerUserDataChange(dataHelper, 'test', () => {});

  SettingsDataUtils.unRegisterUserDataChange(dataHelperUndefined, 'test');
  SettingsDataUtils.unRegisterUserDataChange(dataHelper, 'test');

  SettingsDataUtils.setSettingsDataWithContext(AbilityContextManager.getContext() as Context, '', '');
  SettingsDataUtils.setSettingsDataWithContext(AbilityContextManager.getContext() as Context, 'test', 'test');
  SettingsDataUtils.setSettingsDataWithContext(AbilityContextManager.getContext() as Context, 'test', 'test',
    Settings.domainName.USER_PROPERTY);
  SettingsDataUtils.registerDataChange(dataHelperUndefined, 'test', () => {});
  SettingsDataUtils.registerDataChange(dataHelper, 'test', () => {});
  SettingsDataUtils.unRegisterDataChange(dataHelperUndefined, 'test');
  SettingsDataUtils.unRegisterDataChange(dataHelper, 'test');
}

async function savedTest2() {
  try {
    SettingsDataUtils.getSettingsData('test', '');
    await SettingsDataUtils.getSettingsDataAsync('test', '');
    SettingsDataUtils.setSettingsData('', 'a');
    SettingsDataUtils.setSettingsData('a', 'a');
    const a: string = SettingsDataUtils.getSettingsData('a', 'a');
    expect(a !== undefined).assertTrue();
    SettingsDataUtils.registerKeyObserverUser('test', () => {});
    SettingsDataUtils.unregisterKeyObserverUser('test');
    SettingsDataUtils.unregisterKeyObserverWithDomain('test', Settings.domainName.USER_PROPERTY);

    SettingsDataUtils.getSettingsUri('');
    const str: string = StringUtil.generateUuid();
    expect(str !== undefined).assertTrue();

    let settingDataUtil: SettingsDataUtils = new SettingsDataUtils();
    SettingsDataUtils.getSettingsUri('');
    (settingDataUtil as object)['unRegisterDataChange'](undefined, 'test', () => {});
    (settingDataUtil as object)['registerSecurityDataChange'](undefined, 'test', () => {});
    (settingDataUtil as object)['unRegisterSecurityDataChange'](undefined, 'test');
    (settingDataUtil as object)['registerUserDataChange'](undefined, 'test', () => {});
    (settingDataUtil as object)['unRegisterUserDataChange'](undefined, 'test');
  } catch (e) {
  }
}