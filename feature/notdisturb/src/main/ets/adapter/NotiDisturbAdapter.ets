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

import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ItemResultType } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { FOCUS_MODE_CALL_MESSAGE_POLICY } from '../utils/NotDisturbUtils';

const TAG: string = 'NotDisturbAdapter';

export class NotDisturbAdapter {
  private static instance: NotDisturbAdapter;

  public static getInstance(): NotDisturbAdapter {
    if (NotDisturbAdapter.instance == null) {
      NotDisturbAdapter.instance = new NotDisturbAdapter();
    }
    return NotDisturbAdapter.instance;
  }

  public updateRepeatRingState(modeId: string, isChecked: boolean) {
    AllowDisturbManager.getInstance().updateRepeatCallRing(modeId, isChecked).then((configId) => {
      ModeDetailAdapter.getInstance().updateParsedConfigById(configId);
    });
    LogUtil.showInfo(TAG, `setChecked modeId: ${modeId}, setChecked, refresh: ${isChecked}`);
  }

  public async modifyAllowCallPolicyBy(modeId: string, callAllowPolicy: string): Promise<void> {
    let configId = await AllowDisturbManager.getInstance().updateContactPolicy(modeId, callAllowPolicy);
    if (!CheckEmptyUtils.checkStrIsEmpty(configId)) {
      LogUtil.showInfo(TAG, `modify mode allow call policy configId: ${configId}, callAllowPolicy: ${callAllowPolicy}`);
      ModeDetailAdapter.getInstance().updateParsedConfigById(configId);
      // 如果开关是开的，同步存到数据库中
      const modeOpenState: ModeState = ModeUtil.getModeOpenState();
      LogUtil.showInfo(TAG, `modify mode allow call policy openedMode: ${modeOpenState.modeId}, mode: ${modeId}`);
      if (ModeUtil.isCurrentModeOpened(modeId, modeOpenState)) {
        SettingsDataUtils.setSystemValue(FOCUS_MODE_CALL_MESSAGE_POLICY, callAllowPolicy);
      }
    }
  }
}