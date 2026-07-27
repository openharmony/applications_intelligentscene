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

import lazy { deviceInfo, systemParameterEnhance } from '@kit.BasicServicesKit';
import Display from '@ohos.display';
import { LogUtil } from './LogUtil';
import { taskpool } from '@kit.ArkTS';

/* instrument ignore file */
const TAG: string = 'DeviceUtil';

const DEVICE_TYPE_PHONE = 'phone';
const DEVICE_TYPE_PC = '2in1';
const DEVICE_TYPE_PAD = 'tablet';
const DEVICE_TYPE_WEARABLE = 'wearable';
const DEVICE_TYPE_EMULATOR = 'emulator';
const DEFAULT_DPI: number = 480;

enum FoldPhoneTypeValue {
  /**
   * 无效值
   */
  INVALID_VALUE = -1,
  /**
   * 直板机
   */
  STRAIGHT = 0,
  /**
   * 大折（内折） X5
   */
  LARGE_FOLD = 1,
  /**
   * 小折叠（只有内折） pocket
   */
  SMALL_FOLD = 2,
  /**
   * 外折 XS2
   */
  EXTERNAL_FOLD = 3,
  /**
   * 扩展新形态
   */
  EXPANDING_NEX_FORMS = 4,
  /**
   * super fold
   */
  EXPANDING_SUPER_FOLD = 5,
  /**
   * 三折叠 GRL
   */
  THREE_FOLD_EXPANDING = 6
}

enum FoldStatus {
  FOLD_STATUS_FOLDED = 2,
  FOLD_STATUS_FOLDED_WITH_SECOND_EXPAND = 12,
  FOLD_STATES_FOLDED_WITH_SECOND_HALF_FOLDED = 22,
  FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED = 11,
  FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED = 21,
  FOLD_STATUS_HALF_FOLDED_WITH_SECOND_EXPANDED = 13,
  FOLD_STATUS_HALF_FOLDED_WITH_SECOND_HALF_FOLDED = 23,
}

@Concurrent
function isFoldableSync(): boolean {
  try {
    return Display.isFoldable();
  } catch (err) {
    LogUtil.showError('BaseUtils', `getDeviceFodable failed. error: ${err?.code} ${err?.message}`);
    return false;
  }
}

export class DeviceUtil {
  public static deviceType: string = deviceInfo.deviceType;

  public static productMode: string = deviceInfo.productModel;

  public static isDeviceFoldable: boolean = false;

  private static sFoldProductTypeValue: FoldPhoneTypeValue = FoldPhoneTypeValue.INVALID_VALUE;

  private static isSupportPcMode: boolean | undefined = undefined;

  static {
    DeviceUtil.getDeviceFodable().then((isDeviceFoldable: boolean) => {
      DeviceUtil.isDeviceFoldable = isDeviceFoldable;
    });
  }

  /**
   * Check whether the current device is a mobile phone.
   *
   * @return true: Phone  false: Not a phone
   */
  static isDevicePhone(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_PHONE;
  }

  static isDevicePc(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_PC;
  }

  static isDevicePad(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_PAD;
  }

  static isWearable(): boolean {
    return DeviceUtil.deviceType === DEVICE_TYPE_WEARABLE;
  }

  static isDeviceEmulator(): boolean {
    return DeviceUtil.productMode === DEVICE_TYPE_EMULATOR;
  }

  static isDeviceDefaultSplit(): boolean {
    // 小折叠
    if (DeviceUtil.isSmallFoldProduct()) {
      return false;
    }
    return DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() || DeviceUtil.isDevicePc();
  }

  /**
   * 是否折叠屏
   *
   * @returns boolean true: 是折叠屏, false: 不是折叠屏
   */
  static isFoldable(): boolean {
    return DeviceUtil.isDeviceFoldable;
  }

  /**
   * 是否折叠屏展开状态
   *
   * @return boolean true: 是折叠屏展开态, false: 不是折叠屏展开态
   */
  static isFoldExpand(): boolean {
    return DeviceUtil.isDeviceFoldable && DeviceUtil.isFoldedStatus();
  }

  /**
   * 是否折叠屏折叠状态
   *
   * @return boolean true: 是折叠屏折叠态, false: 不是折叠屏折叠态
   */
  static isFoldFold(): boolean {
    return DeviceUtil.isDeviceFoldable && DeviceUtil.isFoldedStatus();
  }

  /**
   * 当前设备是否为竖屏
   *
   * @return true: 竖屏  false: 横屏
   */
  static isDevicePortrait(): boolean {
    try {
      const orientation: Display.Orientation = Display.getDefaultDisplaySync().orientation;
      if (orientation === Display.Orientation.LANDSCAPE || orientation === Display.Orientation.LANDSCAPE_INVERTED) {
        return false;
      }
    } catch (err) {
      LogUtil.showError(TAG, `isDevicePortrait failed. error: ${err?.code} ${err?.message}`);
    }
    return true;
  }

  /**
   * 获取当前屏幕显示方向
   *
   * @return 屏幕显示方向
   */
  static getDisplayOrientation(): Display.Orientation {
    try {
      return Display.getDefaultDisplaySync().orientation;
    } catch (e) {
      LogUtil.showError(TAG, `getDisplayOrientation failed. error: ${e?.code}`);
    }
    return Display.Orientation.PORTRAIT;
  }

  private static async getDeviceFodable(): Promise<boolean> {
    const task = new taskpool.Task(isFoldableSync);
    try {
      return await taskpool.execute(task, taskpool.Priority.MEDIUM) as boolean;
    } catch (error) {
      LogUtil.showError(TAG, `getDeviceFodable failed. error: ${error?.code} ${error?.message}`);
      return false;
    }
  }

  /**
   * 是否是小内折产品 Lem
   *
   * @returns boolean 如果为小折叠产品返回true
   */
  static isSmallFoldProduct(): boolean {
    // 小折叠 + VDE
    return [
      FoldPhoneTypeValue.SMALL_FOLD,
      FoldPhoneTypeValue.EXPANDING_NEX_FORMS,
    ].includes(DeviceUtil.getFoldProductType());
  }

  /**
   * 是否是大内折产品 X5
   *
   * @returns boolean
   */
  static isLargeInFoldProduct(): boolean {
    return FoldPhoneTypeValue.LARGE_FOLD === DeviceUtil.getFoldProductType();
  }

  private static isFoldedStatus(): boolean {
    try {
      return Display.getFoldStatus() === Display.FoldStatus.FOLD_STATUS_FOLDED;
    } catch (err) {
      LogUtil.showError(TAG, `getFoldStatus: getFoldStatus failed. error: ${err?.code} ${err?.message}`);
    }
    return false;
  }

  /**
   * 是否三折叠屏 GRL
   *
   * @returns boolean true: 是三折叠屏, false: 不是三折叠屏
   */
  static isThreeFoldable(): boolean {
    return FoldPhoneTypeValue.THREE_FOLD_EXPANDING === DeviceUtil.getFoldProductType();
  }

  /**
   * 三折叠屏是否是G态
   *
   * @returns boolean true: 是G态, false: 不是G态
   */
  static isThreeFoldableGmodel(): boolean {
    const foldStatus: number = Display.getFoldStatus().valueOf();
    return DeviceUtil.isDeviceFoldable &&
      (foldStatus === FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED ||
        foldStatus === FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED ||
        foldStatus === FoldStatus.FOLD_STATUS_HALF_FOLDED_WITH_SECOND_EXPANDED ||
        foldStatus === FoldStatus.FOLD_STATUS_HALF_FOLDED_WITH_SECOND_HALF_FOLDED);
  }

  /**
   * 获取代表产品形态的配置项值
   *
   * @returns FoldPhoneTypeValue
   */
  private static getFoldProductType(): number {
    if (DeviceUtil.sFoldProductTypeValue !== FoldPhoneTypeValue.INVALID_VALUE) {
      return DeviceUtil.sFoldProductTypeValue;
    }
    try {
      let productValue: string = systemParameterEnhance.getSync('const.window.foldscreen.type', '0,0,0,0');
      LogUtil.showInfo(TAG, `productValue: ${productValue}`);
      const result: string[] = productValue?.split(',');
      if (result.length > 0) {
        let res = Number.parseInt(result[0]);
        return res;
      }
    } catch (err) {
      LogUtil.showError(TAG, `getFoldProductType: isDevicePortrait failed. error: ${err?.code} ${err?.message}`);
    }
    return FoldPhoneTypeValue.INVALID_VALUE;
  }

  static getDisplayDensityDpi(): number {
    try {
      return Display.getDefaultDisplaySync().densityDPI;
    } catch (e) {
      LogUtil.showError(TAG, `getDisplayDensityDpi failed. error: ${e?.code}, msg: ${e?.message}`);
    }
    return DEFAULT_DPI;
  }

  /**
   * 判断当前是否处于pc模式
   *
   * @returns true 是， false 不是
   */
  public static isPcMode(): boolean {
    try {
      const params: string = systemParameterEnhance.getSync('persist.sceneboard.ispcmode', 'false');
      LogUtil.showInfo(TAG, `ispcmode, params: ${params}`);
      return params === 'true';
    } catch (error) {
      LogUtil.showError(TAG, `get pc mode switch error: ${error?.message}, ${error?.code}`);
    }
    return false;
  }

  /**
   * 设备是否支持pc模式
   *
   * @returns true 支持， false 不支持
   */
  public static isDeviceSupportPcMode(): boolean {
    if (DeviceUtil.isSupportPcMode !== undefined) {
      LogUtil.showInfo(TAG, `suppport windwo pcmode switch: ${DeviceUtil.isSupportPcMode}`);
      return DeviceUtil.isSupportPcMode;
    }
    try {
      DeviceUtil.isSupportPcMode =
        systemParameterEnhance.getSync('const.window.support_window_pcmode_switch', 'false') === 'true';
      LogUtil.showInfo(TAG, `suppport windwo pcmode switch: ${DeviceUtil.isSupportPcMode}`);
      return DeviceUtil.isSupportPcMode;
    } catch (error) {
      LogUtil.showError(TAG, `get switch supportWindowPcModeSwitch failed: ${error?.message}, ${error?.code}`);
      return false;
    }
  }

  /**
   * 是否是新形态小折叠产品
   *
   * @returns boolean 如果是扩展折叠产品返回true
   */
  public static isSingleDisplayPocketFoldDevice(): boolean {
    return FoldPhoneTypeValue.EXPANDING_NEX_FORMS === DeviceUtil.getFoldProductType();
  }

  /**
   * 获取设备的显示模式
   *
   * @returns 设备显示模式
   */
  public static getFoldDisplayMode(): Display.FoldDisplayMode {
    let displayMode: Display.FoldDisplayMode = Display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL;
    try {
      displayMode = Display.getFoldDisplayMode();
    } catch (e) {
      LogUtil.showError(TAG, `getFoldDisplayMode failed. error: ${e?.code}, msg: ${e?.message}`);
    }
    return displayMode;
	}

  /**
   * 是否为新折叠态产品外屏显示状态
   *
   * @returns true 是， false 不是
   */
  public static isPocketExternalDisplayMode(): boolean {
    return DeviceUtil.isSingleDisplayPocketFoldDevice() &&
      DeviceUtil.getFoldDisplayMode() === Display.FoldDisplayMode.FOLD_DISPLAY_MODE_MAIN;
  }
}