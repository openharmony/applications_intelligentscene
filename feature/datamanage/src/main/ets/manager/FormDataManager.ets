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
import { DB_CONFIG } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { FormInfo } from '../model/FormInfo';

const TAG: string = 'FormDataManager';
const TABLE_NAME: string = DB_CONFIG.FORM_DATA.TABLE_NAME;

export class FormDataManager {
  private static instance: FormDataManager;

  private constructor() {
  }

  public static getInstance(): FormDataManager {
    if (!FormDataManager.instance) {
      FormDataManager.instance = new FormDataManager();
    }
    return FormDataManager.instance;
  }

  public async insertForm(formInfo: FormInfo): Promise<number> {
    LogUtil.showInfo(TAG, 'insertForm');
    let result: number = INVALID_VALUE;
    const formId: string = formInfo.formId;
    const formName: string = formInfo.formName;
    if (!formId || !formName) {
      LogUtil.showError(TAG, `insertForm formId ${formId} formName ${formName}`);
      return result;
    }
    let valueBucket: relationalStore.ValuesBucket = this.generateBucket(formInfo);
    try {
      result = await RdbStoreHelper.getInstance().insert(TABLE_NAME, valueBucket);
      LogUtil.showInfo(TAG, `insertForm result index: ${result}`);
    } catch (error) {
      LogUtil.showError(TAG, `insertForm error:${error?.code}, msg: ${error?.message}`);
    }
    return result;
  }

  public async deleteForm(formId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteForm formId: ${formId}`);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('formId', formId);
    return await RdbStoreHelper.getInstance().delete(predicates);
  }

  public async queryFormByName(formName: string): Promise<FormInfo[]> {
    LogUtil.showInfo(TAG, 'queryFormByName');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('formName', formName);
    return await this.queryForm(predicates);
  }

  public async queryFormNameById(formId: string): Promise<string | undefined> {
    LogUtil.showInfo(TAG, 'queryFormNameById');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('formId', formId);
    const formInfos: FormInfo[] = await this.queryForm(predicates);
    if (formInfos?.length > 0) {
      return formInfos[0].formName;
    }
    return undefined;
  }

  private async queryForm(predicates: relationalStore.RdbPredicates): Promise<FormInfo[]> {
    LogUtil.showInfo(TAG, 'queryForm');
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      return this.getFormInfoResultSet(resultSet);
    } catch (error) {
      LogUtil.showError(TAG, `queryForm error code: ${error?.code} message: ${error?.message}`);
    } finally {
      resultSet?.close();
    }
    return [];
  }

  private getFormInfoResultSet(resultSet: relationalStore.ResultSet | undefined): FormInfo[] {
    let formInfoList: FormInfo[] = [];
    if (!resultSet) {
      LogUtil.showWarn(TAG, 'getLearningPlanListFromResultSer result is empty');
      return formInfoList;
    }
    while (resultSet.goToNextRow()) {
      let formInfo: FormInfo = {
        'formId': resultSet.getString(resultSet.getColumnIndex('formId')),
        'formName': resultSet.getString(resultSet.getColumnIndex('formName')),
        'formDimension': resultSet.getString(resultSet.getColumnIndex('formDimension'))
      }
      formInfoList.push(formInfo);
    }
    return formInfoList;
  }

  private generateBucket(formInfo: FormInfo): relationalStore.ValuesBucket {
    let valueBucket: relationalStore.ValuesBucket = {
      formId: formInfo.formId,
      formName: formInfo.formName,
      formDimension: formInfo.formDimension
    };
    return valueBucket;
  }
}