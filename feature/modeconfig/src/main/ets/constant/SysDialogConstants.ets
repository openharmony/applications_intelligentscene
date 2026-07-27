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

import { SysDialogWant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';

/**
 * 情景模式手动开启模式确认系统弹框want参数
 */
export const SYSTEM_DIALOG_WANT: SysDialogWant = {
  bundleName: 'com.ohos.intelligentscene',
  abilityName: 'ModeEnableConfirmDialogUIExtAbility',
  sysDialogZOrder: 2,
}

/**
 * 手动操作类型
 */
export enum OpenType {
  TURN_ON_NOW = '1',
  TURN_ON_ONE_HOUR = '2',
  TURN_ON_TWO_HOUR = '3',
  TURN_ON_TONIGHT = '4',
}

/**
 * 弹框组件退场动画时�?
 */
export const DIALOG_EXIT_ANIMATION_TIME: number = 225;