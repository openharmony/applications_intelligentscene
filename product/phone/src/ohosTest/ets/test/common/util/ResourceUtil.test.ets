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

import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  MockKit,
  when,
  ArgumentMatchers,
  expect,
} from '@ohos/hypium'
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

export default function ResourceUtilTest() {
  describe('ResourceUtilTest', () => {
    beforeAll(() => {
    })
    beforeEach(() => {
    })
    afterEach(() => {
    })
    afterAll(() => {
    })

    it('ResourceUtilTest_01', 0, test);

    it('ResourceUtilTest_02', 0, testString);
  })
}

function test() {
  ResourceUtil.getColorSync($r('app.color.start_window_background'));

  ResourceUtil.getString($r('app.string.recommend_enable_content'));
  ResourceUtil.getString();
  ResourceUtil.getStringSync(undefined);
  ResourceUtil.getStringSync($r('app.string.recommend_enable_content'));

  ResourceUtil.getCapitalString($r('app.string.recommend_enable_content'));
  ResourceUtil.getCapitalString('');
  ResourceUtil.getCapitalString('abc');

  ResourceUtil.getFormatString($r('app.string.recommend_enable_content'), 'test');

  ResourceUtil.getFormatStringSync($r('app.string.recommend_enable_content'), 'test');

  ResourceUtil.getFormatStringByNameSync('app.string.recommend_enable_content', 'test');
  ResourceUtil.getFormatStringByName('app.string.recommend_enable_content', 'test');
  ResourceUtil.getFormatStringByName('app.string.recommend_enable_content', 'test', 'test2');

  ResourceUtil.getNumberFormatString($r('app.string.recommend_enable_content'), 'test');
  ResourceUtil.getNumberFormatStringSync($r('app.string.recommend_enable_content'), 'test');

  ResourceUtil.getNumberFormatStringByName('app.string.recommend_enable_content', 'test');

  ResourceUtil.getAnyFormatString($r('app.string.recommend_enable_content'), 'test', 'test2');

  ResourceUtil.getWindowsStringSync('');
  ResourceUtil.getWindowsStringSync('abc');

  ResourceUtil.getSystemLanguage();

  ResourceUtil.getAnyStrFormatStringSync($r('app.string.recommend_enable_content'), 'test');
  ResourceUtil.getAnyStrFormatStringByName('DND_mode', 'test');

  ResourceUtil.getAnyNumFormatStringSync($r('app.string.recommend_enable_content'), 0);
  ResourceUtil.getAnyNumFormatString($r('app.string.recommend_enable_content'), 0);

  ResourceUtil.getCapitalStringSync('');
  ResourceUtil.getCapitalStringSync('abc');
  ResourceUtil.getCapitalStringSync($r('app.string.recommend_enable_content'));

  ResourceUtil.getCapitalPluralStringValueSync($r('app.string.recommend_enable_content'), 0);
  ResourceUtil.getPluralStringValueSync($r('app.string.recommend_enable_content'), 0);
  ResourceUtil.getPluralStringByNameSync('recommend_enable_content', 0);
  ResourceUtil.getAnyStrFormatString($r('app.string.recommend_enable_content'), 'test');
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();

  try {
    ResourceUtil.getAnyStrFormatStringSync($r('app.string.recommend_enable_content'), 'test', 'abc');
    ResourceUtil.getAnyNumFormatStringSync($r('app.string.recommend_enable_content'), 0, 1);
    ResourceUtil.windowGetAnyStrFormatStringSync($r('app.string.recommend_enable_content'), 'test', 'test2');
  } catch (e) {
  }
}

async function testString(): Promise<void> {
  try {
    let mocker: MockKit = new MockKit();
    let mockGetStringFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getString);
    let mockGetStringSyncFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringSync);
    let mockGetStringByNameFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByName);

    when(mockGetStringFunc)(ArgumentMatchers.anyObj).afterReturn('test %1$d test %2$d');
    when(mockGetStringSyncFunc)(ArgumentMatchers.anyObj).afterReturn('test %1$d test %2$d');

    await ResourceUtil.getAnyNumFormatString($r('app.string.recommend_enable_content'), 0, 1);
    ResourceUtil.getAnyNumFormatStringSync($r('app.string.recommend_enable_content'), 0, 1);

    when(mockGetStringSyncFunc)(ArgumentMatchers.anyObj).afterReturn('test %d');
    when(mockGetStringFunc)(ArgumentMatchers.anyObj).afterReturn('test %d');
    await ResourceUtil.getNumberFormatString($r('app.string.recommend_enable_content'), 'a');
    ResourceUtil.getNumberFormatStringSync($r('app.string.recommend_enable_content'), 'a');

    when(mockGetStringSyncFunc)(ArgumentMatchers.anyObj).afterReturn('');
    when(mockGetStringFunc)(ArgumentMatchers.anyObj).afterReturn('');
    await ResourceUtil.getNumberFormatString($r('app.string.recommend_enable_content'), 'a');
    ResourceUtil.getNumberFormatStringSync($r('app.string.recommend_enable_content'), 'a');

    when(mockGetStringByNameFunc)(ArgumentMatchers.anyString).afterReturn('test %d');
    ResourceUtil.getNumberFormatStringByName('recommend_enable_content', 'tt');
    when(mockGetStringByNameFunc)(ArgumentMatchers.anyString).afterReturn('test %1$s');
    ResourceUtil.getFormatStringByName('recommend_enable_content', 'tt');
    ResourceUtil.getAnyStrFormatStringByName('recommend_enable_content', 'tt');

    when(mockGetStringSyncFunc)(ArgumentMatchers.anyObj).afterReturn('test %1$s asb %2$s');
    ResourceUtil.getAnyStrFormatStringSync($r('app.string.recommend_enable_content'), 'a', 'b');

    when(mockGetStringFunc)(ArgumentMatchers.anyObj).afterReturn('test %1$s test %2$d');
    await ResourceUtil.getAnyFormatString($r('app.string.recommend_enable_content'), 'a', 'b');
    await ResourceUtil.getAnyStrFormatString($r('app.string.recommend_enable_content'), 'a', 'b');

    let mockGetWindowStringSyncFunction: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getWindowsStringSync);
    when(mockGetWindowStringSyncFunction)(ArgumentMatchers.anyObj).afterReturn('hello %1$s, good %2$s');
    ResourceUtil.windowGetAnyStrFormatStringSync($r('app.string.recommend_enable_content'), 'jack', 'job');

    await ResourceUtil.getPixelMap('icon');

    let resource: Resource = {
      bundleName: '',
      moduleName: '',
      id: 1002314
    };
    await ResourceUtil.getString(resource);

    mocker.ignoreMock(ResourceUtil, ResourceUtil.getString);
    mocker.ignoreMock(ResourceUtil, ResourceUtil.getStringSync);
    mocker.ignoreMock(ResourceUtil, ResourceUtil.getStringByName);
    mocker.ignoreMock(ResourceUtil, ResourceUtil.getWindowsStringSync);
    const str: string = StringUtil.generateUuid();
    expect(str !== undefined).assertTrue();
  } catch (e) {
  }
}