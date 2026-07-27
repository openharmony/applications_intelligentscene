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

import common from '@ohos.app.ability.common';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AbilityUtils } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { ConfirmDialogComponent } from '@ohos/scene.common/src/main/ets/basecomponent/dialog/ConfirmDialogComponent';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { OpenType, DIALOG_EXIT_ANIMATION_TIME } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';
import { ModeManualEnableParam } from '@ohos/scene.modeconfig/src/main/ets/model/SysDialogModel';
import { ModeManualEnableUtil } from '../utils/ModeManualEnableUtil';

/* instrument ignore file */
const storage = LocalStorage.getShared();

const TAG: string = 'ModeEnableConfirmDialog:';

/**
 * 控制中心开启模式二次确认弹框
 */
@Component
export struct ModeEnableConfirmDialog {
  private session?: UIExtensionContentSession = storage?.get<UIExtensionContentSession>('UIExtensionContentSession');
  private operationModeId?: string = storage?.get<string>('operationModeId');
  private operationType?: OpenType = storage?.get<OpenType>('operationType');
  content: Resource = $r('app.string.mode_enable_dialog_hint');
  onCheckboxChange: (isChecked: boolean) => void = (isChecked: boolean) => {
    LogUtil.showInfo(TAG, `onCheckboxChange. isChecked:${isChecked}`);
    ModeManualEnableUtil.setNoMoreRemindFlag(isChecked);
  }
  // 模式开启确认弹框
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialogComponent({
      title: $r('app.string.intelligent_scene'),
      content: this.content,
      checkboxText: $r('app.string.no_more_reminder'),
      onCheckboxChange: (isChecked: boolean) => {
        this.onCheckboxChange(isChecked);
      },
      cancelText: $r('app.string.cancel'),
      onCancel: () => {
        this.onCancel();
      },
      confirmText: $r('app.string.dialog_open'),
      onConfirm: () => {
        this.onConfirm();
      },
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    maskColor: $r('sys.color.mask_fourth'),
  });

  build() {
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
    this.dialogController?.open();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }

  /**
   * 弹框取消
   */
  private onCancel(): void {
    LogUtil.showInfo(TAG, 'onCancel.');
    this.dialogController?.close();
    this.closeSysDialog();
  }

  /**
   * 弹框开启
   */
  private onConfirm(): void {
    const context: Context | undefined = AbilityContextManager.getContext();
    if (!context) {
      LogUtil.showError(TAG, 'onConfirm. context is null');
      return;
    }
    const enabledModeId: string = ModeUtil.getModeOpenState().modeId;
    LogUtil.showInfo(TAG,
      `onConfirm. operationModeId:${this.operationModeId} operationType:${this.operationType} enabledModeId:${enabledModeId}`);
    // 再拉回原先的Service 不走弹框逻辑即可 (只有拉Service才能保证模式开启业务执行完)
    AbilityUtils.connectManualEnableService(context as common.UIExtensionContext, {
      modeId: this.operationModeId,
      openType: this.operationType,
      isHideDialog: true,
    } as ModeManualEnableParam);
    this.dialogController?.close();
    this.closeSysDialog();
  }

  /**
   * 关闭系统弹框进程
   */
  private closeSysDialog(): void {
    // 1.延时关闭弹框Ability 避免拉不起来service
    // 2.留给弹框退场动画时间
    setTimeout(() => {
      if (this.session) {
        LogUtil.showInfo(TAG, 'closeSysDialog.');
        this.session.terminateSelf();
      }
    }, DIALOG_EXIT_ANIMATION_TIME);
  }
}

