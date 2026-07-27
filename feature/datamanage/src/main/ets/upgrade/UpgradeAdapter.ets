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

/**
 * 升级配置抽象类，提供数据库升级时，对应的数据初始化接口
 */
export abstract class UpgradeAdapter {
  /**
   * 数据库版本升级时升级数据
   *
   * @param dbVersion 数据库升级版本号
   * @returns 数据初始化成功或不需要初始化返回true; 异常返回false
   */
  abstract upgradeData(dbVersion: number): Promise<boolean>;

  /**
   * 执行初始化数据函数
   *
   * @param funcMap 产品具体类的版本号-执行函数映射map
   * @param dbVersion 升级的版本号
   * @returns 数据初始化成功或不需要初始化返回true; 异常返回false
   */
  static async initUpgradedDbData(funcMap: Map<number, () => Promise<boolean>>, dbVersion: number): Promise<boolean> {
    if (!funcMap.has(dbVersion)) {
      return true;
    }
    return await funcMap.get(dbVersion)?.() ?? false;
  }
}
