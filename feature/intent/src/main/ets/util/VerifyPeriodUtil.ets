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

import account_osAccount from '@ohos.account.osAccount';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';

const TAG: string = 'VerifyPeriodUtil: ';

/**
 * 意图框架校验隐私空间工具类
 */
export class VerifyPeriodUtil {
  /**
   * 校验隐私空间
   *
   * @returns isPrivate，true-隐私空间用户，false-主空间用户
   */
  static async isCurrentPrivate(): Promise<boolean> {
    let accountManager = account_osAccount.getAccountManager();
    try {
      let currentAccount = await accountManager.queryOsAccount();
      return currentAccount.type === account_osAccount.OsAccountType.PRIVATE;
    } catch (exception) {
      LogUtil.showError(TAG, `execute intent fail, query os account error code: ${exception?.code}`);
      return false;
    }
  }

  /**
   * 意图参数校验
   *
   * @param intentName 意图名称
   * @param intentParam 意图参数
   * @returns false 参数异常
   */
  static isIntentParamsValid(intentName: string, intentParam: Record<string, Object>): boolean {
    if (!intentName) {
      LogUtil.showError(TAG, 'intentName is null.');
      return false;
    }
    if (!intentParam) {
      LogUtil.showError(TAG, 'intentParam is null.');
      return false;
    }
    return true;
  }

  /**
   * 校验当前模式是否包含在已有的所有的情景模式中
   *
   * @param modeId 模式Id
   * @returns true：包含, false：不包含
   */
  static async isModeIdExist(modeId: string): Promise<boolean> {
    let modeData: ModeData | undefined = await El1ModeDataManager.getInstance().queryModeDataById(modeId);
    return !CheckEmptyUtils.isEmpty(modeData);
  }
}