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

import { Context, contextConstant } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import { LogUtil } from './LogUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';

/* instrument ignore file */
const TAG: string = 'PreferencesUtil : ';

// UserConfigs
export const APP_CONFIG = 'defaultConfig';

/**
 * Preferences工具类
 *
 * @since 2025-01-09
 */
export class PreferencesUtil {
  /**
   * 获取key-value
   *
   * @param key
   * @param defValue
   * @returns
   */
  static async get(key: string, defValue: preferences.ValueType): Promise<preferences.ValueType> {
    try {
      const prefer: preferences.Preferences | undefined =
        await PreferencesUtil.getPreferences(AbilityContextManager.getContext() as Context, APP_CONFIG);
      if (!prefer) {
        LogUtil.showError(TAG, 'preference get fail, preference undefined');
        return defValue;
      }
      return await prefer.get(key, defValue);
    } catch (error) {
      LogUtil.showError(TAG, `preferences get key: ${key} error: ${error?.code}`);
      return defValue;
    }
  }

  /**
   * 子线程获取key-value
   *
   * @param key
   * @param defValue
   * @returns
   */
  static async getPreferencesData(key: string, defValue: preferences.ValueType,
    taskPoolContext: common.Context): Promise<preferences.ValueType> {
    try {
      const preferencesData: preferences.Preferences | undefined =
        await PreferencesUtil.getPreferences(taskPoolContext, APP_CONFIG);
      if (!preferencesData) {
        LogUtil.showError(TAG, 'getPreferencesData fail, preference undefined');
        return defValue;
      }
      return await preferencesData.get(key, defValue);
    } catch (error) {
      LogUtil.showError(TAG, `preferences getPreferencesData key: ${key} error: ${error?.message}`);
      return defValue;
    }
  }

  /**
   * 判断是否存在
   *
   * @param key
   * @returns 是否存在
   */
  static async has(key: string): Promise<boolean> {
    try {
      const prefer: preferences.Preferences | undefined =
        await PreferencesUtil.getPreferences(AbilityContextManager.getContext() as Context, APP_CONFIG);
      if (!prefer) {
        LogUtil.showError(TAG, 'preference has fail, preference undefined');
        return false;
      }
      return await prefer.has(key);
    } catch (error) {
      LogUtil.showError(TAG, `preferences has key: ${key} error: ${error?.message}`);
      return false;
    }
  }

  /**
   * 同步接口，获取key-value
   *
   * @param key
   * @param defValue
   * @returns
   */
  static getSync(key: string, defValue: preferences.ValueType): preferences.ValueType {
    try {
      const prefer: preferences.Preferences | undefined =
        PreferencesUtil.getPreferencesSync(AbilityContextManager.getContext(), APP_CONFIG);
      if (!prefer) {
        LogUtil.showError(TAG, 'getSync fail, preference undefined');
        return defValue;
      }
      return prefer.getSync(key, defValue);
    } catch (error) {
      LogUtil.showError(TAG, `preferences getSync key: ${key} error: ${error?.message}`);
      return defValue;
    }
  }

  /**
   * 同步接口，获取key-value
   *
   * @param key
   * @param defValue
   * @param removeCache
   * @returns key对应的值
   */
  static getSyncCache(key: string, defValue: preferences.ValueType, removeCache: boolean): preferences.ValueType {
    const context: Context | undefined = AbilityContextManager.getContext();
    if (!context) {
      LogUtil.showError(TAG, 'getSyncCache failed. context undefined');
      return defValue;
    }
    const areaContext: common.ExtensionContext =
      AbilityContextManager.getAreaContext(context, contextConstant.AreaMode.EL2);
    try {
      if (removeCache) {
        let options: preferences.Options = { name: APP_CONFIG };
        preferences.removePreferencesFromCacheSync(areaContext, options);
      }
      return PreferencesUtil.getSync(key, defValue);
    } catch (error) {
      LogUtil.showError(TAG, `preferences getSyncCache key: ${key} error: ${error?.message}`);
      return defValue;
    }
  }

  /**
   * 同步接口，判断是否存在
   *
   * @param key
   * @returns
   */
  static hasSync(key: string): boolean {
    try {
      const prefer: preferences.Preferences | undefined =
        PreferencesUtil.getPreferencesSync(AbilityContextManager.getContext(), APP_CONFIG);
      if (!prefer) {
        LogUtil.showError(TAG, 'hasSync fail, preference undefined');
        return false;
      }
      return prefer.hasSync(key);
    } catch (error) {
      LogUtil.showError(TAG, `preferences hasSync key: ${key} error: ${error?.message}`);
      return false;
    }
  }

  /**
   * 新增/更新
   *
   * @param key
   * @param value
   * @returns
   */
  static async put(key: string, value: preferences.ValueType): Promise<void> {
    try {
      await PreferencesUtil.putValueWithPreferenceName(key, value, APP_CONFIG);
    } catch (error) {
      LogUtil.showError(TAG, `preferences put key: ${key} error: ${error?.message}`)
    }
  }

  /**
   * 子线程新增/更新
   *
   * @param key
   * @param value
   * @returns
   */
  static async putPreferencesData(key: string, value: preferences.ValueType,
    taskPoolContext: common.Context): Promise<void> {
    try {
      const preferencesData: preferences.Preferences | undefined =
        await PreferencesUtil.getPreferences(taskPoolContext, APP_CONFIG);
      if (!preferencesData) {
        LogUtil.showError(TAG, 'putPreferencesData fail, preference undefined');
        return;
      }
      await preferencesData.put(key, value);
      await preferencesData.flush();
    } catch (error) {
      LogUtil.showError(TAG, `preferences putPreferencesData key: ${key} error: ${error?.message}`);
    }
  }

  static putSync(key: string, value: preferences.ValueType): void {
    try {
      const prefer: preferences.Preferences | undefined =
        PreferencesUtil.getPreferencesSync(AbilityContextManager.getContext(), APP_CONFIG);
      if (!prefer) {
        LogUtil.showError(TAG, 'putSync fail, preference undefined');
        return;
      }
      prefer.putSync(key, value);
      prefer.flushSync();
      LogUtil.showInfo(TAG, `preferences putsync key: ${key} successful`);
    } catch (error) {
      LogUtil.showError(TAG, `preferences putsync key: ${key} error: ${error?.message}`);
    }
  }

  /**
   * 删除
   *
   * @param key
   * @returns
   */
  static async delete(key: string): Promise<void> {
    try {
      const prefer: preferences.Preferences | undefined =
        await PreferencesUtil.getPreferences(AbilityContextManager.getContext(), APP_CONFIG);
      if (!prefer) {
        LogUtil.showError(TAG, 'preference delete fail, preference undefined');
        return;
      }
      await prefer.delete(key);
      await prefer.flush();
    } catch (error) {
      LogUtil.showError(TAG, `preferences delete key: ${key} error: ${error?.message}`);
    }
  }

  /**
   * 同步接口，获取key-value
   *
   * @param key key
   * @param defValue 默认值
   * @param preferenceName 修改的preference
   * @returns key对应的value值
   */
  static getSyncWithPreferenceName(key: string, defValue: preferences.ValueType,
    preferenceName: string): preferences.ValueType {
    try {
      const prefer: preferences.Preferences | undefined =
        PreferencesUtil.getPreferencesSync(AbilityContextManager.getContext(), preferenceName);
      if (!prefer) {
        LogUtil.showError(TAG, 'getSyncWithPreferenceName fail, preference undefined');
        return defValue;
      }
      return prefer.getSync(key, defValue);
    } catch (error) {
      LogUtil.showError(TAG, `getSyncWithPreferenceName get key: ${key} error: ${error?.message}`);
      return defValue;
    }
  }

  /**
   * 新增/更新key-value
   *
   * @param key key
   * @param value 值
   * @param preferenceName 修改的preference
   */
  static async putValueWithPreferenceName(key: string, value: preferences.ValueType,
    preferenceName: string): Promise<void> {
    try {
      const prefer: preferences.Preferences | undefined =
        await PreferencesUtil.getPreferences(AbilityContextManager.getContext(), preferenceName);
      if (!prefer) {
        LogUtil.showError(TAG, 'putValueWithPreferenceName fail, preference undefined');
        return;
      }
      await prefer.put(key, value);
      await prefer.flush();
      LogUtil.showInfo(TAG, `preference put: ${key} successful`);
    } catch (error) {
      LogUtil.showError(TAG, `preferences putValueWithPreferenceName key: ${key} error: ${error?.message}`);
    }
  }

  /**
   * 获取Preference实例
   *
   * @param context 上下文
   * @param preferenceName preference名称
   * @param contextArea EL分区，此参数为空，默认EL2分区
   * @returns
   */
  static async getPreferences(context: Context | undefined,
    preferenceName: string): Promise<preferences.Preferences | undefined> {
    if (!context) {
      LogUtil.showError(TAG, `getPreferencesSync faild. context undefined`);
      return undefined;
    }
    try {
      const areaContext: common.ExtensionContext =
        AbilityContextManager.getAreaContext(context, contextConstant.AreaMode.EL2);
      return await preferences.getPreferences(areaContext, preferenceName);
    } catch (error) {
      LogUtil.showError(TAG, `getPreferences error: ${error?.code} ${error?.message}`);
    }
    return undefined;
  }

  /**
   * 获取Preference实例,同步方法
   *
   * @param context 上下文
   * @param preferenceName preference名称
   * @param contextArea EL分区，此参数为空，默认EL2分区
   * @returns
   */
  static getPreferencesSync(context: Context | undefined, preferenceName: string): preferences.Preferences | undefined {
    if (!context) {
      LogUtil.showError(TAG, `getPreferencesSync faild. context undefined`);
      return undefined;
    }
    try {
      const areaContext: common.ExtensionContext =
        AbilityContextManager.getAreaContext(context, contextConstant.AreaMode.EL2);
      const options: preferences.Options = { name: preferenceName };
      return preferences.getPreferencesSync(areaContext, options);
    } catch (error) {
      LogUtil.showError(TAG, `getPreferencesSync error: ${error?.code} ${error?.message}`);
    }
    return undefined;
  }
}