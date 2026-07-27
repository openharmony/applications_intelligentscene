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
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { HOME_MODAL_GROUP_ID } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ModalSheetKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { SingleButtonComponent } from '@ohos/scene.common/src/main/ets/basecomponent/button/SingleButtonComponent';
import {
  DialogButton,
  DialogLayoutStyle,
  SettingItemModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingDialogState,
  SettingModalState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import TriggerConditionManager from '@ohos/scene.configmanage/src/main/ets/manager/TriggerConditionManager';
import { HOME_PAGE_ID } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { NotDisturbUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/NotDisturbUtils';
import { TimeManager } from '../manager/TimeManager';

/* instrument ignore file */
const TAG: string = 'TimedSheetDeleteComponent:';

@Builder
export function timedSheetDeleteBuilder(item: object): void {
  TimedSheetDeleteComponent();
}

@Component
export struct TimedSheetDeleteComponent {
  build() {
    // 新增条件不展示删除；编辑已有条件时展示完整「删除此条件」按钮
    if (!TimeManager.getInstance().isAdd) {
      Column() {
        SingleButtonComponent({
          title: $r('app.string.condition_delete'),
          buttonStyle: ButtonStyleMode.NORMAL,
          buttonRole: ButtonRole.ERROR,
          action: () => {
            this.showDeleteDialog();
          },
        })
      }
      .width('100%')
      .padding({
        top: 24,
        bottom: 16,
      })
    }
  }

  private showDeleteDialog(): void {
    const timeInfo = TimeManager.getInstance().getInfo();
    // 与首页条件副标题一致：开始时间-结束时间（跨天含「次日」）
    const timeSummary: string =
      `${NotDisturbUtils.getSysFormatTime(timeInfo.timeStart)}-${NotDisturbUtils.getEndTimeSummary(
        timeInfo.timeStart, timeInfo.timeEnd)}`;
    const cancelButton: DialogButton = {
      value: $r('app.string.cancel'),
      action: (_component: SettingItemModel) => {
      },
    };
    const deleteButton: DialogButton = {
      value: $r('app.string.delete'),
      style: { role: ButtonRole.ERROR },
      action: (_component: SettingItemModel) => {
        void this.deleteCondition();
      },
    };
    const dialogButtons: DialogButton[] = [cancelButton, deleteButton];
    const dialogStyle: DialogLayoutStyle = {
      autoCancel: true,
    };
    // 半模态内弹窗需覆盖主窗，否则会被 bindSheet 遮挡
    const dialogState: SettingDialogState = {
      message: ResourceUtil.getFormatStringSync($r('app.string.confirm_delete'), timeSummary),
      buttons: dialogButtons,
      style: dialogStyle,
      isShowInSubWindow: true,
    };
    notifyCompStateChange(`${HOME_PAGE_ID}.${HOME_MODAL_GROUP_ID}.${ModalSheetKey.TIMED_SHEET}`,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_DIALOG, dialogState],
      ]));
  }

  private async deleteCondition(): Promise<void> {
    const configId: string = TimeManager.getInstance().getInfo().configId;
    if (StringUtil.isEmpty(configId)) {
      LogUtil.showWarn(TAG, 'deleteCondition configId is empty');
      return;
    }
    const res: number = await TriggerConditionManager.deleteTriggerCondition(configId);
    LogUtil.showInfo(TAG, `deleteCondition res:${res}`);
    if (res >= 0) {
      await ModeDetailAdapter.getInstance().deleteConfigById(configId);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `refresh_${configId}`);
      this.closeSheet();
    }
  }

  private closeSheet(): void {
    notifyCompStateChange(`${HOME_PAGE_ID}.${HOME_MODAL_GROUP_ID}.${ModalSheetKey.TIMED_SHEET}`,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState],
      ]));
  }
}
