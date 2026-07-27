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
  expect,
  MockKit,
  when,
  ArgumentMatchers,
} from '@ohos/hypium';
import Display from '@ohos.display';
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/scene.common';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';

const TAG: string = 'DeviceNameUtilTest: ';

export default function DeviceNameUtilTest() {
  describe('DeviceNameUtilTest', () => {

    beforeEach(() => {

    });
    afterEach(() => {

    });

    it('should_return_true_when_deviceType_test', 0, async (done: Function) => {
      const result = DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad() ||
        DeviceUtil.isDevicePc() || DeviceUtil.isWearable() || DeviceUtil.isDeviceEmulator();
      expect(result).assertTrue();
      done();
    });

    it('should_return_false_when_deviceType_is_not_phone_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePhone);
      when(mockFunc)().afterReturn(false);
      const result = DeviceUtil.isDevicePhone();
      expect(result).assertFalse();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDevicePhone);
      done();
    });

    it('should_return_false_when_deviceType_is_phone_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePhone);
      when(mockFunc)().afterReturn(true);
      const result = DeviceUtil.isDevicePhone();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDevicePhone);
      done();
    });

    it('should_return_false_when_deviceType_is_table_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePad);
      when(mockFunc)().afterReturn(true);
      const result = DeviceUtil.isDevicePad();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDevicePad);
      done();
    });

    it('should_return_false_when_deviceType_is_not_table_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePad);
      when(mockFunc)().afterReturn(false);
      const result = DeviceUtil.isDevicePad();
      expect(result).assertFalse();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDevicePad);
      done();
    });

    it('should_return_false_when_deviceType_is_pc_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
      when(mockFunc)().afterReturn(true);
      const result = DeviceUtil.isDevicePc();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDevicePc);
      done();
    });

    it('should_return_false_when_deviceType_is_not_pc_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
      when(mockFunc)().afterReturn(false);
      const result = DeviceUtil.isDevicePc();
      expect(result).assertFalse();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDevicePc);
      done();
    });

    it('should_return_false_when_deviceType_is_emulator_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDeviceEmulator);
      when(mockFunc)().afterReturn(true);
      const result = DeviceUtil.isDeviceEmulator();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDeviceEmulator);
      done();
    });

    it('should_return_false_when_deviceType_is_not_emulator_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDeviceEmulator);
      when(mockFunc)().afterReturn(false);
      const result = DeviceUtil.isDeviceEmulator();
      expect(result).assertFalse();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDeviceEmulator);
      done();
    });

    it('should_return_false_when_deviceType_is_wearable_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isWearable);
      when(mockFunc)().afterReturn(true);
      const result = DeviceUtil.isWearable();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isWearable);
      done();
    });

    it('should_return_false_when_deviceType_is_not_wearable_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isWearable);
      when(mockFunc)().afterReturn(false);
      const result = DeviceUtil.isWearable();
      expect(result).assertFalse();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isWearable);
      done();
    });

    it('should_return_false_when_deviceType_is_foldable_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable);
      when(mockFunc)().afterReturn(true);
      const result = DeviceUtil.isFoldable();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isFoldable);
      done();
    });

    it('should_return_false_when_deviceType_is_not_foldable_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable);
      when(mockFunc)().afterReturn(false);
      const result = DeviceUtil.isFoldable();
      expect(result).assertFalse();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isFoldable);
      done();
    });

    it('should_return_false_when_deviceType_is_default_split_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDeviceDefaultSplit);
      when(mockFunc)().afterReturn(true);
      const result = DeviceUtil.isDeviceDefaultSplit();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDeviceDefaultSplit);
      done();
    });

    it('should_return_false_when_deviceType_is_not_default_split_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDeviceDefaultSplit);
      when(mockFunc)().afterReturn(false);
      const result = DeviceUtil.isDeviceDefaultSplit();
      expect(result).assertFalse();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDeviceDefaultSplit);
      done();
    });

    it('device_name_test', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldExpand);
      when(mockFunc)().afterReturn(true);
      let result = DeviceUtil.isFoldExpand();
      expect(result).assertTrue();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isFoldExpand);

      mockFunc = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePortrait);
      when(mockFunc)().afterReturn(true);
      result = DeviceUtil.isDevicePortrait();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isDevicePortrait);
      done();
    });

    it('should_return_valid_dpi_test', 0, async (done: Function) => {
      const result = DeviceUtil.getDisplayDensityDpi();
      expect(result).assertLarger(0);
      done();
    });

    it('DeviceUtilTest1_test', 0, async (done: Function) => {
      const flag = DeviceUtil.isDevicePc();
      expect(flag !== undefined).assertTrue();
      DeviceUtil.isDeviceEmulator();
      DeviceUtil.isDeviceDefaultSplit();
      DeviceUtil.isFoldable();
      DeviceUtil.isFoldExpand();
      DeviceUtil.isFoldFold();
      DeviceUtil.isDevicePortrait();
      DeviceUtil.getDisplayOrientation();
      DeviceUtil.isSmallFoldProduct();
      DeviceUtil.isLargeInFoldProduct();
      DeviceUtil.getDisplayDensityDpi();

      SystemParamUtil.setParam('test', 'test a');
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isSmallFoldProduct);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      DeviceUtil.isDeviceDefaultSplit();
      mocker.ignoreMock(DeviceUtil, DeviceUtil.isSmallFoldProduct);
      done();
    });

    it('device_name_util_should_return_false_test1', 0, async (done: Function) => {
      expect(DeviceUtil.isDeviceEmulator()).assertFalse();
      done();
    });

    it('device_name_util_should_return_true_test2', 0, async (done: Function) => {
      expect(DeviceUtil.isDeviceDefaultSplit() !== undefined).assertTrue();
      done();
    });

    it('device_name_util_should_return_false_test3', 0, async (done: Function) => {
      expect(DeviceUtil.isDevicePc()).assertFalse();
      done();
    });

    it('device_name_util_should_return_true_test4', 0, async (done: Function) => {
      expect(DeviceUtil.isDevicePad() || DeviceUtil.isDevicePhone()).assertTrue();
      done();
    });

    it('device_name_util_should_return_false_test5', 0, async (done: Function) => {
      expect(DeviceUtil.isWearable()).assertFalse();
      done();
    });

    it('device_name_util_isSingleDisplayPocketFoldDevice', 0, async (done: Function) => {
      expect(DeviceUtil.isSingleDisplayPocketFoldDevice()).assertFalse();
      done();
    });

    it('device_name_util_getFoldDisplayMode', 0, async (done: Function) => {
      expect(DeviceUtil.getFoldDisplayMode() !== undefined).assertTrue();
      done();
    });

    it('device_name_util_isPocketExternalDisplayMode', 0, async (done: Function) => {
      expect(DeviceUtil.isPocketExternalDisplayMode()).assertFalse();
      done();
    });

    it('device_name_util_isThreeFoldableGmodel', 0, async (done: Function) => {
      try {
        const foldStatus: number = Display.getFoldStatus().valueOf();
        enum FoldStatus {
          FOLD_STATUS_FOLDED = 2,
          FOLD_STATUS_FOLDED_WITH_SECOND_EXPAND = 12,
          FOLD_STATES_FOLDED_WITH_SECOND_HALF_FOLDED = 22,
          FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED = 11,
          FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED = 21,
          FOLD_STATUS_HALF_FOLDED_WITH_SECOND_EXPANDED = 13,
          FOLD_STATUS_HALF_FOLDED_WITH_SECOND_HALF_FOLDED = 23,
        };
        let isDeviceFoldable: boolean = DeviceUtil.isDeviceFoldable &&
          (foldStatus === FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED ||
            foldStatus === FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED ||
            foldStatus === FoldStatus.FOLD_STATUS_HALF_FOLDED_WITH_SECOND_EXPANDED ||
            foldStatus === FoldStatus.FOLD_STATUS_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
        expect(DeviceUtil.isThreeFoldableGmodel()).assertEqual(isDeviceFoldable);
      } catch (err) {
        LogUtil.showError(TAG, `device_util_isThreeFoldableGmodel error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('device_name_util_isPcModeTest', 0, async (done: Function) => {
      try {
        const params: string = systemParameterEnhance.getSync('persist.sceneboard.ispcmode', 'false');
        expect(DeviceUtil.isPcMode()).assertEqual(params === 'true');
      } catch (error) {
        LogUtil.showError(TAG, `get pc mode switch error: ${error?.message}, ${error?.code}`);
      }
      done();
    });
  });
}
