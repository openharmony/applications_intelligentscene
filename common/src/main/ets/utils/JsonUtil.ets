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

import { util } from '@kit.ArkTS';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from './LogUtil';

const TAG = 'JsonUtil';
const UNICODE: string = 'utf-8';

export class JsonUtil {
  /**
   * 获取指定JSON文件的对象
   * @param context 上下文
   */
  public static getStringByFileAsync(resourceManager: resourceManager.ResourceManager | undefined,
    fileName: string): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!resourceManager || !fileName) {
        LogUtil.showError(TAG, 'getFileContent failed. resourceManager or fileName is null.');
        reject();
        return;
      }
      try {
        resourceManager.getRawFileContent(fileName).then((value) => {
          let content = util.TextDecoder.create(UNICODE).decodeWithStream(value);
          resolve(content);
        }).catch((err: BusinessError) => {
          LogUtil.showError(TAG, `getFileContent of ${fileName} failed. ${err?.code} ${err?.message}`);
          reject(err);
        });
      } catch (jsonError) {
        LogUtil.showError(TAG, `JSON parse error:${jsonError?.code} ${jsonError?.message}`);
        reject();
      }
    });
  }

  /**
   * 解析Json对象
   */
  public static fromJson(param: string | undefined): object | undefined {
    if (!param) {
      return undefined;
    }
    try {
      return JSON.parse(param);
    } catch (jsonError) {
      LogUtil.showError(TAG, `JSON parse error:${jsonError?.code} ${jsonError?.message}`);
      return undefined;
    }
  }

  /**
   * 将JSON字符串解析成对象
   *
   * @param param JSON格式字符串
   * @returns 解析成功返回泛型对象，解析失败返回undefined
   */
  public static parse<T>(param: string | undefined): T | undefined {
    if (!param) {
      return undefined;
    }
    try {
      return JSON.parse(param) as T;
    } catch (jsonError) {
      LogUtil.showError(TAG, `JSON parse object error:${jsonError?.code}, msg: ${jsonError?.message}`);
      return undefined;
    }
  }

  /**
   * Json 转 string
   */
  public static stringify(param?: object | string | number): string {
    try {
      return JSON.stringify(param);
    } catch (jsonError) {
      LogUtil.showError(TAG, `JSON stringify error:${jsonError?.code} ${jsonError?.message}`);
    }
    return '';
  }
}