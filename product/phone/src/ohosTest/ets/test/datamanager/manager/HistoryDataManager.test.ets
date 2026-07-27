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
import { HistoryDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/HistoryDataManager';
import { ModeHistory } from '@ohos/scene.datamanage/src/main/ets/model/ModeHistory';

export default function HistoryDataManagerTest() {
  describe('HistoryDataManagerTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('record_auto_data', 0, async (done: Function) => {
      let ruleSatisfyResults: ModeHistory[] = [{
        'operType': 'AUTO_ON',
        'timestamp': 1741762881724,
        'ruleName': 'rule-1_3_418880f27ce645be8090a09559805a1d-1741762880944',
        'modeId': '1',
        'priority': 1,
        'configId': '1_3_418880f27ce645be8090a09559805a1d'
      } as ModeHistory];
      let ruleNotSatisfyResults: ModeHistory[] = [{
        'operType': 'AUTO_OFF',
        'timestamp': 1741762881724,
        'ruleName': 'rule-1_3_01-1741762880844',
        'modeId': '1',
        'priority': 1,
        'configId': '1_3_01'
      }]
      expect(HistoryDataManager.getInstance().recordAutoData(ruleNotSatisfyResults.concat(ruleSatisfyResults))).assertPromiseIsResolved();
      done();
    });

    it('record_manual_data', 0, async (done: Function) => {
      let res: boolean = await HistoryDataManager.getInstance().recordManualData('0', '1', 0);
      expect(res).assertTrue();
      done();
    });

    it('manual_off_same_mode', 0, async (done: Function) => {
      expect(HistoryDataManager.getInstance().manualOffMode('1')).assertPromiseIsResolved() ;
      done();
    })
  });
}