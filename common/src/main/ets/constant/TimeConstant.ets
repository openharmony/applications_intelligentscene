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

import Intl from '@ohos.intl';

/**
 * 时间日期相关值常量类
 * @since 2025-7-11
 */
export class TimeConstant {
  /**
   * 专门用于传参的 timeFormat 对象 只会转换成数字的24小时制
   */
  public static zhTimeFormat: Intl.DateTimeFormat = new Intl.DateTimeFormat(
    'zh-Hans-CN',
    {
      timeStyle: 'short',
      hourCycle: 'h24',
    },
  );
  public static readonly ONE_HOUR_MS_UNIT: number = 1000 * 60 * 60 * 1;
  public static readonly TWO_HOUR_MS_UNIT: number = 1000 * 60 * 60 * 2;
  public static readonly ONE_MINUTE_MS_UNIT: number = 1000 * 60;
  public static readonly ONE_HOUR_MINUTE_UNIT: number = 60;
  public static readonly MAX_TIME: number = 99;
  public static readonly ONE_MINUTE_SECOND_UNIT: number = 60;
  public static readonly ONE_SECOND_MS_UNIT: number = 1000;
}