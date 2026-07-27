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

import { AppData } from './AppData';
import { ConfigType } from './base/ConfigType';

/**
 * 开启方式-触发条件数据基础类
 */
export interface BaseCondition {
  configId: string,
  configType: ConfigType;
  enable: boolean;
}

/**
 * 定时条件数据
 */
export interface TimeCondition extends BaseCondition {
  loopType: LoopType;
  loopDays: string;
  timeStart: string;
  timeEnd: string;
}

/**
 * 应用条件数据
 */
export interface AppCondition extends BaseCondition {
  appConditionList: AppData[];
}

export enum LoopType {
  ONE_TIME = 1,
  EVERY_DAY = 2,
  EVERY_WEEK = 3,
  WORKDAY = 4,
  HOLIDAY = 5
}