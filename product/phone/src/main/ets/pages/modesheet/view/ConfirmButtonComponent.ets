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
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { PromptManager } from '@ohos/scene.common/src/main/ets/basecomponent/prompt/PromptManager';
import { SingleButtonComponent } from '@ohos/scene.common/src/main/ets/basecomponent/button/SingleButtonComponent';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { OperateType } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';
import { EditModeAdapter } from '../adapter/EditModeAdapter';

/* instrument ignore file */

const TAG: string = 'ConfirmButtonComponent:';

/**
 * 添加/编辑模式图标底部按钮业务组件
 */
@Component
export struct ConfirmButtonComponent {
  private type: OperateType = EditModeAdapter.getInstance().getOperateType();
  @State isEnabled: boolean = true;

  /**
   * 按钮可用事件回调
   */
  private onButtonEnabledCallback = (enabled: boolean): void => {
    LogUtil.showInfo(TAG, `onButtonEnabledCallback. enabled:${enabled} isEnabled:${this.isEnabled}`);
    if (this.isEnabled !== enabled) {
      this.isEnabled = enabled;
    }
  };

  build() {
    SingleButtonComponent({
      isEnabled: this.isEnabled,
      title: this.type === OperateType.ADD ? $r('app.string.increase') : $r('app.string.done'),
      buttonStyle: ButtonStyleMode.EMPHASIZED,
      action: () => {
        this.onConfirm();
      },
    })
  }

  aboutToAppear(): void {
    const data: ModeData = EditModeAdapter.getInstance().getEditModeData();
    LogUtil.showInfo(TAG, `aboutToAppear. data:${data.modeId}`);
    // 新增自定义模式 按钮置灰
    if (this.type === OperateType.ADD && ModeUtil.isCustomMode(data.modeId)) {
      this.isEnabled = false
    }
    EventBus.getInstance().on(EventBusNameConstant.EDIT_MODE_BUTTON_ENABLED, this.onButtonEnabledCallback);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
    EventBus.getInstance().detach(EventBusNameConstant.EDIT_MODE_BUTTON_ENABLED, this.onButtonEnabledCallback);
  }

  private onConfirm(): void {
    LogUtil.showInfo(TAG, `onConfirm. type:${this.type}`);
    this.isEnabled = false;
    const data: ModeData = EditModeAdapter.getInstance().getEditModeData();
    const enabledModeId: string = ModeUtil.getModeOpenState().modeId;
    LogUtil.showInfo(TAG, `onConfirmCallback. enabledModeId:${enabledModeId}, editModeId:${data.modeId}`);
    // 修改模式时如果发现模式被开启了 则不可提交 点击禁用掉按钮 并弹toast
    if (this.type === OperateType.EDIT && enabledModeId === data.modeId) {
      PromptManager.getInstance().showToast($r('app.string.edit_enable_mode_hint'));
    } else {
      EventBus.getInstance().emit(EventBusNameConstant.MODE_DATA_SAVE_EVENT, this.type);
    }
  }
}