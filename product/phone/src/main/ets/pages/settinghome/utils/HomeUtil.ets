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
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import {
  notifyCompStateChange,
  SettingDialogState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { SettingItemModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { SceneBaseDataManager } from '@ohos/scene.configmanage/src/main/ets/manager/SceneBaseDataManager';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { ActivationManager } from '@ohos/scene.activationmanage/src/main/ets/manager/ActivationManager';

/* instrument ignore file */
const MAX_CONDITION_COUNT: number = 15;
const SHOW_CONDITION_COUNT: number = 2;

const TAG: string = 'HomeUtil:';

/**
 * 首页工具类
 */
export class HomeUtil {
  /**
   * 根据条件个数获取 条件开启group 底部文字
   */
  public static getTriggerConditionFooter(len: number): Resource {
    if (len < SHOW_CONDITION_COUNT) {
      return $r('app.string.condition_footer_tip');
    }
    if (len >= MAX_CONDITION_COUNT) {
      return $r('app.string.condition_count_limit');
    }
    return $r('app.string.condition_count_initiate_new');
  }

  /**
   * 通过modeId 打开删除模式确认框(这里会自动处理弹框显示字串逻辑)
   */
  public static openDeleteModeDialog(modeId: string): void {
    const modeNameStr = ModeAdapter.getInstance().getModeNameById(modeId);
    LogUtil.showInfo(TAG, `deleteMode. modeId:${modeId}`);
    // 借助架构弹框能力
    notifyCompStateChange(`home_standard_page.modal_group.edit_mode_sheet`, new Map([
      [SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        message: ResourceUtil.getFormatStringSync($r('app.string.delete_mode_message'), modeNameStr),
        buttons: [
          {
            value: $r('app.string.cancel'),
            action: async (component: SettingItemModel) => {
              LogUtil.showInfo(TAG, 'onClick cancel');
            },
          },
          {
            value: $r(`app.string.delete`),
            style: {
              role: ButtonRole.ERROR,
            },
            action: (component: SettingItemModel) => {
              const enabledModeId =
                SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, NO_SCENE);
              LogUtil.showInfo(TAG, `onClick delete. modeId:${modeId} enabledModeId:${enabledModeId}`);
              if (enabledModeId === modeId) {
                // 如果模式已开启 需要先关闭模式 再延时删除
                LogUtil.showInfo(TAG, `onClick delete. stopScene`);
                StateManager.getInstance().stopScene(modeId, FactorType.USER);
                // 延时删除
                setTimeout(async () => {
                  HomeUtil.deleteModeById(modeId);
                }, 200)
              } else {
                // 直接删除
                HomeUtil.deleteModeById(modeId);
              }
            },
          },
        ],
        isShowInSubWindow: true,
        style: {
          autoCancel: true,
          contentStyle: {
            fontWeight: FontWeight.Medium
          }
        },
      } as SettingDialogState]
    ]));
  }

  /**
   * 通过 modeId 删除模式同时更新 ModeAdapter 状态缓存
   */
  private static async deleteModeById(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `deleteModeById. modeId:${modeId}`);
    const configNum = await SceneBaseDataManager.deleteSceneData(modeId);
    LogUtil.showInfo(TAG, `deleteModeById. configNum:${configNum}`);
    if (configNum !== INVALID_VALUE) {
      ModeAdapter.getInstance().deleteModeCacheById(modeId);
    }
    // 删除数据库中联系人黑白名单数据
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysIntelligentSceneEvent.DELETE_MODE,
      ModeUtil.isCustomMode(modeId) ? '-1' : modeId)
    EventBus.getInstance().emit(EventBusNameConstant.DIALOG_DELETE_MODE, modeId);
    // 页面上滑到最顶部
    EventBus.getInstance().emit(EventBusNameConstant.HOME_SCROLL_TO, Edge.Top);
    EventBus.getInstance().emit(EventBusNameConstant.HOME_TITLE_CHANGE, $r('app.string.intelligent_scene'));
  }
}