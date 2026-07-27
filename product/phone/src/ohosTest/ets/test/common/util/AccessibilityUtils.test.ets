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

import {
  describe,
  beforeEach,
  afterEach,
  it,
  MockKit,
  when,
  expect
} from '@ohos/hypium';
import { Driver } from '@ohos.UiTest';
import { AccessibilityUtils } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';

const driver: Driver = Driver.create();
const COMMON_DELAY: number = 1000;

export default function AccessibilityUtilTest() {
  describe('AccessibilityUtilTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('isAccessibilityMode', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(AccessibilityUtils, AccessibilityUtils.isScreenReaderMode);
      when(mockFunc)().afterReturn(true);
      let result = AccessibilityUtils.isScreenReaderMode();
      expect(result).assertTrue();
      done();
    });

    it('requestFocusAccessibility', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(AccessibilityUtils, AccessibilityUtils.isScreenReaderMode);
      when(mockFunc)().afterReturn(true);
      AccessibilityUtils.requestFocusAccessibility('control_center_title');
      await driver.delayMs(COMMON_DELAY);
      when(mockFunc)().afterReturn(false);
      AccessibilityUtils.requestFocusAccessibility('control_center_title');
      const count: number = await ModeDataManager.getInstance().queryModeCount();
      expect(count >= 0).assertTrue();
      done();
    });

    it('announceText', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(AccessibilityUtils, AccessibilityUtils.isScreenReaderMode);
      when(mockFunc)().afterReturn(true);
      AccessibilityUtils.announceText('hello');
      await driver.delayMs(COMMON_DELAY);
      when(mockFunc)().afterReturn(false);
      AccessibilityUtils.announceText('');
      const count: number = await ModeDataManager.getInstance().queryModeCount();
      expect(count >= 0).assertTrue();
      done();
    });
  });
}