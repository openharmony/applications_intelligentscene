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

import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';
import { ConfigData, EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ContactManager } from '@ohos/scene.datamanage/src/main/ets/manager/ContactManager';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { El1CallConfigManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1CallConfigManager';
import { ModeDefaultDataManager } from '../preload/ModeDefaultDataManager';

const NO_SCENE: string = '0';

const TAG: string = 'SceneBaseDataManager:';

/**
 * 模式基础数据管理
 */
export class SceneBaseDataManager {
  public static async getUsedIcons(): Promise<string[]> {
    return [];
  }

  /**
   * 新增模式
   */
  public static async createCustomScene(sceneBaseData: ModeData): Promise<string> {
    const modeId = await ModeDataManager.getInstance().insertModeData(sceneBaseData);
    LogUtil.showInfo(TAG, `createCustomScene presetId:${sceneBaseData.modeId} modeId:${modeId}`);
    if (modeId !== INVALID_MODE_ID) {
      sceneBaseData.modeId = modeId;
      await El1ModeDataManager.getInstance().insertModeData(sceneBaseData);
    }
    SceneBaseDataManager.setIntelligentUsedState();
    let configs: ConfigData[] | undefined =
      await ModeDefaultDataManager.getInstance().getModeDefaultConfigDataByModeId(modeId);
    if (!configs?.length) {
      LogUtil.showError(TAG, 'createCustomScene. configs is empty.');
      return modeId;
    }
    let res: number = await ConfigDataManager.getInstance().batchInsertConfigData(configs);
    await El1CallConfigManager.batchInsertCallConfig(configs);
    LogUtil.showInfo(TAG, `insert template configs result: ${res}`);
    return modeId;
  }

  /**
   * 更新模式数据
   */
  public static async updateCustomScene(sceneBaseData: ModeData): Promise<string> {
    LogUtil.showInfo(TAG, `updateCustomScene. sceneBaseData.modeId:${sceneBaseData.modeId}`);
    const modeId = await ModeDataManager.getInstance().updateModeData(sceneBaseData);
    LogUtil.showInfo(TAG, `updateCustomScene. modeId:${modeId}`);
    if (modeId !== INVALID_MODE_ID) {
      await El1ModeDataManager.getInstance().updateModeData(sceneBaseData);
      const lastEnableMode =
        SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, NO_SCENE);
      // 如果修改的是上一次开启的模式 则需要重新写一边数据 让控制中心一级页面去刷新显示
      if (lastEnableMode === modeId) {
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_NAME, sceneBaseData?.modeName);
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_ICON, sceneBaseData?.iconId);
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, modeId);
        SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, modeId);
      }
    }
    return modeId;
  }

  public static async isModeNameValid(modeName: string): Promise<boolean> {
    let isModeNameExists = await El1ModeDataManager.getInstance().isModeNameExists(modeName);
    return !isModeNameExists;
  }

  public static async getAllSceneBaseData(): Promise<ModeData[]> {
    let modes: ModeData[] = await El1ModeDataManager.getInstance().queryAllModeData();
    // 模式卡片显示顺序 先展示不可删除的预制卡片 后展示可删除的卡片
    modes.sort((a, b) => {
      if ((a.isSupportDelete && b.isSupportDelete) || (!a.isSupportDelete && !b.isSupportDelete)) {
        return (a.createTime ?? 0) - (b.createTime ?? 0);
      }
      if (a.isSupportDelete && !b.isSupportDelete) {
        return 1;
      }
      return -1;
    });
    return modes;
  }

  public static async getSceneDataById(modeId: string): Promise<ModeData | undefined> {
    return await El1ModeDataManager.getInstance().queryModeDataById(modeId);
  }

  /**
   * 删除模式数据
   */
  public static async deleteSceneData(modeId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteSceneData. modeId:${modeId}`);
    const configNum = await ModeDataManager.getInstance().deleteModeDataById(modeId);
    await El1ModeDataManager.getInstance().deleteModeDataById(modeId);
    LogUtil.showInfo(TAG, `deleteSceneData. configNum:${configNum}`);
    ContactManager.getInstance().deleteContactDataByModeId(modeId);
    const lastEnableMode =
      SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, NO_SCENE);
    // 如果删除的是上一次开启的模式 则把控制中心一级页面重置初始态
    if (lastEnableMode === modeId) {
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.LAST_INTELLIGENT_SCENE_ID, NO_SCENE);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.OPERATE_SCENE_CHANGE, NO_SCENE);
    }
    return configNum;
  }

  /**
   * 更新EnableState类型的ConfigData
   *
   * @param modeId 模式id
   * @param configType 配置类型
   * @param enableState 该类型的数据
   * @return 成功:返回更新或者插入的configId 失败:返回空字串
   */
  public static async insertEnableStateConfigData(modeId: string, configType: ConfigType,
    enableState: EnableState): Promise<string> {
    LogUtil.showInfo(TAG, 'insertEnableStateConfigData.');
    let config: ConfigData = {
      configId: ModeUtil.generateConfigId(modeId, configType),
      modeId: modeId,
      configType: configType,
      configValue: JSON.stringify(enableState),
    };
    return await ConfigDataManager.getInstance().insertConfigData(config);
  }

  /**
   * 更新EnableState类型的ConfigData
   *
   * @param modeId 模式id
   * @param configType 配置类型
   * @param enableState 该类型的数据
   * @return 成功:返回更新或者插入的configId 失败:返回空字串
   */
  public static async updateEnableStateConfigData(modeId: string, configType: ConfigType,
    enableState: EnableState): Promise<string> {
    LogUtil.showInfo(TAG, 'updateEnableStateConfigData.');
    return await ConfigDataManager.getInstance()
      .updateConfigValue(ModeUtil.generateConfigId(modeId, configType), JsonUtil.stringify(enableState));
  }

  /**
   * 设置情景模式高阶功能使用标记位
   */
  public static setIntelligentUsedState() {
    const intelligentSceneUsed: boolean =
      SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.IS_INTELLIGENT_SCENE_USED, '0') === '1';
    if (!intelligentSceneUsed) {
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.IS_INTELLIGENT_SCENE_USED, '1');
    }
  }
}