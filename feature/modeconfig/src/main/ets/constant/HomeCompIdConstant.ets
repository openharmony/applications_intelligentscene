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

import { ModalSheetKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';

/**
 * 首页新架构标准组件 pageId
 */
export const HOME_PAGE_ID: string = 'home_standard_page';

/**
 * 首页新架构模态框 groupId
 */
export const HOME_MODAL_GROUP_ID: string = 'modal_group';

export const SLEEP_GUIDE_TIME_STAMP: string = 'sleep_guide_time_stamp';

export const LEARN_GUIDE_TIME_STAMP: string = 'learn_guide_time_stamp';

export const EMERGENCY_GUIDE_TIME_STAMP: string = 'emergency_guide_time_stamp';

export const MODE_GUIDE_KEYS: string[] = [
  SLEEP_GUIDE_TIME_STAMP,
  LEARN_GUIDE_TIME_STAMP,
  EMERGENCY_GUIDE_TIME_STAMP,
];

/**
 * 首页新架构标准组件 groupId
 */
export enum HomeGroupId {
  ENABLE_WAY = 'enable_way_group',
  ALLOWED_DISTURB = 'allowed_disturb_group',
  LEARNING_PLAN = 'learning_plan_group',
  SYSTEM_FUNCTION = 'system_function_group',
  INTELLIGENT_EXPERIENCE = 'intelligent_experience_group',
  SPECIAL_CONFIG = 'special_config_group',
  IMPORTANT_MESSAGE = 'important_message',
}

/**
 * 首页新架构标准组件 itemId
 */
export enum HomeGroupItemId {
  APPLICATION = 'application_item',
  CONTACT = 'contact_item',
  DISABLE_DARK_COLOR_MODE = 'disable_dark_color_mode_item',
  DARK_COLOR_MODE = 'dark_color_mode_item',
  EYE_PROTECTION_MODE = 'eye_protection_mode_item',
  EXTREME_BATTERY_LIFE = 'extreme_battery_life_item',
  AUTO_HANDS_FREE_CALL = 'auto_hands_free_call_item',
  SYSTEM_SETTINGS_HIGH_VOLUME = 'system_settings_high_volume_item',
  CLEAR_BROADCASTING = 'clear_broadcasting_item',
  SYSTEM_SCREEN_SMART_HIGHLIGHTING = 'system_screen_smart_highlighting_item',
  SYSTEM_SETTINGS_SCREEN_OFF_TIMEOUT = 'system_settings_screen_off_timeout_item',
  SMART_ROAD_CONDITIONS = 'smart_road_conditions_item',
}

export class HomeSheetCompId {
  /**
   * 新增模式模态框
   */
  public static readonly ADD_SHEET_COMP_ID = `${HOME_PAGE_ID}.${HOME_MODAL_GROUP_ID}.${ModalSheetKey.ADD_MODE_SHEET}`;
  /**
   * 编辑模式模态框
   */
  public static readonly EDIT_SHEET_COMP_ID = `${HOME_PAGE_ID}.${HOME_MODAL_GROUP_ID}.${ModalSheetKey.EDIT_MODE_SHEET}`;
  /**
   * 引导页模态框
   */
  public static readonly GUIDE_SHEET_COMP_ID =
    `${HOME_PAGE_ID}.${HOME_MODAL_GROUP_ID}.${ModalSheetKey.MODE_GUIDE_SHEET}`;
  /**
   * 情景模式-高德路况提示模态框
   */
  public static readonly GAO_DE_SHEET_COMP_ID =
    `${HOME_PAGE_ID}.${HOME_MODAL_GROUP_ID}.${ModalSheetKey.GAO_DE_GUIDE_SHEET}`;
}