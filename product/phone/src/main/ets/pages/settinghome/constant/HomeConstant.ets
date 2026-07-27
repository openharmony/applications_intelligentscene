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

import { NavEntryKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { SettingsLinkageState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';

// 模式卡片预置模式对应提示语
export const MODE_HINT_MAP: Map<ModeType, Resource> = new Map<ModeType, Resource>([
  [ModeType.DND_MODE, $r('app.string.DND_mode_hint')],
  [ModeType.SLEEP_MODE, $r('app.string.sleep_mode_hint')],
  [ModeType.LEARNING_MODE, $r('app.string.learning_mode_hint')],
  [ModeType.WORKING_MODE, $r('app.string.working_mode_hint')],
  [ModeType.SPORT_MODE, $r('app.string.sport_mode_hint')],
  [ModeType.GAME_MODE, $r('app.string.game_mode_hint')],
  [ModeType.ENTERTAINMENT_MODE, $r('app.string.entertainment_mode_hint')],
  [ModeType.DRIVING_MODE, $r('app.string.driving_mode_hint')],
]);

// 下拉控件选项value数组
export const SELECT_VALUE_ARR: SettingsLinkageState[] = [
  SettingsLinkageState.NOT_LINK,
  SettingsLinkageState.LINK_ENABLE,
  SettingsLinkageState.LINK_DISABLE,
]

// 下拉控件选项映射字串
export const SELECT_RESOURCE_MAP: Map<SettingsLinkageState, Resource> = new Map<SettingsLinkageState, Resource>([
  [SettingsLinkageState.NOT_LINK, $r('app.string.associated_system_noRelated')],
  [SettingsLinkageState.LINK_ENABLE, $r('app.string.associated_system_open')],
  [SettingsLinkageState.LINK_DISABLE, $r('app.string.associated_system_close')],
]);

// 关联系统功能的ConfigType数组（护眼模式入口暂隐藏）
export const SYSTEM_FUNCTION_CONFIG_TYPE_ARR: ConfigType[] = [
  ConfigType.SYSTEM_SETTINGS_DARK_MODE,
  // ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
]

// 关联系统功能的ConfigType映射字串
export const SYSTEM_FUNCTION_RESOURCE_MAP: Map<ConfigType, Resource> = new Map<ConfigType, Resource>([
  [ConfigType.SYSTEM_SETTINGS_DARK_MODE, $r('app.string.dark_color_mode')],
  [ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE, $r('app.string.eye_protection_mode')],
  [ConfigType.SYSTEM_SETTINGS_POWER_SAVE_MODE, $r('app.string.power_save_mode')],
]);

// 定时重复类型
export const LOOP_TYPE: LoopType[] = [
  LoopType.ONE_TIME,
  LoopType.EVERY_DAY,
  LoopType.EVERY_WEEK,
  LoopType.WORKDAY,
  LoopType.HOLIDAY
];

// 定时重复类型字串
export const LOOP_TYPE_CONTENT: ResourceStr[] = [
  $r('app.string.once'),
  $r('app.string.every_day'),
  $r('app.string.every_week'),
  $r('app.string.statutory_workdays'),
  $r('app.string.statutory_holidays')
]

export const OPEN_LOCATION_DIALOG_DELAY: number = 500;

// 搜索跳转白名单
export const REDIRECT_WHITE_LIST: string[] = [
  // 联系人策略界面
  NavEntryKey.INCOMING_CALL_ENTRY,
];