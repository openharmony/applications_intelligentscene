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

import insightIntent from '@ohos.app.ability.insightIntent';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { SceneBaseDataManager } from '@ohos/scene.configmanage/src/main/ets/manager/SceneBaseDataManager';
import { IntentUtil } from '../util/IntentUtil';
import { IntentCodeConstants } from '../constant/IntentCodeConstant';
import { MODE_ID_NAME_MAP } from '../constant/IntentModeConstant';

const TAG: string = 'IntentQueryModeAdaptor: '

/**
 * 意图框架查询转接类
 */
export class IntentQueryModeAdaptor {

  /**
   * 查询已创建所有模式接口
   *
   * @returns 查询结果
   */
  static async queryModeList(): Promise<insightIntent.ExecuteResult> {
    let modeNameList: string[] = await IntentQueryModeAdaptor.getAllCreatedModeName();
    LogUtil.showInfo(TAG, `queryScenarioModeList modeNameList len: ${modeNameList.length}`);
    if (!modeNameList || modeNameList.length === 0) {
      return IntentUtil.errorResponse(IntentCodeConstants.QUERY_MODE_LIST_FAIL_CODE);
    }
    return IntentUtil.successResponse(IntentCodeConstants.QUERY_MODE_LIST_SUCCESS_CODE, modeNameList);
  }

  /**
   * 根据modeId查询模式配置
   *
   * @param modeId 模式id
   * @returns 查询结果
   */
  static async queryModeConfig(modeId: string): Promise<insightIntent.ExecuteResult> {
    let configData: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(modeId);
    LogUtil.showInfo(TAG, `queryScenarioMode configData len: ${configData.length}`);
    if (!configData || configData.length === 0) {
      return IntentUtil.errorResponse(IntentCodeConstants.QUERY_MODE_FAIL_CODE);
    }
    return IntentUtil.successResponse(IntentCodeConstants.QUERY_MODE_SUCCESS_CODE, JsonUtil.stringify(configData));
  }

  /**
   * 获取已创建模式名称
   *
   * @returns 已创建模式名称
   */
  static async getAllCreatedModeName(): Promise<string[]> {
    let modeDataList: ModeData[] = await SceneBaseDataManager.getAllSceneBaseData();
    let modeNameList: string[] = [];
    for (const modeData of modeDataList) {
      let name: string | undefined = ModeUtil.isPrecastMode(modeData.modeId) ?
        MODE_ID_NAME_MAP.get(modeData.modeId) : modeData.modeName;
      if (name) {
        modeNameList.push(name);
      }
    }
    LogUtil.showInfo(TAG, `getAllCreatedModeName modeNameList len: ${modeNameList.length}`);
    return modeNameList;
  }
}