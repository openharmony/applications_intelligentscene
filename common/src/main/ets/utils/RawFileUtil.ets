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

import { BusinessError } from '@ohos.base';
import Stream from '@ohos.file.fs';
import util from '@ohos.util';
import resmgr from '@ohos.resourceManager';
import { LogUtil } from './LogUtil';

const TAG: string = 'RawFileUtil';
const UNICODE: string = 'utf-8';
const DATA_SIZE = 4096;

/**
 * rawFile工具类
 */
export class RawFileUtil {

  /**
   * 获取指定JSON文件的对象
   *
   * @param resourceManager 资源管理器
   * @param fileName 文件路径
   * @returns 文件内容
   */
  public static getStringByFile(resourceManager: resmgr.ResourceManager | undefined,
    fileName: string): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!resourceManager || !fileName) {
        LogUtil.showError(TAG, `getFileContent failed. resourceManager or fileName is null.`);
        reject();
        return;
      }
      try {
        LogUtil.showInfo(TAG, 'start getRawFileContent');
        resourceManager.getRawFileContent(fileName).then((value) => {
          LogUtil.showInfo(TAG, 'getRawFileContent success');
          let content = util.TextDecoder.create(UNICODE).decodeToString(value);
          LogUtil.showInfo(TAG, 'decode success');
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

  static readJsonFile(filePath: string): string {
    LogUtil.showInfo(TAG, 'readJsonFile start execution');
    let readStreamSync: Stream.Stream | undefined = undefined;
    try {
      readStreamSync = Stream.createStreamSync(filePath, 'r');
      return RawFileUtil.getContent(readStreamSync as Stream.Stream);
    } catch (e) {
      LogUtil.showError(TAG, `readJsonFile error: ${e?.message}`);
      return '';
    } finally {
      readStreamSync?.closeSync();
    }
  }

  /**
   * Read JSON object from a file.
   *
   * @param {object} readStreamSync - stream of target file
   * @return {object} - object read from file stream
   */
  static getContent(readStreamSync: Stream.Stream): string {
    LogUtil.showInfo(TAG, 'getContent start');
    const bufArray: ArrayBuffer[] = [];
    let totalLength = 0;
    let buf = new ArrayBuffer(DATA_SIZE);
    let len = readStreamSync.readSync(buf);
    while (len != 0) {
      LogUtil.showInfo(TAG, `getContent FileIO reading ${len}`);
      totalLength += len;
      if (len < DATA_SIZE) {
        buf = buf.slice(0, len);
        bufArray.push(buf);
        break;
      }
      bufArray.push(buf);
      buf = new ArrayBuffer(DATA_SIZE);
      len = readStreamSync.readSync(buf);
    }
    LogUtil.showInfo(TAG, `getContent read finished: ${totalLength}`);
    const contentBuf = new Uint8Array(totalLength);
    let offset = 0;
    for (const bufArr of bufArray) {
      LogUtil.showInfo(TAG, `getContent collecting: ${offset}`);
      const uInt8Arr = new Uint8Array(bufArr);
      contentBuf.set(uInt8Arr, offset);
      offset += uInt8Arr.byteLength;
    }
    let textDecoder = util.TextDecoder.create('utf-8', {ignoreBOM: true});
    const content = textDecoder.decodeToString(contentBuf, {stream: false});
    return content;
  }
}
