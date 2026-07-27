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

import uiEffect from '@ohos.graphics.uiEffect';

/**
 * 内嵌二级底板（浅色模式）
 */
export const INLINE_BACKGROUND_SECOND_LIGHT: VisualEffect =
  uiEffect.createEffect().backgroundColorBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 1,
    degree: -15 / 255,
    saturation: 1.2,
    positiveCoefficient: [0.4, 0.5, 0.5],
    negativeCoefficient: [0.3, 1, 1],
    fraction: 0
  });

/**
 * 内嵌二级底板（深色模式）
 */
export const INLINE_BACKGROUND_SECOND_DARK: VisualEffect =
  uiEffect.createEffect().backgroundColorBlender({
    cubicRate: 0,
    quadraticRate: 0,
    linearRate: 1,
    degree: 15 / 255,
    saturation: 1,
    positiveCoefficient: [1, 0.7, 1],
    negativeCoefficient: [1, 1, 1],
    fraction: 0
  });