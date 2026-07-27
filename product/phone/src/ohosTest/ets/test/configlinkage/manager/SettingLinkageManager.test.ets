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
  expect,
  MockKit,
  when
} from '@ohos/hypium';
import { uiAppearance } from '@kit.ArkUI';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import SystemSettingManager from '@ohos/scene.configmanage/src/main/ets/manager/SystemSettingManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { SettingsLinkageState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import {
  DEFAULT_DARK_MODE,
  DEFAULT_EYE_PROTECT_MODE,
  SETTINGS_DISPLAY_EYE_COMFORT_MODE,
  SETTING_DATA_DARK_MODE,
  SETTING_DATA_LIGHT_MODE
} from '@ohos/scene.configlinkage/src/main/ets/constant/LinkageConstants';

export default function SettingLinkageManagerTest() {
  describe('SettingLinkageManagerTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('set_dark_mode_test', 0, async (done: Function) => {
      SettingLinkageManager.getInstance().init('1');
      SettingLinkageManager.getInstance().updateSettingByType('2', ConfigType.SYSTEM_SETTINGS_DARK_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_DarkMode', '') as string;
      expect(storageStateStr).not().assertNull();
      SettingLinkageManager.getInstance().deInit();
      done();
    });

    it('set_eye_project_mode_test', 0, async (done: Function) => {
      SettingLinkageManager.getInstance().init('1');
      SettingLinkageManager.getInstance().updateSettingByType('2', ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_eyeProtect', '') as string;
      expect(storageStateStr).not().assertNull();
      SettingLinkageManager.getInstance().deInit();
      done();
    });

    it('dark_mode_change_test', 0, async (done: Function) => {
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


    it('dark_mode_on_to_default_test', 0, async (done: Function) => {
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

      SettingLinkageManager.getInstance().init('-1');
      SettingLinkageManager.getInstance().deInit();

      SettingLinkageManager.getInstance().init('40');
      const settingLinkageManager: SettingLinkageManager = new SettingLinkageManager();
      (settingLinkageManager as object)['initOccupationCurrentState']('40');
      (settingLinkageManager as object)['effectOccupationLinkedSettings']('40');
      (settingLinkageManager as object)['processCloneScene']();
      (settingLinkageManager as object)['eyeProtectOffToDefault']();
      SettingsDataUtils.setSecureValue(DEFAULT_EYE_PROTECT_MODE, '');
      SettingsDataUtils.setSystemValue(SETTINGS_DISPLAY_EYE_COMFORT_MODE, '1');
      (settingLinkageManager as object)['eyeProtectOffToDefault']();
      (settingLinkageManager as object)['eyeProtectOnToOff']();
      (settingLinkageManager as object)['onModeDetailRefresh'](ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
      (settingLinkageManager as object)['onSceneStart']('1', '0');
      (settingLinkageManager as object)['onSceneChange']('1', '0');
      (settingLinkageManager as object)['onSceneStop']('1', '0');

      (settingLinkageManager as object)['initOccupationMachine']();
      let mocker: MockKit = new MockKit();
      SettingLinkageManager.getInstance().deInit();

      await SettingLinkageManager.getInstance().effectModeLinkedSettings('1');
      done();
    });

    it('dark_mode_off_to_default_test', 0, async (done: Function) => {
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

    it('eye_project_mode_change_test', 0, async (done: Function) => {
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

    const valueList: string[] = ['1', '2']
    it('auto_hands_free_call_mode_change_test', 0, async (done: Function) => {
      const modeId: string = '41';
      SettingLinkageManager.getInstance().init(modeId);
      SettingsDataUtils.setSystemValue('linkedage_state_autoHandsFreeCall', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL,
        SettingsLinkageState.LINK_ENABLE);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_autoHandsFreeCall', '') as string;
     expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_autoHandsFreeCall', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL,
        SettingsLinkageState.NOT_LINK);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_autoHandsFreeCall', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_autoHandsFreeCall', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_autoHandsFreeCall', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_autoHandsFreeCall', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.AUTO_HANDS_FREE_CALL);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_autoHandsFreeCall', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();
      done();
    });

    it('system_settings_high_volume_mode_change_test', 0, async (done: Function) => {
      const modeId: string = '41';
      SettingLinkageManager.getInstance().init(modeId);
      SettingsDataUtils.setSystemValue('linkedage_state_highVolume', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME,
        SettingsLinkageState.LINK_ENABLE);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_highVolume', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_highVolume', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME,
        SettingsLinkageState.NOT_LINK);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_highVolume', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_highVolume', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_highVolume', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_highVolume', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_HIGH_VOLUME);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_highVolume', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();
      done();
    });

    it('clear_broadcasting_mode_change_test', 0, async (done: Function) => {
      const modeId: string = '41';
      SettingLinkageManager.getInstance().init(modeId);
      SettingsDataUtils.setSystemValue('linkedage_state_clearBroadcasting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.CLEAR_BROADCASTING,
        SettingsLinkageState.LINK_ENABLE);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.CLEAR_BROADCASTING);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_clearBroadcasting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_clearBroadcasting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.CLEAR_BROADCASTING,
        SettingsLinkageState.NOT_LINK);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.CLEAR_BROADCASTING);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_clearBroadcasting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_clearBroadcasting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.CLEAR_BROADCASTING,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.CLEAR_BROADCASTING);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_clearBroadcasting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_clearBroadcasting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.CLEAR_BROADCASTING,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.CLEAR_BROADCASTING);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_clearBroadcasting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();
      done();
    });

    it('system_screen_smart_highlighting_mode_change_test', 0, async (done: Function) => {
      const modeId: string = '41';
      SettingLinkageManager.getInstance().init(modeId);
      SettingsDataUtils.setSystemValue('linkedage_state_smartHighLighting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING,
        SettingsLinkageState.LINK_ENABLE);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_smartHighLighting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_smartHighLighting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING,
        SettingsLinkageState.NOT_LINK);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_smartHighLighting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_smartHighLighting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_smartHighLighting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_smartHighLighting', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SCREEN_SMART_HIGHLIGHTING);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_smartHighLighting', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();
      done();
    });

    it('system_settings_screen_off_timeout_mode_change_test', 0, async (done: Function) => {
      const modeId: string = '41';
      SettingLinkageManager.getInstance().init(modeId);
      SettingsDataUtils.setSystemValue('linkedage_state_screenOffTimeOut', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT,
        SettingsLinkageState.LINK_ENABLE);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT);
      let storageStateStr: string = SettingsDataUtils.getSystemValue('linkedage_state_screenOffTimeOut', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_screenOffTimeOut', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT,
        SettingsLinkageState.NOT_LINK);
      SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_screenOffTimeOut', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_screenOffTimeOut', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT,
        SettingsLinkageState.LINK_ENABLE);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_screenOffTimeOut', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();

      SettingsDataUtils.setSystemValue('linkedage_state_screenOffTimeOut', '2');
      await SystemSettingManager.updateSystemSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT,
        SettingsLinkageState.NOT_LINK);
      await SettingLinkageManager.getInstance().updateSettingByType(modeId, ConfigType.SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT);
      storageStateStr = SettingsDataUtils.getSystemValue('linkedage_state_screenOffTimeOut', '') as string;
      expect(valueList.includes(storageStateStr)).assertTrue();
      done();
    });

    it('restore_occupation_default_settings_test', 0, async (done: Function) => {
      const modeId: string = '41';
      let mocker: MockKit = new MockKit();
      SettingLinkageManager.getInstance().restoreDefaultSettings(modeId);
      const str1 = SettingsDataUtils.getSystemValue('linkedage_state_autoHandsFreeCall', '') as string;
      expect(valueList.includes(str1)).assertTrue();
      const str2 = SettingsDataUtils.getSystemValue('linkedage_state_highVolume', '') as string;
      expect(valueList.includes(str2)).assertTrue();
      const str3 = SettingsDataUtils.getSystemValue('linkedage_state_clearBroadcasting', '') as string;
      expect(valueList.includes(str3)).assertTrue();
      const str4 = SettingsDataUtils.getSystemValue('linkedage_state_smartHighLighting', '') as string;
      expect(valueList.includes(str4)).assertTrue();
      const str5 = SettingsDataUtils.getSystemValue('linkedage_state_screenOffTimeOut', '') as string;
      expect(valueList.includes(str5)).assertTrue();
      done();
    });
  });
}