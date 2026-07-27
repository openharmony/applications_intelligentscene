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
  beforeEach,
  afterEach,
  it,
  expect
} from '@ohos/hypium';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { HistoryDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/HistoryDataManager';
import { ModeHistory } from '@ohos/scene.datamanage/src/main/ets/model/ModeHistory';
import { SceneEndTimeAdapter } from '@ohos/scene.statemanage/src/main/ets/adapter/SceneEndTimeAdapter';

const INTELLIGENT_SCENE_ENDTIME: string = 'Scene_EndTime_TimeTriggered';

export default function SceneEndTimeAdapterTest() {
  describe('SceneEndTimeAdapterTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('auto_on_sleep_mode_save_scene_stop_time', 0, async (done: Function) => {
      let resultMode: ModeHistory = {
        operType: "AUTO_ON",
        timestamp: 1751209201265,
        ruleName: "rule-2_3_01-1750818813407",
        modeId: "2",
        priority: 2,
        configId: "2_3_01"
      };
      await SceneEndTimeAdapter.saveSceneStopTime(resultMode);
      const value: string = SettingsDataUtils.getSecureValue(INTELLIGENT_SCENE_ENDTIME, '1751209201265');
      expect(CheckEmptyUtils.isEmpty(value)).assertFalse();
      done();
    });

    it('manual_on_save_scene_stop_time', 0, async (done: Function) => {
      let resultMode: ModeHistory = {
        operType: 'MANUAL_ON',
        ruleName: '',
        modeId: '0',
        priority: 0,
        configId: '',
      }
      await SceneEndTimeAdapter.saveSceneStopTime(resultMode);
      const value: string = SettingsDataUtils.getSecureValue(INTELLIGENT_SCENE_ENDTIME, '');
      expect(CheckEmptyUtils.isEmpty(value)).assertTrue();
      done();
    });

    it('auto_on_save_scene_stop_time', 0, async (done: Function) => {
      let resultMode: ModeHistory = {
        operType: 'AUTO_ON',
        ruleName: '',
        modeId: '1',
        priority: 1,
        configId: '',
      }
      await SceneEndTimeAdapter.saveSceneStopTime(resultMode);
      const value: string = SettingsDataUtils.getSecureValue(INTELLIGENT_SCENE_ENDTIME, '');
      expect(CheckEmptyUtils.isEmpty(value)).assertTrue();
      done();
    });

    it('get_max_end_time', 0, async (done: Function) => {
      let maxValue: number = 0;
      let records: ModeHistory[] = [
        {
          "operType": "AUTO_ON",
          "timestamp": 1751209201265,
          "ruleName": "rule-2_3_01-1750818813407",
          "modeId": "2",
          "priority": 2,
          "configId": "2_3_01"
        },
        {
          "operType": "AUTO_ON",
          "timestamp": 1751209201265,
          "ruleName": "rule-1_3_06-1750818813407",
          "modeId": "1",
          "priority": 1,
          "configId": "1_3_06"
        }
      ]
      HistoryDataManager.getInstance().recordAutoData(records);
      maxValue = await SceneEndTimeAdapter.getMaxEndTime(records);
      expect(maxValue).assertLargerOrEqual(0);
      done();
    });
  });
}