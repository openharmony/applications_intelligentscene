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

export class IntentConstant {
  // 1、禁止所有应用，2、允许所有应用，3、仅允许指定应用
  public static readonly APP_ALLOW_POLICY: number[] = [1, 2, 3];
  // 0、重复来电开关/自动接听开关 关闭，1、重复来电开关/自动接听开关 打开
  public static readonly SWITCH_VALUE: number[] = [0, 1];
  // 1、不关联 深色/护眼 模式，2、开启 深色/护眼 模式，3、关闭 深色/护眼 模式
  public static readonly SYSTEM_MODE_VALUE: number[] = [1, 2, 3];

  public static readonly INTELLIGENT_STATE_SWITCH: number = 1;
  public static readonly REPEAT_CALL_SWITCH: number = 2;
  public static readonly AUTO_ANSWER_SWITCH: number = 3;
  // 重要信息提醒开关
  public static readonly IMPORTANT_MESSAGE_SWITCH: number = 5;

  public static readonly SYSTEM_DARK_MODE: number = 1;
  public static readonly SYSTEM_EYE_PROTECT_MODE: number = 2;

  public static readonly MAX_CONDITION_LENGTH: number = 15;
  public static readonly CREATE_CUSTOM_MODE_ICON: string = 'person_fill';

  public static readonly INTELLIGENT_EXPERIENCE_ENABLE: string = '1';
  public static readonly INTELLIGENT_EXPERIENCE_DISABLE: string = '0';
  public static readonly INTELLIGENT_DEFAULT_MODE_ID: string = '1';
  public static readonly REFRESH_CONTACT: string = 'refresh_contact';
  public static readonly REFRESH_INTELLIGENT: string = 'refresh_intelligent';
  public static readonly NOTIFICATION: string = 'notification';
  public static readonly CONTACT_CONDITION_LENGTH: number = 4;
  public static readonly INTELLIGENT_CONDITION_LENGTH: number = 4;
  public static readonly TYPE_INDEX: number = 2;
  public static readonly MODE_ID_INDEX: number = 3;
  public static readonly CONTACT_POLICY_INDEX: number = 4;
  public static readonly INTELLIGENT_MODE_ID_INDEX: number = 2;
  public static readonly INTELLIGENT_SWITCH_STATE_INDEX: number = 3;
  public static readonly CONTACT_POLICY: string = 'policy';
  public static readonly CONTACT_REPEAT_CALL: string = 'repeatCall';
  public static readonly CONTACT_AUTO_ANSWER: string = 'autoAnswer';
  public static readonly CONTACT_POLICY_STRING: string = 'contact_policy_';
  public static readonly CONTACT_REPEAT_CALL_STRING: string = 'contact_repeatCall_';
  public static readonly CONTACT_AUTO_ANSWER_STRING: string = 'contact_autoAnswer_';
  public static readonly AUTO_ANSWER_ENABLE: string = 'true';
  public static readonly AUTO_ANSWER_DISABLE: string = 'false';
}

export enum AppAllowPolicy {
  FORBIDDEN_ALL_APP_POLICY = 1,
  ALLOW_ALL_APP_POLICY = 2,
  ALLOW_SPECIFY_APP_POLICY = 3,
}