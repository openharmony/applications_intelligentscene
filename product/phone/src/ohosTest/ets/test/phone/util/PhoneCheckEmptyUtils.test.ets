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
  beforeEach,
  afterEach,
  it,
  expect,
  beforeAll,
  afterAll,
} from '@ohos/hypium';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';

export default function PhoneCheckEmptyUtilsTest() {
  describe('PhoneCheckEmptyUtilsTest', () => {
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

    it('PhoneCheckEmptyUtilsTest_should_return_true_when_obj_is_undefined', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(undefined);
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_when_obj_is_null', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(null);
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_when_obj_is_empty_string', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty('');
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_non_empty_string', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty('Hello');
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_non_empty_array', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty([1, 2, 3]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_non_empty_object', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty({
        name: 'John'
      } as TestData);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_number', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(42);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_boolean', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(true);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_function', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(() => {
      });
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_Date', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(new Date());
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_RegExp', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(/abc/);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_Map', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(new Map());
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_BigInt', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(BigInt(42));
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(globalThis);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_property', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(globalThis.Array);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_method', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(globalThis.parseInt);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_function', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(globalThis.isNaN);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_constructor', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(globalThis.Object);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_instance', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(new globalThis.Object());
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_string_instance', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(new globalThis.String('Hello'));
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_number_instance', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(new globalThis.Number(42));
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_boolean_instance', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(new globalThis.Boolean(true));
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_obj_is_a_global_object_map_instance', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmpty(new globalThis.Map());
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_when_input_is_undefined', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty(undefined);
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_when_input_is_empty_string', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty('');
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_when_input_is_string_with_only_spaces', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty('   ');
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_input_is_non_empty_string', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty('Hello');
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_input_is_string_with_spaces_and_characters', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty('  Hello  ');
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_when_array_is_empty_check_empty', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([]);
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_array_has_elements_check_empty', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([1, 2, 3]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_array_is_not_empty_and_has_only_one_element', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([1]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_array_is_not_empty_one_element_which_is_zero', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([0]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_array_is_not_empty_which_is_false', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([false]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_array_is_not_empty_which_is_empty_string', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr(['']);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_array_is_not_empty_and_has_only_one_element_which_is_empty_object', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([{ name : '111' } as TestData]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_when_array_is_not_empty_and_has_only_one_element_which_is_empty_array', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([[]]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_empty_test1', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr(['a']);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_empty_test2', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([1]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_empty_test3', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([[]]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_empty_test4', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([[1]]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_false_empty_test5', 0, async (done: Function) => {
      const result = CheckEmptyUtils.isEmptyArr([['a']]);
      expect(result).assertFalse();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_test6', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty('');
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_test7', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty(' ');
      expect(result).assertTrue();
      done();
    });

    it('PhoneCheckEmptyUtilsTest_should_return_true_test8', 0, async (done: Function) => {
      const result = CheckEmptyUtils.checkStrIsEmpty('     ');
      expect(result).assertTrue();
      done();
    });
  });
}

interface TestData {
  name: string
}