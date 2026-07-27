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

import { HomeGroupId } from '../constant/HomeCompIdConstant';
import { GuideCardConfig, SpecialSettingConfig } from '../model/ModeConfigModel';

/**
 * 基础模式 (自定义模式)
 */
export class BaseModeConfig {
  /**
   * 模式开启时是否展示其他模式
   */
  public readonly isShowOtherMode: boolean = true;
  /**
   * 模式是否支持小艺语音操作
   */
  public readonly isSupportAgent: boolean = true;
  /**
   * 模式开启时是否支持开启勿扰能力
   */
  public readonly isSupportNotDisturb: boolean = true;
  /**
   * 模式是否支持云同步
   */
  public readonly isSupportCloudSync: boolean = true;
  /**
   * 模式支持的groupIdSet
   */
  public readonly supportGroupIdSet: Set<HomeGroupId> = new Set([
    HomeGroupId.ENABLE_WAY,
    HomeGroupId.ALLOWED_DISTURB,
    HomeGroupId.SYSTEM_FUNCTION,
    HomeGroupId.INTELLIGENT_EXPERIENCE,
    HomeGroupId.IMPORTANT_MESSAGE,
  ]);

  /**
   * 获取模式引导卡片参数
   *
   * 如果有多个卡片，则关闭前一张退出情景模式重进后再加载下一张
   */
  public getGuideCardConfigs(): GuideCardConfig[] {
    return [];
  }

  /**
   * 获取模式特殊配置信息
   *
   * @returns 特殊配置信息
   */
  public getSpecialSettingConfig(): SpecialSettingConfig | undefined {
    return undefined;
  }

  /**
   * 模式开启事件
   */
  public startScene(): void {
  }

  /**
   * 模式关闭事件
   */
  public stopScene(): void {
  }
}