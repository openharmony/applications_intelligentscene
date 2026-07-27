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

import DataShareExtensionAbility from '@ohos.application.DataShareExtensionAbility';
import Want from '@ohos.app.ability.Want';
import { AsyncCallback, BusinessError } from '@ohos.base';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import dataShare from '@ohos.data.dataShare';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager';
import { CursorDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/CursorDataManager';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { DB_CONFIG, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';

/* instrument ignore file */
const TAG: string = 'DataExtAbility : ';
const INVALID_URI_ERROR: BusinessError = { name: 'INVALID_URI_ERROR', code: INVALID_VALUE, message: 'Invalid table name' };

/**
 * 外部可通过DataShare访问的表名-RdbStore实例映射
 */
const DATA_SHARE_TABLE_MAP: Map<string, RdbStoreHelper> = new Map<string, RdbStoreHelper>([
  [DB_CONFIG.MODE_DATA.TABLE_NAME, El1RdbStoreHelper.getInstance()],
  [DB_CONFIG.CONFIG_DATA.TABLE_NAME, RdbStoreHelper.getInstance()],
  [DB_CONFIG.CONTACT_DATA.TABLE_NAME, RdbStoreHelper.getInstance()],
  [DB_CONFIG.HISTORY_DATA.TABLE_NAME, El1RdbStoreHelper.getInstance()],
]);

export class DataExtAbility extends DataShareExtensionAbility {
  private onPresetDataChange = (): void => {
    LogUtil.showInfo(TAG, 'onPresetDataChange');
    PreloadManager.getInstance().getVersionFromCcm();
    PreloadManager.getInstance().batchPresetMode();
    CursorDataManager.getInstance().initCursorData();
    EventBus.getInstance().detach(EventBusNameConstant.RESTORE_PRESET_DATA_EVENT, this.onPresetDataChange);
  }

  onCreate(want: Want, callback: AsyncCallback<void, void>): void {
    LogUtil.showInfo(TAG, 'onCreate');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device');
      return;
    }
    AbilityContextManager.setDataShareExtContext(this.context);
    El1RdbStoreHelper.getInstance().getRdbStore();
    EventBus.getInstance().on(EventBusNameConstant.RESTORE_PRESET_DATA_EVENT, this.onPresetDataChange);

    // 销毁相关实例资源后再初始化
    SettingLinkageManager.getInstance().deInit();
    StateManager.getInstance().deInit();

    // 初始化实例
    StateManager.getInstance().init();
    const currentScene: string = StateManager.getInstance().getCurrentScene();
    SettingLinkageManager.getInstance().init(currentScene);
  }

  insert(uri: string, valueBucket: ValuesBucket, callback: AsyncCallback<number, void>): void {
    LogUtil.showInfo(TAG, 'insert start');
  }

  query(uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[],
    callback: AsyncCallback<Object, void>): void {
    LogUtil.showInfo(TAG, `query start uri length: ${uri.length}`);
    const tableName: string = StringUtil.getTableNameFromUri(uri);
    if (!DATA_SHARE_TABLE_MAP.has(tableName)) {
      LogUtil.showError(TAG, 'query failed, invalid table');
      callback(INVALID_URI_ERROR, INVALID_VALUE);
      return;
    }

    this.enableSilentProxy('query').then(() => {
      try {
        DATA_SHARE_TABLE_MAP.get(tableName)?.queryByDataShare(uri, predicates, columns, callback);
      } catch (err) {
        LogUtil.showError(TAG, `query result from datashare: exception. message: ${err?.message}, code: ${err?.code}`);
        callback(err, INVALID_VALUE);
      }
    }).catch((err: BusinessError) => {
      LogUtil.showError(TAG, `enableSilentProxy. message: ${err.message}, code: ${err.code}`);
      callback(err, INVALID_VALUE);
    });
  }

  update(uri: string, predicates: dataSharePredicates.DataSharePredicates, valueBucket: ValuesBucket,
    callback: AsyncCallback<number, void>): void {
    LogUtil.showInfo(TAG, 'update start');
  }

  batchUpdate(operations: Record<string, dataShare.UpdateOperation[]>,
    callback: AsyncCallback<Record<string, number[]>, void>): void {
    LogUtil.showInfo(TAG, 'batchUpdate start');
  }

  batchInsert(uri: string, valueBuckets: ValuesBucket[],
    callback: AsyncCallback<number, void>): void {
    LogUtil.showInfo(TAG, 'batchInsert start');
  }

  delete(uri: string, predicates: dataSharePredicates.DataSharePredicates,
    callback: AsyncCallback<number, void>): void {
    LogUtil.showInfo(TAG, 'delete start');
  }

  private async enableSilentProxy(tag: string): Promise<void> {
    try {
      await dataShare.enableSilentProxy(this.context);
      LogUtil.showInfo(TAG, `SilentProxy ${tag} enable success`);
    } catch (err) {
      LogUtil.showError(TAG, `SilentProxy ${tag} enable error message: ${err?.message}, code: ${err?.code}`);
    }
  }
}