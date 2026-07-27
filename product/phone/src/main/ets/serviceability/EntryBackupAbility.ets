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

import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ConfigConstant } from '@ohos/scene.common/src/main/ets/constant/ConfigConstant';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import {
  ERROR_RESULT,
  RESTORE_SUCCESS,
  SUCCESS_RESULT
} from '@ohos/scene.backup/src/main/ets/constant/BackupRestoreConstant';
import { BackupRestoreManager } from '@ohos/scene.backup/src/main/ets/manager/BackupRestoreManager';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';

/* instrument ignore file */
const TAG: string = 'EntryBackupAbility: ';
// 克隆恢复场景对应的值
const RESTORE: number = 2;

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackupEx(backupInfo: string): Promise<string> {
    LogUtil.showInfo(TAG, `onBackupEx ${backupInfo}`);
    let intelligenceSceneEnabled: string = SystemParamUtil.getParam(ConfigConstant.CONST_INTELLIGENT_SCENE_ENABLE, '');
    LogUtil.showInfo(TAG, `onBackupEx intelligenceSceneEnabled: ${intelligenceSceneEnabled}`);
    if (intelligenceSceneEnabled !== 'true') {
      return JsonUtil.stringify(SUCCESS_RESULT);
    }
    BackupRestoreManager.getInstance().clearBackupFile();
    BackupRestoreManager.getInstance().transferDbFile();
    BackupRestoreManager.getInstance().transferPreferences();
    return JsonUtil.stringify(SUCCESS_RESULT);
  }

  async onRestoreEx(bundleVersion: BundleVersion, restoreInfo: string): Promise<string> {
    LogUtil.showInfo(TAG, `onRestoreEx bundleName: ${bundleVersion.name},code: ${bundleVersion.code}, ${restoreInfo}`);
    AbilityContextManager.addContext(this.context);

    // 销毁相关实例资源
    SettingLinkageManager.getInstance().deInit();
    StateManager.getInstance().deInit();

    // 初始化实例
    StateManager.getInstance().init();
    const currentScene: string = StateManager.getInstance().getCurrentScene();
    SettingLinkageManager.getInstance().init(currentScene);
    let result: number = await BackupRestoreManager.getInstance().restoreDb(this.context);
    LogUtil.showInfo(TAG, `onRestoreEx result ${result}`);
    return JsonUtil.stringify(result === RESTORE_SUCCESS ? SUCCESS_RESULT : ERROR_RESULT);
  }

  async onRelease(scenario: number): Promise<void> {
    LogUtil.showInfo(TAG, `onRelease scenario: ${scenario}`);
  }
}