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

import { HomeGroupId } from '../../constant/HomeCompIdConstant';
import { BaseModeConfig } from '../../adapter/BaseModeConfig';

/**
 * 运动模式配置
 */
export class SportModeConfig extends BaseModeConfig {
  public readonly supportGroupIdSet: Set<HomeGroupId> = new Set([
    HomeGroupId.ENABLE_WAY,
    HomeGroupId.ALLOWED_DISTURB,
    HomeGroupId.INTELLIGENT_EXPERIENCE,
    HomeGroupId.IMPORTANT_MESSAGE,
  ]);
}