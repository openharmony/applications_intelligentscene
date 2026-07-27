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
import { JSON } from '@kit.ArkTS';
import buffer from '@ohos.buffer';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LogUtil } from './LogUtil';

const TAG: string = 'StringUtil: ';
const PHONE_NO_LEN: number = 4;
const CONTACT_ID_STR_LEN: number = 2;
const MAX_URI_LENGTH: number = 150;

/**
 * 字符串工具类
 */
export class StringUtil {
  private static readonly DEFAULT_LEN_OF_COMMON_STR: number = 6;
  private static readonly HALF_LEN_OF_COMMON_STR: number = 3;
  private static readonly LINK_OF_COMMON_STR: string = '****';
  // 用于uuid生成失败时备选方案，时间�?id拼接
  private static id: number = 1;

  /**
   * 判断字串是否是空字串
   * @param stringValue 字符�?
   */
  public static isEmpty(stringValue: string | null | undefined): boolean {
    return stringValue === undefined || stringValue === null || stringValue.length === 0;
  }

  /**
   * 判断字串是否是非空字�?
   * @param stringValue 字符�?
   */
  public static isNotEmpty(stringValue: string | null | undefined): boolean {
    return stringValue !== undefined && stringValue !== null && stringValue.length !== 0;
  }

  /**
   * 检查页面参数是否相�?
   *
   * @param targetPageParams target page params.
   * @param curPageParams current page params.
   * @returns true: same page
   */
  public static isSameParams(targetPageParams: string, curPageParams: string): boolean {
    if (CheckEmptyUtils.checkStrIsEmpty(curPageParams)) {
      return CheckEmptyUtils.checkStrIsEmpty(targetPageParams);
    } else {
      let newParam = curPageParams.replace(',isShowBack:false', '');
      return newParam === targetPageParams || curPageParams === targetPageParams;
    }
  }

  /**
   * 将字符串转码�?Uint8Array
   *
   * @return Uint8Array
   */
  static stringToUint8Array(val: string): Uint8Array {
    if (CheckEmptyUtils.checkStrIsEmpty(val)) {
      return new Uint8Array([]);
    }
    let textEncoder = new util.TextEncoder();
    try {
      return textEncoder.encodeInto(val);
    } catch (error) {
      LogUtil.showError(TAG, `stringToUint8Array error, ${error?.message}`);
    }
    return new Uint8Array([]);
  }

  /**
   * 通过json方法�?Uint8Array 转码为字符串
   *
   * @param val Uint8Array
   * @return 字符�?
   */
  static uint8ArrayToStringByJson(val: Uint8Array | undefined): string {
    if (!val) {
      return '';
    }

    let arrNumber: number[] = [];
    for (const element of val) {
      arrNumber.push(element);
    }

    return JSON.stringify(arrNumber);
  }

  /**
   * 将base64转换的字符串转码�?Uint8Array
   *
   * @return Uint8Array
   */
  static base64StringToUint8Array(val: string): Uint8Array {
    if (CheckEmptyUtils.checkStrIsEmpty(val)) {
      return new Uint8Array([]);
    }
    let buf: buffer.Buffer = buffer.from(val, 'base64');
    return Uint8Array.from(buf.values());
  }

  /**
   * 将Uint8Array转换为base64字符�?
   *
   * @return Uint8Array
   */
  static uint8ArrayToBase64String(array: Uint8Array): string {
    if (!array || array.length === 0) {
      return '';
    }
    return buffer.from(Array.from(array)).toString('base64');
  }

  /**
   * 通过TextEncoder方法将字符串转码�?Uint8Array
   *
   * @param val 待转换字符串
   * @return Uint8Array 字串对应的Uint8Array
   */
  static stringToUint8ArrayTextEncoder(val: string): Uint8Array {
    if (!val) {
      return new Uint8Array([]);
    }
    let textEncoder = new util.TextEncoder();
    try {
      return textEncoder.encodeInto(val);
    } catch (error) {
      LogUtil.showError(TAG, `stringToUint8Array error, ${error?.message}`);
    }
    return new Uint8Array([]);
  }

  /**
   * 获得字符串的字符�?
   * @param value 字符�?
   * @returns  字符�?
   */
  static getStringLength(value: string): number {
    if (value === undefined || value === null) {
      return 0;
    }
    let len: number = 0;
    for (let i = 0; i < value.length; i++) {
      let charStr = value.charCodeAt(i);
      //单字节加1
      if ((charStr >= 0x0001 && charStr <= 0x007e) || (0xff60 <= charStr && charStr <= 0xff9f)) {
        len++;
      } else {
        len += 3;
      }
    }
    return len;
  }

  /**
   * 获得该字串的0-subStringLength个字节子�?
   *
   * @param value 字串
   * @param subStringLength 字节�?
   * @returns 0-subStringLength个字节子�?
   */
  static getSubstring(value: string, subStringLength: number): string {
    if (value === undefined || value === null || StringUtil.getStringLength(value) <= subStringLength) {
      return value;
    }

    let maxLengthIndex: number = 0;
    let len: number = 0;
    for (let i = 0; i < value.length; i++) {
      let charStr = value.charCodeAt(i);
      //单字节加1
      if ((charStr >= 0x0001 && charStr <= 0x007e) || (0xff60 <= charStr && charStr <= 0xff9f)) {
        len++;
      } else {
        len += 3;
      }
      if (len <= subStringLength) {
        maxLengthIndex++;
      } else {
        return value.substring(0, maxLengthIndex);
      }
    }

    return value;
  }

  /**
   * get anonymization string
   *
   * @param {string} originStr - string
   * @return {string} - anonymization string
   */
  public static anonymizeString(originStr: string): string {
    if (!originStr) {
      return originStr;
    }
    if (originStr.length <= StringUtil.DEFAULT_LEN_OF_COMMON_STR) {
      return originStr;
    }
    return originStr.substring(0, StringUtil.HALF_LEN_OF_COMMON_STR) + StringUtil.LINK_OF_COMMON_STR +
      originStr.substring(originStr.length - StringUtil.HALF_LEN_OF_COMMON_STR);
  }

  /**
   * 获取字串的前size个字节子�?
   *
   * @param value 字串
   * @param size 字节�?
   * @returns 前size字节子串
   */
  public static getSubstringByBytes(value: string, size: number): string {
    if (!value || StringUtil.getStringLength(value) <= size) {
      return value;
    }

    let tempString: string = '';
    let result: string = '';
    for (let index = 0; index < value.length; index++) {
      tempString = tempString + value[index];
      if (StringUtil.isFourBytesChar(value, index)) {
        index++;
        tempString = tempString + value[index];
      }
      if (StringUtil.getStringByteLength(tempString) <= size) {
        result = tempString;
      } else {
        return result;
      }
    }
    return result;
  }

  /**
   * 获取字串的字节数
   *
   * @param value 字串
   * @returns 字节�?
   */
  public static getStringByteLength(str: string): number {
    let byteLength = buffer.from(str || '', 'utf8')?.length;
    return byteLength;
  }

  /**
   * 快速返�?2位数字hash算法
   *
   * @param str
   * @returns 0 or hash
   */
  public static hashCode32(str: string | undefined): number {
    let hash: number = 0;
    if (str === undefined) {
      return hash;
    }
    for (let i = 0; i < str.length; i++) {
      let chr = str.charCodeAt(i);
      hash = (hash << 5) - hash + chr;
      // Convert to 32bit integer
      hash |= 0;
    }
    return hash;
  }

  /**
   * 生成uuid�?如果接口调用失败返回时间�?自增id.
   *
   * @returns uuid
   */
  public static generateUuid(): string {
    let uuid: string = '';
    try {
      uuid = util.generateRandomUUID(false);
      uuid = uuid?.replaceAll('-', '');
    } catch (err) {
      LogUtil.showError(TAG, `generateUuid error code: ${err?.code}, message:, ${err?.message}`);
    }
    if (uuid === '') {
      uuid = new Date().getTime().toString() + '_' + StringUtil.id;
      StringUtil.id++;
    }
    return uuid;
  }

  /**
   * 匿名打印contactId, 打印modeId_policy_phoneNo后四�?
   *
   * @param id contactId
   * @returns 匿名化字符串
   */
  public static getAnonymizedContactId(id: string): string {
    let splitStr: string[] = id.split('_');
    if (CheckEmptyUtils.isEmptyArr(splitStr) || splitStr.length <= CONTACT_ID_STR_LEN) {
      return id;
    }
    let phoneNo: string = splitStr[CONTACT_ID_STR_LEN];
    if (phoneNo.length > PHONE_NO_LEN) {
      phoneNo = phoneNo.slice(phoneNo.length - PHONE_NO_LEN, phoneNo.length);
    }
    return `${splitStr[0]}_${splitStr[1]}_${phoneNo}`;
  }

  /**
   * 匿名化打印数据库表名
   *
   * @param tableName 表名
   * @returns 否则返回表名前一�?
   */
  public static getAnonymizedTableName(tableName: string): string {
    return tableName.substring(0, tableName.length / 2);
  }

  /**
   * 通过正则表达式匹配从URI中获取表�?
   * 格式：datashare:///com.ohos.intelligentscene/phone/IntelligentScene/${tableName}?Proxy=true
   *
   * @param uri DataShareHelper访问传入uri参数
   * @returns 表名
   */
  public static getTableNameFromUri(uri: string): string {
    if (uri === '' || uri.length > MAX_URI_LENGTH) {
      LogUtil.showError(TAG, `getTableNameFromUri, invalid uri: ${uri.length}`);
      return '';
    }
    const tableNamePattern = '/([^/?]+)\\?Proxy';
    const matchArray: string[] | null = uri.match(tableNamePattern);
    return matchArray && matchArray[1] ? matchArray[1] : '';
  }

  /**
   * 解析unitArray数据，避免中文乱�?
   *
   * @param unitArray unitArray数据
   * @returns 字符�?
   */
  public static uintArray2String(unitArray: Uint8Array): string {
    try {
      let decoder: util.TextDecoder = util.TextDecoder.create();
      return decoder.decodeToString(unitArray);
    } catch (e) {
      LogUtil.showError(TAG, `uintArray2String error ${e?.code}, ${e?.message}`);
    }
    return '';
  }

  /**
   * 将数字字符串保留N位小数字�?
   *
   * @param numericStr 数字符串
   * @param retainedDecimalPlaces 默认保留5位小�?
   * @returns 子字符串
   */
  public static fixedString(numericStr: string, retainedDecimalPlaces: number = 5): string {
    if (!numericStr) {
      return '';
    }
    try {
      return Number.parseFloat(numericStr).toFixed(retainedDecimalPlaces);
    } catch (e) {
      LogUtil.showError(TAG, `numericStr2SpecifiedNumberStr error ${e?.code}, ${e?.message}`);
    }
    return numericStr;
  }

  private static isFourBytesChar(value: string, index: number): boolean {
    if (!value) {
      return false;
    }
    let code: number | undefined = value.codePointAt(index);
    if (code == undefined) {
      return false;
    }
    return code > 0xFFFF ? true : false;
  }
}