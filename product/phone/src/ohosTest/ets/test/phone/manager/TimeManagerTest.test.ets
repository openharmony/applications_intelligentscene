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
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
} from '@ohos/hypium';
import { LogUtil } from '@ohos/scene.common';
import { ParsedConfigData } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ConfigType, LoopType, TimeCondition } from '@ohos/scene.datamanage';
import {
  DEFAULT_END,
  DEFAULT_REPEAT,
  DEFAULT_START,
  TimeManager
} from '../../../../../main/ets/pages/conditionsheet/timedsheet/manager/TimeManager';

const TAG: string = 'TimeManagerTest: ';

export default function TimeManagerTest() {
  describe('TimeManagerTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('time_manager_get_instance_test', 0, (done: Function) => {
      try {
        const instance: TimeManager = TimeManager.getInstance();
        expect(instance !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG, `time_manager_get_instance_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('get_default_condition_test', 0, (done: Function) => {
      try {
        const defaultCondition: TimeCondition = TimeManager.getDefaultCondition();
        expect(defaultCondition.enable).assertTrue();
        expect(defaultCondition.configId).assertEqual('');
        expect(defaultCondition.configType).assertEqual(ConfigType.TRIGGER_CONDITION_TIME);
        expect(defaultCondition.loopDays).assertEqual(DEFAULT_REPEAT);
        expect(defaultCondition.timeStart).assertEqual(DEFAULT_START);
        expect(defaultCondition.timeEnd).assertEqual(DEFAULT_END);
      } catch (err) {
        LogUtil.showError(TAG, `get_default_condition_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('init_test', 0, (done: Function) => {
      try {
        const instance: TimeManager = TimeManager.getInstance();
        instance.init();
        expect(instance.isAdd).assertTrue();
        const defaultCondition: TimeCondition = TimeManager.getDefaultCondition();
        expect(defaultCondition.enable).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG, `init_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('fill_info_test', 0, (done: Function) => {
      try {
        const instance: TimeManager = TimeManager.getInstance();
        const condition: TimeCondition = {
          loopType: LoopType.ONE_TIME,
          loopDays: '',
          timeStart: '',
          timeEnd: '',
          configId: '1',
          configType: ConfigType.INVALID_TYPE,
          enable: false
        };
        const data: ParsedConfigData = {
          parsedValue: condition,
          configId: '1',
          modeId: '',
          configType: 0,
          configValue: ''
        };
        instance.filInfo(data);
        const conditionInfo: TimeCondition = instance.getInfo();
        expect(conditionInfo.configId).assertEqual('1');
      } catch (err) {
        LogUtil.showError(TAG, `fill_info_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });
  });
}