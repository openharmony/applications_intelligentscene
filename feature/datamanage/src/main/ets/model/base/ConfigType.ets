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
 * 情景模式配置数据类型
 */
export enum ConfigType {
  /**
   * 非法type，数据初始化无法获取到type时使用
   */
  INVALID_TYPE = -1,
  /**
   * 当前已开启的模式, 用于云同步
   */
  CURRENT_OPENED_MODE = 1,

  /**
   * 触发条件-时间
   */
  TRIGGER_CONDITION_TIME = 3,

  /**
   * 触发条件-APP启动
   */
  TRIGGER_CONDITION_APP = 5,

  /**
   * 来电免打扰策略
   */
  CALL_NOT_DISTURB_POLICY = 6,

  /**
   * 重复来电响铃开关
   */
  REPEATED_CALL_RING_SWITCH = 7,

  /**
   * 来电拒接开关
   */
  CALL_REJECT_SWITCH = 8,

  /**
   * 来电智能代接开关
   */
  CALL_INTELLIGENT_ANSWER_SWITCH = 9,

  /**
   * 通知免打扰策略
   */
  NOTIFICATION_NOT_DISTURB_POLICY = 10,

  /**
   * 智能体验开关
   */
  INTELLIGENT_EXPERIENCE_SWITCH = 11,

  /**
   * 提醒方式开关
   */
  REMINDER_TYPE_SWITCH = 12,

  /**
   * 关联系统功能-深色模式
   */
  SYSTEM_SETTINGS_DARK_MODE = 13,

  /**
   * 关联系统功能-护眼模式
   */
  SYSTEM_SETTINGS_EYE_PROTECT_MODE = 14,

  /**
   * 关联系统功能-省电模式
   */
  SYSTEM_SETTINGS_POWER_SAVE_MODE = 15,

  /**
   * 控制中心临时时间触发条件
   */
  TEMPORARY_TIME_CONDITION = 16,

  /**
   * 法定节假日信息
   */
  HOLIDAY_INFO = 17,

  /**
   * 关联系统功能-智能路况
   */
  SMART_ROAD_CONDITIONS = 19,

  /**
   * 关联系统功能-通话自动免提
   */
  AUTO_HANDS_FREE_CALL = 20,

  /**
   * 关联系统功能-声音提醒增强
   */
  SYSTEM_SETTINGS_HIGH_VOLUME = 21,

  /**
   * 关联系统功能-清晰播报
   */
  CLEAR_BROADCASTING = 22,

  /**
   * 关联系统功能-屏幕智能高亮模式
   */
  SYSTEM_SCREEN_SMART_HIGHLIGHTING = 23,

  /**
   * 关联系统功能-自动熄屏延长
   */
  SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT = 24,
  /**
   * 当前已开启的模式信息，保存状态用于穿戴同步，存储在EL1分区
   */
  CURRENT_OPENED_MODE_EL1 = 25,

  /**
   * 重要信息提醒
   */
  IMPORTANT_MESSAGE_REMINDER = 27,
}