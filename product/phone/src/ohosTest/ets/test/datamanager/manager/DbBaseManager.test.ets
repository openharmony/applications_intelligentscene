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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { RdbStoreHelper } from '@ohos/scene.common';
import { DbBaseManager, DbUpgrade,
  PhoneEl2Adapter,
  PHONE_UPGRADE_CONFIGS,
  UpgradeConfig,
  UpgradeManager,
  WEARABLE_UPGRADE_CONFIGS } from '@ohos/scene.datamanage';

export default function DbBaseManagerTest() {
  describe('DbBaseManagerTest', () => {
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

    it('DbBaseManagerTest_upgradeDb', 0, async (done: Function) => {
      const upgrade: DbUpgrade = {
        latestVersion: 2,
        upgrades: [{
          version: 2,
          scripts: ['NO_NEED_EXECUTE_SQL']
        }]
      };
      const result: boolean = await DbBaseManager.upgradeDb(PHONE_UPGRADE_CONFIGS[0], upgrade.upgrades, 1, 2);
      expect(result).assertTrue();
      done();
    });

    it('DbBaseManagerTest_upgradeDb_empty', 0, async (done: Function) => {
      const result: boolean = await DbBaseManager.upgradeDb(PHONE_UPGRADE_CONFIGS[0], [], 1, 2);
      expect(result).assertFalse();
      done();
    });

    it('DbBaseManagerTest_upgradeData_undefined', 0, async (done: Function) => {
      const config: UpgradeConfig = {
        product: '',
        area: 0,
        scriptsPath: '',
        getRdbStore: () => RdbStoreHelper.getInstance()
      };
      const result = await UpgradeManager.upgradeData(config, 1);
      expect(result).assertFalse();
      done();
    });

    it('DbBaseManagerTest_upgradeManager_6', 0, async (done: Function) => {
      const result = await UpgradeManager.upgradeData(PHONE_UPGRADE_CONFIGS[0], 6);
      expect(result).assertTrue();
      done();
    });

    it('DbBaseManagerTest_upgradeManager_7', 0, async (done: Function) => {
      const result = await UpgradeManager.upgradeData(PHONE_UPGRADE_CONFIGS[0], 7);
      expect(result).assertTrue();
      done();
    });

    it('DbBaseManagerTest_upgradeManager_El1_1', 0, async (done: Function) => {
      const result: boolean = await UpgradeManager.upgradeData(PHONE_UPGRADE_CONFIGS[1], 1);
      expect(result).assertTrue();
      done();
    });

    it('DbBaseManagerTest_upgradeManager_wearable', 0, async (done: Function) => {
      const result: boolean = await UpgradeManager.upgradeData(WEARABLE_UPGRADE_CONFIGS[0], 7);
      expect(result).assertTrue();
      done();
    });

    it('DbBaseManagerTest_generateRoundIcon', 0, async (done: Function) => {
      const result: boolean = await PhoneEl2Adapter.generateRoundIcon();
      expect(result).assertTrue();
      done();
    });

  })
}