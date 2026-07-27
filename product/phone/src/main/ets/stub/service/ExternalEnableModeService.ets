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
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { Response } from '@ohos/scene.common/src/main/ets/constant/Response';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { CallMessage, IService } from '@ohos/scene.common/src/main/ets/stub/BaseServiceStub';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import {
  FaultScene,
  FaultSubScene,
  ActionType
} from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { EffectiveSourceType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { ModeDataViewUtils } from '@ohos/scene.configmanage/src/main/ets/utils/ModeDataViewUtils';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

const MODE_ENABLE_TO_OUTSIDE: string = 'externalEnableMode';
const TAG: string = 'ExternalEnableModeService';
const MIN_SOURCE_TYPE = 100;

/**
 * 参数对象
 */
export interface ExtraParams {
  modeId: string,
  actionType: ActionType,
  // 外部服务sourceType从100开始
  sourceType: EffectiveSourceType,
  operType?: FactorType,
  extraStr?: string,
}

/**
 * 对外提供模式开关Service
 */
export class ExternalEnableModeService implements IService {
  async onCall(json: string): Promise<string> {
    const message: CallMessage | undefined = JsonUtil.parse<CallMessage>(json);
    if (!message) {
      LogUtil.showError(TAG, 'message is invalid');
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.FACTOR_START_ERROR, FaultSubScene.INPUT_ERROR, json);
      return Response.UNKNOWN_METHOD;
    }
    const method: string = message.method;
    LogUtil.showInfo(TAG, `onCall method = ${method}`);
    if (this.isNeedIntercept()) {
      LogUtil.showWarn(TAG, 'ExternalEnableModeService return by intercept');
      return Response.SUCCESS;
    }
    if (method === MODE_ENABLE_TO_OUTSIDE) {
      await El1RdbStoreHelper.getInstance().getRdbStore();
      await RdbStoreHelper.getInstance().getRdbStore();
      return this.modeEnable(message);
    }
    LogUtil.showError(TAG, 'onCall method is invalid');
    return Response.INVALID_METHOD;
  }

  private isNeedIntercept(): boolean {
    const curModeId: string = ModeUtil.getModeOpenState().modeId;
    // 部分模式不支持开启时展示/切换其他模式,需拦截
    const isShowOther: boolean = ModeConfigAdapter.getInstance().getConfigByModeId(curModeId).isShowOtherMode ?? true;
    LogUtil.showInfo(TAG, `isNeedIntercept, open mode: ${curModeId}, isShowOtherMode: ${isShowOther}`);
    return !isShowOther;
  }

  private modeEnable(message: CallMessage): string {
    if (CheckEmptyUtils.isEmpty(message.extra)) {
      LogUtil.showError(TAG, 'message extra is invalid');
      return Response.FAULT_PARAM;
    }
    const extraParam: ExtraParams = message.extra as ExtraParams;
    const modeId: string = extraParam.modeId;
    if (typeof extraParam.sourceType !== 'number' || extraParam.sourceType < MIN_SOURCE_TYPE) {
      LogUtil.showError(TAG, `sourceType: ${extraParam.sourceType} is invalid`);
      return Response.FAULT_PARAM;
    }
    if (!modeId) {
      LogUtil.showError(TAG, 'modeId is invalid');
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
        FaultScene.FACTOR_START_ERROR, FaultSubScene.ID_NOTFOUND, '', '', modeId);
      return Response.FAULT_MODE_ID;
    }
    LogUtil.showInfo(TAG, `onCall extraParam,modeId: ${modeId},actionType: ${extraParam.actionType},sourceType: ${extraParam.sourceType},operType: ${extraParam.operType}`);
    const operType: FactorType = extraParam.operType ?? FactorType.USER;
    const isEnable: boolean = extraParam.actionType === ActionType.SWITCH_ON;
    if (isEnable) {
      StateManager.getInstance().startScene(modeId, operType, extraParam.sourceType);
    } else {
      StateManager.getInstance().stopScene(modeId, operType, extraParam.sourceType);
    }
    ModeDataViewUtils.hiViewWhenOpenOrClose(modeId, isEnable, extraParam.sourceType);
    return Response.SUCCESS;
  }
}