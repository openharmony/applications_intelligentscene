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
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { HomeSheetCompId } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { SceneBaseDataManager } from '@ohos/scene.configmanage/src/main/ets/manager/SceneBaseDataManager';
import { AppCategoryNotificationManager } from '../../nodisturb/manager/AppCategoryNotificationManager';

/* instrument ignore file */
const TAG: string = 'ModeSheetBusinessUtil:';

/**
 * 新增/修改模式业务类
 */
export class ModeSheetBusinessUtil {
  /**
   * 关闭模态框
   */
  public static closeSheet(compId: string): void {
    notifyCompStateChange(compId,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState]
      ])
    );
  }

  /**
   * 新增模式
   */
  public static async addData(data: ModeData): Promise<void> {
    const modeId: string = await SceneBaseDataManager.createCustomScene(data);
    LogUtil.showInfo(TAG, `addData. modeId:${modeId}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysIntelligentSceneEvent.CREATING_PROFILE,
      ModeUtil.isCustomMode(modeId) ? '-1' : modeId);
    if (modeId !== INVALID_MODE_ID) {
      ModeAdapter.getInstance().updateModeCacheById(modeId);
      AppCategoryNotificationManager.getInstance().initModeAppNotificationConfigData(modeId);
      ModeSheetBusinessUtil.closeSheet(HomeSheetCompId.ADD_SHEET_COMP_ID);
    }
  }

  /**
   * 更新模式
   */
  public static async updateData(data: ModeData): Promise<void> {
    const modeId: string = await SceneBaseDataManager.updateCustomScene(data);
    LogUtil.showInfo(TAG, `updateData. modeId:${modeId}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysIntelligentSceneEvent.CHANGE_MODE_NAME);
    if (modeId !== INVALID_MODE_ID) {
      ModeAdapter.getInstance().updateModeCacheById(modeId);
      ModeSheetBusinessUtil.closeSheet(HomeSheetCompId.EDIT_SHEET_COMP_ID);
    }
  }
}