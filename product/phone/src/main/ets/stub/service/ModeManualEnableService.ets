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

import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { Response } from '@ohos/scene.common/src/main/ets/constant/Response';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { CallMessage, IService } from '@ohos/scene.common/src/main/ets/stub/BaseServiceStub';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import {
  FaultScene,
  FaultSubScene,
} from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { EffectiveSourceType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { OpenType } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';
import { ModeManualEnableParam } from '@ohos/scene.modeconfig/src/main/ets/model/SysDialogModel';
import { ModeDataViewUtils } from '@ohos/scene.configmanage/src/main/ets/utils/ModeDataViewUtils';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { ModeManualEnableUtil } from '../../pages/controlcenter/utils/ModeManualEnableUtil';

/* instrument ignore file */
const METHOD: string = 'modeManualEnable';

const TAG: string = 'ModeManualEnableService:';

export class ModeManualEnableService implements IService {
  async onCall(json: string): Promise<string> {
    let message: CallMessage;
    try {
      message = JSON.parse(json) as CallMessage;
    } catch (err) {
      LogUtil.showError(TAG, 'parse input message invalid');
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.CONTROL_START_FAIL, FaultSubScene.PARAMS_ERROR, '', '', json);
      return Response.UNKNOWN_METHOD;
    }
    const method: string = message?.method;
    LogUtil.showWarn(TAG, `onCall method = ${method}`);
    if (method !== METHOD) {
      LogUtil.showWarn(TAG, 'onCall invalid method');
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.CONTROL_START_FAIL, FaultSubScene.METHOD_ERROR, '', '', method);
      return Response.INVALID_METHOD;
    }
    const extraParam: ModeManualEnableParam = message?.extra as ModeManualEnableParam;
    LogUtil.showInfo(TAG,
      `onCall extraParam. modeId:${extraParam?.modeId} openType:${extraParam?.openType} isHideDialog:${extraParam?.isHideDialog}`);
    const modeId: string = extraParam?.modeId;
    const openType: OpenType = extraParam?.openType ?? OpenType.TURN_ON_NOW;
    const isHideDialog: boolean = extraParam?.isHideDialog ?? false;
    if (!modeId) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.CONTROL_START_FAIL, FaultSubScene.ID_NOTFOUND, '', '', modeId);
      return Response.FAULT_MODE_ID;
    }
    await RdbStoreHelper.getInstance().getRdbStore();
    await El1RdbStoreHelper.getInstance().getRdbStore();
    const modeOpenState: ModeState = ModeUtil.getModeOpenState();
    LogUtil.showInfo(TAG, `onCall queryEnabledModeId. enabledModeId:${modeOpenState.modeId}`);
    // 如果指定modeId为空 则关闭当前模式
    if (modeId === NO_SCENE) {
      this.closeMode(modeOpenState.modeId);
      return Response.SUCCESS;
    }
    // 与当前模式比较 相等为关闭 不等为开启
    if (modeId === modeOpenState.modeId) {
      this.closeMode(modeId);
    } else {
      this.enableMode(modeId, openType, isHideDialog);
    }
    return Response.SUCCESS;
  }

  /**
   * 关闭模式
   */
  private closeMode(modeId: string): void {
    StateManager.getInstance().stopScene(modeId, FactorType.USER);
    ModeDataViewUtils.hiViewWhenOpenOrClose(modeId, false, EffectiveSourceType.CONTROL_CENTER);
  }

  /**
   * 开启模式
   */
  private enableMode(modeId: string, openType: OpenType, isHideDialog: boolean): void {
    const isNeedDialog: boolean = !isHideDialog && !ModeManualEnableUtil.isNoMoreRemind();
    if (isNeedDialog) {
      ModeManualEnableUtil.openEnableSysDialog(modeId, openType);
    } else {
      ModeManualEnableUtil.manualStartScene(modeId, openType);
      ModeDataViewUtils.hiViewWhenOpenOrClose(modeId, true, EffectiveSourceType.CONTROL_CENTER);
    }
  }
}
