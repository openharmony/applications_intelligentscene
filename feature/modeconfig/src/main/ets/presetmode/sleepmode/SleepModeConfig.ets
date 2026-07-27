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

import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { GuideCardConfig } from '../../model/ModeConfigModel';
import { HOME_PAGE_ID, HomeGroupId, SLEEP_GUIDE_TIME_STAMP } from '../../constant/HomeCompIdConstant';
import { BaseModeConfig } from '../../adapter/BaseModeConfig';

/**
 * 睡眠模式配置
 */
export class SleepModeConfig extends BaseModeConfig {
  public getGuideCardConfigs(): GuideCardConfig[] {
    return [
      {
        preferencesKey: SLEEP_GUIDE_TIME_STAMP,
        icon: $r('app.media.sleep_guide_icon'),
        iconBackgroundColor: '#8A38C6',
        title: $r('app.string.sleep_guide_title'),
        message: $r('app.string.sleep_guide_hint'),
        linkText: $r('app.string.sleep_guide_link'),
        action: () => {
          EventBus.getInstance().emit(EventBusNameConstant.HOME_SCROLL_TO, Edge.Bottom,
            `${HOME_PAGE_ID}.${HomeGroupId.SYSTEM_FUNCTION}.header`);
        },
        isSupportClose: true,
      },
    ];
  }
}