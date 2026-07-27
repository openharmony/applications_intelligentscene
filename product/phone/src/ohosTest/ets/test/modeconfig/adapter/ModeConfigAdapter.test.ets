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
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
} from '@ohos/hypium';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';

export default function ModeConfigAdapterTest() {
  describe('ModeConfigAdapterTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('ModeConfigAdapterTest_queryConfigByModeAndType', 0, async () => {
      const modeConfig = await ModeConfigAdapter.getInstance().queryConfigByModeAndType(ModeType.DND_MODE);
      expect(modeConfig.length).assertLargerOrEqual(0);

      const notExistModeConfig = await ModeConfigAdapter.getInstance().queryConfigByModeAndType('-2');
      expect(notExistModeConfig.length).assertEqual(0);
    });

    it('ModeConfigAdapterTest_queryConfigDataById', 0, async () => {
      const configId: string = ModeUtil.generateConfigId(ModeType.DND_MODE, ConfigType.REPEATED_CALL_RING_SWITCH);
      let config: ConfigData | undefined = await ModeConfigAdapter.getInstance().queryConfigDataById(configId);
      if (config) {
        expect(config.configId.length).assertLargerOrEqual(1);
      }

      let emptyConfig: ConfigData | undefined = await ModeConfigAdapter.getInstance().queryConfigDataById('');
      expect(emptyConfig?.configId?.length ?? 0).assertLessOrEqual(0);
    });

    it('ModeConfigAdapterTest_getConfigDataManager', 0, async () => {
      let manager: ConfigDataManager = await ModeConfigAdapter.getInstance().getConfigDataManager(ModeType.DND_MODE);
      expect(manager instanceof ConfigDataManager).assertTrue();
    });

    it('ModeConfigAdapterTest_updateConfigData', 0, async () => {
      let updateResult: string = await ModeConfigAdapter.getInstance().updateConfigData('', {
        configId: '',
        modeId: '',
        configType: 1,
        configValue: ''
      });
      expect(updateResult).assertEqual('');
    });

    it('ModeConfigAdapterTest_insertConfigData', 0, async () => {
      let updateResult: string = await ModeConfigAdapter.getInstance().insertConfigData('', {
        configId: '',
        modeId: '',
        configType: 1,
        configValue: ''
      });
      expect(updateResult).assertEqual('');
    });
  });
}