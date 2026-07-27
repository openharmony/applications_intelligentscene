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

import commonEventManager from '@ohos.commonEventManager';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/scene.common/src/main/ets/commonevent/CommonEventHelper';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { OpenType } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';
import { ModeEnableConfirmDialog } from './view/ModeEnableConfirmDialog';

/* instrument ignore file */
const storage = LocalStorage.getShared();

const TAG: string = 'CommonSysDialogEntry:';

/**
 * 情景模式系统弹框组件入口
 */
@Entry
@Component
struct CommonSysDialogEntry {
  private session?: UIExtensionContentSession = storage?.get<UIExtensionContentSession>('UIExtensionContentSession');
  private operationModeId?: string = storage?.get<string>('operationModeId');
  private operationType?: OpenType = storage?.get<OpenType>('operationType');
  /**
   * 锁屏事件
   */
  private onLockScreenEventHelper: CommonEventHelper = new CommonEventHelper({
    events: [commonEventManager.Support.COMMON_EVENT_SCREEN_LOCKED],
  }, (err, data) => {
    if (err?.code) {
      LogUtil.showWarn(TAG, `onLockScreenEventHelper failed. code:${err?.code} message:${err?.message}`);
    } else {
      LogUtil.showInfo(TAG, 'onLockScreenEventHelper change.');
      this.closeSysDialog();
    }
  });

  build() {
    Column() {
      ModeEnableConfirmDialog()
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear. operationModeId:${this.operationModeId} operationType:${this.operationType}`);
    this.onLockScreenEventHelper.registerCommonEvent();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
    this.onLockScreenEventHelper.unRegisterCommonEvent();
  }

  /**
   * 关闭系统弹框进程
   */
  private closeSysDialog(): void {
    if (this.session) {
      LogUtil.showInfo(TAG, 'closeSysDialog.');
      this.session.terminateSelf();
    } else {
      LogUtil.showError(TAG, 'closeSysDialog failed, session is empty');
    }
  }
}

