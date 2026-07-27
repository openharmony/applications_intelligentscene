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

/**
 * 情景模式配置数据
 */
export interface ConfigData {
  /**
   * modeId_configType_timestamp
   */
  configId: string;
  modeId: string;
  configType: number;
  configValue: string;
  updateTime?: number;
  createTime?: number;
}

/**
 * 当前开启的模式信息,ConfigType.CURRENT_OPENED_MODE对应的configValue
 */
export interface CurrentOpenedMode {
  /**
   * 开启的模式id，模式关闭:'0'
   */
  modeId: string;
  /**
   * 模式开启类型，对应FactorType枚举值
   */
  openType: number;

  /**
   * 导致模式自动开启或关闭的条件configId, 如定时开启免打扰：1_3_xx；非自动开启为空，通过openType区分类型
   */
  effectiveConfigId?: string;
}

export interface LocationTriggerDevice {
  deviceId: string;
  deviceName: string;
}

export interface EnableState {
  enable: boolean;
}

export enum SettingsLinkageState {
  /**
   * 不关联
   */
  NOT_LINK = 1,
  /**
   * 关联开启
   */
  LINK_ENABLE = 2,
  /**
   * 关联关闭
   */
  LINK_DISABLE = 3
}


