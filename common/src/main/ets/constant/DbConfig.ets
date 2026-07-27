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

/**
 * 情景模式数据库名称、数据库版本号、数据表名、字段等定义
 */
export const DB_CONFIG: DB_CONFIG_TYPE = {
  DB_NAME: 'IntelligentScene.db',
  BACKUP_DB_NAME: 'IntelligentSceneBackup.db',
  BASE_DB_VERSION: 2,
  PRIVACY_AGREEMENT_VERSION: 20241228,

  MODE_DATA: {
    TABLE_NAME: 'MODE_DATA_TABLE',
    modeId: 'modeId',
    modeName: 'modeName',
    iconId: 'iconId',
    iconColor: 'iconColor',
    filletIcon: 'filletIcon',
    roundIcon: 'roundIcon',
    isSupportDelete: 'isSupportDelete',
    modePriority: 'modePriority',
    updateTime: 'updateTime',
    createTime: 'createTime'
  } as ModeDataType,

  CONFIG_DATA: {
    TABLE_NAME: 'MODE_CONFIG_DATA_TABLE',
    configId: 'configId',
    modeId: 'modeId',
    configType: 'configType',
    configValue: 'configValue',
    updateTime: 'updateTime',
    createTime: 'createTime'
  } as ConfigDataType,

  CONTACT_DATA: {
    TABLE_NAME: 'CONTACT_DATA',
    contactId: 'contactId',
    modeId: 'modeId',
    detailInfo: 'detail_info',
    formatPhoneNumber: 'format_phone_number',
    focusModeList: 'focus_mode_list',
    updateTime: 'updateTime'
  } as ContactDataType,

  HISTORY_DATA: {
    TABLE_NAME: 'MODE_HISTORY_DATA_TABLE',
    id: 'id',
    operType: 'operType',
    ruleName: 'ruleName',
    configId: 'configId',
    modeId: 'modeId',
    priority: 'priority',
    timestamp: 'timestamp',
  } as HistoryDataType,

  LEARNING_PLAN: {
    TABLE_NAME: 'LEARNING_PLAN',
    id: 'id',
    planName: 'planName',
    status: 'status',
    createTime: 'createTime',
    updateTime: 'updateTime'
  } as LearningPlanType,

  OPERATION_DATA: {
    TABLE_NAME: 'MODE_OPERATION_DATA',
    id: 'id',
    modeId: 'modeId',
    operationTime: 'operationTime',
    longitude: 'longitude',
    latitude: 'latitude',
    locationDesc: 'locationDesc',
    application: 'application',
    week: 'week',
    duration: 'duration'
  } as OperationDataType,

  RULE_FEEDBACK: {
    TABLE_NAME: 'RULE_FEEDBACK',
    id: 'id',
    ruleId: 'ruleId',
    modeId: 'modeId',
    createTime: 'createTime',
    timeRange: 'timeRange',
    longitude: 'longitude',
    latitude: 'latitude',
    application: 'application',
    feedback: 'feedback',
  } as RuleFeedbackType,

  CURSOR_DATA: {
    TABLE_NAME: 'CURSOR_DATA_TABLE',
    tableName: 'tableName',
    cursor: 'currentCursor',
  } as CursorDataType,

  FORM_DATA: {
    TABLE_NAME: 'FORM_INFO_TABLE',
    formId: 'formId',
    formName: 'formName',
    formDimension: 'formDimension'
  } as FormData,
};

interface DB_CONFIG_TYPE {
  DB_NAME: string,
  BACKUP_DB_NAME: string,
  BASE_DB_VERSION: number,
  PRIVACY_AGREEMENT_VERSION: number,
  MODE_DATA: ModeDataType,
  CONFIG_DATA: ConfigDataType,
  CONTACT_DATA: ContactDataType,
  HISTORY_DATA: HistoryDataType,
  LEARNING_PLAN: LearningPlanType,
  OPERATION_DATA: OperationDataType,
  RULE_FEEDBACK: RuleFeedbackType,
  CURSOR_DATA: CursorDataType,
  FORM_DATA: FormData,
}

interface ModeDataType {
  TABLE_NAME: string,
  modeId: string,
  modeName: string,
  iconId: string,
  iconColor: string,
  filletIcon: string,
  roundIcon: string,
  isSupportDelete: string,
  modePriority: string,
  updateTime: string,
  createTime: string
}

interface ConfigDataType {
  TABLE_NAME: string,
  configId: string,
  modeId: string,
  configType: string,
  configValue: string,
  updateTime: string,
  createTime: string,
}

interface ContactDataType {
  TABLE_NAME: string,
  contactId: string,
  modeId: string,
  detailInfo: string,
  formatPhoneNumber: string,
  focusModeList: string,
  updateTime: string
}

interface HistoryDataType {
  TABLE_NAME: string,
  id: string,
  operType: string,
  ruleName: string,
  configId: string,
  modeId: string,
  priority: string,
  timestamp: string,
}

interface LearningPlanType {
  TABLE_NAME: string,
  id: string,
  planName: string,
  status: string,
  createTime: string,
  updateTime: string
}

interface OperationDataType {
  TABLE_NAME: string,
  id: string,
  modeId: string,
  operationTime: string,
  longitude: string,
  latitude: string,
  locationDesc: string,
  application: string,
  week: string,
  duration: string
}

interface RuleFeedbackType {
  TABLE_NAME: string,
  id: string,
  ruleId: string,
  modeId: string,
  createTime: string,
  timeRange: string,
  longitude: string,
  latitude: string,
  application: string,
  feedback: string,
}

interface CursorDataType {
  TABLE_NAME: string,
  tableName: string,
  cursor: string,
}

interface FormData {
  TABLE_NAME: string,
  formId: string,
  formName: string,
  formDimension: string,
}

/**
 * 下发给RdbStore的配置
 */
export const RDB_STORE_CONFIG: rdb.StoreConfig = {
  name: DB_CONFIG.DB_NAME,
  securityLevel: rdb.SecurityLevel.S2,
  encrypt: false,
  isSearchable: true,
  haMode: rdb.HAMode.MAIN_REPLICA, // 配置为双写备份
  allowRebuild: true,
  autoCleanDirtyData: false // 云同步云端有数据删除，本地不会自动删除，查询到删除数据后，手动调用clearDirtyData()清理脏数据
};

export const BASE_TABLE_NAMES = [
  DB_CONFIG.MODE_DATA.TABLE_NAME,
  DB_CONFIG.CONFIG_DATA.TABLE_NAME
];

/**
 * 退出账号需要清空的数据表名列表
 */
export const ACCOUNT_EXIT_CLEAR_TABLES_EL2 = [
  DB_CONFIG.MODE_DATA.TABLE_NAME,
  DB_CONFIG.CONFIG_DATA.TABLE_NAME,
  DB_CONFIG.CONTACT_DATA.TABLE_NAME,
  DB_CONFIG.HISTORY_DATA.TABLE_NAME,
  DB_CONFIG.CURSOR_DATA.TABLE_NAME,
  DB_CONFIG.LEARNING_PLAN.TABLE_NAME,
  DB_CONFIG.OPERATION_DATA.TABLE_NAME,
  DB_CONFIG.RULE_FEEDBACK.TABLE_NAME,
];

export const ACCOUNT_EXIT_CLEAR_TABLES_EL1 = [
  DB_CONFIG.MODE_DATA.TABLE_NAME,
  DB_CONFIG.CONFIG_DATA.TABLE_NAME,
  DB_CONFIG.HISTORY_DATA.TABLE_NAME,
];

/**
 * 需要端云同步的表名列表
 */
export const CLOUD_SYNC_TABLES = [
  DB_CONFIG.MODE_DATA.TABLE_NAME,
  DB_CONFIG.CONFIG_DATA.TABLE_NAME,
  DB_CONFIG.CONTACT_DATA.TABLE_NAME,
];

export const INVALID_VALUE: number = -1;
export const INVALID_MODE_ID: string = '-1';
export const INVALID_DB_VERSION: number = -1;
