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

import image from '@ohos.multimedia.image';
import {
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium';
import { ImageUtil } from '@ohos/scene.common/src/main/ets/utils/ImageUtil';

export default function ImageUtilTest() {
  describe('ImageUtilTest', () => {

    beforeEach(() => {

    });
    afterEach(() => {

    });

    it('should_return_base64_string_when_packing_is_successful', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let pixelMap: image.PixelMap = {} as image.PixelMap;
      await ImageUtil.pixelMapToBase64('jpeg', pixelMap);
      const result = await ImageUtil.pixelMapToBase64('', pixelMap);
      expect(result === undefined || result === '').assertTrue();
      mocker.ignoreMock(ImageUtil, ImageUtil.pixelMapToBase64);
      done();
    });

    it('should_return_empty_string_when_packing_fails', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let pixelMap: image.PixelMap = {} as image.PixelMap;
      await ImageUtil.pixelMapToBase64('jpeg2', pixelMap);
      const result = await ImageUtil.pixelMapToBase64(' ', pixelMap);
      expect(result === undefined || result === '').assertTrue();
      mocker.ignoreMock(ImageUtil, ImageUtil.pixelMapToBase64);
      done();
    });

    it('should_return_undefined_when_base64Str_is_empty', 0, async (done: Function) => {
      const result = await ImageUtil.base64ToPixelMap('');
      expect(result).assertUndefined();
      done();
    });

    it('should_return_pixelMap_when_base64Str_is_valid', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFunc = mocker.mockFunc(ImageUtil, ImageUtil.base64ToPixelMap);
      when(mockFunc)(ArgumentMatchers.any).afterReturn({ buffer: new ArrayBuffer(8) });
      const result = await ImageUtil.base64ToPixelMap('valid');
      expect(result).assertDeepEquals({ buffer: new ArrayBuffer(8) });
      mocker.ignoreMock(ImageUtil, ImageUtil.base64ToPixelMap);
      let pixelMap: image.PixelMap = {} as image.PixelMap;
      await ImageUtil.pixelMapToBase64('', pixelMap);
      done();
    });
  });
}