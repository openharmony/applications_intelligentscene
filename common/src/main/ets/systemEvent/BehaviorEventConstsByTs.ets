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

export class HiSysIntelligentSceneEvent {
  public static readonly CREATING_PROFILE: string = 'CREATING_PROFILE';
  public static readonly CHANGE_MODE_NAME: string = 'CHANGE_MODE_NAME';
  public static readonly DELETE_MODE: string = 'DELETE_MODE';
  public static readonly MULTIDEVICE_SWITCH: string = 'MULTIDEVICE_SWITCH';
  public static readonly CURRENT_MODE_DATA: string = 'CURRENT_MODE_DATA';
  public static readonly NOTIFY_LIVE_CHANGE: string = 'NOTIFY_LIVE_CHANGE';
  public static readonly CALL_POLICY_CHANGE: string = 'CALL_POLICY_CHANGE';
  public static readonly MODE_CONTACTS: string = 'MODE_CONTACTS';
  public static readonly RECOMMEND_NOTIFICATION: string = 'RECOMMEND_NOTIFICATION';
  // 语音助手
  public static readonly INTENT: string = 'INTENT_ACTION';
  // 跳转其他应用
  public static readonly ENTER_OTHER_APP: string = 'ENTER_OTHER_APP';
  // 规则下发
  public static readonly PROCESS_RULES_ACTION: string = 'PROCESS_RULES_ACTION';
  // 新增卡片
  public static readonly ADD_CARD_TO_DESKTOP_BY_CLICK_UE: string = 'ADD_CARD_TO_DESKTOP_BY_CLICK_UE';

  public static readonly ADD_SCHEDULE: string = 'ADD_SCHEDULE';
  public static readonly UPDATE_SCHEDULE: string = 'UPDATE_SCHEDULE';
  public static readonly DELETE_SCHEDULE: string = 'DELETE_SCHEDULE';
  public static readonly DISABLE_SCHEDULE: string = 'DISABLE_SCHEDULE';
  public static readonly ENABLE_SCHEDULE: string = 'ENABLE_SCHEDULE';
}

export class HiSysIntelligentSceneErrorEvent {
  public static readonly SENCE_INTERNAL_ERROR: string = 'SENCE_INTERNAL_ERROR';
  public static readonly SENCE_EXTERNAL_ERROR: string = 'SENCE_EXTERNAL_ERROR';
}