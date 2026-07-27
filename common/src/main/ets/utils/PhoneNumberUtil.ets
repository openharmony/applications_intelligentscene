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

import i18n from '@ohos.i18n';
import call from '@ohos.telephony.call';
import { LogUtil } from './LogUtil';
import { CheckEmptyUtils } from './CheckEmptyUtils';

const TAG: string = 'PhoneNumberUtil';

/**
 * 时间工具类
 */
export class PhoneNumberUtil {

  static clearPhoneNumberSymbols(phoneNumber: string): string {
    if (!phoneNumber || phoneNumber === '') {
      return '';
    }
    let commaIndex = phoneNumber.indexOf(',');
    let semicolonIndex = phoneNumber.indexOf(';');
    if (semicolonIndex >= 0 && commaIndex === -1) {
      phoneNumber = phoneNumber.substring(0, semicolonIndex);
    } else if (commaIndex >= 0 && semicolonIndex === -1) {
      phoneNumber = phoneNumber.substring(0, commaIndex);
    } else if (semicolonIndex >= 0 && commaIndex >= 0) {
      if (commaIndex > semicolonIndex) {
        phoneNumber = phoneNumber.substring(0, semicolonIndex);
      } else {
        phoneNumber = phoneNumber.substring(0, commaIndex);
      }
    }
    return phoneNumber;
  }

  static async formatPhoneNumber(phoneNumber: string): Promise<string> {
    phoneNumber = PhoneNumberUtil.clearPhoneNumberSymbols(phoneNumber);
    if (CheckEmptyUtils.isEmpty(phoneNumber)) {
      LogUtil.showError(TAG, 'phoneNumber is empty');
      return phoneNumber;
    }
    let countryId: string = i18n.System.getSystemRegion();
    let options: call.NumberFormatOptions = {
      countryCode: countryId
    }
    let formatNumber: string = '';
    try {
      formatNumber = await call.formatPhoneNumber(phoneNumber, options);
    } catch (error) {
      LogUtil.showError(TAG, `formatPhoneNumber error: ${error?.code}, ${error?.message}`);
    }
    if (CheckEmptyUtils.isEmpty(formatNumber)) {
      LogUtil.showInfo(TAG, 'formatNumber is empty');
      formatNumber = phoneNumber;
    }
    return formatNumber;
  }
}