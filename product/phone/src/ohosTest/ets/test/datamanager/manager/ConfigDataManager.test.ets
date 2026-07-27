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

import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';

export default function ConfigDataManagerTest() {
  describe('ConfigDataManagerTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('query_test', 0, async (done: Function) => {
      let configDataList: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(ModeType.DND_MODE);
      expect(configDataList.length).assertLarger(0);
      let configIds: string[] = [];
      for (let configData of configDataList) {
        let queryData: ConfigData | undefined = await ConfigDataManager.getInstance()
          .queryConfigDataById(configData.configId);
        expect(queryData === undefined).assertFalse();
        configIds.push(configData.configId);
      }
      let queryConfigDataList: ConfigData[] | undefined = await ConfigDataManager.getInstance()
        .queryConfigDataByIds(configIds);
      expect(queryConfigDataList !== undefined).assertTrue();
      expect(queryConfigDataList?.length === configIds.length);

      let callConfigData: ConfigData[] = await ConfigDataManager.getInstance()
        .queryModeIdByConfigTypeAndValue(ConfigType.CALL_NOT_DISTURB_POLICY, ContactPolicy.ALLOW_FAVORITE_CONTACTS);
      expect(callConfigData.length).assertLargerOrEqual(0);

      let configTypes: ConfigType[] = [ConfigType.CALL_NOT_DISTURB_POLICY, ConfigType.TRIGGER_CONDITION_TIME];
      let multiConfigData: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndTypes(ModeType.DND_MODE, configTypes);
      expect(multiConfigData.length).assertLargerOrEqual(0);

      let allConfigData: ConfigData[] = await ConfigDataManager.getInstance().queryConfigDataByConfigType([
        ConfigType.TRIGGER_CONDITION_TIME,
        ConfigType.TRIGGER_CONDITION_APP,
        ConfigType.TEMPORARY_TIME_CONDITION,
      ]);
      expect(allConfigData.length).assertLarger(0);
      done();
    });

    it('insert_delete_test', 0, async (done: Function) => {
      let timeConfigValue: TimeCondition = {
        loopType: LoopType.EVERY_DAY,
        loopDays: '',
        timeStart: '07:07',
        timeEnd: '08:08',
        configId: '',
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        enable: false
      };
      let configData: ConfigData = {
        configId: '',
        modeId: ModeType.DND_MODE,
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        configValue: JsonUtil.stringify(timeConfigValue)
      };
      let result: string = await ConfigDataManager.getInstance().insertConfigData(configData);
      expect(result !== '').assertTrue();
      let deleteNum: number = await ConfigDataManager.getInstance().deleteConfigDataById(result);
      expect(deleteNum).assertLarger(0);

      let insertNum: number = await ConfigDataManager.getInstance().batchInsertConfigData([configData]);
      expect(insertNum).assertLarger(0);
      done();
    });

    it('insert_invalid_test', 0, async (done: Function) => {
      let configData: ConfigData = {
        configId: '',
        modeId: '-1',
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        configValue: ''
      };
      let result: string = await ConfigDataManager.getInstance().insertConfigData(configData);
      expect(result === '').assertTrue();
      done();
    });

    it('batchInsert_invalid_test', 0, async (done: Function) => {
      let configData: ConfigData = {
        configId: '',
        modeId: '-1',
        configType: ConfigType.TRIGGER_CONDITION_TIME,
        configValue: ''
      };
      let result: number = await ConfigDataManager.getInstance().batchInsertConfigData([configData]);
      expect(result === -1).assertTrue();

      done();
    });
  });
}