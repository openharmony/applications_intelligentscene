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

import { relationalStore } from '@kit.ArkData';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { DB_CONFIG, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { RuleFeedBack } from '../model/base/RuleFeedback';

const TAG: string = 'RuleFeedbackManager';

export class RuleFeedbackManager {
  private static instance: RuleFeedbackManager;

  public static getInstance(): RuleFeedbackManager {
    if (RuleFeedbackManager.instance == null) {
      RuleFeedbackManager.instance = new RuleFeedbackManager();
    }
    return RuleFeedbackManager.instance;
  }

  async insertRuleFeedback(ruleFeedback: RuleFeedBack): Promise<number> {
    LogUtil.showInfo(TAG, `insertRuleFeedback, ruleId: ${ruleFeedback.ruleId}`);
    try {
      let result: number = 0;
      let valuesBucket: relationalStore.ValuesBucket = {
        'ruleId': ruleFeedback.ruleId,
        'modeId': ruleFeedback.modeId,
        'createTime': ruleFeedback.createTime,
        'timeRange': ruleFeedback.timeRange,
        'longitude': StringUtil.fixedString(ruleFeedback.longitude),
        'latitude': StringUtil.fixedString(ruleFeedback.latitude),
        'application': ruleFeedback.application ?? '',
        'feedback': ruleFeedback.feedback ?? '0',
      };
      result = await RdbStoreHelper.getInstance().insert(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME, valuesBucket);
      LogUtil.showInfo(TAG, `insertRuleFeedback result index: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `insertRuleFeedback error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async batchInsertRuleFeedback(ruleFeedbackList: RuleFeedBack[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertRuleFeedback, ruleId: ${ruleFeedbackList.length}`);
    try {
      if (ruleFeedbackList.length === 0) {
        return INVALID_VALUE;
      }
      let result: number = 0;
      let valuesBucketList: relationalStore.ValuesBucket[] = [];
      for (let ruleFeedback of ruleFeedbackList) {
        let valuesBucket: relationalStore.ValuesBucket = {
          'ruleId': ruleFeedback.ruleId,
          'modeId': ruleFeedback.modeId,
          'createTime': ruleFeedback.createTime,
          'timeRange': ruleFeedback.timeRange,
          'longitude': StringUtil.fixedString(ruleFeedback.longitude),
          'latitude': StringUtil.fixedString(ruleFeedback.latitude),
          'application': ruleFeedback.application ?? '',
          'feedback': '0'
        };
        valuesBucketList.push(valuesBucket);
      }
      result = await RdbStoreHelper.getInstance().batchInsert(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME, valuesBucketList);
      LogUtil.showInfo(TAG, `batchInsertRuleFeedback result index: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchInsertRuleFeedback error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async updateRuleFeedback(ruleFeedback: RuleFeedBack): Promise<number> {
    LogUtil.showInfo(TAG, `updateRuleFeedback, modeId: ${ruleFeedback.modeId}`);
    // 判断数据库中是否存在ruleId
    const ruleFeedbacks: RuleFeedBack[] =
      await RuleFeedbackManager.getInstance().queryRuleFeedbackByModeId(ruleFeedback.modeId);
    if (ruleFeedbacks.length === 0) {
      const result: number = await RuleFeedbackManager.getInstance().insertRuleFeedback(ruleFeedback);
      return result;
    }
    try {
      const predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('modeId', ruleFeedback.modeId);
      const updateValueBucket: relationalStore.ValuesBucket = {
        'createTime': ruleFeedback.createTime,
        'timeRange': ruleFeedback.timeRange,
        'longitude': StringUtil.fixedString(ruleFeedback.longitude),
        'latitude': StringUtil.fixedString(ruleFeedback.latitude),
        'feedback': '0'
      };
      const result: number = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateRuleFeedback updated change rows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `updateRuleFeedback error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async updateRuleFeedbackByRuleId(ruleId: string, ruleFeedback: RuleFeedBack): Promise<number> {
    LogUtil.showInfo(TAG, `updateRuleFeedbackByRuleId, ruleId: ${ruleId}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('ruleId', ruleId);
      const updateValueBucket: relationalStore.ValuesBucket = {
        'createTime': ruleFeedback.createTime,
        'timeRange': ruleFeedback.timeRange,
        'longitude': StringUtil.fixedString(ruleFeedback.longitude),
        'latitude': StringUtil.fixedString(ruleFeedback.latitude),
        'feedback': ruleFeedback.feedback ?? '0',
      };
      let result = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateRuleFeedbackByRuleId updated change rows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `updateRuleFeedbackByRuleId error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async updateFeedbackByModeId(modeId: string, feedback: string): Promise<number> {
    LogUtil.showInfo(TAG, `updateFeedbackByModeId, modeId: ${modeId}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('modeId', modeId);
      const updateValueBucket: relationalStore.ValuesBucket = {
        'feedback': feedback
      };
      let result: number = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateFeedbackByModeId updated change rows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `updateFeedbackByModeId error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async updateFeedbackByRuleId(ruleId: string, feedback: string): Promise<number> {
    LogUtil.showInfo(TAG, `updateFeedbackByRuleId, ruleId: ${ruleId}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('ruleId', ruleId);
      const updateValueBucket: relationalStore.ValuesBucket = {
        'feedback': feedback
      };
      let result: number = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateFeedbackByRuleId updated change rows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `updateFeedbackByRuleId error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async deleteRuleFeedbackByModeId(modeId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteRuleFeedbackByModeId modeId: ${modeId}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('modeId', modeId);
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteRuleFeedbackByModeId changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteRuleFeedbackByModeId error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async deleteRuleFeedbackByRuleId(ruleId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteRuleFeedbackByRuleId ruleId: ${ruleId}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('ruleId', ruleId);
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteRuleFeedbackByRuleId changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteRuleFeedbackByRuleId error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async queryRuleFeedbackByModeId(modeId: string): Promise<RuleFeedBack[]> {
    LogUtil.showInfo(TAG, `queryRuleFeedbackByModeId id: ${modeId}`);
    let result: RuleFeedBack[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('modeId', modeId);
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'queryRuleFeedbackByModeId warn: resultSet is empty.');
        return result;
      }
      LogUtil.showInfo(TAG, `resultSet count: ${resultSet.columnCount}`);
      result = this.convertResultToRuleFeedList(resultSet);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `queryRuleFeedbackByModeId error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  async queryLatestRuleByModeId(modeId: string): Promise<RuleFeedBack | undefined> {
    let result: RuleFeedBack[] = await RuleFeedbackManager.getInstance().queryRuleFeedbackByModeId(modeId);
    if (result.length <= 0) {
      LogUtil.showError(TAG, 'queryLatestRuleByModeId result is null.');
      return undefined;
    }
    let last: number = result.length - 1;
    LogUtil.showInfo(TAG, `queryLatestRuleByModeId result len: ${result.length}`);
    return result[last];
  }

  async queryFeedback(modeId: string): Promise<number> {
    let rule: RuleFeedBack | undefined = await RuleFeedbackManager.getInstance().queryLatestRuleByModeId(modeId);
    if (!rule) {
      LogUtil.showWarn(TAG, 'current rule is null');
      return INVALID_VALUE;
    }
    let feedback: string | undefined = rule.feedback;
    if (!feedback) {
      feedback = '0';
    }
    LogUtil.showInfo( TAG, `queryFeedback is: ${feedback}`);
    return parseInt(feedback);
  }

  async queryRuleFeedbackByRuleId(ruleId: string): Promise<RuleFeedBack | undefined> {
    LogUtil.showInfo(TAG, `queryRuleFeedbackByRuleId id: ${ruleId}`);
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates: relationalStore.RdbPredicates = new relationalStore
        .RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.equalTo('ruleId', ruleId);
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'queryRuleFeedbackByModeId warn: resultSet is empty.');
        return undefined;
      }
      let ruleFeedList: RuleFeedBack[] = await this.convertResultToRuleFeedList(resultSet);
      LogUtil.showInfo(TAG, `ruleFeedList count: ${ruleFeedList.length}`);
      return ruleFeedList[0];
    } catch (err) {
      LogUtil.showError(TAG, `queryRuleFeedbackByModeId error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return undefined;
  }

  async queryOtherUsingRuleFeedback(modeId: string): Promise<RuleFeedBack[]> {
    LogUtil.showInfo(TAG, `queryOtherUsingRuleFeedback id: ${modeId}`);
    let result: RuleFeedBack[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.notEqualTo('modeId', modeId).and().notEqualTo('feedback', '-1');
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'queryOtherUsingRuleFeedback warn: resultSet is empty.');
        return result;
      }
      LogUtil.showInfo(TAG, `resultSet count: ${resultSet.columnCount}`);
      result = this.convertResultToRuleFeedList(resultSet);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `queryOtherUsingRuleFeedback error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  async batchDeleteRuleFeedbackByRuleIds(ruleIds: string[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchDeleteRuleFeedbackByRuleIds ruleId: ${ruleIds.length}`);
    try {
      if (ruleIds.length === 0) {
        return INVALID_VALUE;
      }
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      predicates.in('ruleId', ruleIds);
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `batchDeleteRuleFeedbackByRuleIds changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchDeleteRuleFeedbackByRuleIds error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async queryAllRuleFeedback(): Promise<RuleFeedBack[]> {
    LogUtil.showInfo(TAG, 'queryAllRuleFeedback');
    let result: RuleFeedBack[] = [];
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      resultSet = await RdbStoreHelper.getInstance().queryAll(DB_CONFIG.RULE_FEEDBACK.TABLE_NAME);
      if (!resultSet) {
        LogUtil.showWarn(TAG, 'queryAllRuleFeedback warn: resultSet is empty.');
        return result;
      }
      LogUtil.showInfo(TAG, `queryAllRuleFeedback count: ${resultSet.rowCount}`);
      result = this.convertResultToRuleFeedList(resultSet);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `queryAllRuleFeedback error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return result;
  }

  private convertResultToRuleFeedBack(resultSet: relationalStore.ResultSet): RuleFeedBack | undefined {
    let result: RuleFeedBack | undefined = undefined;
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToRuleFeedBack result is empty');
      return result;
    }
    try {
      const id = resultSet.getLong(resultSet.getColumnIndex('id'));
      const ruleId = resultSet.getString(resultSet.getColumnIndex('ruleId'));
      const modeId = resultSet.getString(resultSet.getColumnIndex('modeId'));
      const createTime = resultSet.getLong(resultSet.getColumnIndex('createTime'));
      const timeRange = resultSet.getString(resultSet.getColumnIndex('timeRange'));
      const longitude = resultSet.getString(resultSet.getColumnIndex('longitude'));
      const latitude = resultSet.getString(resultSet.getColumnIndex('latitude'));
      const application = resultSet.getString(resultSet.getColumnIndex('application'));
      const feedback = resultSet.getString(resultSet.getColumnIndex('feedback'));
      result = {
        id,
        ruleId,
        modeId,
        createTime,
        timeRange,
        longitude,
        latitude,
        application,
        feedback,
      };
    } catch (error) {
      LogUtil.showError(TAG, `convertResultToRuleFeedBack error code: ${error?.code} message: ${error?.message}`);
    }
    return result;
  }

  private convertResultToRuleFeedList(resultSet: relationalStore.ResultSet): RuleFeedBack[] {
    let results: RuleFeedBack[] = [];
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'convertResultToRuleFeedList result is empty');
      return results;
    }

    while (resultSet.goToNextRow()) {
      let result: RuleFeedBack | undefined = this.convertResultToRuleFeedBack(resultSet);
      if (!result) {
        LogUtil.showWarn(TAG, 'result is undefined.');
        continue;
      }
      results.push(result);
    }
    return results;
  }
}