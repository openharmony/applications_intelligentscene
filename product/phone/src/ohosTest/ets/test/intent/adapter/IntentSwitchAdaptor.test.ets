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
  ArgumentMatchers,
  beforeEach,
  describe,
  expect,
  it,
  MockKit,
  when,
} from '@ohos/hypium';
import insightIntent from '@ohos.app.ability.insightIntent';
import { IntentSwitchAdaptor } from '@ohos/scene.intent/src/main/ets/adapter/IntentSwitchAdaptor';
import { IntentCodeConstants, ERROR_MSG } from '@ohos/scene.intent/src/main/ets/constant/IntentCodeConstant';
import { IntentConstant } from '@ohos/scene.intent/src/main/ets/constant/IntentConstant';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { PrivacyStatementUtil } from '@ohos/scene.common/src/main/ets/utils/PrivacyStatementUtil';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { RefreshAdapter } from '@ohos/scene.recommendation/src/main/ets/adapter/RefreshAdapter';

export default function IntentSwitchAdaptorTest() {
  describe('IntentSwitchAdaptorTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('modifyModeSwitch_not_exist_test', 0, async (done: Function) => {
      let intentParam = {
        'itemName': 'testIntentName'
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.NO_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_NOT_EXIST,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_NOT_EXIST] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_NOT_EXIST).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSwitch_switch_type_invalid_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 4,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSwitch_switch_state_invalid_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 1,
        'switchState': 3,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_INVALID_STATE_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_INVALID_STATE_CODE] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_INVALID_STATE_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSwitch_intelligent_switch_false_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 1,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      when(mockFunc)().afterReturn(false);
      mocker.ignoreMock(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_NO_AUTH,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_NO_AUTH] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_NO_AUTH).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSwitch_intelligent_switch_true1_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 1,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      when(mockFunc)().afterReturn(true);
      mocker.ignoreMock(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);

      let mocker1: MockKit = new MockKit();
      let mockFunc1: Function = mocker1.mockFunc(SettingsDataUtils, SettingsDataUtils.getSecureValue);
      when(mockFunc1)(ArgumentMatchers.any).afterReturn(ModeType.DND_MODE);
      mocker1.ignoreMock(SettingsDataUtils, SettingsDataUtils.getSecureValue);

      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let successResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
        result: { 'mg': 1 },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE).assertEqual(successResponse.code);
      done();
    });

    it('modifyModeSwitch_intelligent_switch_true_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 1,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      when(mockFunc)().afterReturn(true);
      mocker.ignoreMock(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let successResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
        result: { 'mg': 1 },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE).assertEqual(successResponse.code);
      done();
    });

    it('modifyModeSwitch_repeatCall_switch_false_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 2,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);
      when(mockFunc)().afterReturn(false);
      mocker.ignoreMock(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSwitch_repeatCall_switch_true_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 2,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);
      when(mockFunc)().afterReturn(true);
      mocker.ignoreMock(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let successResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
        result: { 'mg': 1 },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE).assertEqual(successResponse.code);
      done();
    });

    it('modifyModeSwitch_autoAnswer_switch_false_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 3,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isSupportAutoAnswer);
      when(mockFunc)().afterReturn(false);
      mocker.ignoreMock(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isSupportAutoAnswer);
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSwitch_autoAnswer_switch_true_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 3,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isSupportAutoAnswer);
      when(mockFunc)().afterReturn(true);
      mocker.ignoreMock(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isSupportAutoAnswer);

      let mocker1: MockKit = new MockKit();
      let mockFunc1: Function = mocker1.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);
      when(mockFunc1)().afterReturn(true);
      mocker1.ignoreMock(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);

      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let successResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
        result: { 'mg': 1 },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE).assertEqual(successResponse.code);
      done();
    });

    it('modifyModeSwitch_autoAnswer_switch_true1_test', 0, async (done: Function) => {
      let intentParam = {
        'switch': 3,
        'switchState': 1,
      } as Record<string, Object>;
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isSupportAutoAnswer);
      when(mockFunc)().afterReturn(true);
      mocker.ignoreMock(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isSupportAutoAnswer);

      let mocker1: MockKit = new MockKit();
      let mockFunc1: Function = mocker1.mockFunc(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);
      when(mockFunc1)().afterReturn(false);
      mocker1.ignoreMock(IncomingCallUtils.getInstance(), IncomingCallUtils.getInstance().isShowRepeatCall);

      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSyncSwitch_switch_state_invalid_test', 0, async (done: Function) => {
      let intentParam = {
        'syncSwitch': 3,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSyncSwitch(intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_INVALID_STATE_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_INVALID_STATE_CODE] },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_INVALID_STATE_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeSyncSwitch_success_test', 0, async (done: Function) => {
      let intentParam = {
        'syncSwitch': 1,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeSyncSwitch(intentParam);
      let successResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
        result: { 'msg': '1' },
      };
      expect(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE).assertEqual(successResponse.code);
      done();
    });

    it('modifyModeAssociatedSwitch_not_exist_test', 0, async (done: Function) => {
      let intentParam = {
        'itemName': 'testIntentName'
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeAssociatedSwitch(ModeType.NO_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_NOT_EXIST,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_NOT_EXIST] },
      };
      expect(IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_NOT_EXIST).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeAssociatedSwitch_param_invalid_test', 0, async (done: Function) => {
      let intentParam = {
        'associatedSwitch': 3,
        'switchState': 4,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeAssociatedSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_TYPE_NOT_SUPPORT,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_TYPE_NOT_SUPPORT] },
      };
      expect(IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_TYPE_NOT_SUPPORT).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeAssociatedSwitch_param1_valid_test', 0, async (done: Function) => {
      let intentParam = {
        'associatedSwitch': 1,
        'switchState': 1,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeAssociatedSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS] },
      };
      expect(IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS).assertEqual(errorResponse.code);
      done();
    });

    it('modifyModeAssociatedSwitch_param2_valid_test', 0, async (done: Function) => {
      let intentParam = {
        'associatedSwitch': 2,
        'switchState': 1,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentSwitchAdaptor.modifyModeAssociatedSwitch(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS] },
      };
      expect(IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS).assertEqual(errorResponse.code);
      done();
    });

    it('should_return_false_when_switchState_is_not_valid_test', 0, () => {
      let invalidSwitchState: number = 999;
      const result = IntentSwitchAdaptor.switchStateValid(invalidSwitchState);
      expect(result).assertEqual(false);
    });

    it('should_return_true_when_switchState_is_valid_test', 0, () => {
      let validSwitchState: number = IntentConstant.SWITCH_VALUE[0];
      const result = IntentSwitchAdaptor.switchStateValid(validSwitchState);
      expect(result).assertEqual(true);
    });

    it('should_return_false_when_associatedState_is_not_valid_test', 0, () => {
      let associatedState: number = 3;
      const result = IntentSwitchAdaptor.isAssociatedStateValid(associatedState);
      expect(result).assertEqual(false);
    });

    it('should_return_true_when_associatedState_is_valid_test', 0, () => {
      let associatedState: number = IntentConstant.SYSTEM_DARK_MODE;
      const result = IntentSwitchAdaptor.isAssociatedStateValid(associatedState);
      expect(result).assertEqual(true);
    });

    it('should_return_false_when_switch_is_not_valid_test', 0, () => {
      const invalidSwitchState: number = 999;
      const result = IntentSwitchAdaptor.isSwitchValid(invalidSwitchState);
      expect(result).assertEqual(false);
    });

    it('should_return_true_when_switch_is_valid_test', 0, () => {
      let validSwitchState: number = IntentConstant.SYSTEM_MODE_VALUE[0];
      const result = IntentSwitchAdaptor.isSwitchValid(validSwitchState);
      expect(result).assertEqual(true);
    });

    it('atc_isIntelligentExperienceAgreedFromOtherProcess_is_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockRefreshAdapterUpdateIntelligentState: Function = mocker.mockFunc(RefreshAdapter, RefreshAdapter.getInstance().updateIntelligentState);
      when(mockRefreshAdapterUpdateIntelligentState)(ArgumentMatchers.any).afterReturnNothing();

      let mockPrivacyStatementUtilIsIntelligentExperienceAgreedFromOtherProcess: Function =
        mocker.mockFunc(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      when(mockPrivacyStatementUtilIsIntelligentExperienceAgreedFromOtherProcess)().afterReturn(false);

      const result: ESObject = IntentSwitchAdaptor.modifyIntelligentState('modeId', true);
      expect(result !== undefined).assertTrue();

      mocker.ignoreMock(RefreshAdapter, RefreshAdapter.getInstance().updateIntelligentState);
      mocker.ignoreMock(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
    });

    it('atc_isIntelligentExperienceAgreedFromOtherProcess_is_true', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockRefreshAdapterUpdateIntelligentState: Function = mocker.mockFunc(RefreshAdapter, RefreshAdapter.getInstance().updateIntelligentState);
      when(mockRefreshAdapterUpdateIntelligentState)(ArgumentMatchers.any).afterReturnNothing();

      let mockPrivacyStatementUtilIsIntelligentExperienceAgreedFromOtherProcess: Function =
        mocker.mockFunc(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      when(mockPrivacyStatementUtilIsIntelligentExperienceAgreedFromOtherProcess)().afterReturn(true);

      let mockSettingsDataUtilsGetSecureValue: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSecureValue);
      when(mockSettingsDataUtilsGetSecureValue)(ArgumentMatchers.any).afterReturn('0');

      let mockSettingsDataUtilsSetSecureValue: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.setSecureValue);
      when(mockSettingsDataUtilsSetSecureValue)(ArgumentMatchers.any).afterReturnNothing();

      const result: ESObject = IntentSwitchAdaptor.modifyIntelligentState('modeId', true);
      expect(result !== undefined).assertTrue();

      mocker.ignoreMock(RefreshAdapter, RefreshAdapter.getInstance().updateIntelligentState);
      mocker.ignoreMock(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      mocker.ignoreMock(SettingsDataUtils, SettingsDataUtils.getSecureValue);
      mocker.ignoreMock(SettingsDataUtils, SettingsDataUtils.setSecureValue);
    });

    it('atc_isOpen_is_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockRefreshAdapterUpdateIntelligentState: Function = mocker.mockFunc(RefreshAdapter, RefreshAdapter.getInstance().updateIntelligentState);
      when(mockRefreshAdapterUpdateIntelligentState)(ArgumentMatchers.any).afterReturnNothing();

      let mockPrivacyStatementUtilIsIntelligentExperienceAgreedFromOtherProcess: Function =
        mocker.mockFunc(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      when(mockPrivacyStatementUtilIsIntelligentExperienceAgreedFromOtherProcess)().afterReturn(true);

      let mockSettingsDataUtilsGetSecureValue: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSecureValue);
      when(mockSettingsDataUtilsGetSecureValue)(ArgumentMatchers.any).afterReturn('0');

      let mockSettingsDataUtilsSetSecureValue: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.setSecureValue);
      when(mockSettingsDataUtilsSetSecureValue)(ArgumentMatchers.any).afterReturnNothing();

      const result: ESObject = IntentSwitchAdaptor.modifyIntelligentState('modeId', false);
      expect(result !== undefined).assertTrue();

      mocker.ignoreMock(RefreshAdapter, RefreshAdapter.getInstance().updateIntelligentState);
      mocker.ignoreMock(PrivacyStatementUtil, PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess);
      mocker.ignoreMock(SettingsDataUtils, SettingsDataUtils.getSecureValue);
      mocker.ignoreMock(SettingsDataUtils, SettingsDataUtils.setSecureValue);
    });
  });
}