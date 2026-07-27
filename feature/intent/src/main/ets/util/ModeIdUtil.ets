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

import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SceneBaseDataManager } from '@ohos/scene.configmanage/src/main/ets/manager/SceneBaseDataManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeData, ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { MODE_ID_NAME_MAP } from '../constant/IntentModeConstant';
import { IntentConstant } from '../constant/IntentConstant';

const TAG: string = 'ModeIdUtil: ';

/**
 * 意图框架modeName与modeId转化工具类
 */
export class ModeIdUtil {

  /**
   * modeName转化为modeId
   *
   * @param intentParam 意图参数
   */
  static async changeModeNameToModeId(intentParam: Record<string, Object>): Promise<string> {
    if (CheckEmptyUtils.isEmpty(intentParam.scenarioModeName)) {
      LogUtil.showInfo(TAG, `scenarioModeName is empty, use default mode id.`);
      return IntentConstant.INTELLIGENT_DEFAULT_MODE_ID;
    }
    let modeId: string = ModeType.NO_MODE;
    let modeName: string = String(intentParam.scenarioModeName);
    let modeDataList: ModeData[] = await SceneBaseDataManager.getAllSceneBaseData();
    LogUtil.showInfo(TAG, `set modeId from created mode by name modeDataList len: ${modeDataList.length}`);
    if (modeDataList.length <= 0) {
      return modeId;
    }
    for (let modeData of modeDataList) {
      let tempModeName: string | undefined = ModeUtil.isPrecastMode(modeData.modeId) ?
        MODE_ID_NAME_MAP.get(modeData.modeId) : modeData.modeName;
      if (tempModeName === modeName) {
        LogUtil.showInfo(TAG, 'set modeId from created mode.');
        modeId = modeData.modeId;
      }
    }
    return modeId;
  }
}