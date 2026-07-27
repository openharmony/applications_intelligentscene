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
import { AppCondition } from '@ohos/scene.datamanage';
import {
  ApplicationManager
} from '../../../../../main/ets/pages/conditionsheet/applicationsheet/manager/ApplicationManager';

const TAG: string = 'ApplicationManagerTest: ';

export default function ApplicationManagerTest() {
  describe('ApplicationManagerTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('app_manager_get_instance_test', 0, (done: Function) => {
      try {
        const instance: ApplicationManager = ApplicationManager.getInstance();
        expect(instance !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG, `app_manager_get_instance_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('get_default_condition_test', 0, (done: Function) => {
      try {
        const defaultCondition: AppCondition = ApplicationManager.getDefaultCondition();
        expect(defaultCondition.enable).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG, `get_default_condition_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('get_info_test', 0, (done: Function) => {
      try {
        const instance: ApplicationManager = ApplicationManager.getInstance();
        const condition: AppCondition = instance.getInfo();
        const appCondition: AppCondition = (instance as object)['appCondition'];
        expect(condition.configId).assertEqual(appCondition.configId);
      } catch (err) {
        LogUtil.showError(TAG, `get_info_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('fill_info_test', 0, (done: Function) => {
      try {
        const instance: ApplicationManager = ApplicationManager.getInstance();
        const condition: AppCondition = {
          appConditionList: [],
          enable: false,
          configId: '1',
          configType: 1,
        };
        const data: ParsedConfigData = {
          parsedValue: condition,
          configId: '',
          modeId: '',
          configType: 0,
          configValue: ''
        };
        instance.filInfo(data);
        const conditionInfo: AppCondition = instance.getInfo();
        expect(conditionInfo.configId).assertEqual('1');
      } catch (err) {
        LogUtil.showError(TAG, `fill_info_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });
  });
}