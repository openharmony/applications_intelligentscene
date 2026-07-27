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

import { ModeIdUtil } from '@ohos/scene.intent/src/main/ets/util/ModeIdUtil';
import { ModeData, ModeDataManager } from '@ohos/scene.datamanage';
import {
  afterEach,
  ArgumentMatchers,
  beforeEach,
  describe,
  expect,
  it,
  MockKit,
  when,
} from '@ohos/hypium';

export default function ModeIdUtilTest() {
  describe('ModeIdUtilTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('ModeIdUtil_changeModeNameToModeId', 0, async () => {
      let mocker: MockKit = new MockKit();
      let modeDataManager: ModeDataManager = ModeDataManager.getInstance();
      let mockfunc: Function = mocker.mockFunc(modeDataManager, modeDataManager.queryAllModeData);
      let modeDataList: ModeData[] = [];
      when(mockfunc)(ArgumentMatchers.any).afterReturn(Promise.resolve(modeDataList));
      let intentParam: Record<string, Object> = {
        'scenarioModeName': '$string:sleep_mode'
      };
      const result = await ModeIdUtil.changeModeNameToModeId({});
      expect(result).assertLargerOrEqual(0);
      await ModeIdUtil.changeModeNameToModeId(intentParam);
      mocker.ignoreMock(modeDataManager, modeDataManager.queryAllModeData);
      modeDataList = await ModeDataManager.getInstance().queryAllModeData();
      await ModeIdUtil.changeModeNameToModeId(intentParam);
      intentParam.scenarioModeName = '睡眠模式';
      await ModeIdUtil.changeModeNameToModeId(intentParam);
    });
  });
}