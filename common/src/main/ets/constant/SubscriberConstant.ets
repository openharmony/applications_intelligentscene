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

export class SubscriberConstant {
  // 静态广播拉起服务
  public static readonly ABILITY_NAME: string = 'IntelligentSceneActionServiceAbility';

  // 拉起服务公共事件
  public static readonly CUSTOM_EVENT_INTELLIGENT_SCENE_CONFIG_CHANGED: string =
    'custom.event.SETTINGS_DATA_RESTORE_FINISH';

  public static readonly ACTION_UPDATE_RULE_SET: string = 'updateRuleSet';

  public static readonly ACTION_CREATE_RULE_SET: string = 'createRuleSet';

  public static readonly ACTION_START_SCENE: string = 'startScene';

  public static readonly ACTION_STOP_SCENE: string = 'stopScene';

  public static readonly ACTION_RESET_ANS_DATA: string = 'resetAnsData';

  public static readonly RESTORE_PRESET_DATA: string = 'restore_preset_data';

  public static readonly ACTION_CREATE_OPERATION_RECORD: string = 'recordOperation';

  public static readonly ACTION_UPDATE_OPERATION_RECORD: string = 'updateOperationRecord';

  public static readonly ACTION_UPDATE_CONDITION: string = 'updateCondition';

  public static readonly ACTION_CLOUD_SYNC_DATA_INSERT: string = 'cloudSyncDataInsert';

  public static readonly ACTION_CLOUD_SYNC_DATA_DELETE: string = 'cloudSyncDataDelete';

  public static readonly ACTION_CLOUD_SYNC_DATA_MODIFY: string = 'cloudSyncDataModify';

  public static readonly ACTION_UPDATE_UG_SERVICE: string = 'updateUgService';

  public static readonly ACTION_CLONE_FINISHED: string = 'cloneFinished';
}

export const IS_NEED_START_SERVICE_ACTION: string[] = [
  SubscriberConstant.ACTION_UPDATE_RULE_SET,
  SubscriberConstant.ACTION_CREATE_RULE_SET,
  SubscriberConstant.ACTION_START_SCENE,
  SubscriberConstant.ACTION_STOP_SCENE,
  SubscriberConstant.ACTION_CREATE_OPERATION_RECORD,
  SubscriberConstant.ACTION_UPDATE_OPERATION_RECORD,
  SubscriberConstant.ACTION_UPDATE_CONDITION,
  SubscriberConstant.ACTION_CLOUD_SYNC_DATA_INSERT,
  SubscriberConstant.ACTION_CLOUD_SYNC_DATA_DELETE,
  SubscriberConstant.ACTION_CLOUD_SYNC_DATA_MODIFY,
  SubscriberConstant.ACTION_RESET_ANS_DATA,
  SubscriberConstant.RESTORE_PRESET_DATA,
  SubscriberConstant.ACTION_UPDATE_UG_SERVICE,
  SubscriberConstant.ACTION_CLONE_FINISHED,
];