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
  it, expect,
} from '@ohos/hypium'
import { AbilityContextManager, DebounceUtil } from '@ohos/scene.common'
import { HiSysEventUtil, ModeParams } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs'
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager'
import { ModeDataViewUtils } from '@ohos/scene.configmanage/src/main/ets/utils/ModeDataViewUtils'
import { TimePickerUtil, WeekDayFormat } from '@ohos/scene.configmanage/src/main/ets/utils/TimePickerUtil'
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { NotDisturbTimerManager } from '@ohos/scene.notdisturb/src/main/ets/NotDisturbTimerManager';

export default function HiSysEventUtilTest() {
  describe('HiSysEventUtilTest', () => {
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

    it('HiSysEventUtilTest_test', 0, test);
  })
}

async function test(): Promise<void> {
  const pkgName: string = HiSysEventUtil.getPkgName();
  expect(pkgName !== undefined).assertTrue();
  HiSysEventUtil.getProcessName();
  HiSysEventUtil.reportUEStatisticEvent('test', 'test');
  await generateConfigData();
  await ModeDataViewUtils.hiViewWhenOpenOrClose('2', true, 2);
  DebounceUtil.sleep(2000);
  await ModeDataViewUtils.hiViewWhenOpenOrClose('2', false, 2);
  const weekDayFormat = WeekDayFormat.Short;
  TimePickerUtil.getDayOfWeek(1, weekDayFormat);
  TimePickerUtil.getDaysOfWeekLabels();
  TimePickerUtil.getDaysOfWeekDesc('1,2,4');
  TimePickerUtil.getDaysOfWeekDesc('');
  TimePickerUtil.getDaysOfWeekDesc('1,2,3,4,5');
  const context: Context = AbilityContextManager.getContext() as Context;
  await PreloadManager.getInstance().getVersionFromPreference(context);
  await NotDisturbTimerManager.getInstance().getTimers(context);
  await NotDisturbTimerManager.getInstance().initOtherConfig(context, true);
  await NotDisturbTimerManager.getInstance().initOtherConfig(context, false);
}

async function generateConfigData(): Promise<void> {
  let configData: ConfigData = {
    configId: '',
    modeId: '2',
    configType: ConfigType.TRIGGER_CONDITION_APP,
    configValue: '{"enable":true,"appConditionList":[{"bundleName":"com.wuba.life","index":0}],"configType":5}'
  };
  await ConfigDataManager.getInstance().insertConfigData(configData);
}