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

import { contextConstant } from '@kit.AbilityKit';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';

/**
 * 升级配置数据结构
 */
export interface UpgradeConfig {
  /**
   * 产品，phone(pad)/pc/wearable
   */
  product: string,

  /**
   * 数据库文件分区，EL1/EL2/EL3
   */
  area: contextConstant.AreaMode,

  /**
   * 数据库升级脚本存放路径
   */
  scriptsPath: string,

  /**
   * 获取RdbStore实例方法
   */
  getRdbStore: () => RdbStoreHelper,
}

export const PHONE_UPGRADE_CONFIGS: UpgradeConfig[] = [
  {
    product: 'phone',
    area: contextConstant.AreaMode.EL2,
    scriptsPath: 'rawfile/phone/dbUpgrades.json',
    getRdbStore: () => RdbStoreHelper.getInstance()
  },
  {
    product: 'phone',
    area: contextConstant.AreaMode.EL1,
    scriptsPath: 'rawfile/phone/dbUpgradesEL1.json',
    getRdbStore: () => El1RdbStoreHelper.getInstance()
  },
];

export const WEARABLE_UPGRADE_CONFIGS: UpgradeConfig[] = [
  {
    product: 'wearable',
    area: contextConstant.AreaMode.EL2,
    scriptsPath: 'rawfile/phone/dbUpgrades.json',
    getRdbStore: () => RdbStoreHelper.getInstance()
  },
];
