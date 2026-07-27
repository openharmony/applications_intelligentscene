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

import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import {
  ConfigData,
  CurrentOpenedMode
} from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';

/* instrument ignore file */
const TAG: string = 'LocalSceneManager';

/**
 * 本地模式状态数据管理类
 */
export class LocalSceneManager {
  /**
   * 根据配置类型获取本地模式
   *
   * @returns CurrentOpenedMode 当前本地存储的开启模式数据，查询失败返回空
   */
  public static async getLocalScene(): Promise<CurrentOpenedMode | undefined> {
    const config: ConfigData | undefined = await ConfigDataManager.getInstance()
      .queryConfigDataById(`${ConfigType.CURRENT_OPENED_MODE}`);
    if (config) {
      LogUtil.showInfo(TAG, `getLocalScene configValue: ${config.configValue}, updateTime: ${config.updateTime}`);
      return JsonUtil.parse<CurrentOpenedMode>(config.configValue);
    }
    return undefined;
  }

  /**
   * 根据配置类型获取本地模式，同步方法
   *
   * @returns CurrentOpenedMode 当前本地存储的开启模式数据，查询失败返回空
   */
  public static getLocalSceneSync(): CurrentOpenedMode | undefined {
    let configId: string = String(ConfigType.CURRENT_OPENED_MODE);
    let config: ConfigData = ConfigDataManager.getInstance().queryConfigDataByIdSync(configId) as ConfigData;
    if (config) {
      try {
        return JSON.parse(config.configValue) as CurrentOpenedMode;
      } catch (err) {
        LogUtil.showError(TAG, `invalid config ${err?.code} ${err?.message}`);
      }
    }
    return undefined;
  }

  /**
   * 更新本地开启模式数据
   *
   * @param openedMode 即将开启的模式
   * @param preScene 当前开启的模式信息
   * @param sourceType 开启模式的来源，枚举类型EffectiveSourceType，可选参数
   * @param updateTime 更新时间，可选参数
   * @returns 更新成功返回1; 更新失败或未更新返回空
   */
  public static async updateLocalScene(openedMode: CurrentOpenedMode, preScene: string, sourceType?: number,
    updateTime?: number): Promise<string> {
    const config: ConfigData | undefined =
      await ConfigDataManager.getInstance().queryConfigDataById(`${ConfigType.CURRENT_OPENED_MODE}`);
    const newOpenedMode: string = JsonUtil.stringify(openedMode);
    LogUtil.showInfo(TAG,
      `db openState: ${config?.configValue} time: ${config?.updateTime}, new: ${newOpenedMode} time:${updateTime}`);
    if (config?.configValue === newOpenedMode) {
      LogUtil.showInfo(TAG, 'open status no change, no need update');
      return '';
    }
    return await ConfigDataManager.getInstance()
      .updateConfigValue(`${ConfigType.CURRENT_OPENED_MODE}`, newOpenedMode, updateTime);
  }
}