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

import Want from '@ohos.app.ability.Want';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';
import { FontScaleUtils } from '@ohos/scene.common/src/main/ets/utils/FontScaleUtils';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { SysDialogParam } from '@ohos/scene.modeconfig/src/main/ets/model/SysDialogModel';
import { OpenType } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';

/* instrument ignore file */
const TAG: string = 'ModeEnableConfirmDialogUIExtAbility:';

const storage: LocalStorage = new LocalStorage();

/**
 * 情景模式系统弹框入口Ability
 */
export default class ModeEnableConfirmDialogUIExtAbility extends UIExtensionAbility {

  onCreate(): void {
    LogUtil.showInfo(TAG, 'onCreate');
    AbilityContextManager.addContext(this.context);
    if (!this.context.config.fontSizeScale) {
      FontScaleUtils.setConfig(FontScaleUtils.DEFAULT_FONT_SCALE);
    } else {
      FontScaleUtils.setConfig(this.context.config.fontSizeScale);
    }
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.showInfo(TAG, 'onSessionCreate');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device');
      return;
    }
    let contentSession: UIExtensionContentSession | undefined =
      storage?.get<UIExtensionContentSession>('UIExtensionContentSession');
    // 连续拉起2次UIExtensionAbility场景会创建2个窗口，此时需要移除前一个窗口，避免冻屏
    if (contentSession) {
      LogUtil.showWarn(TAG, 'terminate previous session.');
      contentSession.terminateSelf();
    }
    // 接收业务参数
    const extra = want?.parameters?.extra as SysDialogParam;
    if (extra) {
      LogUtil.showInfo(TAG,
        `onSessionCreate. modeId:${extra.modeId} openType:${extra.openType} restoreBundleNames:${extra.restoreBundleNames}`);
      storage.setOrCreate<string>('operationModeId', extra.modeId);
      storage.setOrCreate<OpenType>('operationType', extra.openType);
      storage.setOrCreate<string[]>('restoreBundleNames', extra.restoreBundleNames);
    }
    // 存session
    storage.setOrCreate<UIExtensionContentSession>('UIExtensionContentSession', session);
    // 跳转页面
    try {
      session.loadContent('pages/controlcenter/CommonSysDialogEntry', storage);
      session.setWindowBackgroundColor('#00FFFFFF');
    } catch (err) {
      LogUtil.showError(TAG, `session.loadContent catch err. code:${err?.code} message:${err?.message}`);
    }
  }

  onSessionDestroy(): void {
    LogUtil.showInfo(TAG, 'onSessionDestroy');
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    AbilityContextManager.removeContext(this.context);
  }
}