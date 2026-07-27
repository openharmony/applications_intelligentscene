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

import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { HomeGroupId } from '../constant/HomeCompIdConstant';
import { SleepModeConfig } from '../presetmode/sleepmode/SleepModeConfig';
import { SportModeConfig } from '../presetmode/sportmode/SportModeConfig';
import { BaseModeConfig } from './BaseModeConfig';

// 模式默认配置
const MODE_DEFAULT_CONFIG: BaseModeConfig = new BaseModeConfig();

// 预置模式配置映射
const MODE_CONFIG_MAP: Record<string, BaseModeConfig> = {
  [ModeType.SLEEP_MODE]: new SleepModeConfig(),
  [ModeType.SPORT_MODE]: new SportModeConfig(),
};

const NO_SYNC_CONFIG_MAP : ConfigType[] = [
];

/**
 * 模式配置适配类
 */
export class ModeConfigAdapter {
  public tag: string = 'ModeConfigAdapter:';
  private static singleInstance: ModeConfigAdapter;

  /**
   * 单例
   */
  public static getInstance(): ModeConfigAdapter {
    if (!ModeConfigAdapter.singleInstance) {
      ModeConfigAdapter.singleInstance = new ModeConfigAdapter();
    }
    return ModeConfigAdapter.singleInstance;
  }

  /**
   * 根据modeId获取模式配置类
   */
  public getConfigByModeId(modeId: string): BaseModeConfig {
    return MODE_CONFIG_MAP[modeId] || MODE_DEFAULT_CONFIG;
  }

  /**
   * 根据modeId和groupId判断该group组件是否显示
   *
   * @param modeId 模式ID
   * @param groupId 首页组件groupId
   * @returns boolean
   */
  public getGroupVisible(modeId: string, groupId: HomeGroupId): boolean {
    const modeConfig: BaseModeConfig = this.getConfigByModeId(modeId);
    if (groupId === HomeGroupId.INTELLIGENT_EXPERIENCE) {
      return false;
    }
    return modeConfig.supportGroupIdSet.has(groupId);
  }

  /**
   * 根据modeId查询config信息
   *
   * @param modeId 模式ID
   * @returns config信息
   */
  public async queryConfigByModeAndType(modeId: string): Promise<ConfigData[]> {
    let result: ConfigData[] = [];
    if (CheckEmptyUtils.isEmpty(modeId)) {
      return result;
    }
    const configManager: ConfigDataManager = this.getConfigDataManager(modeId);
    result = await configManager.queryConfigByModeAndType(modeId);
    if (modeId === ModeType.LEARNING_MODE) {
      let resultEl1: ConfigData[] = await El1ConfigDataManager.getInstance().queryConfigByModeAndType(modeId);
      result.push(...resultEl1);
    }
    return result;
  }

  /**
   * 根据modeId查询config信息
   *
   * @param configId config id
   * @returns config信息
   */
  public async queryConfigDataById(configId: string): Promise<ConfigData | undefined> {
    if (CheckEmptyUtils.isEmpty(configId)) {
      return undefined;
    }
    const modeId: string = ModeUtil.getModeIdFromConfigId(configId);
    const configType: ConfigType = ModeUtil.getTypeFromConfigId(configId);
    const configManager: ConfigDataManager = this.getConfigDataManager(modeId, configType);
    const result: ConfigData | undefined = await configManager.queryConfigDataById(configId);
    return result;
  }

  /**
   * 根据modeId插入config信息
   *
   * @param modeId 模式id
   * @param configId config id
   * @returns 插入成功的配置数据configId; 插入失败返回空字符串
   */
  public async insertConfigData(modeId: string, config: ConfigData): Promise<string> {
    if (CheckEmptyUtils.isEmpty(modeId) || CheckEmptyUtils.isEmpty(config)) {
      return '';
    }
    const configManager: ConfigDataManager = this.getConfigDataManager(modeId, config.configType);
    return await configManager.insertConfigData(config);
  }

  /**
   * 根据modeId更新config信息
   *
   * @param modeId 模式id
   * @param configId config id
   * @returns 更新成功返回配置id；更新失败返回空字符串
   */
  public async updateConfigData(modeId: string, config: ConfigData): Promise<string> {
    if (CheckEmptyUtils.isEmpty(modeId) || CheckEmptyUtils.isEmpty(config)) {
      return '';
    }
    const configManager: ConfigDataManager = this.getConfigDataManager(modeId, config.configType);
    return await configManager.updateConfigData(config);
  }

  public getConfigDataManager(modeId: string, configType?: ConfigType): ConfigDataManager {
    const modeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(modeId);
    if (modeConfig.isSupportCloudSync && this.isConfigTypeSupportCloudSync(configType)) {
      return ConfigDataManager.getInstance();
    }
    return El1ConfigDataManager.getInstance();
  }

  public isConfigTypeSupportCloudSync(config?: ConfigType): boolean {
    if(config !== undefined && NO_SYNC_CONFIG_MAP.includes(config)){
      return false;
    }
    return true;
  }

  /**
   * 根据modeId执行开启模式，关闭模式时的操作
   *
   * @param preScene 上个模式的modeId (执行关闭操作)
   * @param nextScene 下个模式的modeId (执行开启操作)
   */
  public onModeToggle(preScene: string, nextScene: string): void {
    const preSceneModeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(preScene);
    const nextSceneModeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(nextScene);
    preSceneModeConfig.stopScene();
    nextSceneModeConfig.startScene();
  }
}