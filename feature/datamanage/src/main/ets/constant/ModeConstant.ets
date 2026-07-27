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

import { ModeType } from '../model/base/ModeModel';

/**
 * 操作类型枚举
 */
export enum OperateType {
  ADD = 1,
  EDIT,
};

/**
 * 默认颜色数据
 */
export const COLOR_ARR: string[] = [
  '#542BD7', '#8981F7', '#8A38C6', '#46B1E3', '#61CFBE', '#64BB5C',
  '#E84026', '#E64566', '#E87361', '#FF8A12', '#F9A01E', '#F7CE00',
];

/**
 * 默认颜色文本
 */
export const COLOR_MAP: Map<string, Resource> = new Map([
  [COLOR_ARR[0], $r('app.string.color_purple')],
  [COLOR_ARR[1], $r('app.string.color_purple')],
  [COLOR_ARR[2], $r('app.string.color_purple')],
  [COLOR_ARR[3], $r('app.string.color_blue')],
  [COLOR_ARR[4], $r('app.string.color_cyan_blue')],
  [COLOR_ARR[5], $r('app.string.color_green')],
  [COLOR_ARR[6], $r('app.string.color_red')],
  [COLOR_ARR[7], $r('app.string.color_red')],
  [COLOR_ARR[8], $r('app.string.color_red')],
  [COLOR_ARR[9], $r('app.string.color_yellow')],
  [COLOR_ARR[10], $r('app.string.color_yellow')],
  [COLOR_ARR[11], $r('app.string.color_yellow')],
]);

/**
 * 默认Symbol图标数据
 */
export const SYMBOL_CODE_ARR: string[] = [
  'ebook',
  'cart_fill',
  'case_fill',
  'music_fill',
  'paintpalette_fill',
  'fork_knife_fill',
  'gas_fee_fill',
  'graduationcap_fill',
  'gift_fill',
  'average_step_frequency_fill',
  'doc_text_fill',
  'fast_fill',
  'person_fill',
  'purification_fill',
  'pawprint_fill',
  'house_fill',
  'company_fill',
  'monorail_fill',
  'creditcard_fill',
  'spanner',
  'spa',
  'snowflake_circle_fill',
  'heart_fill',
  'lightbulb_fill',
  'triangleshape_fill',
];

export const SYMBOL_CODE_MAP: Map<string, Resource> = new Map([
  [SYMBOL_CODE_ARR[0], $r('app.string.icon_read')],
  [SYMBOL_CODE_ARR[1], $r('app.string.icon_shopping')],
  [SYMBOL_CODE_ARR[2], $r('app.string.icon_office')],
  [SYMBOL_CODE_ARR[3], $r('app.string.icon_music')],
  [SYMBOL_CODE_ARR[4], $r('app.string.icon_painting')],
  [SYMBOL_CODE_ARR[5], $r('app.string.icon_dining')],
  [SYMBOL_CODE_ARR[6], $r('app.string.icon_flame')],
  [SYMBOL_CODE_ARR[7], $r('app.string.icon_research')],
  [SYMBOL_CODE_ARR[8], $r('app.string.icon_gift')],
  [SYMBOL_CODE_ARR[9], $r('app.string.icon_foot')],
  [SYMBOL_CODE_ARR[10], $r('app.string.icon_document')],
  [SYMBOL_CODE_ARR[11], $r('app.string.icon_rocket')],
  [SYMBOL_CODE_ARR[12], $r('app.string.icon_user')],
  [SYMBOL_CODE_ARR[13], $r('app.string.icon_leaf')],
  [SYMBOL_CODE_ARR[14], $r('app.string.icon_pet')],
  [SYMBOL_CODE_ARR[15], $r('app.string.icon_home')],
  [SYMBOL_CODE_ARR[16], $r('app.string.icon_company')],
  [SYMBOL_CODE_ARR[17], $r('app.string.icon_high_speed_rail')],
  [SYMBOL_CODE_ARR[18], $r('app.string.icon_card')],
  [SYMBOL_CODE_ARR[19], $r('app.string.icon_repair')],
  [SYMBOL_CODE_ARR[20], $r('app.string.icon_lotus')],
  [SYMBOL_CODE_ARR[21], $r('app.string.icon_cold')],
  [SYMBOL_CODE_ARR[22], $r('app.string.icon_love')],
  [SYMBOL_CODE_ARR[23], $r('app.string.icon_inspiration')],
  [SYMBOL_CODE_ARR[24], $r('app.string.icon_triangle')],
  ['computer_fill', $r('app.string.icon_work')],
  ['bookshelf', $r('app.string.icon_study')],
]);

export const PRECAST_MODE_STRING_ID_MAP: Map<string, string> = new Map([
  [ModeType.DND_MODE, '$string:DND_mode'],
  [ModeType.SLEEP_MODE, '$string:sleep_mode'],
  [ModeType.LEARNING_MODE, '$string:learning_mode'],
  [ModeType.WORKING_MODE, '$string:working_mode'],
  [ModeType.SPORT_MODE, '$string:sport_mode'],
  [ModeType.GAME_MODE, '$string:game_mode'],
  [ModeType.ENTERTAINMENT_MODE, '$string:entertainment_mode'],
  [ModeType.DRIVING_MODE, '$string:driving_mode'],
]);

export const PRECAST_MODE_ROUND_ICON_MAP: Map<string, string> = new Map([
  [ModeType.DND_MODE, 'dnd_mode_round'],
  [ModeType.SLEEP_MODE, 'sleep_mode_round'],
  [ModeType.LEARNING_MODE, 'learning_mode_round'],
  [ModeType.WORKING_MODE, 'working_mode_round'],
  [ModeType.SPORT_MODE, 'sport_mode_round'],
  [ModeType.GAME_MODE, 'game_mode_round'],
  [ModeType.ENTERTAINMENT_MODE, 'entertainment_mode_round'],
  [ModeType.DRIVING_MODE, 'driving_mode_round'],
]);