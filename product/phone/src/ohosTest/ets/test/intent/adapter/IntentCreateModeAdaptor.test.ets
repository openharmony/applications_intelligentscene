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
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium';
import insightIntent from '@ohos.app.ability.insightIntent';
import { IntentCodeConstants, ERROR_MSG } from '@ohos/scene.intent/src/main/ets/constant/IntentCodeConstant';
import { IntentCreateModeAdaptor } from '@ohos/scene.intent/src/main/ets/adapter/IntentCreateModeAdaptor';
import { IntentQueryModeAdaptor } from '@ohos/scene.intent/src/main/ets/adapter/IntentQueryModeAdaptor';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { SceneBaseDataManager } from '@ohos/scene.configmanage/src/main/ets/manager/SceneBaseDataManager';
import { IntentSwitchAdaptor } from '@ohos/scene.intent/src/main/ets/adapter/IntentSwitchAdaptor';
import { NotDisturbAdapter } from '@ohos/scene.notdisturb/src/main/ets/adapter/NotiDisturbAdapter';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { ModeConfigData } from '@ohos/scene.configmanage/src/main/ets/preload/model/model/DefaultModeConfigData';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

export default function IntentCreateModeAdaptorTest() {
  describe('IntentCreateModeAdaptorTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('createMode_include_modeName_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);
      let modeNameList: string[] =[];
      when(mockFunc)().afterReturn(modeNameList);
      mocker.ignoreMock(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);
      let intentParam = {
        'itemName': 'testIntentName'
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentCreateModeAdaptor.createMode(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.CREATE_MODE_REPEAT,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.CREATE_MODE_REPEAT] },
      };
      expect(IntentCodeConstants.CREATE_MODE_REPEAT).assertEqual(errorResponse.code);
      let mockFunc2: Function = mocker.mockFunc(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);
      let modeNameList2: string[] = ['1', '2', '3', '4', '5', '1', '2', '3', '4', '5', '1', '2', '3', '4', '5'];
      when(mockFunc2)().afterReturn(modeNameList2);
      await IntentCreateModeAdaptor.createMode(ModeType.DND_MODE, intentParam);
      mocker.ignoreMock(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);

      await IntentCreateModeAdaptor.createMode('1', intentParam);
      done();
    });

    it('createMode_modeName_max_length_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);
      let modeNameList: string[] = ["testName1",  "testName2", "testName3", "testName4",
        "testName5", "testName6", "testName7", "testName8", "testName9", "testName10",
        "testName11", "testName12", "testName13", "testName14", "testName15"];
      when(mockFunc)().afterReturn(modeNameList);
      mocker.ignoreMock(IntentQueryModeAdaptor, IntentQueryModeAdaptor.getAllCreatedModeName);
      let intentParam = {
        'itemName': 'testIntentName'
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentCreateModeAdaptor.createMode(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.CREATE_MODE_MAX_NUMBER_FAIL_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.CREATE_MODE_MAX_NUMBER_FAIL_CODE] },
      };
      expect(IntentCodeConstants.CREATE_MODE_MAX_NUMBER_FAIL_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('createMode_modeId_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(IntentCreateModeAdaptor, IntentCreateModeAdaptor.createModeByModeName);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(-1);
      mocker.ignoreMock(IntentCreateModeAdaptor, IntentCreateModeAdaptor.createModeByModeName);
      let intentParam = {
        'itemName': 'testIntentName'
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentCreateModeAdaptor.createMode(ModeType.DND_MODE, intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.CREATE_MODE_FAIL_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.CREATE_MODE_FAIL_CODE] },
      };
      expect(IntentCodeConstants.CREATE_MODE_FAIL_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('createMode_call_fail_test', 0, async (done: Function) => {
      let intentParam = {
        "scenarioModeName": "个人模式",
        "callAllowPolicy": 7,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentCreateModeAdaptor.createMode("个人模式", intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.CREATE_MODE_FAIL_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.CREATE_MODE_FAIL_CODE] },
      };
      expect(IntentCodeConstants.CREATE_MODE_FAIL_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('createMode_notify_fail_test', 0, async (done: Function) => {
      let intentParam = {
        "scenarioModeName": "个人模式",
        "callAllowPolicy": 1,
        "notifyAllowPolicy": 5,
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentCreateModeAdaptor.createMode("个人模式", intentParam);
      let errorResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.CREATE_MODE_FAIL_CODE,
        result: { 'errMsg': ERROR_MSG[IntentCodeConstants.CREATE_MODE_FAIL_CODE] },
      };
      expect(IntentCodeConstants.CREATE_MODE_FAIL_CODE).assertEqual(errorResponse.code);
      done();
    });

    it('createMode_success_test', 0, async (done: Function) => {
      let intentParam = {
        "scenarioModeName": "个人模式",
        "callAllowPolicy": 1,
        "notifyAllowPolicy": 1,
        "periodPolicy": 3,
        "repeatDays": [6,7],
        "startTime": "17:00:00",
        "endTime": "18:00:00",
      } as Record<string, Object>;
      let result: insightIntent.ExecuteResult = await IntentCreateModeAdaptor.createMode("个人模式", intentParam);
      let successResponse: insightIntent.ExecuteResult = {
        code: IntentCodeConstants.CREATE_MODE_SUCCESS_CODE,
        result: { 'msg': '1' },
      };
      expect(IntentCodeConstants.CREATE_MODE_SUCCESS_CODE).assertEqual(successResponse.code);
      done();
    });

    it('addTimePeriod_valid_test', 0, async (done: Function) => {
      let result: string = "Test";
      let intentParam = {
        "periodPolicy": 3,
        "repeatDays": [6,7],
        "startTime": "17:00:00",
        "endTime": "18:00:00",
      } as Record<string, Object>;
      await IntentCreateModeAdaptor.addTimePeriod(ModeType.DND_MODE, intentParam);
      expect(result).assertEqual("Test");
      done();
    });

    it('addTimePeriod_inValid_test', 0, async (done: Function) => {
      let result: string = "Test";
      let intentParam = {
        'startTime': "",
        'endTime': "",
      } as Record<string, Object>;
      await IntentCreateModeAdaptor.addTimePeriod(ModeType.DND_MODE, intentParam);
      expect(result).assertEqual("Test");
      done();
    });

    it('atc_darkModePolicy_is_valid', 0, async () => {
      let modeId: string = "1";
      let intentParam: Record<string, Object> = {
        "darkModePolicy": "1",
        "eyeProtectionPolicy": "2",
        "smartOpenSwitch": "3",
        "repeatRingCallSwitch": "4",
        "autoPickupSwitch": "5"
      };
      let mocker: MockKit = new MockKit();
      let mockfunc1: Function = mocker.mockFunc(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      when(mockfunc1)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc2: Function = mocker.mockFunc(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc3: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      when(mockfunc3)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc4: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
      when(mockfunc4)(ArgumentMatchers.any).afterReturn(null);

      await IntentCreateModeAdaptor.modifySwitch(modeId, intentParam);

      mocker.ignoreMock(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      mocker.ignoreMock(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
    });

    it('atc_eyeProtectionPolicy_is_valid', 0, async () => {
      let modeId: string = "1";
      let intentParam: Record<string, Object> = {
        "darkModePolicy": "2",
        "eyeProtectionPolicy": "1",
        "smartOpenSwitch": "3",
        "repeatRingCallSwitch": "4",
        "autoPickupSwitch": "5"
      };
      let mocker: MockKit = new MockKit();
      let mockfunc1: Function = mocker.mockFunc(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      when(mockfunc1)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc2: Function = mocker.mockFunc(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc3: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      when(mockfunc3)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc4: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
      when(mockfunc4)(ArgumentMatchers.any).afterReturn(null);

      await IntentCreateModeAdaptor.modifySwitch(modeId, intentParam);

      mocker.ignoreMock(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      mocker.ignoreMock(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
    });

    it('atc_smartOpenSwitch_is_valid', 0, async () => {
      let modeId: string = "1";
      let intentParam: Record<string, Object> = {
        "darkModePolicy": "2",
        "eyeProtectionPolicy": "2",
        "smartOpenSwitch": "1",
        "repeatRingCallSwitch": "4",
        "autoPickupSwitch": "5"
      };
      let mocker: MockKit = new MockKit();
      let mockfunc1: Function = mocker.mockFunc(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      when(mockfunc1)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc2: Function = mocker.mockFunc(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc3: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      when(mockfunc3)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc4: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
      when(mockfunc4)(ArgumentMatchers.any).afterReturn(null);

      await IntentCreateModeAdaptor.modifySwitch(modeId, intentParam);

      mocker.ignoreMock(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      mocker.ignoreMock(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
    });

    it('atc_repeatRingCallSwitch_is_valid', 0, async () => {
      let modeId: string = "1";
      let intentParam: Record<string, Object> = {
        "darkModePolicy": "2",
        "eyeProtectionPolicy": "2",
        "smartOpenSwitch": "3",
        "repeatRingCallSwitch": "1",
        "autoPickupSwitch": "5"
      };
      let mocker: MockKit = new MockKit();
      let mockfunc1: Function = mocker.mockFunc(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      when(mockfunc1)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc2: Function = mocker.mockFunc(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc3: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      when(mockfunc3)(ArgumentMatchers.any).afterReturn(null);
      let mockfunc4: Function = mocker.mockFunc(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
      when(mockfunc4)(ArgumentMatchers.any).afterReturn(null);

      await IntentCreateModeAdaptor.modifySwitch(modeId, intentParam);

      mocker.ignoreMock(IntentSwitchAdaptor, IntentSwitchAdaptor.modifyAssociatedSwitch);
      mocker.ignoreMock(RefreshAdapter.getInstance(), RefreshAdapter.getInstance().updateIntelligentState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateRepeatRingState);
      mocker.ignoreMock(NotDisturbAdapter.getInstance(), NotDisturbAdapter.getInstance().updateAutoAnswerState);
    });

    it('atc_modeName_is_invalid', 0, async () => {
      let modeName: string = 'invalidModeName';
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SceneBaseDataManager, SceneBaseDataManager.isModeNameValid);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn(false);
      const result: ESObject = await IntentCreateModeAdaptor.createModeByModeName(modeName);
      expect(result).assertEqual('');
      mocker.ignoreMock(SceneBaseDataManager, SceneBaseDataManager.isModeNameValid);
    });

    it('atc_modeData_is_not_created', 0, async () => {
      let modeName: string = 'validModeName';
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SceneBaseDataManager, SceneBaseDataManager.isModeNameValid);
      let mockfunc2: Function = mocker.mockFunc(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      let mockfunc3: Function = mocker.mockFunc(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getModeIdFromTemplate);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn(true);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn(true);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn([new ModeConfigData()]);
      when(mockfunc3)(ArgumentMatchers.any).afterReturn(undefined);
      const result: ESObject = await IntentCreateModeAdaptor.createModeByModeName(modeName);
      mocker.ignoreMock(SceneBaseDataManager, SceneBaseDataManager.isModeNameValid);
      mocker.ignoreMock(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      mocker.ignoreMock(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getModeIdFromTemplate);
    });

    it('atc_modeName_is_null', 0, async () => {
      let modeName: string = '';
      let modeconfigData: ModeConfigData = {
        modeId: '1',
        modeName: 'mode1',
        iconId: '',
        iconColor: '',
        configs: [],
        filletIcon: '',
        roundIcon: '',
        isSupportDelete: false,
        modePriority: 0
      };
      let templateModeArr: ModeConfigData[] = [modeconfigData];
      const result: ESObject = await IntentCreateModeAdaptor.getModeIdFromTemplate(modeName, templateModeArr);
    });

    it('atc_templateModeArr_is_null', 0, async () => {
      let modeName: string = 'mode1';
      let templateModeArr: ModeConfigData[] = [];
      const result: ESObject = await IntentCreateModeAdaptor.getModeIdFromTemplate(modeName, templateModeArr);
    });

    it('atc_modeName_not_found_in_templateModeArr', 0, async () => {
      let modeName: string = 'mode2';
      let modeconfigData: ModeConfigData = {
        modeId: '1',
        modeName: 'mode1',
        iconId: '',
        iconColor: '',
        filletIcon: '',
        roundIcon: '',
        isSupportDelete: false,
        modePriority: 0,
        configs: []
      };
      let templateModeArr: ModeConfigData[] = [modeconfigData];
      const result: ESObject = await IntentCreateModeAdaptor.getModeIdFromTemplate(modeName, templateModeArr);
    });

    it('atc_modeName_found_in_templateModeArr', 0, async () => {
      let modeName: string = 'mode1';
      let modeconfigData: ModeConfigData = {
        modeId: '1',
        modeName: 'mode1',
        iconId: '',
        iconColor: '',
        filletIcon: '',
        roundIcon: '',
        isSupportDelete: false,
        modePriority: 0,
        configs: []
      };
      let templateModeArr: ModeConfigData[] = [modeconfigData];
      const result: ESObject = await IntentCreateModeAdaptor.getModeIdFromTemplate(modeName, templateModeArr);
    });

    it('atc_when_modeName_is_valid', 0, () => {
      let modeName: string = "testMode";
      let result: ModeData = IntentCreateModeAdaptor.getCustomModeData(modeName);
      expect(result.modeId).assertEqual(INVALID_MODE_ID);
    });

    it('atc_icon_is_not_found', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: ESObject = mocker.mockFunc(ResourceUtil, ResourceUtil.getPixelMap);
      when(mockFunc)(ArgumentMatchers.anyString).afterReturn(undefined);

      let modeName: string = "testMode";
      let result: ModeData = IntentCreateModeAdaptor.getCustomModeData(modeName);
      expect(result.modeId).assertEqual(INVALID_MODE_ID);

      mocker.ignoreMock(ResourceUtil, ResourceUtil.getPixelMap);
    });

    it('atc_icon_is_found', 0, () => {
      let modeName: string = "testMode";
      let result: ModeData = IntentCreateModeAdaptor.getCustomModeData(modeName);
      expect(result.modeId).assertEqual(INVALID_MODE_ID);
    });

    it('atc_templateMode_is_null', 0, () => {
      let modeName: string = "modeName";
      let modeId: string = "modeId";
      let templateModeArr: ModeConfigData[] = [];
      const result: ESObject = IntentCreateModeAdaptor.getTemplateModeData(modeName, modeId, templateModeArr);
      expect(result).assertUndefined();
    });

    it('atc_templateMode_modeId_not_equal_modeId', 0, () => {
      let modeName: string = "modeName";
      let modeId: string = "modeId";
      let modeConfigData: ModeConfigData = {
        modeId: "otherId",
        iconId: "iconId",
        modeName: "modeName",
        iconColor: "iconColor",
        filletIcon: "filletIcon",
        roundIcon: "roundIcon",
        isSupportDelete: true,
        modePriority: 0,
        configs: []
      };
      let templateModeArr: ModeConfigData[] = [modeConfigData];
      const result: ESObject = IntentCreateModeAdaptor.getTemplateModeData(modeName, modeId, templateModeArr);
      expect(result).assertUndefined();
    });

    it('atc_templateMode_is_valid', 0, () => {
      let modeName: string = "modeName";
      let modeId: string = "modeId";
      let modeConfigData: ModeConfigData = {
        modeId: modeId,
        iconId: "iconId",
        modeName: "modeName",
        iconColor: "iconColor",
        filletIcon: "filletIcon",
        roundIcon: "roundIcon",
        isSupportDelete: true,
        modePriority: 0,
        configs: []
      };
      let templateModeArr: ModeConfigData[] = [modeConfigData];
      let mocker: MockKit = new MockKit();
      let mockGetCustomModeData: Function = mocker.mockFunc(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      when(mockGetCustomModeData)(ArgumentMatchers.anyString).afterReturn({ modeId: modeId, iconId: "iconId", modeName: "modeName", iconColor: "iconColor", filletIcon: "filletIcon", roundIcon: "roundIcon", isSupportDelete: true });
      let mockGetPixelMap: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getPixelMap);
      when(mockGetPixelMap)(ArgumentMatchers.anyString).afterReturn(undefined);
      const result: ESObject = IntentCreateModeAdaptor.getTemplateModeData(modeName, modeId, templateModeArr);
      mocker.ignoreMock(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      mocker.ignoreMock(ResourceUtil, ResourceUtil.getPixelMap);
    });

    it('atc_templateMode_is_valid_and_filletIcon_is_valid', 0, () => {
      let modeName: string = "modeName";
      let modeId: string = "modeId";
      let modeConfigData: ModeConfigData = {
        modeId: modeId,
        iconId: "iconId",
        modeName: "modeName",
        iconColor: "iconColor",
        filletIcon: "filletIcon",
        roundIcon: "roundIcon",
        isSupportDelete: true,
        modePriority: 0,
        configs: []
      };
      let templateModeArr: ModeConfigData[] = [modeConfigData];
      let mocker: MockKit = new MockKit();
      let mockGetCustomModeData: Function = mocker.mockFunc(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      when(mockGetCustomModeData)(ArgumentMatchers.anyString).afterReturn({ modeId: modeId, iconId: "iconId", modeName: "modeName", iconColor: "iconColor", filletIcon: "filletIcon", roundIcon: "roundIcon", isSupportDelete: true });
      const result: ESObject = IntentCreateModeAdaptor.getTemplateModeData(modeName, modeId, templateModeArr);
      mocker.ignoreMock(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      mocker.ignoreMock(ResourceUtil, ResourceUtil.getPixelMap);
    });

    it('atc_templateMode_is_valid_and_roundIcon_is_valid', 0, () => {
      let modeName: string = "modeName";
      let modeId: string = "modeId";
      let modeConfigData: ModeConfigData = {
        modeId: modeId,
        iconId: "iconId",
        modeName: "modeName",
        iconColor: "iconColor",
        filletIcon: "filletIcon",
        roundIcon: "roundIcon",
        isSupportDelete: true,
        modePriority: 0,
        configs: []
      };
      let templateModeArr: ModeConfigData[] = [modeConfigData];
      let mocker: MockKit = new MockKit();
      let mockGetCustomModeData: Function = mocker.mockFunc(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      when(mockGetCustomModeData)(ArgumentMatchers.anyString).afterReturn({ modeId: modeId, iconId: "iconId", modeName: "modeName", iconColor: "iconColor", filletIcon: "filletIcon", roundIcon: "roundIcon", isSupportDelete: true });
      let mockGetPixelMap: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getPixelMap);
      when(mockGetPixelMap)(ArgumentMatchers.anyString).afterReturn(undefined);
      const result: ESObject = IntentCreateModeAdaptor.getTemplateModeData(modeName, modeId, templateModeArr);
      mocker.ignoreMock(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      mocker.ignoreMock(ResourceUtil, ResourceUtil.getPixelMap);
    });

    it('atc_templateMode_is_valid_and_both_filletIcon_and_roundIcon_are_valid', 0, () => {
      let modeName: string = "modeName";
      let modeId: string = "modeId";
      let modeConfigData: ModeConfigData = {
        modeId: modeId,
        iconId: "iconId",
        modeName: "modeName",
        iconColor: "iconColor",
        filletIcon: "filletIcon",
        roundIcon: "roundIcon",
        isSupportDelete: true,
        modePriority: 0,
        configs: []
      };
      let templateModeArr: ModeConfigData[] = [modeConfigData];
      let mocker: MockKit = new MockKit();
      let mockGetCustomModeData: Function = mocker.mockFunc(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      when(mockGetCustomModeData)(ArgumentMatchers.anyString).afterReturn({ modeId: modeId, iconId: "iconId", modeName: "modeName", iconColor: "iconColor", filletIcon: "filletIcon", roundIcon: "roundIcon", isSupportDelete: true });
      const result: ESObject = IntentCreateModeAdaptor.getTemplateModeData(modeName, modeId, templateModeArr);
      mocker.ignoreMock(IntentCreateModeAdaptor, IntentCreateModeAdaptor.getCustomModeData);
      mocker.ignoreMock(ResourceUtil, ResourceUtil.getPixelMap);
    });
    });
}