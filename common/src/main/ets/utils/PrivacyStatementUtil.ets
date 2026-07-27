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

import { LogUtil } from './LogUtil';
import { PreferencesUtil } from './PreferencesUtil';

const TAG: string = 'PrivacyStatementUtil:';
export const PRIVATE_STATEMENT_STATUS: string = 'PRIVATE_STATEMENT_STATUS';

/**
 * 隐私声明工具类
 */
export class PrivacyStatementUtil {
  public static isIntelligentExperienceAgreed(): boolean {
    const isAgreePrivateStatement: boolean = PreferencesUtil.getSync(PRIVATE_STATEMENT_STATUS, false) as boolean;
    LogUtil.showInfo(TAG, `isIntelligentExperienceAgreed: ${isAgreePrivateStatement}`);
    return isAgreePrivateStatement;
  }

  public static setIntelligentExperienceAgreed(isAgreed: boolean): void {
    PreferencesUtil.putSync(PRIVATE_STATEMENT_STATUS, isAgreed);
    LogUtil.showInfo(TAG, `setIntelligentExperienceAgreed: ${isAgreed}`);
  }

  /**
   * A进程设置值后，B进程读取需要调用此方法，保证值是最新的
   *
   * @returns 同意隐私声明
   */
  public static isIntelligentExperienceAgreedFromOtherProcess(): boolean {
    const isAgreePrivateStatement: boolean =
      PreferencesUtil.getSyncCache(PRIVATE_STATEMENT_STATUS, false, true) as boolean;
    LogUtil.showInfo(TAG, `isIntelligentExperienceAgreedFromOtherProcess: ${isAgreePrivateStatement}`);
    return isAgreePrivateStatement;
  }
}
