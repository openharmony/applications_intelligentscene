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

import { common } from '@kit.AbilityKit';
import { describe, beforeEach, afterEach, it, expect, MockKit } from '@ohos/hypium';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { AbilityUtils, SysDialogWant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { ModeManualEnableParam } from '@ohos/scene.modeconfig/src/main/ets/model/SysDialogModel';
import { OpenType } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';

export default function AbilityUtilTest() {
  describe('AbilityUtilTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('startAbility_test', 0, async (done: Function) => {
      let wantInfo: Want = {
        bundleName: 'com.openharmony.ohos.calendar',
        abilityName: 'MainAbility',
      };
      AbilityUtils.startAbility(AbilityContextManager.getContext() as common.UIAbilityContext, wantInfo);
      const str: string = StringUtil.generateUuid();
      expect(str !== undefined).assertTrue();
      done();
    });

    it('AbilityUtilTest_test', 0, test);

    it('AbilityUtilTest_abilityContextTest', 0, abilityContextTest);
  });
}

function test() {
  AbilityUtils.startAbilityIntelligent();
  AbilityUtils.isUiExtensionAbilityActive();
  const str: string = StringUtil.generateUuid();
  expect(str !== undefined).assertTrue();
  AbilityUtils.connectManualEnableService({} as common.UIAbilityContext, {
    modeId: '1',
    openType: OpenType.TURN_ON_NOW,
    isHideDialog: true,
  } as ModeManualEnableParam);
}

async function abilityContextTest(): Promise<void> {
  let context: Context = {} as Context;
  AbilityContextManager.addContext(context);
  AbilityContextManager.removeContext(context);
  AbilityContextManager.setStageContext(context);
  AbilityContextManager.getStageContext();
  AbilityContextManager.removeContext(context);
  AbilityContextManager.setExtContext(context);
  AbilityContextManager.getExtContext();
  AbilityContextManager.removeContext(context)
  AbilityContextManager.setDataShareExtContext(context);
  AbilityContextManager.getDataShareExtContext();
  AbilityContextManager.removeContext(context);
  expect(context !== undefined).assertTrue();

  AbilityContextManager.tryKillBackgroundAbility();
}