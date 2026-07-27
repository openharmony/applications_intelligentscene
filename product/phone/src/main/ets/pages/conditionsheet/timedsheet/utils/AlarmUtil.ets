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

import common from '@ohos.app.ability.common';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AbilityUtils } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';

// 闹钟相关参数
const ALARM_BUNDLE_NAME: string = 'com.openharmony.ohos.clock';
const ALARM_ABILITY_NAME: string = 'com.openharmony.ohos.clock.phone';
const ALARM_TAB_KEY: string = 'ALARM_CLOCK_TAB';

const TAG: string = 'AlarmUtil:';

/**
 * 闹钟 工具类
 */
export class AlarmUtil {
  /**
   * 跳转闹钟
   */
  static jumpAlarm(): void {
    LogUtil.showInfo(TAG, 'jumpAlarm start.');
    // 打点
    const param: Record<string, Object> = {};
    param.BUNDLE_NAME = ALARM_BUNDLE_NAME;
    param.ABILITY_NAME = ALARM_ABILITY_NAME;
    param.MODE_ID = ModeDetailAdapter.getInstance().getCurrentModeId();
    HiSysEventUtil.reportBehaviorEventByUE(HiSysIntelligentSceneEvent.ENTER_OTHER_APP, param);
    // 跳转
    AbilityUtils.startAbility(AbilityContextManager.getContext() as common.UIExtensionContext, {
      bundleName: ALARM_BUNDLE_NAME,
      abilityName: ALARM_ABILITY_NAME,
      parameters: {
        tabActive: ALARM_TAB_KEY,
      }
    }, () => {
      LogUtil.showInfo(TAG, 'jumpAlarm end.');
    });
  }
}