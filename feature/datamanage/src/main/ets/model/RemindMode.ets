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
 * 提醒方式数据
 */
export interface RemindMode {
  followSystem: boolean;
  ringMode: RingMode;
  ringVibrate: boolean;
}

/**
 * 声音模式
 */
export enum RingMode {
  /**
   * 响铃
   */
  RINGER_MODE_RINGING = 1,
  /**
   * 震动
   */
  RINGER_MODE_VIBRATION = 2,
  /**
   * 静音
   */
  RINGER_MODE_MUTE = 3,
}