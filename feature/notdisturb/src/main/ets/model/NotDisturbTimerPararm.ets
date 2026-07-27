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

export class NotDisturbTimerPararm {
  //timer 的id
  public id: number = 0;
  public startTime: string = '';
  public endTime: string = '';
  public repeat: string = '';
  public isOpen: boolean = false;
  public repeatText?: ResourceStr = ''; //重复类型展示的文字
  // 重复类型
  public repeatType: number = 0; // 0 : 单次； 1：自定义
  public skipEndTime: number = 0; // 是否跳过本次，非0则跳过，保存需要跳过的时间段的endtime
  public onceType?: PresetOnceType;
}

export enum NotDisturbTimerRepeatType {
  ONES = 0, // 只响一次
  EVERY_WEEK = 1, // 自定义响铃
}

export enum PresetOnceType {
  DEFAULT = -1, // 默认值
  ONE_HOUR = 0, // 一小时
  TWO_HOUR = 1, // 二小时
  TONIGHT = 2 // 至今晚
}

/**
 * 小艺帮接 自定义场景卡片数据类型
 * 目前数据结构是实际数据的子集 以小艺那边为准
 */
export interface CustomSceneRuleBaseData {
  // 卡片id
  scenarioId: string;

  // 是否打开
  isChecked: boolean;
}