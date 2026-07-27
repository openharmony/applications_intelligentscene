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

import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { RawFileUtil } from '@ohos/scene.common/src/main/ets/utils/RawFileUtil';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { DefaultModeConfigData, ModeConfigData, ModeDetailConfig } from './model/model/DefaultModeConfigData';

const DEFAULT_DATA_JSON_PATH: string = 'rawfile/phone/defaultSceneConfigData.json';

const TAG: string = 'ModeDefaultDataManager:';

/**
 * 本地模式默认数据管理类
 */
export class ModeDefaultDataManager {
  private static instance?: ModeDefaultDataManager;
  private defaultModeConfigData?: DefaultModeConfigData;

  static getInstance(): ModeDefaultDataManager {
    if (!ModeDefaultDataManager.instance) {
      ModeDefaultDataManager.instance = new ModeDefaultDataManager();
    }
    return ModeDefaultDataManager.instance;
  }

  /**
   * 获取所有模式默认数据
   */
  private async getAllModeDefaultData(): Promise<DefaultModeConfigData | undefined> {
    if (!this.defaultModeConfigData) {
      this.defaultModeConfigData = await this.parseJsonData();
    }
    return this.defaultModeConfigData;
  }

  /**
   * 获取指定模式默认数据
   */
  public async getModeDefaultDataByModeId(modeId: string): Promise<ModeConfigData | undefined> {
    const allModeDefaultData: DefaultModeConfigData | undefined = await this.getAllModeDefaultData();
    if (!allModeDefaultData) {
      LogUtil.showError(TAG, 'getModeDefaultDataByModeId. allModeDefaultData is empty.');
      return undefined;
    }
    return allModeDefaultData.modeDataList.find((it) => it.modeId === modeId);
  }

  /**
   * 获取指定模式默认config数据
   */
  public async getModeDefaultConfigDataByModeId(modeId: string): Promise<ConfigData[]> {
    // 如果是自定义modeId 需要转成 -1 去找配置数据
    const templateModeId: string = ModeUtil.isCustomMode(modeId) ? INVALID_MODE_ID : modeId;
    const modeDefaultData: ModeConfigData | undefined = await this.getModeDefaultDataByModeId(templateModeId);
    if (!modeDefaultData) {
      LogUtil.showError(TAG, 'getModeDefaultConfigDataByModeId. modeDefaultData is empty.');
      return [];
    }
    const configDataArr: ConfigData[] = modeDefaultData.configs.map((it) => {
      // 返回的时候 需要再转回实际的modeId
      const configData: ConfigData = {
        configId: it.configId,
        modeId: modeId,
        configType: it.configType,
        configValue: JsonUtil.stringify(it.configValue),
      }
      return configData;
    })
    return configDataArr;
  }

  /**
   * 解析本地模式初始数据JSON
   */
  private async parseJsonData(): Promise<DefaultModeConfigData | undefined> {
    const context: Context | undefined = AbilityContextManager.getContext();
    if (!context) {
      LogUtil.showError(TAG, 'parseJsonData. context is empty.');
      return;
    }
    try {
      LogUtil.showInfo(TAG, 'parseJsonData start.');
      const rawContent: string = await RawFileUtil.getStringByFile(context.resourceManager, DEFAULT_DATA_JSON_PATH);
      const configData: DefaultModeConfigData = JSON.parse(rawContent);
      LogUtil.showInfo(TAG, 'parseJsonData end.');
      return configData;
    } catch (err) {
      LogUtil.showError(TAG, `parseJsonData catch err. code:${err?.code} message:${err?.message}`);
      return undefined;
    }
  }
}