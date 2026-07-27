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

import { describe, it, expect } from '@ohos/hypium';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PhoneNumberUtil } from '@ohos/scene.common/src/main/ets/utils/PhoneNumberUtil';

const TAG: string = 'PhoneNumberUtilTest: ';

export default function PhoneNumberUtilTest() {
  describe('PhoneNumberUtilTest', () => {

    it('should_return_empty_string_when_input_is_null_or_empty', 0, async (done: Function) => {
      expect(PhoneNumberUtil.clearPhoneNumberSymbols('')).assertEqual('');
      done();
    });

    it('should_return_substring_before_comma_when_comma_is_present_and_no_semicolon', 0, async (done: Function) => {
      expect(PhoneNumberUtil.clearPhoneNumberSymbols('123,456')).assertEqual('123');
      done();
    });

    it('should_return_substring_before_semicolon_when_semicolon_is_present_and_no_comma', 0, async (done: Function) => {
      expect(PhoneNumberUtil.clearPhoneNumberSymbols('123;456')).assertEqual('123');
      done();
    });

    it('should_return_substring_before_the_first_symbol_when_both_comma_and_semicolon_are_present', 0, async (done: Function) => {
      expect(PhoneNumberUtil.clearPhoneNumberSymbols('123,456;789')).assertEqual('123');
      expect(PhoneNumberUtil.clearPhoneNumberSymbols('123;456,789')).assertEqual('123');
      done();
    });

    it('should_return_empty_string_when_input_is_empty', 0, async (done: Function) => {
      const result = await PhoneNumberUtil.formatPhoneNumber("");
      expect(result).assertEqual("");
      done();
    });

    it('should_return_formatted_number_when_input_is_valid', 0, async (done: Function) => {
      const result = await PhoneNumberUtil.formatPhoneNumber("123-456-7890");
      LogUtil.showInfo(TAG, `${result}`);
      expect(result).assertEqual("123-456-7890");
      done();
    });

    it('should_return_original_number_when_formatted_number_is_empty', 0, async (done: Function) => {
      const result = await PhoneNumberUtil.formatPhoneNumber("123-456-7890");
      expect(result).assertEqual("123-456-7890");
      done();
    });

    it('should_handle_clearPhoneNumberSymbols_and_formatPhoneNumber_failure', 0, async (done: Function) => {
      const result = await PhoneNumberUtil.formatPhoneNumber("123-456-7890");
      expect(result).assertEqual("123-456-7890");
      done();
    });
  });
}