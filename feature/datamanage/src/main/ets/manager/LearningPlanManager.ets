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

import relationalStore from '@ohos.data.relationalStore';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { LearningPlan } from '../model/LearningPlan';
import { DateTimeUtil } from '../utils/DateTimeUtil';

const TAG: string = 'LearningPlanManager: ';

export const LEARNING_PLAN_TABLE: string = 'LEARNING_PLAN';

/**
 * 学习计划数据库管理类
 */
export class LearningPlanManager {
  private static instance?: LearningPlanManager;

  public static getInstance(): LearningPlanManager {
    if (!LearningPlanManager.instance) {
      LearningPlanManager.instance = new LearningPlanManager();
    }
    return LearningPlanManager.instance;
  }

  /**
   * 添加学习计划
   *
   * @param plan 学习计划
   * @returns 学习计划id
   */
  public async addLearningPlan(plan: LearningPlan): Promise<string> {
    const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
    let valuesBucket: relationalStore.ValuesBucket = {
      'planName': plan.planName ?? '',
      'createTime':nowTime,
      'updateTime':nowTime,
    };
    let result = await RdbStoreHelper.getInstance().insert(LEARNING_PLAN_TABLE, valuesBucket);
    LogUtil.showInfo(TAG, `${TAG} addLearningPlan result: ${result}`);
    return result.toString();
  }

  /**
   * 删除学习计划
   *
   * @param id 学习计划id
   * @returns 是否删除成功
   */
  public async deleteLearningPlan(id: string): Promise<boolean> {
    LogUtil.showInfo(TAG, `deleteLearningPlan: ${id}`);
    try {
      let predicates = new relationalStore.RdbPredicates(LEARNING_PLAN_TABLE);
      predicates.equalTo('id', id);
      let result = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteLearningPlan changeRows: ${result}`);
      return true;
    } catch (error) {
      LogUtil.showError(TAG, `deleteLearningPlan error:${error?.code}, msg: ${error?.message}`);
      return false;
    }
  }

  /**
   * 清空所有学习计划
   */
  public async clearLearningPlans(): Promise<void> {
    LogUtil.showInfo(TAG, 'clearLearningPlans');
    try {
      let result = await RdbStoreHelper.getInstance().deleteTableData(LEARNING_PLAN_TABLE);
      LogUtil.showInfo(TAG, `clearLearningPlans changeRows: ${result}`);
    } catch (error) {
      LogUtil.showError(TAG, `clearLearningPlans error:${error?.code}, msg: ${error?.message}`);
    }
  }

  /**
   * 获取所有学习计划
   *
   * @returns 学习计划列表
   */
  public async getAllLearningPlans(): Promise<LearningPlan[]> {
    LogUtil.showInfo(TAG, 'getAllLearningPlans');
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(LEARNING_PLAN_TABLE);
      predicates.orderByAsc('id');
      resultSet = await RdbStoreHelper.getInstance().queryAllByPredicates(predicates);
      return this.getLearningPlanListFromResultSet(resultSet);
    } catch (error) {
      LogUtil.showError(TAG, `getAllLearningPlans error:${error?.code}, msg: ${error?.message}`);
    } finally {
      resultSet?.close();
    }
    return [];
  }

  /**
   * 同步获取所有学习计划
   *
   * @returns 学习计划列表
   */
  public getAllLearningPlansSync(): LearningPlan[] {
    LogUtil.showInfo(TAG, 'getAllLearningPlansSync');
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(LEARNING_PLAN_TABLE);
      predicates.orderByAsc('id');
      resultSet = RdbStoreHelper.getInstance().queryAllByPredicatesSync(predicates);
      return this.getLearningPlanListFromResultSet(resultSet);
    } catch (error) {
      LogUtil.showError(TAG, `getAllLearningPlansSync error:${error?.code}, msg: ${error?.message}`);
    } finally {
      resultSet?.close();
    }
    return [];
  }

  /**
   * 获取已完成学习计划
   *
   * @returns 学习计划列表
   */
  public async getFinishLearningPlans(): Promise<LearningPlan[]> {
    LogUtil.showInfo(TAG, 'getFinishLearningPlans');
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(LEARNING_PLAN_TABLE);
      predicates.equalTo('status', 1);
      resultSet = await RdbStoreHelper.getInstance().queryAllByPredicates(predicates);
      return this.getLearningPlanListFromResultSet(resultSet);
    } catch (error) {
      LogUtil.showError(TAG, `getFinishLearningPlans error:${error?.code}, msg: ${error?.message}`);
    } finally {
      resultSet?.close();
    }
    return [];
  }

  /**
   * 根据id更新学习计划状态
   *
   * @param id 学习计划id
   * @param status 状态
   */
  public async updateLearningPlanStatus(id: string, status: number): Promise<void> {
    let predicates = new relationalStore.RdbPredicates(LEARNING_PLAN_TABLE);
    predicates.equalTo('id', id);
    const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
    const updateValueBucket: relationalStore.ValuesBucket = {
      'status': status,
      'updateTime': nowTime
    };
    let result = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
    LogUtil.showInfo(TAG, `updateLearningPlanStatus updated change rows: ${result}`);
  }

  /**
   * 更新学习计划任务名称
   *
   * @param id 学习计划id
   * @param planName 任务名称
   * @returns 是否修改成功
   */
  public async updateLearningPlanName(id: string, planName: string): Promise<boolean> {
    let predicates = new relationalStore.RdbPredicates(LEARNING_PLAN_TABLE);
    predicates.equalTo('id', id);
    const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
    const updateValueBucket: relationalStore.ValuesBucket = {
      'planName': planName,
      'updateTime': nowTime,
      'status': 0
    };
    let result = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
    LogUtil.showInfo(TAG, `updateLearningPlanStatus updated change rows: ${result}`);
    return result > 0 ? true : false;
  }

  /**
   * 重置所有学习计划状态
   *
   * @returns 是否重置成功
   */
  public async resetAllLearningPlanStatus(): Promise<boolean> {
    let predicates = new relationalStore.RdbPredicates(LEARNING_PLAN_TABLE);
    predicates.isNotNull('id');
    const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
    const updateValueBucket: relationalStore.ValuesBucket = {
      'status': 0,
      'updateTime': nowTime
    };
    let result = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
    AppStorage.setAndLink('finishPlanCount', 0)
    LogUtil.showInfo(TAG, `updateLearningPlanStatus updated change rows: ${result}`);
    return result > 0 ? true : false;
  }

  private getLearningPlanListFromResultSet(resultSet: relationalStore.ResultSet | undefined): LearningPlan[] {
    let learningPlan: LearningPlan[] = [];
    if (!resultSet) {
      LogUtil.showWarn(TAG, `getLearningPlanListFromResultSer result is empty`);
      return learningPlan;
    }
    while (resultSet.goToNextRow()) {
      let item: LearningPlan = {
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        planName: resultSet.getString(resultSet.getColumnIndex('planName')),
        status: resultSet.getLong(resultSet.getColumnIndex('status')),
      }
      learningPlan.push(item);
    }
    return learningPlan;
  }
}