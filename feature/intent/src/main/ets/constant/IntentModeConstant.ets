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

import { ModeName, ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

export const MODE_ID_NAME_MAP: Map<string, string> = new Map<string, string>([
  [ModeType.NO_MODE, ModeName.NO_MODE_NAME],
  [ModeType.DND_MODE, ModeName.DND_MODE_NAME],
  [ModeType.SLEEP_MODE, ModeName.SLEEP_MODE_NAME],
  [ModeType.LEARNING_MODE, ModeName.LEARNING_MODE_NAME],
  [ModeType.WORKING_MODE, ModeName.WORKING_MODE_NAME],
  [ModeType.SPORT_MODE, ModeName.SPORT_MODE_NAME],
  [ModeType.GAME_MODE, ModeName.GAME_MODE_NAME],
  [ModeType.ENTERTAINMENT_MODE, ModeName.ENTERTAINMENT_MODE_NAME],
  [ModeType.DRIVING_MODE, ModeName.DRIVING_MODE_NAME],
]);