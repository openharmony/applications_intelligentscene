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
  beforeEach,
  afterEach,
  it,
  expect
} from '@ohos/hypium';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { UpdateConditionUtil } from '@ohos/scene.statemanage/src/main/ets/utils/UpdateConditionUtil';

export default function UpdateConditionUtilTest() {
  describe('UpdateConditionUtilTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('invalid_param_distributeFun', 0, (done: Function) => {
      UpdateConditionUtil.distributeFun();
      const value: string =
        SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.INTELLIGENT_GAME_SUITE_CONDITION, '');
      expect(CheckEmptyUtils.isEmpty(value)).assertTrue();
      done();
    });

    it('action_on_param_distributeFun', 0, (done: Function) => {
      let param : Record<string, Object> = {
        'modeId': '1',
        'actionType': 1,
        'sourceType': 1,
      }
      UpdateConditionUtil.distributeFun(param);
      const value: string =
        SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.INTELLIGENT_GAME_SUITE_CONDITION, 'default_condition');
      expect(CheckEmptyUtils.isEmpty(value)).assertFalse();
      done();
    });

    it('action_off_param_distributeFun', 0, (done: Function) => {
      let param : Record<string, Object> = {
        'modeId': '1',
        'actionType': 0,
        'sourceType': 1,
      }
      UpdateConditionUtil.distributeFun(param);
      const value: string =
        SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.INTELLIGENT_GAME_SUITE_CONDITION, '');
      expect(CheckEmptyUtils.isEmpty(value)).assertTrue();
      done();
    });

    it('add_game_suite_condition', 0, (done: Function) => {
      UpdateConditionUtil.addGameSuiteCondition('1');
      const value: string =
        SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.INTELLIGENT_GAME_SUITE_CONDITION, 'default_condition');
      expect(CheckEmptyUtils.isEmpty(value)).assertFalse();
      done();
    });

    it('delete_game_suite_condition', 0, (done: Function) => {
      UpdateConditionUtil.deleteGameSuiteCondition('1');
      const value: string =
        SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.INTELLIGENT_GAME_SUITE_CONDITION, '');
      expect(CheckEmptyUtils.isEmpty(value)).assertTrue();
      done();
    });
  });
}