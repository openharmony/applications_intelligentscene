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

import { DataVerify } from '../common/DataVerify';
import { EventBus } from '../common/EventBus';
import { ItemResultType, SettingDialogModel, SettingSelectMenu } from './SettingItemModel';

export enum SettingStateType {
  // item状态类型
  STATE_TYPE_ITEM_ICON = 1,
  STATE_TYPE_ITEM_TITLE = 2,
  STATE_TYPE_ITEM_DESP = 3,
  STATE_TYPE_ITEM_RESULT = 4,
  STATE_TYPE_ITEM_SELECTED = 5,
  STATE_TYPE_ITEM_DIALOG = 6,
  STATE_TYPE_ITEM_SHEET = 7,
  STATE_TYPE_ITEM_POS = 8,
  STATE_TYPE_ITEM_ENABLED = 9,
  STATE_TYPE_ITEM_MENU = 10,
  STATE_TYPE_ITEM_VISIBLE = 11,
  STATE_TYPE_ITEM_IS_GROUP_START = 12,

  // group状态类型
  STATE_TYPE_GROUP_VISIBLE = 100,
  STATE_TYPE_STANDARD_GROUP_ITEMS_CHANGE = 101,
  STATE_TYPE_GROUP_FOOTER_VISIBLE = 104,
  STATE_TYPE_GROUP_FOOTER_CONTENT = 105,

  // page状态类型
  STATE_TYPE_PAGE_TITLE = 1000,
  // 滑动到顶部
  STATE_TYPE_PAGE_SCROLL_TO_TOP = 1001,
}

export interface SettingBaseState {
}

// icon可更新内容
export interface SettingIconState extends SettingBaseState {
  icon: ResourceStr;
}

// text可更新内容
export interface SettingTextState extends SettingBaseState {
  content?: ResourceStr;
  fontColor?: ResourceColor;
}

// toggle状态变化
export interface SettingToggleState extends SettingBaseState {
  state: boolean;
  enabled?: boolean;
  onAllowChanged?: (isOn: boolean) => boolean;
}

// radio状态变化
export interface SettingRadioState extends SettingBaseState {
  checked: boolean;
}

// result状态变化
export interface SettingResultState extends SettingBaseState {
  type: ItemResultType;
  result: SettingTextState | SettingIconState | SettingToggleState | SettingRadioState;
}

export interface SettingCompState extends SettingBaseState {
  state: boolean;
}

export interface SettingModalState extends SettingBaseState {
  state?: boolean;
  sheetHeight?: SheetSize | Length;
  sheetDetents?: [(SheetSize | Length), (SheetSize | Length)?, (SheetSize | Length)?];
}

// 通用content状态变化
export interface SettingContentState extends SettingBaseState {
  content: ResourceStr;
}

// 外部通知进行弹框
export interface SettingDialogState extends SettingBaseState, SettingDialogModel {
}

// 外部更新菜单项
export interface SettingSelectMenuState extends SettingBaseState, SettingSelectMenu {
}

// 标准group item变化接口，仅视图变化，group配置不会变
export interface SettingStandardGroupItemsChange extends SettingBaseState {
  // true: 删除; false: 添加
  deleted: boolean;
  itemIds: string[];
}

// 通过组件ID更新组件状态，没有组件上下文情况使用；如果已知组件上下文，直接调用onItemEvent更新组件状态
export function notifyCompStateChange(compId: string, states: Map<SettingStateType, SettingBaseState>): boolean {
  if (!DataVerify.checkStr(compId) || states.size === 0) {
    return false;
  }
  EventBus.getInstance().emit(compId, states);
  return true;
}