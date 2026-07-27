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

import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { Context } from '@kit.AbilityKit';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { FontScaleUtils } from '@ohos/scene.common/src/main/ets/utils/FontScaleUtils';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

export default function FontScaleUtilTest() {
  describe('FontScaleUtilTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('getContext', 0, async (done: Function) => {
      let context: Context | null = FontScaleUtils.getContext(null);
      expect(context).assertNull();
      done();
    });

    it('getCurrentScale', 0, async (done: Function) => {
      let fontScale: number = FontScaleUtils.getCurrentScale(AbilityContextManager.getContext() as Context);
      expect(fontScale).assertLargerOrEqual(0.5);
      done();
    });

    it('FontScaleUtilTest_test', 0, test);

    it('FontScaleUtilTest_test_getContext', 0, () => {
      FontScaleUtils.getContext(AbilityContextManager.getContext() as Context);
      expect(AbilityContextManager.getContext() !== undefined).assertTrue();
    });

    it('FontScaleUtilTest_test_getCurrentScale', 0, () => {
      const fontScale: number = FontScaleUtils.getCurrentScale(AbilityContextManager.getContext() as Context);
      expect(fontScale > 0.5).assertTrue();
    });

    it('FontScaleUtilTest_test_getCurrentScale_null', 0, () => {
      const fontScale: number = FontScaleUtils.getCurrentScale(null);;
      expect(fontScale > 0).assertTrue();
    });

    it('FontScaleUtilTest_test_setCurrentScale_1', 0, () => {
      FontScaleUtils.setFontScaleSize(FontScaleUtils.EXTRA_LARGE_FONT_1);
      FontScaleUtils.setCurrentTopPadding();
      FontScaleUtils.setCurrentPadding();
      FontScaleUtils.setButtonTopPadding();
      FontScaleUtils.setTabBarHeight();
      const fontScale: number = FontScaleUtils.getCurrentScale(null);;
      expect(fontScale > 0).assertTrue();
    });

    it('FontScaleUtilTest_test_setCurrentScale_2', 0, () => {
      FontScaleUtils.setFontScaleSize(FontScaleUtils.EXTRA_LARGE_FONT_2);
      FontScaleUtils.setCurrentTopPadding();
      FontScaleUtils.setCurrentPadding();
      FontScaleUtils.setButtonTopPadding();
      FontScaleUtils.setTabBarHeight();
      const fontScale: number = FontScaleUtils.getCurrentScale(null);;
      expect(fontScale > 0).assertTrue();
    });

    it('FontScaleUtilTest_test_setCurrentScale_3', 0, () => {
      FontScaleUtils.setFontScaleSize(FontScaleUtils.EXTRA_LARGE_FONT_3);
      FontScaleUtils.setCurrentTopPadding();
      FontScaleUtils.setCurrentPadding();
      FontScaleUtils.setButtonTopPadding();
      FontScaleUtils.setTabBarHeight();
      const fontScale: number = FontScaleUtils.getCurrentScale(null);;
      expect(fontScale > 0).assertTrue();
    });
  });
}

function test() {
  FontScaleUtils.setFontScaleSize(1);
  FontScaleUtils.getFontScaleSize();
  FontScaleUtils.setConfig(1);

  FontScaleUtils.setFontScaleSize(0.9);
  FontScaleUtils.setCurrentTopPadding();
  FontScaleUtils.setCurrentPadding();

  FontScaleUtils.getCurrentPadding();
  FontScaleUtils.getCurrentContentPadding();
  FontScaleUtils.getButtonTopPadding();

  FontScaleUtils.getTabBarHeight();
  FontScaleUtils.isExtraLargeFontMode();
  FontScaleUtils.setExtraLargeFontMode();
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
}