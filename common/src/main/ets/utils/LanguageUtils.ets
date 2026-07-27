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

import I18n from '@ohos.i18n';
import Intl from '@ohos.intl';
import { LogUtil } from './LogUtil';

const TAG = 'LanguageUtils:';
// 藏文
const BO_LANGUAGE_ID: string = 'bo';
// 缅甸语
const MY_LANGUAGE_ID: string = 'my';
// 资源自适应语言
const ADAPTIVE_LANGUAGE_ARR: string[] = [MY_LANGUAGE_ID];

export class LanguageUtils {
  /**
   * 获取当前系统区域语言
   *
   * @returns 系统设置区域语言，如：zh。取值遵循ISO 639标准。
   */
  static getLocalLanguage(): string {
    const locale: Intl.Locale = new Intl.Locale();
    return locale.language;
  }


  /**
   * 获取当前系统设置语言
   *
   * @returns 系统设置具体语言，如：zh-Hans。
   */
  static getSystemLanguage(): string {
    return I18n.System.getSystemLanguage();
  }

  /**
   * 系统当前语言是否镜像语言
   * @returns true：是； false：不是
   */
  static isRtlDirection(): boolean {
    return I18n.isRTL(I18n.System.getSystemLocale());
  }

  /**
   * 当前系统是否为藏文
   *
   * @returns true 是，false 不是
   */
  static isSystemLanguageBo(): boolean {
    return I18n.System.getSystemLanguage() === BO_LANGUAGE_ID;
  }

  /**
   * 如果是特殊小语种（缅甸语），则行高给0，以字体资源高度为准，否则以应用测为准
   *
   * @returns lineHeight 行高
   */
  static getLineHeight(lineHeight?: Length): Length {
    const language: string = I18n.System.getSystemLanguage();
    if (!lineHeight || ADAPTIVE_LANGUAGE_ARR.includes(language)) {
      return 0;
    }
    return lineHeight;
  }
}