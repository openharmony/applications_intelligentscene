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

import { LogUtil } from '../../utils/LogUtil';
import { Any } from './AnyType';

// 适配到模块日志系统
export class LogHelper {
  private static readonly PREFIX: string = 'SettingFramework';
  private static readonly SYMBOL: string = ' --> ';

  public static debug(tag: string, format: string, ...args: Any[]): void {
    LogUtil.showDebug(LogHelper.PREFIX, tag + LogHelper.SYMBOL + format, args);
  }

  public static info(tag: string, format: string, ...args: Any[]): void {
    LogUtil.showInfo(LogHelper.PREFIX, tag + LogHelper.SYMBOL + format, args);
  }

  public static warn(tag: string, format: string, ...args: Any[]): void {
    LogUtil.showWarn(LogHelper.PREFIX, tag + LogHelper.SYMBOL + format, args);
  }

  public static error(tag: string, format: string, ...args: Any[]): void {
    LogUtil.showError(LogHelper.PREFIX, tag + LogHelper.SYMBOL + format, args);
  }
}