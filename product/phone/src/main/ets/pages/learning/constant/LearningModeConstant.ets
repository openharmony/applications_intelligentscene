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
 * LearningModeConstant常量类
 *
 * @since 2024-12-31
 */
export class LearningModeConstant {

  // 计时是否开启
  public static readonly IS_ENABLED_TIMING = 'isEnabledTiming';

  // 学习计划最大文案字节长度
  public static readonly MAX_LEARNING_PLAN_NAME_LENGTH = 60;

  // 学习计划最大添加长度
  public static readonly MAX_LEARNING_PLAN_COUNT = 80;

  // 已完成
  public static readonly FINISHED: string = '1';

  // 未完成
  public static readonly UN_FINISHED: string = '0';

  // 添加任务事件
  public static readonly ADD_LEARNING_PLAN_EVENT: string = 'add_learning_plan_event';

  // 关闭添加任务弹窗
  public static readonly CLOSE_ADD_LEARNING_TASK_DIALOG_EVENT: string = 'close_add_learning_task_dialog';

  // 删除学习计划
  public static readonly DELETE_LEARNING_PLAN_EVENT: string = 'delete_learning_plan_event';

  // 修改任务名称事件
  public static readonly EDIT_LEARNING_PLAN_NAME_EVENT: string = 'edit_learning_plan_name_event';
}