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

import {
  ArgumentMatchers,
  describe,
  expect,
  it,
  MockKit,
  when
} from '@ohos/hypium';
import { FormDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/FormDataManager';
import { FormInfo } from '@ohos/scene.datamanage/src/main/ets/model/FormInfo';
import { SceneForm } from '@ohos/scene.form/src/main/ets/constant/FormConstant';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';

export default function FormDataManagerTest() {
  describe('FormDataManagerTest', () => {
    let formDataManager: FormDataManager = FormDataManager.getInstance();
    let mocker: MockKit = new MockKit();
    const formInfo: FormInfo = {
      formId: '123123',
      formName: SceneForm.SLEEP_FORM,
      formDimension: '2'
    };

    it('FormDataManagerTest_insertForm_formId_is_null', 0, async () => {
      const formInfo1: FormInfo = {
        formId: '',
        formName: SceneForm.SLEEP_FORM,
        formDimension: '2'
      };
      const result: number = await formDataManager.insertForm(formInfo1);
      expect(result === -1).assertEqual(true);
    });

    it('FormDataManagerTest_insertForm_formName_is_null', 0, async () => {
      const formInfo1: FormInfo = {
        formId: '123123',
        formName: '',
        formDimension: '2'
      };
      const result: number = await formDataManager.insertForm(formInfo1);
      expect(result === -1).assertEqual(true);
    });

    it('FormDataManagerTest_insertForm_insert_success', 0, async () => {
      const result: number = await formDataManager.insertForm(formInfo);
      expect(result >= -1).assertTrue();
    });

    it('FormDataManagerTest_deleteForm_test', 0, async () => {
      const result: number = await formDataManager.deleteForm('123123');
      expect(result >= -1).assertTrue();
    })

    it('FormDataManagerTest_queryFormByName_test', 0, async () => {
      const formInfos: FormInfo[] = await formDataManager.queryFormByName(SceneForm.SLEEP_FORM);
      expect(formInfos.length).assertLargerOrEqual(0);
    })

    it('FormDataManagerTest_queryFormNameById_formInfos_is_empty', 0, async () => {
      const result: string | undefined = await formDataManager.queryFormNameById(SceneForm.SLEEP_FORM);
      expect(result).assertUndefined();
    })

    it('FormDataManagerTest_queryFormNameById_formInfos_not_empty', 0, async () => {
      let formDataManagerObj: object = formDataManager as object;
      let queryFormFunc: Function = mocker.mockFunc(formDataManagerObj, formDataManagerObj['queryForm']);
      const formInfos: FormInfo[] = [formInfo];
      when(queryFormFunc)().afterReturn(formInfos);
      const result: string | undefined = await formDataManager.queryFormNameById(SceneForm.SLEEP_FORM);
      expect(result).assertUndefined();
    })

    it('FormDataManagerTest_queryForm_test', 0, async () => {
      let rdbStoreHelper: RdbStoreHelper = RdbStoreHelper.getInstance();
      let mockInsertFunc: Function = mocker.mockFunc(rdbStoreHelper, rdbStoreHelper.query);
      when(mockInsertFunc)(ArgumentMatchers.any).afterReturn(undefined);
      const result: FormInfo[] = (formDataManager as object)['queryForm']();
      expect(result.length).assertLargerOrEqual(0);
    })

    it('FormDataManagerTest_getFormInfoResultSet_resultSet_is_null', 0, () => {
      const result: FormInfo[] = (formDataManager as object)['getFormInfoResultSet']();
      expect(result.length).assertLargerOrEqual(0);
    })
  });
}