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

export enum FactorType {
  USER = 0,
  SYNC = 1,
  AUTO = 2,
  WEARABLE_SYNC = 3,
  RECOMMENDATION = 4,
  WEARABLE_USER = 5,
}

export enum FactorTypeValue {
  MANUAL_ON = 'MANUAL_ON',
  MANUAL_OFF = 'MANUAL_OFF',
  AUTO_ON = 'AUTO_ON',
  AUTO_OFF = 'AUTO_OFF'
}

/**
 * 模式状态变化来源
 */
export enum EffectiveSourceType {
  INTELLIGENT_SCENE_HOME = 1,
  CONTROL_CENTER = 2,
  AUTO_LOCATION = 3,
  AUTO_APPLICATION = 4,
  AUTO_TIMER = 5,
  CLOUD_SYNC = 6,
  LOG_OUT_HW_ACCOUNT = 7,
  // 语音助手
  INTENT = 9,
  // 穿戴同步
  WEARABLE_SYNC = 10,
  // 卡片
  FORM = 12,
}