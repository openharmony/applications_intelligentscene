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

import hilog from '@ohos.hilog';
import { Any } from '../framework/common/AnyType';

const INTELLIGENT_SCENE_NAME: string = 'IntelligentScene';
const LOG_SYMBOL: string = ' --> ';

/**
 * 日志工具类
 *
 * @since 2024-12-06
 */
export class LogUtil {
  private static readonly DOMAIN: number = 0x0700;

  static showDebug(tag: string, format: string, ...args: Any[]) : void {
    hilog.debug(LogUtil.DOMAIN, INTELLIGENT_SCENE_NAME, tag + LOG_SYMBOL + format, args);
  }

  static showInfo(tag: string, format: string, ...args: Any[]) : void {
    hilog.info(LogUtil.DOMAIN, INTELLIGENT_SCENE_NAME, tag + LOG_SYMBOL + format, args);
  }

  static showWarn(tag: string, format: string, ...args: Any[]) : void {
    hilog.warn(LogUtil.DOMAIN, INTELLIGENT_SCENE_NAME, tag + LOG_SYMBOL + format, args);
  }

  static showError(tag: string, format: string, ...args: Any[]) : void {
    hilog.error(LogUtil.DOMAIN, INTELLIGENT_SCENE_NAME, tag + LOG_SYMBOL + format, args);
  }
}

/**
 * 日志工具类-掩码处理
 *
 * @since 2024-04-24
 */
export class LogMaskUtil {

  static getLogNickNameString(nickNameString: String): string {
    if (!nickNameString) {
      return '';
    }

    let maskString: string = '************************************';
    let minMaskLen: number = 2;
    let maxLen: number = 32;
    let len = nickNameString.length;
    if (len <= 1 || len > maxLen) {
      return '***';
    }

    let maskLen: number = len + minMaskLen;
    let midLen: number = 10;
    if (len <= midLen) {
      return nickNameString.charAt(0) + maskString.substring(0, maskLen - 1);
    }

    return nickNameString.charAt(0) + maskString.substring(0, maskLen - 1) + nickNameString.charAt(len - 1);
  }
}