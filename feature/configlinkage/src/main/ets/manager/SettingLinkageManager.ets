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
import { uiAppearance } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import SystemSettingManager from '@ohos/scene.configmanage/src/main/ets/manager/SystemSettingManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsLinkageState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { DebounceUtil } from '@ohos/scene.common/src/main/ets/utils/DebounceUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import {
  FaultConsts,
  FaultScene,
  FaultSubScene
} from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import {
  ACTION,
  DEFAULT_DARK_MODE,
  DEFAULT_EYE_PROTECT_MODE,
  EYE_PROTECT_MODE_DISABLED,
  EYE_PROTECT_MODE_ENABLED,
  SETTINGS_DISPLAY_EYE_COMFORT_MODE,
  SETTING_DATA_DARK_MODE, SETTING_DATA_LIGHT_MODE,
  SETTING_DATA_LIGHT_MODE_NOT_LINKED
} from '../constant/LinkageConstants';
import { LinkageStateMachine } from './LinkageStateMachine';

const TAG = 'SettingLinkageManager';
const OTA_FINISHED: string = '1'; // ota流程已完成
const UI_APPEARANCE_CLONE_EFFECT_TIME: number = 5000; // 克隆场景标记为生效时长

export class SettingLinkageManager {

  private static singleInstance: SettingLinkageManager;

  private darkModeStateMachine: LinkageStateMachine = new LinkageStateMachine('DarkMode');

  private eyeProtectStateMachine: LinkageStateMachine = new LinkageStateMachine('eyeProtect');

  private linkageStateMap: Map<ConfigType, LinkageStateMachine | undefined> = new Map([
    [ConfigType.SYSTEM_SETTINGS_DARK_MODE, this.darkModeStateMachine],
    [ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE, this.eyeProtectStateMachine],
  ]);

  /**
   * 克隆场景适配
   *
   * @returns 克隆场景是否已处理缓存值 true 已处理 false 未处理
   */
  private processCloneScene(): boolean {
    const cloneTime: number = parseInt(SettingsDataUtils
      .getSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_CLONE_TIME, '0'));
    const currentTime: number = new Date().getTime();
    SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.IS_UI_APPEARANCE_FROM_CLONE, 'false');
    LogUtil.showInfo(TAG, `currentTime: ${currentTime}, cloneTime: ${cloneTime},diff: ${currentTime - cloneTime}`);
    if (currentTime - cloneTime > UI_APPEARANCE_CLONE_EFFECT_TIME) {
      return false;
    }
    const defaultDarkMode: string = SettingsDataUtils.getSecureValue(DEFAULT_DARK_MODE, '');
    LogUtil.showInfo(TAG, `darkModeCacheAndOn, defaultDarkMode: ${defaultDarkMode}`);

    // 情景模式缓存值为空情况，以系统当前状态值缓存
    if (!defaultDarkMode) {
      const isDarkMode: boolean = this.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
      LogUtil.showInfo(TAG, `darkModeCacheAndOn, set default dark mode: ${isDarkMode}`);
      SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, isDarkMode ? SETTING_DATA_DARK_MODE :
        SETTING_DATA_LIGHT_MODE);
    }
    this.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
    return true;
  }

  private darkModeCacheAndOn = (): void => {
    LogUtil.showInfo(TAG, 'darkModeCacheAndOn');
    const isUiAppearanceClone: string = SettingsDataUtils
      .getSettingsData(SettingsDataKeyConstant.IS_UI_APPEARANCE_FROM_CLONE, 'false');

    // 如果元能力接口返回值来自克隆，且在克隆流程5s内完成模式开启，则以情景模式自己的DEFAULT_DARK_MODE当做默认值，否则以元能力接口返回为准
    if (isUiAppearanceClone === 'true' && this.processCloneScene()) {
      return;
    }
    const isDarkMode: boolean = this.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
    SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, isDarkMode ? SETTING_DATA_DARK_MODE : SETTING_DATA_LIGHT_MODE);
    this.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
  }

  private darkModeOnToDefault = (): void => {
    LogUtil.showInfo(TAG, 'darkModeOnToDefault');
    let systemDarkModeConfig: string = SettingsDataUtils.getSecureValue(DEFAULT_DARK_MODE,
      SETTING_DATA_LIGHT_MODE_NOT_LINKED);
    const isDarkMode: boolean = this.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
    LogUtil.showInfo(TAG, `darkModeLinkedToDefault systemDarkModeConfig is ${systemDarkModeConfig}, uiAppearance isDarkMode: ${isDarkMode}`);
    if (!isDarkMode) {
      LogUtil.showInfo(TAG, 'dark mode has changed, no need to restore');
      return;
    }
    if (systemDarkModeConfig === SETTING_DATA_DARK_MODE) {
      this.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
    } else if (systemDarkModeConfig === SETTING_DATA_LIGHT_MODE) {
      this.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
    }
  }

  private darkModeOffToDefault = (): void => {
    LogUtil.showInfo(TAG, 'darkModeOffToDefault');
    let systemDarkModeConfig: string = SettingsDataUtils.getSecureValue(DEFAULT_DARK_MODE,
      SETTING_DATA_LIGHT_MODE_NOT_LINKED);
    const isDarkMode: boolean = this.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
    LogUtil.showInfo(TAG, `darkModeOffToDefault systemDarkModeConfig is ${systemDarkModeConfig}, uiAppearance isDarkMode: ${isDarkMode}`);
    if (isDarkMode) {
      LogUtil.showInfo(TAG, 'dark mode has changed, no need to restore');
      return;
    }
    if (systemDarkModeConfig === SETTING_DATA_DARK_MODE) {
      this.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
    } else if (systemDarkModeConfig === SETTING_DATA_LIGHT_MODE) {
      this.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
    }
  }

  private darkModeOffToOn = (): void => {
    LogUtil.showInfo(TAG, 'darkModeOffToOn');
    this.setDarkMode(uiAppearance.DarkMode.ALWAYS_DARK);
  }

  private darkModeOnToOff = (): void => {
    LogUtil.showInfo(TAG, 'darkModeOnToOff');
    this.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
  }

  private darkModeCacheAndOff = (): void => {
    LogUtil.showInfo(TAG, 'darkModeCacheAndOff');
    const isDarkMode: boolean = this.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
    SettingsDataUtils.setSecureValue(DEFAULT_DARK_MODE, isDarkMode ? SETTING_DATA_DARK_MODE : SETTING_DATA_LIGHT_MODE);
    this.setDarkMode(uiAppearance.DarkMode.ALWAYS_LIGHT);
  }

  private eyeProtectCacheAndOn = (): void => {
    LogUtil.showInfo(TAG, 'eyeProtectCacheAndOn');
    // 获取情景模式当前的临时开启状态是否生效
    let eyeEnableAllDay: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE,
      EYE_PROTECT_MODE_DISABLED, Settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `eyeEnableAllDay: ${eyeEnableAllDay}`);
    // 存储历史的系统开启状态
    SettingsDataUtils.setSecureValue(DEFAULT_EYE_PROTECT_MODE, eyeEnableAllDay);
    // 开启护眼模式
    SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE, EYE_PROTECT_MODE_ENABLED,
      Settings.domainName.USER_PROPERTY);
  }

  private eyeProtectOnToDefault = (): void => {
    // 从临时存储中获取护眼模式状态
    let systemEyeProtectConfig: string = SettingsDataUtils.getSecureValue(DEFAULT_EYE_PROTECT_MODE,
      EYE_PROTECT_MODE_DISABLED);
    if (!systemEyeProtectConfig) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
        FaultScene.LINKAGE_MODE_ERROR, FaultSubScene.LINKAGE_MODE_ERROR, '', FaultConsts.GET_PROTECT);
    }
    // 获取当前系统生效的配置状态
    let eyeTempState: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE,
      EYE_PROTECT_MODE_DISABLED, Settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `eyeProtectModeState is ${systemEyeProtectConfig}, current eye project temp state: ${eyeTempState}`);
    const isEyeProjectMode: boolean = eyeTempState === EYE_PROTECT_MODE_ENABLED;

    // 缓存模式为开启
    if (isEyeProjectMode) {
      SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE, systemEyeProtectConfig,
        Settings.domainName.USER_PROPERTY);
    } else {
      LogUtil.showInfo(TAG, 'eye project mode has changed, no need to restore');
    }
  }

  private eyeProtectOffToDefault = (): void => {
    // 从临时存储中获取护眼模式状态
    let systemEyeProtectConfig: string = SettingsDataUtils.getSecureValue(DEFAULT_EYE_PROTECT_MODE,
      EYE_PROTECT_MODE_DISABLED);
    if (!systemEyeProtectConfig) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
        FaultScene.LINKAGE_MODE_ERROR, FaultSubScene.LINKAGE_MODE_ERROR, '', FaultConsts.GET_PROTECT);
    }
    // 获取当前系统生效的配置状态
    let eyeTempState: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE,
      EYE_PROTECT_MODE_DISABLED, Settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `eyeProtectModeState is ${systemEyeProtectConfig}, current eye project temp state: ${eyeTempState}`);
    const isEyeProjectMode: boolean = eyeTempState === EYE_PROTECT_MODE_ENABLED;

    // 缓存模式为关闭
    if (isEyeProjectMode) {
      LogUtil.showInfo(TAG, 'eye project mode has changed, no need to restore');
    } else {
      SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE, systemEyeProtectConfig,
        Settings.domainName.USER_PROPERTY);
    }
  }

  private eyeProtectOffToOn = (): void => {
    SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE, EYE_PROTECT_MODE_ENABLED,
      Settings.domainName.USER_PROPERTY);
  }

  private eyeProtectOnToOff = (): void => {
    SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE, EYE_PROTECT_MODE_DISABLED,
      Settings.domainName.USER_PROPERTY);
  }

  private eyeProtectCacheAndOff = (): void => {
    // 获取情景模式当前的临时开启状态是否生效
    let eyeEnableAllDay: string = SettingsDataUtils.getSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE,
      EYE_PROTECT_MODE_DISABLED, Settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `eyeEnableAllDay: ${eyeEnableAllDay}`);
    // 存储历史的系统开启状态
    if (eyeEnableAllDay) {
      SettingsDataUtils.setSecureValue(DEFAULT_EYE_PROTECT_MODE, eyeEnableAllDay);
      // 开启护眼模式
      SettingsDataUtils.setSettingsDataDomain(SETTINGS_DISPLAY_EYE_COMFORT_MODE, EYE_PROTECT_MODE_DISABLED,
        Settings.domainName.USER_PROPERTY);
    } else {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
        FaultScene.LINKAGE_MODE_ERROR, FaultSubScene.LINKAGE_MODE_ERROR, '', FaultConsts.SET_PROTECT);
    }
  }

  private onModeDetailRefresh = (configType: ConfigType): void => {
    LogUtil.showInfo(TAG, `onModeDetailRefresh: ${configType}`);
    const modeOpenState: ModeState = ModeUtil.getModeOpenState();
    if (modeOpenState.isOpened) {
      this.updateSettingByType(modeOpenState.modeId, configType);
    }
  }

  private onSceneStart = (modeId: string, operType: string): void => {
    LogUtil.showInfo(TAG, `onSceneStart modeId: ${modeId}, operType: ${operType}`);
    this.effectModeLinkedSettings(modeId);
  }

  private onSceneChange = (modeId: string, operType: string): void => {
    LogUtil.showInfo(TAG, `onSceneChange modeId: ${modeId}, operType: ${operType}`);
    this.effectModeLinkedSettings(modeId);
  }

  private onSceneStop = (modeId: string, operType: string): void => {
    LogUtil.showInfo(TAG, `onSceneStop modeId: ${modeId}, operType: ${operType}`);
    this.restoreDefaultSettings(modeId);
  }

  /**
   * 单例
   */
  public static getInstance(): SettingLinkageManager {
    if (!SettingLinkageManager.singleInstance) {
      SettingLinkageManager.singleInstance = new SettingLinkageManager();
    }
    return SettingLinkageManager.singleInstance;
  }

  public async init(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `init linkage config, mode: ${modeId}`);
    EventBus.getInstance().on(EventBusNameConstant.MODE_START_EVENT, this.onSceneStart);
    EventBus.getInstance().on(EventBusNameConstant.MODE_STOP_EVENT, this.onSceneStop);
    EventBus.getInstance().on(EventBusNameConstant.MODE_CHANGE_EVENT, this.onSceneChange);
    EventBus.getInstance().on(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onModeDetailRefresh);
    EventBus.getInstance().on(EventBusNameConstant.DB_SYS_FUNCTION_DATA_REFRESH, this.onModeDetailRefresh);

    this.darkModeStateMachine.addCallback(ACTION.CACHE_AND_ON, this.darkModeCacheAndOn);
    this.darkModeStateMachine.addCallback(ACTION.ON_TO_DEFAULT, this.darkModeOnToDefault);
    this.darkModeStateMachine.addCallback(ACTION.OFF_TO_ON, this.darkModeOffToOn);
    this.darkModeStateMachine.addCallback(ACTION.ON_TO_OFF, this.darkModeOnToOff);
    this.darkModeStateMachine.addCallback(ACTION.CACHE_AND_OFF, this.darkModeCacheAndOff);
    this.darkModeStateMachine.addCallback(ACTION.OFF_TO_DEFAULT, this.darkModeOffToDefault);

    this.eyeProtectStateMachine.addCallback(ACTION.CACHE_AND_ON, this.eyeProtectCacheAndOn);
    this.eyeProtectStateMachine.addCallback(ACTION.ON_TO_DEFAULT, this.eyeProtectOnToDefault);
    this.eyeProtectStateMachine.addCallback(ACTION.OFF_TO_ON, this.eyeProtectOffToOn);
    this.eyeProtectStateMachine.addCallback(ACTION.ON_TO_OFF, this.eyeProtectOnToOff);
    this.eyeProtectStateMachine.addCallback(ACTION.CACHE_AND_OFF, this.eyeProtectCacheAndOff);
    this.eyeProtectStateMachine.addCallback(ACTION.OFF_TO_DEFAULT, this.eyeProtectOffToDefault);

    let defaultDarkModeState: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(modeId,
      ConfigType.SYSTEM_SETTINGS_DARK_MODE);
    this.darkModeStateMachine.initCurrentState(defaultDarkModeState);

    // 获取情景模式关联的护眼模式信息
    let defaultEyeProtectState: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(modeId,
      ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
    if (defaultEyeProtectState) {
      this.eyeProtectStateMachine.initCurrentState(defaultEyeProtectState);
    } else {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
        FaultScene.LINKAGE_MODE_ERROR, FaultSubScene.LINKAGE_MODE_ERROR, '', FaultConsts.SET_PROTECT);
    }
  }

  public deInit(): void {
    LogUtil.showInfo(TAG, 'deInit');
    EventBus.getInstance().detach(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onModeDetailRefresh, false);
    EventBus.getInstance().detach(EventBusNameConstant.MODE_START_EVENT, this.onSceneStart, false);
    EventBus.getInstance().detach(EventBusNameConstant.MODE_STOP_EVENT, this.onSceneStop, false);
    EventBus.getInstance().detach(EventBusNameConstant.MODE_CHANGE_EVENT, this.onSceneChange, false);
    EventBus.getInstance().detach(EventBusNameConstant.DB_SYS_FUNCTION_DATA_REFRESH, this.onModeDetailRefresh, false);
  }

  /**
   * 更新单个模式的关联配置项
   *
   * @param modeId 模式Id
   * @param linkedSetting 需生效的关联设置项
   * @returns
   */
  public async updateSettingByType(modeId: string, type: ConfigType): Promise<void> {
    LogUtil.showInfo(TAG, `updateSettingByType. modeId: ${modeId}, type: ${type}`);
    if (!this.linkageStateMap.has(type)) {
      LogUtil.showError(TAG, 'updateSettingByType error not find ConfigType.');
      return;
    }
    const linkageStateMachine: LinkageStateMachine | undefined = this.linkageStateMap.get(type);
    if (!linkageStateMachine?.convertState) {
      LogUtil.showError(TAG, 'updateSettingByType linkageStateMachine.convertState is undefined.');
      return;
    }
    let state: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(modeId, type);
    linkageStateMachine?.convertState(state);
  }

  /**
   * 恢复系统默认配置项
   *
   * @returns
   */
  public async restoreDefaultSettings(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `restoreDefaultSettings mode:${modeId}`);
    this.darkModeStateMachine.convertState(SettingsLinkageState.NOT_LINK);
    this.eyeProtectStateMachine.convertState(SettingsLinkageState.NOT_LINK);
  }

  /**
   * 生效模式关联的所有系统配置项
   *
   * @param modeId 模式Id
   * @returns
   */
  public async effectModeLinkedSettings(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `effectModeLinkedSettings mode:${modeId}`);
    let darkModeState: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(modeId,
      ConfigType.SYSTEM_SETTINGS_DARK_MODE);
    this.darkModeStateMachine.convertState(darkModeState);

    // 获取情景模式关联的护眼模式信息
    let eyeProtectState: SettingsLinkageState = await SystemSettingManager.getSystemSettingByType(modeId,
      ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE);
    this.eyeProtectStateMachine.convertState(eyeProtectState);
  }

  private getDarkMode(): uiAppearance.DarkMode | undefined {
    try {
      let darkMode: uiAppearance.DarkMode = uiAppearance.getDarkMode();
      return darkMode;
    } catch (err) {
      LogUtil.showError(TAG, `getDarkMode error ${err?.code} ${err?.message}`);
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
        FaultScene.LINKAGE_MODE_ERROR, FaultSubScene.LINKAGE_MODE_ERROR, '', FaultConsts.GET_DARK);
    }
    return undefined;
  }

  private async setDarkMode(darkMode: uiAppearance.DarkMode): Promise<void> {
    const isOtaFinished: boolean = SettingsDataUtils
      .getSecureValue(SettingsDataKeyConstant.IS_OTA_FINISHED, '') === OTA_FINISHED;
    LogUtil.showInfo(TAG, `setDarkMode isOtaFinished: ${isOtaFinished}, darkMode: ${darkMode}`);
    if (!isOtaFinished && darkMode === uiAppearance.DarkMode.ALWAYS_DARK) {
      return;
    }

    await DebounceUtil.debouncePromise(() => {
      let currentDarkMode: uiAppearance.DarkMode | undefined = this.getDarkMode();
      LogUtil.showInfo(TAG, `current color mode: ${currentDarkMode}, set mode: ${darkMode}`);
      if (currentDarkMode === darkMode) {
        LogUtil.showWarn(TAG, 'current mode is already enabled, no need set current mode again');
        return;
      }
      uiAppearance.setDarkMode(darkMode).then(() => {
        LogUtil.showInfo(TAG, `succeed to set dark mode: ${darkMode}`);
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `failed to set dark mode, cause: ${err?.code}`);
        HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
          FaultScene.LINKAGE_MODE_ERROR, FaultSubScene.LINKAGE_MODE_ERROR, '', FaultConsts.SET_DARK);
      });
    })();
  }
}