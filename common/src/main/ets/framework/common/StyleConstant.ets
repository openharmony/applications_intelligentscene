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

import { LengthMetrics } from '@ohos.arkui.node';

/* instrument ignore file */
export const PADDING_0: LengthMetrics = LengthMetrics.vp(0);
export const PADDING_1: LengthMetrics = LengthMetrics.vp(1);
export const PADDING_2: LengthMetrics = LengthMetrics.vp(2);
export const PADDING_3: LengthMetrics = LengthMetrics.vp(3);
export const PADDING_4: LengthMetrics = LengthMetrics.vp(4);
export const PADDING_5: LengthMetrics = LengthMetrics.vp(5);
export const PADDING_6: LengthMetrics = LengthMetrics.vp(6);
export const PADDING_8: LengthMetrics = LengthMetrics.vp(8);
export const PADDING_9: LengthMetrics = LengthMetrics.vp(9);
export const PADDING_10: LengthMetrics = LengthMetrics.vp(10);
export const PADDING_11: LengthMetrics = LengthMetrics.vp(11);
export const PADDING_12: LengthMetrics = LengthMetrics.vp(12);
export const PADDING_13: LengthMetrics = LengthMetrics.vp(13);
export const PADDING_14: LengthMetrics = LengthMetrics.vp(14);
export const PADDING_16: LengthMetrics = LengthMetrics.vp(16);
export const PADDING_17: LengthMetrics = LengthMetrics.vp(17);
export const PADDING_18: LengthMetrics = LengthMetrics.vp(18);
export const PADDING_20: LengthMetrics = LengthMetrics.vp(20);
export const PADDING_23: LengthMetrics = LengthMetrics.vp(23);
export const PADDING_24: LengthMetrics = LengthMetrics.vp(24);
export const PADDING_27: LengthMetrics = LengthMetrics.vp(27);
export const PADDING_28: LengthMetrics = LengthMetrics.vp(28);
export const PADDING_30: LengthMetrics = LengthMetrics.vp(30);
export const PADDING_32: LengthMetrics = LengthMetrics.vp(32);
export const PADDING_36: LengthMetrics = LengthMetrics.vp(36);
export const PADDING_40: LengthMetrics = LengthMetrics.vp(40);
export const PADDING_42: LengthMetrics = LengthMetrics.vp(42);
export const PADDING_44: LengthMetrics = LengthMetrics.vp(44);
export const PADDING_48: LengthMetrics = LengthMetrics.vp(48);
export const PADDING_54: LengthMetrics = LengthMetrics.vp(54);
export const PADDING_60: LengthMetrics = LengthMetrics.vp(60);
export const PADDING_64: LengthMetrics = LengthMetrics.vp(64);
export const PADDING_72: LengthMetrics = LengthMetrics.vp(72);
export const PADDING_78: LengthMetrics = LengthMetrics.vp(78);

export const FOCUS_BOX_PADDING_METRICS: LengthMetrics = LengthMetrics.vp(-2);
// 顶部状态栏高度
export const STATUS_BAR_HEIGHT: number = 40;
//按钮避让常量值
export const INIT_AVOID_WIDTH: number = 151;
export const INIT_DEFAULT_WIDTH: number = 123;

export class StyleConstant {
  public static getLocalizedPadding(padding: Padding | undefined): LocalizedPadding {
    if (!padding) {
      return {
        start: PADDING_0,
        end: PADDING_0,
        top: PADDING_0,
        bottom: PADDING_0
      };
    }
    return {
      start: padding?.left ? StyleConstant.transform(padding.left) : PADDING_0,
      end: padding?.right ? StyleConstant.transform(padding.right) : PADDING_0,
      top: padding?.top ? StyleConstant.transform(padding.top) : PADDING_0,
      bottom: padding?.bottom ? StyleConstant.transform(padding.bottom) : PADDING_0
    };
  }

  private static transform(padding: Length): LengthMetrics {
    let res: LengthMetrics;
    if (typeof padding === 'number') {
      res = LengthMetrics.vp(padding as number);
    } else if (typeof padding === 'string') {
      res = LengthMetrics.vp(Number(padding.toLowerCase().replace('vp', '')));
    } else {
      res = LengthMetrics.resource(padding as Resource);
    }
   return res;
  }
}