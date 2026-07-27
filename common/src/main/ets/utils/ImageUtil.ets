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
import image from '@ohos.multimedia.image';
import util from '@ohos.util';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LogUtil } from './LogUtil';

/**
 * 像素坐标
 */
export interface IImgCoordinate {
  x: number,
  y: number,
}

export interface IImgSize {
  width: number,
  height: number,
}

const TAG: string = 'ImageUtil: ';

// base64前缀
export const prefix: string = 'data:image/png;base64,';

export class ImageUtil {
  public static readonly MAX_SIZE: number = 1000; // 图片尺寸的最大边长
  public static readonly IMG_BASE64_REG: RegExp = new RegExp('data:image/\\w+;base64,.*$');

  /**
   * 图片转base64格式
   *
   * @param format 待转化的图片类型（image/png、image/jpg、image/webp）
   * @param pixelMap
   * @returns
   */
  public static async pixelMapToBase64(format: string, pixelMap: image.PixelMap): Promise<string> {
    if (CheckEmptyUtils.checkStrIsEmpty(format) || !pixelMap) {
      LogUtil.showWarn(TAG, 'pixelMapToBase64 invalid param');
      return '';
    }
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    const base64Helper = new util.Base64Helper();
    let packOpts: image.PackingOption = {
      format: format,
      quality: 30
    };
    try {
      const data: ArrayBuffer = await imagePackerApi.packToData(pixelMap, packOpts);
      let base64 = base64Helper.encodeToStringSync(new Uint8Array(data));
      LogUtil.showInfo(TAG, 'packing success');
      // 添加base64编码格式前缀
      base64 = prefix + base64;
      return base64;
    } catch (err) {
      LogUtil.showError(TAG, `packing failed, code: ${err?.code} message: ${err?.message}`);
      return '';
    } finally {
      imagePackerApi.release();
      LogUtil.showError(TAG, 'release imagePackerApi success.');
    }
  }

  /**
   * Base64转PixelMap
   *
   * @param base64Str base64字符串
   * @returns 图片pixelMap
   */
  public static async base64ToPixelMap(base64Str: string): Promise<PixelMap | undefined> {
    let imageSource: image.ImageSource | null = null;
    if (!base64Str) {
      return undefined;
    }
    const base64Helper = new util.Base64Helper();
    // 解码前先去掉前缀
    if (base64Str.startsWith(prefix)) {
      base64Str = base64Str.substring(prefix.length);
    }
    try {
      const data = base64Helper.decodeSync(base64Str, util.Type.BASIC);
      imageSource = image.createImageSource(data.buffer);
      let pixelMap: PixelMap = await imageSource.createPixelMap({ editable: true });
      return pixelMap;
    } catch (err) {
      LogUtil.showError(TAG, `decode base64 failed, code: ${err?.code} message: ${err?.message}`);
    } finally {
      if (imageSource !== null) {
        imageSource.release().then(() => {
          LogUtil.showInfo(TAG, 'release imageSource success.');
        }).catch((err: BusinessError) => {
          LogUtil.showError(TAG, `release imageSource error: ${err?.code} message: ${err?.message}`);
        })
      }
    }
    return undefined;
  }

  /**
   * 检查字符串是否是图片 base64 文本
   */
  public static isBase64Str(str: string): boolean {
    return ImageUtil.IMG_BASE64_REG.test(str);
  }
}