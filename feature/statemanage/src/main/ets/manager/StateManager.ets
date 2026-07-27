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
import { CommonEventHelper } from '@ohos/scene.common/src/main/ets/commonevent/CommonEventHelper';
import { ConfigConstant } from '@ohos/scene.common/src/main/ets/constant/ConfigConstant';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { NO_SCENE, SCENE_DISABLE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { BaseModeConfig } from '@ohos/scene.modeconfig/src/main/ets/adapter/BaseModeConfig';
import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import { LocalSceneManager } from '@ohos/scene.configmanage/src/main/ets/manager/LocalSceneManager';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { AllowDisturbDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import { CurrentOpenedMode } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { NOT_DISTURB_DISABLE, NOT_DISTURB_ENABLE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { CLOSE } from '../constant/StateConstants';

// 模式立即开启关闭的节流间隔时间
export const THROTTLE_INTERVAL_TIME: number = 300;

export const MIN_TIMESTAMP: number = 0;

const TAG: string = 'SceneStateManager: ';

/**
 * 模式状态管理模块
 */
export class StateManager {
  private static singleInstance: StateManager;
  // 当前开启模式，为0表示当前没有开启任何模式
  private currentScene: string = NO_SCENE;

  /**
   * 系统时间改变事件
   */
  private onTimeChangeEventHelper: CommonEventHelper = new CommonEventHelper({
    events: [commonEventManager.Support.COMMON_EVENT_TIME_CHANGED],
  }, (err, data) => {
    if (err?.code) {
      LogUtil.showError(TAG, `onTimeChangeEventHelper failed. code:${err?.code} message:${err?.message}`);
    } else {
      LogUtil.showInfo(TAG, 'onTimeChangeEventHelper init mode enable time');
    }
  });

  /**
   * 单例
   */
  public static getInstance(): StateManager {
    if (!StateManager.singleInstance) {
      StateManager.singleInstance = new StateManager();
    }
    return StateManager.singleInstance;
  }

  public init(): void {
    LogUtil.showInfo(TAG, 'init');
    this.onTimeChangeEventHelper.registerCommonEvent();
    if (!SystemParamUtil.isSupportIntelligentScene()) {
      LogUtil.showWarn(TAG, 'not support intelligent scene, no need registerSceneStatusListener');
      return;
    }
  }

  public deInit(): void {
    LogUtil.showInfo(TAG, 'deInit');
    this.onTimeChangeEventHelper.unRegisterCommonEvent();
    if (!SystemParamUtil.isSupportIntelligentScene()) {
      LogUtil.showWarn(TAG, 'not support intelligent scene, no need unRegisterSceneStatusListener');
      return;
    }
  }

  /**
   * 从settingsdata数据库获取当前开启模式
   *
   * @returns modeId
   */
  public getCurrentScene(): string {
    this.currentScene = ModeUtil.getModeOpenState().modeId;
    return this.currentScene;
  }

  /**
   * 开启模式
   *
   * @param modeId 待开启模式
   * @param operType 操作类型，值对应枚举类型FactorType
   * @param sourceType 开启模式的来源，可选参数，值对应枚举类型EffectiveSourceType
   * @param updateTime 更新时间， 可选参数
   * @returns 当前开启的模式id
   */
  public startScene(modeId: string, operType: number, sourceType?: number, updateTime?: number): string {
    LogUtil.showWarn(TAG, `startScene, scene: ${modeId}, operType: ${operType}`);
    this.effectiveScene(modeId, operType, sourceType, updateTime);
    if (operType === FactorType.USER) {
      this.saveEffectiveConfigId(ConfigConstant.RULE_NAME_SCENE_MANUAL_START, sourceType);
    }
    return this.getCurrentScene();
  }

  /**
   * 关闭模式
   *
   * @param modeId 待关闭模式
   * @param operType 操作类型，值对应枚举类型FactorType
   * @param sourceType 关闭模式来源，枚举类型EffectiveSourceType，可选参数
   * @param updateTime 更新时间，可选参数
   * @returns 当前模式
   */
  public stopScene(modeId: string, operType: number, sourceType?: number, updateTime?: number): string {
    LogUtil.showWarn(TAG, `stopScene, scene: ${modeId}, operType: ${operType}`);
    this.effectiveScene(NO_SCENE, operType, sourceType, updateTime);
    this.saveEffectiveConfigId(ConfigConstant.RULE_NAME_SCENE_DISABLED);
    return this.getCurrentScene();
  }

  /**
   * 保存生效中的规则id
   *
   * @param ruleName 规则名称
   */
  public saveEffectiveConfigByRule(ruleName: string): void {
    if (CheckEmptyUtils.checkStrIsEmpty(ruleName)) {
      LogUtil.showError(TAG, 'save effective config by rule fail, ruleName is invalid');
      return;
    }
    const prefixLen: number = ConfigConstant.RULE_NAME_PREFIX.length;
    if (ruleName.startsWith(ConfigConstant.RULE_NAME_PREFIX) && ruleName.length > prefixLen) {
      let configId: string = ruleName.substring(prefixLen);
      if (CheckEmptyUtils.checkStrIsEmpty(configId)) {
        LogUtil.showError(TAG, 'save effective config by rule fail, configId is invalid');
        return;
      }
      if (configId.indexOf('-')) {
        configId = configId.substring(0, configId.length - ConfigConstant.RULE_NAME_SUFFIX_LENGTH);
      }
      // 保存到数据库的条件(非临时创建规则，控制中心等)，从数据库取出configValue存到SettingsData
      LogUtil.showInfo(TAG, `saveEffectiveConfigByRule, configId: ${configId} ruleName: ${ruleName}`);
      this.saveEffectiveConfigId(configId);
    }
  }

  /**
   * 保存保存生效中的规则id/类型
   *
   * @param configId 配置id
   * @param sourceType 模式生效的来源，可选参数，值对应枚举类型EffectiveSourceType
   */
  public saveEffectiveConfigId(configId: string, sourceType?: number): void {
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_CONFIG_ID_IN_EFFECT, configId);
    const configType: ConfigType = ModeUtil.getTypeFromConfigId(configId);
    LogUtil.showInfo(TAG, `saveEffectiveConfigId. configId:${configId} configType:${configType}`);
  }

  /**
   * 获取已开启模式的触发的开启条件配置id
   *
   * @returns 条件开启返回configId ;手动开启返回manual_on, 关闭返回off
   */
  public getEffectiveConfigId(): string {
    return SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.INTELLIGENT_CONFIG_ID_IN_EFFECT, '');
  }

  /**
   * 生效模式（该方法需要保证同步执行）
   *
   * @param nextScene 将要生效的模式
   * @param operType 操作类型，值对应枚举类型FactorType
   * @param sourceType 可选参数，模式变化的来源，枚举类型EffectiveSourceType
   * @param updateTime 可选参数，模式变化时间
   */
  private effectiveScene(nextScene: string, operType: number, sourceType?: number, updateTime?: number): void {
    this.getCurrentScene();
    LogUtil.showWarn(TAG, `effectiveScene, currentScene: ${this.currentScene}, nextScene: ${nextScene}, source: ${sourceType}`);
    // 待开启模式与当前模式相同，不做切换
    if (this.currentScene === nextScene) {
      let currentScene: CurrentOpenedMode | undefined = LocalSceneManager.getLocalSceneSync();
      LogUtil.showInfo(TAG, `effectiveScene, config's currentScene: ${currentScene?.modeId}`);
      if (currentScene && currentScene.modeId === this.currentScene) {
        return;
      }
    }
    if (!this.updateSettingsDataScene(nextScene)) {
      LogUtil.showError(TAG, `updateSettingsDataScene fail, nextScene: ${nextScene}`);
      return;
    }
    this.notifyToUpdateScene(this.currentScene, nextScene, operType);
    const preScene: string = this.currentScene;
    this.currentScene = nextScene;
    this.updateConfigScene(preScene, nextScene, operType, sourceType, updateTime);
    this.updateIncomingConfig(nextScene);
    this.updateNotificationConfig(nextScene);
  }

  /**
   * 模式开启的时候，需要刷新一下通知勿扰和声音振动白名单数据
   *
   * @param scene 模式id
   */
  private updateNotificationConfig(scene: string): void {
    const modeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(scene);
    if (!modeConfig.isSupportNotDisturb) {
      LogUtil.showWarn(TAG, `scene ${scene} is not support notdisburt.`);
      return;
    }
    AllowDisturbDataManager.setAllowDisturbAppList(scene).then(()=> {
      this.updateSoundAndVibrationWhiteList(scene);
    });
  }

  /**
   * 持久化保存本地开启模式数据
   *
   * @param preScene 当前开启的模式信息
   * @param scene 即将开启的模式
   * @param operType 开启类型，值对应枚举类型FactorType
   * @param sourceType 开启模式的来源，可选参数，值对应枚举类型EffectiveSourceType
   * @param updateTime 更新时间，可选参数
   * @returns 更新成功返回1; 更新失败或未更新返回空
   */
  private updateConfigScene(preScene: string, scene: string, operType: number, sourceType?: number,
    updateTime?: number) {
    const openedMode: CurrentOpenedMode = {
      modeId: scene,
      openType: operType
    };
    LocalSceneManager.updateLocalScene(openedMode, preScene, sourceType, updateTime);
  }

  /**
   * 模式开启的时候，需要刷新一下声音振动白名单数据
   *
   * @param scene 模式id
   */
  private updateSoundAndVibrationWhiteList(scene: string) {
    if (scene !== SCENE_DISABLE) {
      AllowDisturbDataManager.setSoundAndVibrationWhiteList(scene);
    }
  }

  /**
   * 更新SettingsData数据库中模式，供外部监听
   *
   * @param scene
   */
  private updateSettingsDataScene(scene: string): boolean {
    let isOpen: boolean = scene !== NO_SCENE;
    if (isOpen) {
      let modeData: ModeData | undefined = El1ModeDataManager.getInstance().queryModeDataByIdSync(scene);
      if (!modeData) {
        LogUtil.showError(TAG, `updateSettingsDataScene fail because no mode data, scene: ${scene}`);
        return false;
      }
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_NAME, modeData?.modeName);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_ICON, modeData?.iconId);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, scene);
    }
    SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, '');
    // 保存当前开启模式
    const isSceneFault: boolean = SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, scene);

    // 保存勿扰开关开启状态
    const isStartNotDisturb: boolean =
      isOpen && ModeConfigAdapter.getInstance().getConfigByModeId(scene).isSupportNotDisturb;
    let notDisturbStatus: string = isStartNotDisturb ? NOT_DISTURB_ENABLE : NOT_DISTURB_DISABLE;
    const isOpenFault: boolean =
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.FOCUS_MODE_ENABLED, notDisturbStatus);
    const isOperateFault: boolean =
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, scene);
    if (!isSceneFault || !isOpenFault || !isOperateFault) {
      LogUtil.showError(TAG,
        `updateSettingsDataScene. isSceneFault:${isSceneFault} isOpenFault:${isOpenFault} isOperateFault:${isOperateFault}`);
      return false;
    }
    return true;
  }

  /**
   * 更新来电勿扰相关配置
   * @param scene
   */
  private updateIncomingConfig(scene: string): void {
    LogUtil.showInfo(TAG, `updateIncomingConfig scene: ${scene}`);
    AllowDisturbManager.getInstance().getEl1ContactPolicy(scene).then((contactPolicy) => {
      LogUtil.showInfo(TAG, `updateIncomingConfig contactPolicy: ${contactPolicy}`);
      SettingsDataUtils.setSystemValue(SettingsDataKeyConstant.CALL_MESSAGE_POLICY, contactPolicy);
    });

    // 不支持重复来电，直接关闭
    SettingsDataUtils.setSystemValue(SettingsDataKeyConstant.REPEAT_CALLERS_ENABLE, CLOSE);
  }

  /**
   * 通知内部模块进行模式切换
   *
   * @param currentScene 当前开启模式
   * @param nextScene 待切换模式Id
   * @param operType 类型
   */
  private notifyToUpdateScene(currentScene: string, nextScene: string, operType: number): void {
    if (nextScene === NO_SCENE) {
      this.notifyToStopScene(currentScene, operType);
      return;
    }
    if (currentScene === NO_SCENE) {
      this.notifyToStartScene(nextScene, operType);
    } else {
      this.notifyToChangeScene(nextScene, operType);
    }
  }

  /**
   * 通知模式启动
   *
   * @param nextScene 待切换模式Id
   * @param operType 类型
   */
  private notifyToStartScene(scene: string, operType: number): void {
    LogUtil.showInfo(TAG, `notifyToStartScene, scene: ${scene}`);
    EventBus.getInstance().emit(EventBusNameConstant.MODE_START_EVENT, scene, operType);
  }

  /**
   * 通知模式切换
   *
   * @param nextScene 待切换模式Id
   * @param operType 类型
   */
  private notifyToChangeScene(scene: string, operType: number): void {
    LogUtil.showInfo(TAG, `notifyToChangeScene, scene: ${scene}`);
    EventBus.getInstance().emit(EventBusNameConstant.MODE_CHANGE_EVENT, scene, operType);
  }

  /**
   * 通知关闭模式
   *
   * @param nextScene 待切换模式Id
   * @param operType 类型
   */
  private notifyToStopScene(scene: string, operType: number): void {
    LogUtil.showInfo(TAG, `notifyToStopScene, scene: ${scene}`);
    EventBus.getInstance().emit(EventBusNameConstant.MODE_STOP_EVENT, scene, operType);
  }
}