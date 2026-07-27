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

import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ContactAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ContactAdapter';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';

/* instrument ignore file */
const TAG: string = 'DefaultIntentBackgroundUiAbility: ';

export default class DefaultIntentBackgroundUiAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.showInfo(TAG, 'onCreate is called');
    if (AbilityContextManager.getContext()) {
      return;
    }
    AbilityContextManager.addContext(this.context);
    StateManager.getInstance().init();
    const currentScene: string = StateManager.getInstance().getCurrentScene();
    // 初始化生效当前模式的关联配置项状态机
    SettingLinkageManager.getInstance().init(currentScene);
    ModeAdapter.getInstance().initData();
    ModeDetailAdapter.getInstance().initData();
    ContactAdapter.getInstance().init();
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.showInfo(TAG, 'onNewWant is called');
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy is called');
    AbilityContextManager.removeContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LogUtil.showInfo(TAG, 'onWindowStageCreate is called');
  }
}
