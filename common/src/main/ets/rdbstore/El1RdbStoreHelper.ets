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

import rdb from '@ohos.data.relationalStore';
import { contextConstant } from '@kit.AbilityKit';
import { RdbStoreHelper } from './RdbStoreHelper';

const EL1_RDB_CONFIG: rdb.StoreConfig = {
  name: 'IntelligentSceneEL1.db',
  securityLevel: rdb.SecurityLevel.S1,
  encrypt: false,
  isSearchable: true,
  haMode: rdb.HAMode.MAIN_REPLICA, // 配置为双写备份
  allowRebuild: true,
};

/**
 * EL1分区数据库操作帮助类
 */
export class El1RdbStoreHelper extends RdbStoreHelper {
  protected static instance: El1RdbStoreHelper;
  protected tag: string = 'El1RdbStoreHelper :';
  protected dbName: string = 'IntelligentSceneEL1.db';
  protected backupDbName: string = 'IntelligentSceneEL1Backup.db';
  protected area: contextConstant.AreaMode = contextConstant.AreaMode.EL1;
  protected rdbStoreConfig: rdb.StoreConfig = EL1_RDB_CONFIG;
  protected isNeedCloudSync: boolean = false;

  public static getInstance(): El1RdbStoreHelper {
    if (El1RdbStoreHelper.instance == null) {
      El1RdbStoreHelper.instance = new El1RdbStoreHelper();
    }
    return El1RdbStoreHelper.instance;
  }
}
