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

// 情景模式根路由
export const BASE_ROUTER = 'IntelligentScene';

export enum NavEntryKey {
  CLOUD_DRIVE_ENTRY = 'cloud_drive_entry',
  INTELLIGENT_SCENE_HOME_ENTRY = 'intelligent_scene_home_entry',
  NOT_DISTURB_ENTRY = 'not_disturb_entry',
  APPLICATION_ENTRY = 'application_entry',
  TIME_PERIOD_ENTRY = 'time_period_entry',
  INCOMING_CALL_ENTRY = 'incoming_call_entry',
  LEARNING_PLAN_ENTRY = 'learning_plan_entry',
  SPECIAL_SETTING_ENTRY = 'special_setting_page',
  EMERGENCY_INFO_ENTRY = 'emergency_info_page',
  INTELLIGENT_SERVICE_ENTRY = 'intelligent_service_entry',
}

export enum ModalSheetKey {
  MODE_GUIDE_SHEET = 'mode_guide_sheet',
  ADD_MODE_SHEET = 'add_mode_sheet',
  EDIT_MODE_SHEET = 'edit_mode_sheet',
  APP_AND_META_SERVICES_SHEET = 'app_and_meta_services_sheet',
  TIMED_SHEET = 'timed_sheet',
  APPLICATION_SHEET = 'application_sheet',
  LOCATION_SHEET = 'location_sheet',
  LOCATION_DETAIL_SHEET = 'location_detail_sheet',
  GAO_DE_GUIDE_SHEET = 'gao_de_guide_sheet',
  CALENDAR_SHEET = 'calendar_sheet',
}

// 一级菜单（有顺序）
export const PHONE_SETTING_HOME_MENU_KEYS = new Set(['not_disturb_entry']);