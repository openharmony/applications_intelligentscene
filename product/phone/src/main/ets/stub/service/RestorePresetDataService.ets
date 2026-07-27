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

import { ActivationManager } from '@ohos/scene.activationmanage/src/main/ets/manager/ActivationManager';
import { MODE_GUIDE_KEYS } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { Response } from '@ohos/scene.common/src/main/ets/constant/Response';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { CallMessage, IService } from '@ohos/scene.common/src/main/ets/stub/BaseServiceStub';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { SubscriberConstant } from '@ohos/scene.common/src/main/ets/constant/SubscriberConstant';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import {
  INVALID_VALUE,
  ACCOUNT_EXIT_CLEAR_TABLES_EL2,
  ACCOUNT_EXIT_CLEAR_TABLES_EL1,
} from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { StaticSubscriberUtil } from '@ohos/scene.common/src/main/ets/utils/StaticSubscriberUtil';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { PreferencesUtil } from '@ohos/scene.common/src/main/ets/utils/PreferencesUtil';

/* instrument ignore file */
const METHOD: string = 'restorePresetData';

const TAG: string = 'RestorePresetDataService:';

export class RestorePresetDataService implements IService {
  private syncTimerId: number = 0;

  async onCall(json: string): Promise<string> {
    if (CheckEmptyUtils.isEmpty(json)) {
      LogUtil.showError(TAG, 'json is empty');
      return Response.INVALID_METHOD;
    }
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

    await this.restorePresetData();
    return Response.SUCCESS;
  }

  private async restorePresetData(): Promise<void> {
    const enabledMode: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, NO_SCENE);
    if (enabledMode !== NO_SCENE) {
      StaticSubscriberUtil.publishEvent(SubscriberConstant.ACTION_STOP_SCENE);
      LogUtil.showInfo(TAG, `publish event to stopScene ${enabledMode} before reset preset data`);
    }
    if (this.syncTimerId > 0) {
      return;
    }
    StaticSubscriberUtil.publishEvent(SubscriberConstant.ACTION_RESET_ANS_DATA);
    this.syncTimerId = setTimeout(async () => {
      let deleteResult: number = INVALID_VALUE;
      await this.clearModeGuideKey();
      for (const tableName of ACCOUNT_EXIT_CLEAR_TABLES_EL2) {
        deleteResult = await RdbStoreHelper.getInstance().deleteTableData(tableName);
        LogUtil.showInfo(TAG, `delete EL2 ${StringUtil.getAnonymizedTableName(tableName)} res: ${deleteResult}`);
      }
      for (const tableName of ACCOUNT_EXIT_CLEAR_TABLES_EL1) {
        deleteResult = await El1RdbStoreHelper.getInstance().deleteTableData(tableName);
        LogUtil.showInfo(TAG, `delete EL1 ${StringUtil.getAnonymizedTableName(tableName)} res: ${deleteResult}`);
      }
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, NO_SCENE);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, NO_SCENE);
      StaticSubscriberUtil.publishEvent(SubscriberConstant.ACTION_UPDATE_RULE_SET);
      LogUtil.showInfo(TAG, 'delete tables success');
      StaticSubscriberUtil.publishEvent(SubscriberConstant.RESTORE_PRESET_DATA);
      this.syncTimerId = 0;
    }, 5000);
  }

  private async clearModeGuideKey(): Promise<void> {
    for (let keys of MODE_GUIDE_KEYS) {
      await PreferencesUtil.delete(keys);
    }
  }
}
