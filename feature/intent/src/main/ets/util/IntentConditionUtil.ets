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

import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { CONDITION_LIST } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { IntentConstant } from '../constant/IntentConstant';

const TAG: string = 'IntentConditionUtil: ';

/**
 * 意图框架工具类
 */
export class IntentConditionUtil {
  /**
   * 校验某个模式围栏条件是否小于15
   * true：小于15
   * false：大于等于15
   */
  static async isConditionCountValid(modeId: string): Promise<boolean> {
    let configDataList: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndTypes(modeId, CONDITION_LIST);
    if (configDataList && configDataList.length >= 0 &&
      configDataList.length < IntentConstant.MAX_CONDITION_LENGTH) {
      LogUtil.showInfo(TAG, 'the count of query conditions based on the model id is valid.');
      return true;
    }
    LogUtil.showInfo(TAG, 'the count of query conditions based on the model id is inValid.');
    return false;
  }

  /**
   * 获取某个模式单次且关闭的第一个时间围栏条件
   *
   * @param modeId 模式id
   * @returns 某个模式单次且关闭的第一个时间围栏条件
   */
  static async getFirstSingleAndCloseCondition(modeId: string): Promise<ConfigData | undefined> {
    let configDataList: ConfigData[] = (await ConfigDataManager.getInstance()
      .queryConfigByModeAndTypes(modeId, [ConfigType.TRIGGER_CONDITION_TIME])).filter((configData) => {
      let timeInfo: TimeCondition = JsonUtil.fromJson(configData.configValue) as TimeCondition;
      return timeInfo.loopType === LoopType.ONE_TIME && !timeInfo.enable;
    });
    if (!CheckEmptyUtils.isEmptyArr(configDataList) && configDataList.length >= 1) {
      LogUtil.showInfo(TAG, `time condition length: ${configDataList.length}`);
      return configDataList[0];
    }
    return undefined;
  }

  /**
   * 当前模式的条件已达最大值15，不存在单次且关闭的时间条件
   *
   * @param modeId 模式id
   * @returns false无法添加条件，true可添加或替换条件
   */
  static async hasConditionUpdate(modeId: string): Promise<boolean>{
    let isConditionCountValid: boolean = await IntentConditionUtil.isConditionCountValid(modeId);
    let singleAndCloseCondition: ConfigData | undefined =
      await IntentConditionUtil.getFirstSingleAndCloseCondition(modeId);
    if (!isConditionCountValid && !singleAndCloseCondition) {
      return false;
    }
    return true;
  }
}

