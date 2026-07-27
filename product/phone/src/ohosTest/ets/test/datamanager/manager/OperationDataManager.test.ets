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
  describe,
  beforeAll,
  beforeEach,
  afterEach,
  afterAll,
  it,
  expect
} from '@ohos/hypium';
import { relationalStore } from '@kit.ArkData';
import { DB_CONFIG } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { OperationData } from '@ohos/scene.datamanage/src/main/ets/model/base/OperationData';
import { OperationDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/OperationDataManager';
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

export default function OperationDataManagerTest() {
  describe('OperationDataManagerTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('OperationDataManagerTest_insertOperationData_invalid', 0, async (done: Function) => {
      const result: boolean = ModeUtil.isPrecastMode('2');
      expect(result).assertTrue();
      let operationData: OperationData = {
        modeId: '',
        operationTime: DateTimeUtil.getCurrentTimeStamp().toString(),
        longitude: '114.52812',
        latitude: '30.49723',
        locationDesc: '',
        application: '',
        week: '1'
      };
      await OperationDataManager.getInstance().insertOperationData(operationData);
      done();
    });

    it('OperationDataManagerTest_insertOperationData_success', 0, async (done: Function) => {
      let operationData: OperationData = {
        modeId: '1',
        operationTime: DateTimeUtil.getCurrentTimeStamp().toString(),
        longitude: '114.52812',
        latitude: '30.49723',
        locationDesc: '',
        application: '',
        week: '1'
      };
      const id: number = await OperationDataManager.getInstance().insertOperationData(operationData);
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().deleteOperationDataById(id);
      done();
    });

    it('OperationDataManagerTest_deleteOperationDataByPredicates', 0, async (done: Function) => {
      let operationData: OperationData = {
        modeId: '2',
        operationTime: DateTimeUtil.getCurrentTimeStamp().toString(),
        longitude: '114.52812',
        latitude: '30.49723',
        locationDesc: '',
        application: '',
        week: '1'
      };
      const id: number = await OperationDataManager.getInstance().insertOperationData(operationData);
      expect(id !== undefined).assertTrue();
      let predicates: relationalStore.RdbPredicates = new relationalStore
        .RdbPredicates(DB_CONFIG.OPERATION_DATA.TABLE_NAME);
      predicates.equalTo('id', id);
      await OperationDataManager.getInstance().deleteOperationDataByPredicates(predicates);
      done();
    });

    it('OperationDataManagerTest_queryOperationDataCountByModeId_success', 0, async (done: Function) => {
      let operationData: OperationData = {
        modeId: '3',
        operationTime: DateTimeUtil.getCurrentTimeStamp().toString(),
        longitude: '114.52812',
        latitude: '30.49723',
        locationDesc: '',
        application: '',
        week: '1'
      };
      const id: number = await OperationDataManager.getInstance().insertOperationData(operationData);
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().queryOperationDataCountByModeId('3');
      done();
    });

    it('OperationDataManagerTest_queryOperationDataCountByModeId_error', 0, async (done: Function) => {
      const id = StringUtil.generateUuid();
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().queryOperationDataCountByModeId('9');
      done();
    });

    it('OperationDataManagerTest_deleteOperationDataIfOverflow', 0, async (done: Function) => {
      const id = StringUtil.generateUuid();
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().deleteOperationDataIfOverflow('1');
      done();
    });

    it('OperationDataManagerTest_clearOperationData', 0, async (done: Function) => {
      const id = StringUtil.generateUuid();
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().clearOperationData('1');
      done();
    });

    it('OperationDataManagerTest_clearOneWeekOperationData', 0, async (done: Function) => {
      const id = StringUtil.generateUuid();
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().clearOneWeekOperationData('');
      await OperationDataManager.getInstance().clearOneWeekOperationData('rule_1');
      await OperationDataManager.getInstance().clearOneWeekOperationData('rule_1_uuid_1752752259499');
      done();
    });

    it('OperationDataManagerTest_getLastThreeOperationData', 0, async (done: Function) => {
      const id = StringUtil.generateUuid();
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().getLastThreeOperationData('1');

      let operationData: OperationData = {
        modeId: '1',
        operationTime: DateTimeUtil.getCurrentTimeStamp().toString(),
        longitude: '114.52812',
        latitude: '30.49723',
        locationDesc: '',
        application: '',
        week: '1'
      };
      await OperationDataManager.getInstance().insertOperationData(operationData);
      operationData.week = '2';
      operationData.operationTime = '1752570415593';
      await OperationDataManager.getInstance().insertOperationData(operationData);
      operationData.week = '3';
      operationData.operationTime = '1752743850983';
      await OperationDataManager.getInstance().insertOperationData(operationData);
      await OperationDataManager.getInstance().getLastThreeOperationData('1');
      done();
    });

    it('OperationDataManagerTest_queryOperationDataById_empty', 0, async (done: Function) => {
      const id = StringUtil.generateUuid();
      expect(id !== undefined).assertTrue();
      await OperationDataManager.getInstance().queryOperationDataById(-1);
      done();
    });

    it('OperationDataManagerTest_queryOperationTimeById', 0, async (done: Function) => {
      const id = StringUtil.generateUuid();
      expect(id !== undefined).assertTrue();
      let operationData: OperationData = {
        modeId: '1',
        operationTime: DateTimeUtil.getCurrentTimeStamp().toString(),
        longitude: '114.52812',
        latitude: '30.49723',
        locationDesc: '',
        application: '',
        week: '1'
      };
      const operationId: number = await OperationDataManager.getInstance().insertOperationData(operationData);
      await OperationDataManager.getInstance().queryOperationTimeById(operationId);
      done();
    });
  })
}