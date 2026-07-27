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
 * 定义SettingsData key值常量类
 */
export class SettingsDataKeyConstant {
  public static readonly CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy';

  public static readonly REPEAT_CALLERS_ENABLE: string = 'focus_mode_repeate_callers_enable';

  public static readonly LAST_AUTOMATIC_ANSWERING_ENABLE: string = 'automatic_answering_manual_enable';

  public static readonly NOTIFICATION_POLICY: string = 'notification_policy';

  public static readonly FOCUS_MODE_ENABLED: string = 'focus_mode_enable';

  public static readonly FOCUS_MODE_PROFILE: string = 'focus_mode_profile';

  public static readonly INTELLIGENT_SCENE_ICON: string = 'intelligent_scene_icon';

  public static readonly INTELLIGENT_SCENE_NAME: string = 'intelligent_scene_name';

  public static readonly NOT_DISTURB_SOUND_VIBRATION_WHITE_LIST: string =
    'intelligent_scene_notification_white_list';

  /**
   * 上一次开启的模式id（控制中心一级页面用）
   */
  public static readonly LAST_INTELLIGENT_SCENE_ID: string = 'last_intelligent_scene_id';

  /**
   * 操作模式变化（控制中心一级页面监听用）
   */
  public static readonly OPERATE_SCENE_CHANGE: string = 'operate_scene_change';

  /**
   * 不再提示标记（控制中心确认弹框）
   */
  public static readonly INTELLIGENT_SCENE_ENABLE_REMINDER_FLAG: string = 'intelligent_scene_reminder_flag';

  public static readonly INTELLIGENT_SCENE_DATA: string = 'intelligent_scene_data';

  public static readonly INTELLIGENT_URI: string = 'intelligent_uri';

  public static readonly INTELLIGENT_CONFIG_ID_IN_EFFECT: string = 'config_id_in_effect';

  public static readonly IS_STARTED_IN_LOCK: string = 'is_started_in_lock';

  public static readonly INTELLIGENT_EXPERIENCE: string = 'intelligent_experience';

  public static readonly SETTINGS_WINDOW_MODE: string = 'settings.windowMode';

  public static readonly INTELLIGENT_REFRESH_CONFIG_DATA: string = 'intelligent_refresh_config_data';

  // 意图框架改变模式，刷新主页
  public static readonly INTELLIGENT_REFRESH_MODE: string = 'intelligent_refresh_mode';

  public static readonly DEFAULT_DISPLAY_DPI: string = 'default_display_dpi';

  // 大桌面实况通知内容
  public static readonly INTELLIGENT_SCENE_NTF_DATA: string = 'intelligent_scene_notify_data';

  // 大桌面通知刷新标记位
  public static readonly INTELLIGENT_SCENE_NTF_STATE: string = 'intelligent_scene_notify_state';

  // 情景模式高阶功能使用标记位
  public static readonly IS_INTELLIGENT_SCENE_USED: string = 'is_intelligent_scene_used';

  // 记录设备uiAppearance值是否来自克隆
  public static readonly IS_UI_APPEARANCE_FROM_CLONE: string = 'isUiAppearanceFromClone';

  // 记录情景模式推荐开启通知规则信息
  public static readonly RECOMMEND_NOTIFICATION_OPEN_RULE: string = 'intelligent_scene_recommend_ntf_open_rule';

  // OOBE是否走完标记位
  public static readonly IS_OTA_FINISHED: string = 'is_ota_finished';

  // 记录情景模式克隆时间
  public static readonly INTELLIGENT_SCENE_CLONE_TIME: string = 'intelligent_scene_clone_time';

  // 记录ota流程，ug服务订阅是否处理
  public static readonly IS_UG_SERVICE_OTA_PROCESSED: string = 'isUgServiceOtaProcessed';
}