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

import lazy Package from '@system.package';
import lazy { bundleManager } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import { LogUtil } from './LogUtil';
import { StringUtil } from './StringUtil';

const TAG: string = 'PackageUtils:';

/**
 * PackageUtils工具类
 */
export class PackageUtils {
  /**
   * 获取应用包名
   *
   * @param context 上下文
   * @returns 应用包名
   */
  static getAppPackageName(context: common.UIAbilityContext): string {
    if (!context.applicationInfo) {
      LogUtil.showWarn(TAG, 'getAppPackageName: applicationInfo is null');
      return '';
    }
    return context.applicationInfo.name;
  }

  /**
   * 获取情景模式签名信息
   *
   * @returns 签名信息
   */
  static async getSelfSignatureInfo(): Promise<bundleManager.BundleInfo | undefined> {
    try {
      return await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO);
    } catch (e) {
      LogUtil.showError(TAG, `getSelfSignatureInfo error ${e?.code}, ${e?.message}`);
    }
    return undefined;
  }
}
