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
 * 定义config相关值常量类
 * @since 2025-1-22
 */
export class ConfigConstant {
  public static readonly TEMP_TIME_CONDITION_PREFIX: string = 'temp_condition_';
  public static readonly TEMP_TIME_CONDITION_ONE_HOUR: string = 'one_hour';
  public static readonly TEMP_TIME_CONDITION_TWO_HOUR: string = 'two_hour';
  public static readonly TEMP_TIME_CONDITION_TWELVE_HOUR: string = 'twelve_hour';
  public static readonly TEMP_TIME_CONDITION_TO_NIGHT: string = 'to_night';
  public static readonly RULE_NAME_PREFIX = 'rule-';
  public static readonly STATE_NAME_PREFIX = 'state-';
  public static readonly RULE_NAME_SCENE_MANUAL_START = 'manual_on';
  public static readonly RULE_NAME_SCENE_DISABLED = 'off';
  public static readonly RULE_NAME_SUFFIX_LENGTH = 14;
  public static readonly CONST_INTELLIGENT_SCENE_ENABLE: string = 'const.intelligentscene.enable';
  public static readonly ENABLE: string = '1';
  public static readonly DISABLE: string = '0';
  public static readonly TRUE: string = 'true';
  public static readonly FALSE: string = 'false';
}