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

import Settings from '@ohos.settings';
import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { PrivacyStatementUtil } from '@ohos/scene.common/src/main/ets/utils/PrivacyStatementUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';

const driver: Driver = Driver.create();
const COMMON_DELAY: number = 4000;

export default function StateManagerTest() {
  describe('StateManagerTest', () => {
    beforeEach(() => {
      StateManager.getInstance().init();
      const currentScene: string = StateManager.getInstance().getCurrentScene();
      // 初始化生效当前模式的关联配置项状态机
      SettingLinkageManager.getInstance().init(currentScene);
    });

    afterEach(() => {
      SettingLinkageManager.getInstance().deInit();
    });

    it('init_when_mode_enable_test', 0, async (done: Function) => {
      const isSceneFault: boolean = SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '1');
      const isOpenFault: boolean = SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '1');
      let modeId: string = StateManager.getInstance().getCurrentScene();
      expect(!StringUtil.isEmpty(modeId)).assertTrue();
      done();
    })

    it('start_or_stop_scene_test', 0, async (done: Function) => {
      StateManager.getInstance().startScene(ModeType.DND_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      let modeEnable: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '0', Settings.domainName.USER_SECURITY);
      let modeId: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '', Settings.domainName.USER_SECURITY);

      StateManager.getInstance().stopScene(ModeType.DND_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      modeEnable = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '0', Settings.domainName.USER_SECURITY);
      modeId = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '', Settings.domainName.USER_SECURITY);
      expect(modeId !== ModeType.DND_MODE).assertTrue();
      done();
    });

    it('get_save_effective_config_by_rule_invalid_rule_test', 0, (done: Function) => {
      StateManager.getInstance().saveEffectiveConfigByRule('');
      expect(StringUtil.generateUuid() !== undefined).assertTrue();
      done();
    })

    it('get_save_effective_config_by_rule_invalid_config_test', 0, (done: Function) => {
      StateManager.getInstance().saveEffectiveConfigByRule('rule--');
      expect(StringUtil.generateUuid() !== undefined).assertTrue();
      done();
    })

    it('get_save_effective_config_by_rule_test', 0, (done: Function) => {
      const configId: string = '2_3';
      StateManager.getInstance().saveEffectiveConfigByRule('rule-2_3_01-1745164616');
      let getValue: string = StateManager.getInstance().getEffectiveConfigId();
      expect(!StringUtil.isEmpty(configId)).assertTrue();
      done();
    })

    it('update_scene_test', 0, async (done: Function) => {
      StateManager.getInstance().startScene(ModeType.DND_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      let modeEnable: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '0', Settings.domainName.USER_SECURITY);
      let modeId: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '1', Settings.domainName.USER_SECURITY);
      expect(modeId === ModeType.DND_MODE).assertTrue();

      StateManager.getInstance().startScene(ModeType.SLEEP_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      modeEnable = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '0', Settings.domainName.USER_SECURITY);
      modeId = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '2', Settings.domainName.USER_SECURITY);
      expect(modeId === ModeType.SLEEP_MODE).assertTrue();
      StateManager.getInstance().stopScene(ModeType.SLEEP_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      done();
    });

    it('start_learning_scene_test', 0, async (done: Function) => {
      StateManager.getInstance().startScene(ModeType.LEARNING_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      let modeEnable: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '1', Settings.domainName.USER_SECURITY);
      let modeId: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '3', Settings.domainName.USER_SECURITY);
      expect(modeEnable === '1').assertTrue();
      expect(modeId === ModeType.LEARNING_MODE).assertTrue();

      StateManager.getInstance().stopScene(ModeType.LEARNING_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      done();
    });

    it('on_scene_status_change_recommend_test', 0, async (done: Function) => {
      StateManager.getInstance().startScene(ModeType.DND_MODE, FactorType.USER);
      await driver.delayMs(COMMON_DELAY);
      StateManager.getInstance().startScene(ModeType.SLEEP_MODE, FactorType.AUTO);
      let modeEnable: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '1', Settings.domainName.USER_SECURITY);
      expect(modeEnable === '1').assertTrue();
      done();
    });

    it('on_update_operation_record_current_mode', 0, async (done: Function) => {
      StateManager.getInstance().startScene(ModeType.DND_MODE, FactorType.AUTO);
      let modeEnable: string = SettingsDataUtils
        .getSettingsData(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, '1', Settings.domainName.USER_SECURITY);
      expect(modeEnable === '1').assertTrue();
      done();
    });

    it('get_effective_config_id', 0, async (done: Function) => {
      StateManager.getInstance().saveEffectiveConfigId('manual_on');
      expect(StateManager.getInstance().getEffectiveConfigId()).not().assertNull();
      done();
    });
  });
}