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

import insightIntent from '@ohos.app.ability.insightIntent';
import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
} from '@ohos/hypium';
import { IntentUtil } from '@ohos/scene.intent/src/main/ets/util/IntentUtil'
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ERROR_MSG, IntentCodeConstants } from '@ohos/scene.intent/src/main/ets/constant/IntentCodeConstant';
import { BaseModeConfig } from '@ohos/scene.modeconfig/src/main/ets/adapter/BaseModeConfig';
import { SpecialSettingConfig } from '@ohos/scene.modeconfig/src/main/ets/model/ModeConfigModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

export default function IntentUtilTest() {
  describe('IntentUtilTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('IntentUtil_nullResponse', 0, () => {
      let result: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.DEFAULT_CODE_FAILED,
        result: ({
          'errMsg': ERROR_MSG[IntentCodeConstants.DEFAULT_CODE_FAILED],
        } as Record<string, Object>)
      };
      IntentUtil.nullResponse().then(value => {
        expect(value.code).assertEqual(result.code);
      });
    });

    it('IntentUtil_errorResponse', 0, () => {
      let result: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.DEFAULT_CODE_FAILED,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.DEFAULT_CODE_FAILED] }
      };
      expect(IntentUtil.errorResponse(IntentCodeConstants.DEFAULT_CODE_FAILED).code).assertEqual(result.code);
    });

    it('IntentUtil_successResponse', 0, () => {
      let result: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.DEFAULT_CODE_SUCCESS,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.DEFAULT_CODE_SUCCESS] }
      };
      expect(IntentUtil.successResponse(IntentCodeConstants.DEFAULT_CODE_SUCCESS,
        ERROR_MSG[IntentCodeConstants.DEFAULT_CODE_SUCCESS]).code).assertEqual(result.code);
    });

    it('IntentUtil_getCurrentOpenedModeConfig', 0, () => {
      let openedModeId: string = ModeUtil.getModeOpenState().modeId;
      const config: BaseModeConfig = IntentUtil.getCurrentOpenedModeConfig();
      let specialSettingConfig: SpecialSettingConfig | undefined = config.getSpecialSettingConfig();
      if (openedModeId === ModeType.DND_MODE) {
        expect(specialSettingConfig).assertUndefined();
        return;
      }
      expect(config.isSupportAgent).assertTrue();
    });
  });
}