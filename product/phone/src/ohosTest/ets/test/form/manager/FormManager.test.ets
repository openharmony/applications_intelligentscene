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

import formBindingData from '@ohos.app.form.formBindingData';
import {
  describe,
  it,
  MockKit,
  when,
  ArgumentMatchers,
  expect
} from '@ohos/hypium';
import { FormManager } from '@ohos/scene.form/src/main/ets/manager/FormManager';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { FormDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/FormDataManager';
import { FormInfo } from '@ohos/scene.datamanage/src/main/ets/model/FormInfo';
import { SceneForm } from '@ohos/scene.form/src/main/ets/constant/FormConstant';
import { RecentTimeConditionCalUtils } from '@ohos/scene.form/src/main/ets/utils/RecentTimeConditionCalUtils';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { FormModeData } from '@ohos/scene.form/src/main/ets/model/FormControlData';

const TAG: string = 'FormManagerTest';

export default function FormManagerTest() {
  describe('FormManagerTest', () => {
    let mocker: MockKit = new MockKit();
    let formManager: FormManager = FormManager.getInstance();

    it('FormManagerTest_updateAllForms_test', 0, async (done: Function) => {
      let processResult: boolean = false;
      try {
        const mockFunc: Function = mocker.mockFunc(formManager, formManager.updateSleepModeForAllForm);
        when(mockFunc)(ArgumentMatchers.anyString).afterReturnNothing();
        await formManager.updateAllForms(ModeType.DND_MODE, ModeType.SLEEP_MODE);
        await formManager.updateAllForms(ModeType.SLEEP_MODE, ModeType.DND_MODE);
        await formManager.updateAllForms(ModeType.LEARNING_MODE, ModeType.DND_MODE);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `updateAllForms_test error: ${e?.code}, ${e?.message}`);
      }
      expect(processResult).assertTrue();
      done();
    });

    it('FormManagerTest_updateAllFormByConfigurationUpdate_test', 0, async (done: Function) => {
      let processResult: boolean = false;
      try {
        const mockFunc: Function = mocker.mockFunc(formManager, formManager.updateSleepModeForAllForm);
        when(mockFunc)(ArgumentMatchers.anyString).afterReturnNothing();
        await formManager.updateAllFormByConfigurationUpdate('zh_CN');
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `updateAllFormByConfigurationUpdate_test error: ${e?.code}, ${e?.message}`);
      }
      expect(processResult).assertTrue();
      done();
    });

    it('FormManagerTest_getSleepFormDataWithFormId_test', 0, async (done: Function) => {
      let processResult: boolean = false;
      try {
        await formManager.getSleepFormDataWithFormId(ModeType.SLEEP_MODE);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `getSleepFormDataWithFormId_test error: ${e?.code}, ${e?.message}`);
      }
      expect(processResult).assertTrue();
      done();
    });

    it('FormManagerTest_updateModeByTimeCondition_test', 0, async (done: Function) => {
      let processResult: boolean = false;
      try {
        await formManager.updateModeByTimeCondition(ModeType.DND_MODE);
        await formManager.updateModeByTimeCondition(ModeType.SLEEP_MODE);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `updateModeByTimeCondition_test error: ${e?.code}, ${e?.message}`);
      }
      expect(processResult).assertTrue();
      done();
    });

    it('FormManagerTest_updateSleepModeForAllForm_queryFormByName_is_null', 0, async (done: Function) => {
      let processResult: boolean = false;
      try {
        let formDataManager: FormDataManager = FormDataManager.getInstance();
        const mockQueryFunc: Function = mocker.mockFunc(formDataManager, formDataManager.queryFormByName);
        when(mockQueryFunc)(ArgumentMatchers.any).afterReturn([]);
        await formManager.updateSleepModeForAllForm(ModeType.SLEEP_MODE);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `updateSleepModeForAllForm_queryFormByName_is_null error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
      done();
    });

    it('FormManagerTest_updateSleepModeForAllForm_test_all_conditions', 0, async (done: Function) => {
      let processResult: boolean = false;
      try {
        const formList: FormInfo[] = [
          {
            formId: '12123123',
            formName: SceneForm.SLEEP_FORM,
            formDimension: '2'
          }
        ];
        let formDataManager: FormDataManager = FormDataManager.getInstance();
        const mockQueryFunc: Function = mocker.mockFunc(formDataManager, formDataManager.queryFormByName);
        when(mockQueryFunc)(ArgumentMatchers.anyString).afterReturn(formList);
        const getSleepModeFormDataMockFunc: Function = mocker.mockFunc(formManager, formManager.getSleepModeFormData);
        when(getSleepModeFormDataMockFunc)().afterReturnNothing();
        await formManager.updateSleepModeForAllForm(ModeType.SLEEP_MODE);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `updateSleepModeForAllForm_test_all_conditions error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
      done();
    });

    it('FormManagerTest_getSleepModeFormData_test', 0, async (done: Function) => {
      const mockFunc: Function = mocker.mockFunc(RecentTimeConditionCalUtils,
        RecentTimeConditionCalUtils.getRecentEnableTimeConditionDescription);
      when(mockFunc)(ArgumentMatchers.any).afterReturn("周一23:00 - 周二7:00");
      let modeState: ModeState = {
        isOpened: true,
        modeId: ModeType.SLEEP_MODE
      }
      const getModeOpenStateMockFunc: Function =
        mocker.mockFunc(ModeUtil, ModeUtil.getModeOpenState);
      when(getModeOpenStateMockFunc)(ArgumentMatchers.any).afterReturn(modeState);
      let curModeData: FormModeData = await formManager.getSleepModeFormData(ModeType.SLEEP_MODE);
      expect(curModeData).assertUndefined();
      done();
    });

    it('FormManagerTest_updateForm_test', 0, async (done: Function) => {
      let processResult: boolean = false;
      try {
        const testFormMsg: ESObject = formBindingData.createFormBindingData({});
        await formManager.updateForm('304629384', testFormMsg);
        processResult = true;
      } catch (e) {
        LogUtil.showError(TAG, `updateForm error: ${e?.code}, ${e?.message}`);
        processResult = false;
      }
      expect(processResult).assertTrue();
      done();
    });
  });
}