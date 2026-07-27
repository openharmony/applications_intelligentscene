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

import Settings from '@ohos.settings';
import dataShare from '@ohos.data.dataShare';
import taskpool from '@ohos.taskpool';
import type common from '@ohos.app.ability.common';
import osAccount from '@ohos.account.osAccount';
import type { AsyncCallback } from '@ohos.base';
import { LogUtil } from './LogUtil';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { StringUtil } from './StringUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';

const TAG = 'SettingsDataUtils : ';

@Concurrent
function getValueSync(key: string, defaultValue: string, context: common.Context, domain?: string): string {
  if (domain) {
    return Settings.getValueSync(context, key, defaultValue ?? '', domain);
  }
  return Settings.getValueSync(context, key, defaultValue ?? '');
}

/**
 * 设置数据库工具类
 *
 * @since 2022-06-29
 */
export class SettingsDataUtils {
  public static readonly settingsDataUrl = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=';
  public static readonly settingsDataUserUrl = 'datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_';

  static getSettingsData(key: string, defaultValue: string, domain?: string): string {
    if (StringUtil.isEmpty(key)) {
      LogUtil.showWarn(TAG, 'getSettingsData key invalid');
      return '';
    }
    let context: common.Context | undefined = SettingsDataUtils.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showError(TAG, 'getSettingsData failed, context is undefined');
      return defaultValue ?? '';
    }
    try {
      if (domain) {
        return Settings.getValueSync(context, key, defaultValue ?? '', domain);
      }
      return Settings.getValueSync(context, key, defaultValue ?? '');
    } catch (error) {
      LogUtil.showError(TAG, `getValueSync failed, ${error?.message}`);
    }
    return defaultValue ?? '';
  }

  static getSettingsDataWithContext(context: common.Context, key: string, defaultValue: string,
    domain?: string): string {
    if (StringUtil.isEmpty(key)) {
      LogUtil.showWarn(TAG, 'getSettingsData key invalid');
      return '';
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showError(TAG, 'getSettingsData failed, context is undefined');
      return defaultValue ?? '';
    }
    if (domain) {
      return Settings.getValueSync(context, key, defaultValue ?? '', domain);
    }
    return Settings.getValueSync(context, key, defaultValue ?? '');
  }

  static getSystemValue(key: string, defaultValue: string): string {
    return SettingsDataUtils.getSettingsData(key, defaultValue, Settings.domainName.USER_PROPERTY);
  }

  static getSecureValue(key: string, defaultValue: string): string {
    return SettingsDataUtils.getSettingsData(key, defaultValue, Settings.domainName.USER_SECURITY);
  }

  static async getSettingsDataAsync(key: string, defaultValue: string, domain?: string): Promise<string> {
    if (!key) {
      LogUtil.showWarn(TAG, 'getSettingsData key invalid');
      return '';
    }
    let context: common.Context | undefined = SettingsDataUtils.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showError(TAG, 'getSettingsData failed, context is undefined');
      return defaultValue ?? '';
    }
    return String(await SettingsDataUtils.doTask(getValueSync, key, defaultValue, domain as string));
  }

  static setSettingsData(key: string, value: string, domain?: string): boolean {
    if (StringUtil.isEmpty(key)) {
      LogUtil.showWarn(TAG, 'setSettingsData key invalid');
      return false;
    }
    let context: common.Context | undefined = SettingsDataUtils.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showError(TAG, 'setSettingsData failed, context is undefined');
      return false;
    }
    LogUtil.showInfo(TAG, `setSettingsData key: ${key}`);
    try {
      if (domain) {
        return Settings.setValueSync(context, key, value ?? '', domain);
      } else {
        return Settings.setValueSync(context, key, value ?? '');
      }
    } catch (e) {
      LogUtil.showError(TAG, `setSettingsData error: ${e?.code} ${e?.message}`);
      return false;
    }
  }

  static setSettingsDataAsync(key: string, value: string, domain?: string): void {
    if (StringUtil.isEmpty(key)) {
      LogUtil.showWarn(TAG, 'setSettingsDataAsync key invalid');
      return;
    }
    SettingsDataUtils.setSettingsDataAsyncWithContext(SettingsDataUtils.getContext() as Context,
      key, value ?? '', domain);
  }

  static setSettingsDataAsyncWithContext(context: common.Context, key: string, value: string, domain?: string): void {
    if (StringUtil.isEmpty(key)) {
      LogUtil.showWarn(TAG, 'setValue key invalid');
      return;
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showWarn(TAG, 'setValue context invalid');
      return;
    }

    LogUtil.showInfo(TAG, `setSettingsDataAsyncWithContext key: ${key}, value: ${value}`);
    try {
      if (domain) {
        Settings.setValue(context, key, value ?? '', domain);
      } else {
        Settings.setValue(context, key, value ?? '');
      }
    } catch (e) {
      LogUtil.showError(TAG, `setSettingsDataAsyncWithContext error: ${e?.code} ${e?.message}`);
    }
  }

  static setSystemValue(key: string, value: string): void {
    SettingsDataUtils.setSettingsData(key, value, Settings.domainName.USER_PROPERTY);
  }

  static setSecureValue(key: string, value: string): boolean {
    return SettingsDataUtils.setSettingsData(key, value, Settings.domainName.USER_SECURITY);
  }

  static setSettingsDataDomain(key: string, value: string, domainName: string): void {
    SettingsDataUtils.setSettingsData(key, value, domainName);
  }

  static getSettingsDataDomain(key: string, defaultValue: string, domainName: string): string {
    return SettingsDataUtils.getSettingsData(key, defaultValue, domainName);
  }

  static registerKeyObserver(key: string, observer: AsyncCallback<void>): boolean {
    try {
      return Settings.registerKeyObserver(SettingsDataUtils.getContext(), key,
        Settings.domainName.DEVICE_SHARED, observer);
    } catch (e) {
      LogUtil.showError(TAG, `Settings registerKeyObserver error: ${e?.code} ${e?.message}`);
      return false;
    }
  }

  static unregisterKeyObserver(key: string): boolean {
    return Settings.unregisterKeyObserver(SettingsDataUtils.getContext(), key, Settings.domainName.DEVICE_SHARED);
  }

  static registerKeyObserverUser(key: string, observer: AsyncCallback<void>): boolean {
    try {
      return Settings.registerKeyObserver(SettingsDataUtils.getContext(), key,
        Settings.domainName.USER_PROPERTY, observer);
    } catch (e) {
      LogUtil.showError(TAG, `Settings registerKeyObserverUser error: ${e?.code} ${e?.message}`);
      return false;
    }
  }

  static unregisterKeyObserverUser(key: string): boolean {
    return Settings.unregisterKeyObserver(SettingsDataUtils.getContext(), key, Settings.domainName.USER_PROPERTY);
  }

  static registerKeyObserverWithDomain(key: string, domainName: string, observer: AsyncCallback<void>): boolean {
    try {
      return Settings.registerKeyObserver(SettingsDataUtils.getContext(), key, domainName, observer);
    } catch (e) {
      LogUtil.showError(TAG, `Settings registerKeyObserverWithDomain error: ${e?.code} ${e?.message}`);
      return false;
    }
  }

  static unregisterKeyObserverWithDomain(key: string, domainName: string): boolean {
    if (SettingsDataUtils.getContext()) {
      return Settings.unregisterKeyObserver(SettingsDataUtils.getContext(), key, domainName);
    }
    LogUtil.showError(TAG, 'unregisterKeyObserverWithDomain failed, context is undefined');
    return false;
  }

  static getSupport(key: string, value: string): void {
    SettingsDataUtils.setSettingsData(key, value);
  }

  static getSettingsUri(key: string): string {
    if (!key) {
      LogUtil.showWarn(TAG, 'getSettingsUri key invalid');
      return '';
    }
    return SettingsDataUtils.settingsDataUrl + key;
  }

  static async getSettingsSecurityUri(key: string): Promise<string> {
    try {
      let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
      let id: number = await accountManager.getOsAccountLocalId();
      let url =
        `datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_${id}?Proxy=true&key=${key}`;
      return url;
    } catch (err) {
      LogUtil.showError(TAG, `key: ${key} getOsAccountLocalId fail: ${err?.code} ${err?.message}`);
      return '';
    }
  }

  static async getSettingsUserUri(key: string): Promise<string> {
    try {
      let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
      let id: number = await accountManager.getOsAccountLocalId();
      let url: string = `${SettingsDataUtils.settingsDataUserUrl}${id}?Proxy=true&key=${key}`;
      return url;
    } catch (err) {
      LogUtil.showError(TAG, `getOsAccountLocalId fail: ${err?.code} ${err?.message}`);
      return '';
    }
  }

  static registerDataChange(dataHelper: dataShare.DataShareHelper, key: string, onDataChange: () => void): void {
    if (!dataHelper || !onDataChange) {
      LogUtil.showWarn(TAG, 'registerDataChange params invalid');
      return;
    }
    let uri = SettingsDataUtils.getSettingsUri(key);
    if (!uri) {
      LogUtil.showError(TAG, 'registerDataChange uri invalid');
      return;
    }
    try {
      dataHelper.on('dataChange', uri, onDataChange);
    } catch (err) {
      LogUtil.showError(TAG, `dataHelper on dataChange fail: ${err?.code} ${err?.message}`);
    }
  }

  static unRegisterDataChange(dataHelper: dataShare.DataShareHelper, key: string, offDataChange?: () => void): void {
    if (!dataHelper) {
      LogUtil.showWarn(TAG, 'unRegisterDataChange params invalid');
      return;
    }
    let uri = SettingsDataUtils.getSettingsUri(key);
    if (!uri) {
      LogUtil.showError(TAG, 'unRegisterDataChange uri invalid');
      return;
    }
    try {
      if (offDataChange) {
        dataHelper.off('dataChange', uri, offDataChange);
      } else {
        dataHelper.off('dataChange', uri);
      }
    } catch (err) {
      LogUtil.showError(TAG, `dataHelper off dataChange fail: ${err?.code} ${err?.message}`);
    }
  }

  static registerSecurityDataChange(dataHelper: dataShare.DataShareHelper, key: string,
    onDataChange: () => void): void {
    if (!dataHelper || !onDataChange) {
      LogUtil.showWarn(TAG, 'registerDataChange params invalid');
      return;
    }
    SettingsDataUtils.getSettingsSecurityUri(key).then((uri) => {
      try {
        dataHelper.on('dataChange', uri, onDataChange);
      } catch (err) {
        LogUtil.showError(TAG, `dataHelper on dataChange fail: ${err?.code} ${err?.message}`);
      }
    });
  }

  static unRegisterSecurityDataChange(dataHelper: dataShare.DataShareHelper, key: string,
    offDataChange?: () => void): void {
    if (!dataHelper) {
      LogUtil.showWarn(TAG, 'unRegisterSecurityDataChange params invalid');
      return;
    }
    SettingsDataUtils.getSettingsSecurityUri(key).then((uri) => {
      try {
        if (offDataChange) {
          dataHelper.off('dataChange', uri, offDataChange);
        } else {
          dataHelper.off('dataChange', uri);
        }
      } catch (err) {
        LogUtil.showError(TAG, `dataHelper off dataChange fail: ${err?.code} ${err?.message}`);
      }
    });
  }

  static registerUserDataChange(dataHelper: dataShare.DataShareHelper, key: string, onDataChange: () => void): void {
    if (!dataHelper || !onDataChange) {
      LogUtil.showWarn(TAG, 'registerDataChange params invalid');
      return;
    }
    SettingsDataUtils.getSettingsUserUri(key)
      .then((uri) => {
        try {
          dataHelper.on('dataChange', uri, onDataChange);
        } catch (err) {
          LogUtil.showError(TAG, `dataHelper on dataChange fail: ${err?.code} ${err?.message}`);
        }
      });
  }

  static unRegisterUserDataChange(dataHelper: dataShare.DataShareHelper, key: string,
    offDataChange?: () => void): void {
    if (!dataHelper) {
      LogUtil.showWarn(TAG, `unRegisterSecurityDataChange params invalid`);
      return;
    }
    SettingsDataUtils.getSettingsUserUri(key).then((uri) => {
      try {
        if (offDataChange) {
          dataHelper.off('dataChange', uri, offDataChange);
        } else {
          dataHelper.off('dataChange', uri);
        }
      } catch (err) {
        LogUtil.showError(TAG, `dataHelper off dataChange fail: ${err?.code} ${err?.message}`);
      }
    });
  }

  static createDataHelper(key: string): Promise<dataShare.DataShareHelper> | undefined {
    let uri = SettingsDataUtils.getSettingsUri(key);
    if (!uri) {
      LogUtil.showError(TAG, 'createDataHelper uri invalid');
      return undefined;
    }
    let pageContext: common.Context | undefined = SettingsDataUtils.getContext();

    try {
      if (pageContext !== undefined) {
        return dataShare.createDataShareHelper(pageContext, uri);
      }
    } catch (error) {
      LogUtil.showError(TAG, `createDataShareHelper failed ${error?.code}, ${error?.message}`);
    }

    return undefined;
  }

  private static async doTask(func: Function, ...args: Object[]): Promise<Object> {
    try {
      let context: common.Context = SettingsDataUtils.getContext() as Context;
      args.push(context);
      const dbTask = new taskpool.Task(func, ...args);
      return await taskpool.execute(dbTask);
    } catch (err) {
      LogUtil.showError(TAG, `doTask error when execute ${func.name}, ${err?.message}`);
    }

    return '';
  }

  public static getContext(): common.Context | undefined {
    let context = AbilityContextManager.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getStageContext();
    }
    return context;
  }

  static setSettingsDataWithContext(context: common.Context, key: string, value: string, domain?: string): void {
    if (StringUtil.isEmpty(key) || !context) {
      LogUtil.showWarn(TAG, 'setSettingsDataWithContext key invalid or context is empty');
      return;
    }
    LogUtil.showInfo(TAG, 'setSettingsDataWithContext key: ${key}');
    try {
      if (domain) {
        Settings.setValueSync(context, key, value ?? '', domain);
      } else {
        Settings.setValueSync(context, key, value ?? '');
      }
    } catch (e) {
      LogUtil.showError(TAG, `setSettingsDataWithContext error: ${e?.code} ${e?.message}`);
    }
  }
}
