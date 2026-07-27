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
  when
} from '@ohos/hypium';
import LiveViewManager from '@ohos/scene.configlinkage/src/main/ets/manager/LiveViewManager';
import {
  NotificationData,
  RequestMethod,
  REQUEST_CODE,
  SCB_IS_WANT
} from '@ohos/scene.configlinkage/src/main/ets/constant/LinkageConstants';
import { TimeUtil } from '@ohos/scene.common/src/main/ets/utils/TimeUtil';
import { ModeDataManager } from '@ohos/scene.datamanage';
import { RemoteService } from '@ohos/scene.configlinkage/src/main/ets/proxy/RemoteService';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import IServiceProxy from '@ohos/scene.configlinkage/src/main/ets/proxy/IServiceProxy';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { DebounceUtil } from '@ohos/scene.common/src/main/ets/utils/DebounceUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { Context } from '@kit.AbilityKit';

const COMMON_DELAY: number = 2000;
let mocker: MockKit = new MockKit();
let mockFunc: Function = mocker.mockFunc(LiveViewManager, LiveViewManager.sendLiveView);
let queryModeDataByIdFunc: Function = mocker.mockFunc(ModeDataManager, ModeDataManager.getInstance().queryModeDataById);
let learnPlanFunc: Function = mocker.mockFunc(LearningPlanManager, LearningPlanManager.getInstance().getAllLearningPlans);

export default function LiveViewManagerTest() {
  describe('LiveViewManagerTest', () => {
    beforeEach(() => {
      when(mockFunc)().afterReturn(1);
    });

    afterEach(() => {
      mocker.ignoreMock(LiveViewManager, LiveViewManager.sendLiveView);
      mocker.ignoreMock(LearningPlanManager, LearningPlanManager.getInstance().getAllLearningPlans);
    });

    it('send_live_view_test_no_plan', 0, async (done: Function) => {
      const modeId: string = '1';
      LiveViewManager.sendLiveView(modeId)
      expect(!StringUtil.isEmpty(modeId)).assertTrue();
      await DebounceUtil.sleep(COMMON_DELAY);
      done();
    });

    it('send_live_view_test_with_plan', 0, async (done: Function) => {
      const modeId: string = '3';
      when(learnPlanFunc)().afterReturn(1);
      LiveViewManager.sendLiveView(modeId)
      expect(!StringUtil.isEmpty(modeId)).assertTrue();
      LiveViewManager.sendLiveView('-1')
      await DebounceUtil.sleep(COMMON_DELAY);
      done();
    });

    it('cancel_live_view_test', 0, async (done: Function) => {
      const modeId: string = '3';
      LiveViewManager.cancelLiveView('3')
      expect(!StringUtil.isEmpty(modeId)).assertTrue();
      await DebounceUtil.sleep(COMMON_DELAY);
      await LearningPlanManager.getInstance().addLearningPlan({
        planName: '测试学习计划通知',
        status: 0,
      });
      LiveViewManager.fillLearningNtfData({
        'title': '学习模式',
        'text': '已关闭',
        'capsuleTitle': '学习模式',
        'capsuleContent': '已关闭',
        'modeId': '3',
        'startTime': 756430,
        'preStartTime': 0,
        'duration': 0,
        'type': ''
      });
      LiveViewManager.sendLiveView('3');
      await DebounceUtil.sleep(COMMON_DELAY);
      SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, '');
      LiveViewManager.sendLiveView('3');
      await DebounceUtil.sleep(COMMON_DELAY);
      LiveViewManager.cancelLiveView('-3')
      done();
    });

    it('cancel_live_view_test_fail', 0, async (done: Function) => {
      const modeId: string = '1';
      when(queryModeDataByIdFunc)().afterReturn(undefined);
      LiveViewManager.cancelLiveView('3')
      expect(!StringUtil.isEmpty(modeId)).assertTrue();
      await DebounceUtil.sleep(COMMON_DELAY);
      done();
    });

    it('update_live_view_test', 0, async (done: Function) => {
      const ntfData: NotificationData = {
        title: '学习模式',
        text: '00:00',
        capsuleTitle: '学习模式',
        capsuleContent: '已开启',
        modeId: '3',
        startTime: TimeUtil.getDeviceBootTime(),
        preStartTime: 0,
        duration: 0,
        type: ''
      };
      LiveViewManager.updateLiveView(ntfData);
      await DebounceUtil.sleep(COMMON_DELAY);
      expect(ntfData.duration).assertEqual(0);
      done();
    });

    it('update_live_view_test_same_mode', 0, async (done: Function) => {
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '3');
      const ntfData: NotificationData = {
        title: '学习模式',
        text: '00:00',
        capsuleTitle: '学习模式',
        capsuleContent: '已开启',
        modeId: '3',
        startTime: TimeUtil.getDeviceBootTime(),
        preStartTime: 0,
        duration: 0,
        type: ''
      };
      LiveViewManager.updateLiveView(ntfData);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '0');
      expect(ntfData.duration).assertEqual(0);
      done();
    });

    it('remote_service_connect', 0, () => {
      let serviceInstance: RemoteService = new RemoteService(AbilityContextManager.getContext() as Context);
      const ntfData: NotificationData = {
        title: '学习模式',
        text: '00:00',
        capsuleTitle: '学习模式',
        capsuleContent: '已开启',
        modeId: '3',
        startTime: TimeUtil.getDeviceBootTime(),
        preStartTime: 0,
        duration: 0,
        type: ''
      };
      serviceInstance?.getProxy(SCB_IS_WANT).then((proxy: IServiceProxy) => {
        proxy.getICallback(REQUEST_CODE, RequestMethod.UPDATE_NOTIFICATION, JSON.stringify(ntfData), () => {});
      }).catch((e: Error) => {
        serviceInstance?.disConnect();
      });
      serviceInstance?.disConnect();
      expect(ntfData.duration).assertEqual(0);
    });

    it('remote_service_connect_fail', 0, () => {
      let serviceInstance: RemoteService = new RemoteService(AbilityContextManager.getContext() as Context);
      const ntfData: NotificationData = {
        title: '学习模式',
        text: '00:00',
        capsuleTitle: '学习模式',
        capsuleContent: '已开启',
        modeId: '3',
        startTime: TimeUtil.getDeviceBootTime(),
        preStartTime: 0,
        duration: 0,
        type: ''
      };
      const SCB_IS_WANT: Want = {
        bundleName: 'com.ohos.sceneboard',
        abilityName: 'IntelligentSceneServiceNoExist'
      };
      serviceInstance.getProxy(SCB_IS_WANT).then((proxy: IServiceProxy) => {
        proxy.getICallback(REQUEST_CODE, RequestMethod.UPDATE_NOTIFICATION, JSON.stringify(ntfData), () => {});
      }).catch((e: Error) => {
        serviceInstance.disConnect();
      });
      expect(ntfData.duration).assertEqual(0);
    });

    it('remote_service_connect_reject', 0, () => {
      AbilityContextManager.setStageContext(undefined);
      let serviceInstance: RemoteService = new RemoteService(AbilityContextManager.getStageContext() as Context);
      const SCB_IS_WANT: Want = {
        bundleName: 'com.ohos.sceneboard',
        abilityName: 'IntelligentSceneServiceNoExist'
      };
      serviceInstance.disConnect();
      expect(serviceInstance.getProxy(SCB_IS_WANT)).assertPromiseIsRejected();
    });

    it('notifyLiveViewRefresh', 0, () => {
      LiveViewManager.notifyLiveViewRefresh();
      let ntfState: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_STATE, '0');
      expect(ntfState).assertEqual('1');
    });
  });
}
