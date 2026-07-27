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

import { DB_CONFIG } from '@ohos/scene.common/src/main/ets/constant/DbConfig';

export const RESTORE_DIR: string = 'restore/';
export const INTELLIGENT_SCENE_DB_PATH: string = 'data/storage/el2/database/phone/rdb/';
export const BACKUP_RESTORE_TABLES: string[] = [
  DB_CONFIG.MODE_DATA.TABLE_NAME,
  DB_CONFIG.CONFIG_DATA.TABLE_NAME,
  DB_CONFIG.CONTACT_DATA.TABLE_NAME,
  DB_CONFIG.LEARNING_PLAN.TABLE_NAME,
];
export const INTELLIGENT_SCENE_DB: string = 'IntelligentScene.db';
export const INTELLIGENT_SCENE_DB_SHM: string = 'IntelligentScene.db-shm';
export const INTELLIGENT_SCENE_DB_WAL: string = 'IntelligentScene.db-wal';
export const INTELLIGENT_SCENE_BACKUP_DB: string = 'IntelligentScene_backup.db';
export const INTELLIGENT_SCENE_BACKUP_DB_SHM: string = 'IntelligentScene_backup.db-shm';
export const INTELLIGENT_SCENE_BACKUP_DB_WAL: string = 'IntelligentScene_backup.db-wal';
export const RESTORE_SUCCESS: number = 0;
export const RESTORE_FAIL: number = -1;
export const BACK_UP_PREFERENCES_PATH: string = 'data/storage/el2/base/haps/phone/preferences/';
export const BACK_UP_PREFERENCES_NAME: string = 'backUpPreferences';

export interface IResultExInfo {
  resultInfo: [IResultErrorInfo];
}

export interface IResultErrorInfo {
  type: string;
  errorCode: string;
  errorInfo: string;
}

export const SUCCESS_RESULT: IResultExInfo = {
  resultInfo: [
    {
      type: 'ErrorInfo',
      errorCode: '0',
      errorInfo: '',
    }
  ]
};
export const ERROR_RESULT: IResultExInfo = {
  resultInfo: [
    {
      type: 'ErrorInfo',
      errorCode: '13500099',
      errorInfo: '',
    }
  ]
};

export const UI_REFRESH_MSG_KEY: string = 'ui_refresh_message';
