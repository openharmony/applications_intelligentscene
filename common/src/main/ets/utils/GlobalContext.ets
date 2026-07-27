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

import { LogUtil } from './LogUtil';
import { StringUtil } from './StringUtil';

const TAG: string = 'GlobalContext: ';

/**
 * GlobalThis变量名常量枚举,不能重复
 */
export enum GlobalCtxKey {

  /**
   * trace打印的task和method的对应关系map
   */
  GLOBAL_KEY_TASK_ID_MAP = 'taskIdMap',

  /**
   * trace索引
   */
  GLOBAL_KEY_TRACE_INDEX = 'traceIndex',
}

// 替代globalThis的单例
export class GlobalContext {
  private static instance: GlobalContext | null = null;
  private contextMap = new Map<string, Object>();

  private constructor() {
  }

  public static getInstance(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  set<T>(key: string, value: T): void {
    if (StringUtil.isEmpty(key)) {
      LogUtil.showError(TAG, 'The key is empty, return set');
      return;
    }
    this.contextMap.set(key, value as Object);
  }

  get<T>(key: string, defaultValue?: T): T | undefined {
    if (StringUtil.isEmpty(key) || !this.contextMap.has(key)) {
        LogUtil.showInfo(TAG, 'The key is empty, return default value');
      return defaultValue;
    }
    return this.contextMap.get(key) as T ?? defaultValue;
  }

  remove(key: string): void {
    if (StringUtil.isEmpty(key)) {
      LogUtil.showError(TAG, 'The key is empty, return remove');
      return;
    }
    this.contextMap.delete(key);
  }
}