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

import UIAbility from '@ohos.app.ability.UIAbility';
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { Hypium } from '@ohos/hypium';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { DB_CONFIG } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { PreferencesUtil } from '@ohos/scene.common/src/main/ets/utils/PreferencesUtil';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import testsuite from '../../ets/test/List.test';

const TAG: string = 'IntelligentSceneTestAbility: ';
type AbilityDelegator = AbilityDelegatorRegistry.AbilityDelegator;
type AbilityDelegatorArgs = AbilityDelegatorRegistry.AbilityDelegatorArgs;

export default class TestAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    LogUtil.showInfo(TAG, 'TestAbility onCreate');
    const ABILITY_DELEGATOR: AbilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
    const ABILITY_DELEGATOR_ARGUMENTS: AbilityDelegatorArgs = AbilityDelegatorRegistry.getArguments();
    LogUtil.showInfo(TAG, 'start run testcase!!!');
    AppStorage.setOrCreate<common.UIAbilityContext>('pageContext', this.context);
    AbilityContextManager.addContext(this.context);
    await this.clearTableData();
    await PreloadManager.getInstance().initData(this.context, false);
    LogUtil.showInfo(TAG, 'create base tables and init preset data');
    Hypium.hypiumTest(ABILITY_DELEGATOR, ABILITY_DELEGATOR_ARGUMENTS, testsuite);
  }

  /**
   * 升级预制模式数据
   */
  private async upgradePreloadMode(): Promise<void> {
    const ccmVersion: number = PreloadManager.getInstance().getVersionFromCcm();
    const preferenceVersion: number = await PreloadManager.getInstance().getVersionFromPreference(this.context);
    LogUtil.showInfo(TAG, `upgradePreloadMode. ccmVersion:${ccmVersion} preferenceVersion:${preferenceVersion}`);
    if (preferenceVersion !== ccmVersion) {
      await PreloadManager.getInstance().batchPresetMode();
      await PreloadManager.getInstance().updateVersionToPreference(this.context, ccmVersion);
    }
  }

  private async clearTableData(): Promise<void> {
    LogUtil.showInfo(TAG, 'clearTableData');
    await RdbStoreHelper.getInstance().deleteTableData(DB_CONFIG.MODE_DATA.TABLE_NAME);
    await RdbStoreHelper.getInstance().deleteTableData(DB_CONFIG.CONFIG_DATA.TABLE_NAME);
    await RdbStoreHelper.getInstance().deleteTableData(DB_CONFIG.LEARNING_PLAN.TABLE_NAME);
    await El1RdbStoreHelper.getInstance().deleteTableData(DB_CONFIG.MODE_DATA.TABLE_NAME);
    await El1RdbStoreHelper.getInstance().deleteTableData(DB_CONFIG.CONFIG_DATA.TABLE_NAME);
    PreferencesUtil.put('local_ccm_version', '');
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'TestAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LogUtil.showInfo(TAG, 'onWindowStageCreate');
    windowStage.loadContent('testability/pages/Index', (err, data) => {
      if (err.code) {
        LogUtil.showError(TAG, `Failed to load the content. Cause: ${err?.code}, ${err?.message}`);
        return;
      }
      LogUtil.showInfo(TAG, 'Succeeded in loading the content');
    });
  }

  onWindowStageDestroy(): void {
    LogUtil.showInfo(TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    LogUtil.showInfo(TAG, 'onForeground');
  }

  onBackground(): void {
    LogUtil.showInfo(TAG, 'onBackground');
  }
}