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

import {
  describe,
  beforeEach,
  afterEach,
  it,
  expect
} from '@ohos/hypium';
import { uiAppearance } from '@kit.ArkUI';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import SystemSettingManager from '@ohos/scene.configmanage/src/main/ets/manager/SystemSettingManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { SettingsLinkageState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import {
  DEFAULT_DARK_MODE,
  SETTING_DATA_DARK_MODE,
  SETTING_DATA_LIGHT_MODE
} from '@ohos/scene.configlinkage/src/main/ets/constant/LinkageConstants';

export default function SettingLinkManagerTest() {
  describe('SettingLinkManagerTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('setting_set_dark_mode_test', 0, async (done: Function) => {
      SettingLinkageManager.getInstance().init('1');
      SettingLinkageManager.getInstance().updateSettingByType('2', ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();
      SettingLinkageManager.getInstance().deInit();
      done();
    });

    it('setting_set_eye_project_mode_test', 0, async (done: Function) => {
      SettingLinkageManager.getInstance().init('1');
      SettingLinkageManager.getInstance().updateSettingByType('2', ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_eyeProtect', '') as string;
      expect(storageStateStr).not().assertNull();
      SettingLinkageManager.getInstance().deInit();
      done();
    });

    it('setting_dark_mode_change_test', 0, async (done: Function) => {
      const modeId: string = '1';
      SettingLinkageManager.getInstance().init(modeId);

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_DISABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_DISABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
      SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, SETTING_DATA_LIGHT_MODE);
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_DISABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_DISABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      SettingLinkageManager.getInstance().deInit();
      done();
    });


    it('setting_dark_mode_on_to_default_test', 0, async (done: Function) => {
      const modeId: string = '1';
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.LINK_ENABLE);
      SettingLinkageManager.getInstance().init(modeId);

      SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, SETTING_DATA_DARK_MODE);
      SettingsDataUtils.setSystemValue('linkedage_state_DarkMode', '2');
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      SettingsDataUtils.setSystemValue('linkedage_state_DarkMode', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, SETTING_DATA_LIGHT_MODE);
      SettingsDataUtils.setSystemValue('linkedage_state_DarkMode', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      SettingLinkageManager.getInstance().deInit();
      done();
    });

    it('setting_dark_mode_off_to_default_test', 0, async (done: Function) => {
      const modeId: string = '1';
      SettingLinkageManager.getInstance().init(modeId);

      SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, SETTING_DATA_LIGHT_MODE);
      SettingsDataUtils.setSystemValue('linkedage_state_DarkMode', '3');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      SettingsDataUtils.setSystemValue('linkedage_state_DarkMode', '3');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      uiAppearance.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, SETTING_DATA_DARK_MODE);
      SettingsDataUtils.setSystemValue('linkedage_state_DarkMode', '3');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();

      SettingLinkageManager.getInstance().deInit();
      done();
    });

    it('setting_eye_project_mode_change_test', 0, async (done: Function) => {
      const modeId: string = '1';
      SettingLinkageManager.getInstance().init(modeId);
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
        SettingsLinkageState.LINK_ENABLE);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_eyeProtect', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
        SettingsLinkageState.LINK_DISABLE);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_eyeProtect', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
        SettingsLinkageState.NOT_LINK);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_eyeProtect', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
        SettingsLinkageState.LINK_DISABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_eyeProtect', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_eyeProtect', '') as string;
      expect(storageStateStr).not().assertNull();

      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      SettingLinkageManager.getInstance().deInit();
      done();
    });
  });
}