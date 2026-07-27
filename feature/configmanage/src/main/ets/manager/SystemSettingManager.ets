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

import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigData, SettingsLinkageState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { BaseModeConfig } from '@ohos/scene.modeconfig/src/main/ets/adapter/BaseModeConfig';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';

const TAG: string = 'SystemSettingManager:';

/**
 * 关联系统功能数据管理类
 */
export class SystemSettingManager {
  /**
   * 根据配置类型获取关联系统配置项数据
   *
   * @param modeId 模式ID
   * @param configType 配置类型
   * @returns SettingsLinkageState枚举，查询失败返回不关联
   */
  public async getSystemSettingByType(modeId: string, configType: number): Promise<SettingsLinkageState> {
    const configDataManager: ConfigDataManager = ModeConfigAdapter.getInstance().getConfigDataManager(modeId);
    let configs: ConfigData[] = await configDataManager.queryConfigByModeAndType(modeId, configType);
    if (configs?.length === 1) {
      let configValue = JSON.parse(configs[0].configValue) as SettingsLinkageState;
      return configValue;
    }
    LogUtil.showInfo(TAG, 'getSystemSettingByType failed');
    return SettingsLinkageState.NOT_LINK;
  }

  /**
   * 插入SettingsLinkageState类型的ConfigData
   *
   * @param modeId 模式id
   * @param configType 配置类型
   * @param state 该类型的数据
   * @return 成功:返回更新或者插入的configId 失败:返回空字串
   */
  public async insertSystemSettingByType(modeId: string, configType: ConfigType,
    state: SettingsLinkageState): Promise<string> {
    LogUtil.showInfo(TAG, 'insertSystemSettingByType.');
    let config: ConfigData = {
      configId: '',
      modeId: modeId,
      configType: configType,
      configValue: '' + state,
    };
    return await ModeConfigAdapter.getInstance().insertConfigData(modeId, config);
  }

  /**
   * 更新SettingsLinkageState类型的ConfigData
   *
   * @param modeId 模式id
   * @param configType 配置类型
   * @param state 该类型的数据
   * @return 成功:返回更新或者插入的configId 失败:返回空字串
   */
  public async updateSystemSettingByType(modeId: string, configType: ConfigType,
    state: SettingsLinkageState): Promise<string> {
    LogUtil.showInfo(TAG, 'updateSystemSettingByType.');
    let config: ConfigData = {
      configId: ModeUtil.generateConfigId(modeId, configType),
      modeId: modeId,
      configType: configType,
      configValue: '' + state,
    };
    return await ModeConfigAdapter.getInstance().updateConfigData(modeId, config);
  }
}

export default new SystemSettingManager();