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
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { ModeUtil, ModeState } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

const TAG: string = 'ActionManager:';

export class ActionManager {
  private static singleInstance: ActionManager;

  public static getInstance(): ActionManager {
    if (!ActionManager.singleInstance) {
      ActionManager.singleInstance = new ActionManager();
    }
    return ActionManager.singleInstance;
  }

  public startScene(params?: Record<string, Object>): void {
    if (!params || !params['modeId'] || params['openType'] === undefined) {
      LogUtil.showError(TAG, `start scene fail, mode: ${params?.['modeId']}, type: ${params?.['openType']}`);
      return;
    }
    const enableModeId: string = params['modeId'] as string;
    const openType: number = params['openType'] as number;
    const sourceType: number | undefined = params['sourceType'] as number;
    StateManager.getInstance().startScene(enableModeId, openType, sourceType);
  }

  public dealStopSceneAction(params?: Record<string, Object>): void {
    let actionId: string = params?.actionId ? params?.actionId as string : '';
    if (!actionId) {
      LogUtil.showWarn(TAG, 'dealStopSceneAction failed, actionId is invalid');
      return;
    }

    const sourceType: number | undefined = params ? params['sourceType'] as number : undefined;
    const modeState: ModeState = ModeUtil.getModeOpenState();
    LogUtil.showInfo(TAG, `stopScene enabledMode: ${modeState.modeId} sourceType: ${sourceType}`);
    if (modeState.isOpened) {
      StateManager.getInstance().stopScene(modeState.modeId, FactorType.USER, sourceType);
    }
  }
}

