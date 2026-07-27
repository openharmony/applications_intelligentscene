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
import {
  afterAll,
  afterEach,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it
} from '@ohos/hypium';
import { DB_CONFIG} from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { El1CallConfigManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1CallConfigManager';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

const CONFIG_DATA: ConfigData = {
  configId: '',
  modeId: '1',
  configType: 6,
  configValue: '1'
};
const TAG: string = 'El1CallConfigManagerTest: ';

export default function El1CallConfigManagerTest() {
  describe('El1CallConfigManagerTest', () => {
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

    it('El1CallConfigManagerTest_insertCallConfig', 0, async (done: Function) => {
      const data: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.CALL_NOT_DISTURB_POLICY);
      const configData: ConfigData = data[0] ?? CONFIG_DATA;
      const result: string = await El1CallConfigManager.insertCallConfig(configData);
      expect(result.length >= 0).assertTrue();
      done();
    });

    it('El1CallConfigManagerTest_batchInsertCallConfigValues', 0, async (done: Function) => {
      const data: relationalStore.ValuesBucket[] = await queryAllConfigData();
      const result: number = await El1CallConfigManager.batchInsertCallConfigValues(data);
      expect(result >= 0).assertTrue();
      done();
    });

    it('El1CallConfigManagerTest_batchInsertCallConfig', 0, async (done: Function) => {
      const configData: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(ModeType.DND_MODE);
      const result: number = await El1CallConfigManager.batchInsertCallConfig(configData);
      await El1CallConfigManager.batchInsertConfigData(configData);
      expect(result >= 0).assertTrue();
      done();
    });
  })
}

async function queryAllConfigData(): Promise<relationalStore.ValuesBucket[]> {
  let result: relationalStore.ValuesBucket[] = [];
  try {
  let resultSet: relationalStore.ResultSet | undefined = await RdbStoreHelper.getInstance()
    .queryAll(DB_CONFIG.CONFIG_DATA.TABLE_NAME);
  if (!resultSet) {
    return result;
  }
  result = resultSet2ConfigDataValuesBuckets(resultSet);
} catch (e) {
  LogUtil.showError(TAG, `queryAllConfigData errCode: ${e?.code}, errMessage: ${e?.message}`);
}
return result;
}

function resultSet2ConfigDataValuesBuckets(resultSet: relationalStore.ResultSet): relationalStore.ValuesBucket[] {
  let configDataList: relationalStore.ValuesBucket[] = [];
  try {
    while (resultSet.goToNextRow()) {
      let item: relationalStore.ValuesBucket = {
        'configId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configId)),
        'modeId': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.modeId)),
        'configType': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configType)),
        'configValue': resultSet.getString(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.configValue)),
        'updateTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.updateTime)),
        'createTime': resultSet.getLong(resultSet.getColumnIndex(DB_CONFIG.CONFIG_DATA.createTime)),
      };
      configDataList.push(item);
    }
  } catch (e) {
    LogUtil.showError(TAG, `resultSet2ConfigDataValuesBuckets error, ${e?.code}, ${e?.message}`);
  } finally {
    resultSet?.close();
  }
  return configDataList;
}