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

import { MockKit } from '@ohos/hamock'
import {
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect
} from '@ohos/hypium'
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil'
import { util } from '@kit.ArkTS'

export default function CommonUtilTest() {
  describe('CommonUtilTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('CommonUtilTest_isEmpty', 0, () => {
      let a: string = '';
      expect(StringUtil.isEmpty(a)).assertTrue();
    });

    it('CommonUtilTest_isNotEmpty', 0, isNotEmptyTest);

    it('CommonUtilTest_isSameParams', 0, isSameParamsTest);

    it('CommonUtilTest_getStringLength', 0, getStringLengthTest);

    it('CommonUtilTest_stringToUint8ArrayTest', 0, CommonUtilTest2);

    it('CommonUtilTest_getTableNameFromUri', 0, getTableNameFromUriTest);

    it('CommonUtilTest_getAnonymizedTableName', 0, getAnonymizedTableNameTest);

    it('CommonUtilTest_expect_test1', 0, () => {
      expect(StringUtil.getTableNameFromUri('datashare:////datashare:///com.ohos.intelligentscene/phonedatashare:///com.ohos.intelligentscene/phone/IntelligentScene/MODE_DATA?Proxy=true') === '').assertTrue();
    });

    it('CommonUtilTest_expect_test2', 0, () => {
      expect(StringUtil.getTableNameFromUri('tableName') === '').assertTrue();
    });

    it('CommonUtilTest_expect_test3', 0, () => {
      expect(StringUtil.getTableNameFromUri('datashare:///com.ohos.intelligentscene/phone/IntelligentScene/MODE_DATA?Proxy=true') === 'MODE_DATA').assertTrue();
    });

    it('CommonUtilTest_expect_test4', 0, () => {
      expect(StringUtil.getTableNameFromUri('datashare:///com.ohos.intelligentscene/phone/IntelligentScene/MODE_DATA') === '').assertTrue();
    });

    it('CommonUtilTest_expect_test5', 0, () => {
      expect(StringUtil.getTableNameFromUri('/MODE_DATA') === '').assertTrue();
    });

    it('CommonUtilTest_expect_test6', 0, () => {
      expect(StringUtil.getAnonymizedTableName('MODE_DATA_TABLE') === 'MODE_DA').assertTrue();
    });

    it('CommonUtilTest_expect_test7', 0, () => {
      let jsonStr: string = `{ 'name': 'Tom' }`;
      const str: string = StringUtil.getSubstring(jsonStr, 1000);
      expect(str !== undefined).assertTrue();
    });

    it('CommonUtilTest_expect_test8', 0, () => {
      let specialString: string = `测试· 中文繁体`;
      const str: string = StringUtil.getSubstring(specialString, 12);
      expect(str.startsWith('�?)).assertTrue();
    });

    it('CommonUtilTest_expect_test9', 0, () => {
      const str: string = StringUtil.anonymizeString('a');
      const subStr: string = StringUtil.getSubstringByBytes('测试test 测试123', 7);
      expect(subStr.length > 0).assertTrue();
    });

    it('CommonUtilTest_expect_test10', 0, () => {
      const str: string = StringUtil.getSubstringByBytes('测试test', 100);
      expect(str.length > 0).assertTrue();
    });
  })
}

function isNotEmptyTest() {
  let a: string = 'a';
  expect(StringUtil.isNotEmpty(a)).assertTrue();
  a = '';
  expect(StringUtil.isNotEmpty(a)).assertFalse();
}

function isSameParamsTest() {
  let a: string = 'a';
  let b: string = 'b';
  expect(StringUtil.isSameParams(a, b)).assertFalse();
  a = '';
  b = '';
  expect(StringUtil.isSameParams(a, b)).assertTrue();
}

function getStringLengthTest() {
  let a: string = 'abc';
  expect(StringUtil.getStringLength(a) === 3).assertTrue();
  StringUtil.getStringLength('abcd测试字串！@#�?%·丶end');
}

function CommonUtilTest2() {
  let a: string = 'a';
  expect(StringUtil.stringToUint8Array(a) instanceof Uint8Array).assertTrue();
  a = '';
  StringUtil.stringToUint8Array(a)

  a = `{ 'name': 'Tom', 'age': 17 }`;
  let uint8Array: Uint8Array = StringUtil.stringToUint8Array(a);
  let uint8ArrayEmpty: Uint8Array = StringUtil.stringToUint8Array('');

  let base64String: string = StringUtil.uint8ArrayToBase64String(uint8Array)
  StringUtil.base64StringToUint8Array(base64String);
  StringUtil.base64StringToUint8Array('');
  StringUtil.uint8ArrayToBase64String(uint8ArrayEmpty);

  let json: string = StringUtil.uint8ArrayToStringByJson(uint8Array);
  StringUtil.stringToUint8ArrayTextEncoder('');
  StringUtil.stringToUint8ArrayTextEncoder(json);
  StringUtil.uint8ArrayToStringByJson(uint8ArrayEmpty);

  StringUtil.getSubstring('', 2);
  StringUtil.getSubstring(a, 2);

  StringUtil.anonymizeString(a);
  StringUtil.anonymizeString('');

  StringUtil.getSubstringByBytes('', 2);
  StringUtil.getSubstringByBytes(a, 2);

  StringUtil.getStringByteLength(a);

  StringUtil.hashCode32(a);
  StringUtil.hashCode32(undefined);

  StringUtil.generateUuid();

  StringUtil.getAnonymizedContactId('');
  StringUtil.getAnonymizedContactId('1_1_13011111111');

  StringUtil.uintArray2String(uint8Array);

  StringUtil.uint8ArrayToStringByJson(undefined);

  let jsonStr: string = `{ 'name': 'Tom' }`;
  StringUtil.getSubstring(jsonStr, 1000);
  let specialString: string = `测试· 中文繁体`;
  StringUtil.getSubstring(specialString, 12);
  StringUtil.anonymizeString('a');
  StringUtil.getSubstringByBytes('测试test', 100);
  StringUtil.getSubstringByBytes('测试test 测试123', 7);
}

function getTableNameFromUriTest() {
  expect(StringUtil.getTableNameFromUri('') === '').assertTrue();
  expect(StringUtil.getTableNameFromUri('datashare:////datashare:///com.ohos.intelligentscene/phonedatashare:///com.ohos.intelligentscene/phone/IntelligentScene/MODE_DATA?Proxy=true') === '').assertTrue();
  expect(StringUtil.getTableNameFromUri('tableName') === '').assertTrue();
  expect(StringUtil.getTableNameFromUri('datashare:///com.ohos.intelligentscene/phone/IntelligentScene/MODE_DATA?Proxy=true') === 'MODE_DATA').assertTrue();
  expect(StringUtil.getTableNameFromUri('datashare:///com.ohos.intelligentscene/phone/IntelligentScene/MODE_DATA') === '').assertTrue();
  expect(StringUtil.getTableNameFromUri('/MODE_DATA') === '').assertTrue();
}

function getAnonymizedTableNameTest() {
  expect(StringUtil.getAnonymizedTableName('') === '').assertTrue();
  expect(StringUtil.getAnonymizedTableName('MODE_DATA_TABLE') === 'MODE_DA').assertTrue();
}