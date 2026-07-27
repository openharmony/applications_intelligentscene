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
  it,
  beforeAll,
  afterAll
} from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { IntelligentSceneConstant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { Constant } from '../constant/Constant';

const TAG: string = 'ConditionManagerTest: ';
const driver: Driver = Driver.create();
const COMMON_DELAY: number = 400;
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

async function startIntelligentScene(): Promise<void> {
  try {
    await DELEGATOR.startAbility({
      'bundleName': IntelligentSceneConstant.BUNDLE_NAME,
      'abilityName': 'EntryAbility',
    }).then(() => {
      LogUtil.showInfo(TAG, 'EntryAbility start success');
    });
  } catch (err) {
    LogUtil.showError(TAG, `failed to startAbility. Code: ${err?.code}, message: ${err?.message}`);
  }
}

async function clearCondition(): Promise<void> {
  const configs: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.TRIGGER_CONDITION_TIME);
  for (let config of configs) {
    ConfigDataManager.getInstance().deleteConfigDataById(config.configId);
  }
}

export default function ConditionManagerTest() {
  describe('ConditionManagerTest', () => {
    beforeAll(async () => {
      await startIntelligentScene();
      await clearCondition();
    });

    afterAll(async () => {
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    it('ConditionManagerTest_addTimeConditionDndMode', 0, addTimeConditionDndMode);

  });
}

async function addTimeConditionDndMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'AddTimeConditionDndMode');
  try {
    await driver.assertComponentExist(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    let addTriggeringConditionBtn = await driver.findComponent(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    await addTriggeringConditionBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let addTimeConditionBtm = await driver.findComponent(ON.text(Constant.TIME_TRIGGERING_CONDITION));
    await addTimeConditionBtm.click();
    await driver.delayMs(COMMON_DELAY);


    let typeBtn = await driver.findComponent(ON.text(Constant.ONE_TIME));
    await typeBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let everyDayBtn = await driver.findComponent(ON.text(Constant.EVERY_DAY));
    await everyDayBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let saveBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.TIME_TRIGGERING_CONDITION)))
    await saveBtn.click();
  } catch (e) {
    LogUtil.showError(TAG, `failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
}
