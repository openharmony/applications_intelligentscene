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
import { FactorTypeValue } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { HistoryDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/HistoryDataManager';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { ModeHistory } from '@ohos/scene.datamanage/src/main/ets/model/ModeHistory';
import { SCENE_DISABLE } from '@ohos/scene.configlinkage/src/main/ets/constant/LinkageConstants';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

const TAG: string = 'SceneEndTimeAdapter: ';
const INTELLIGENT_SCENE_ENDTIME: string = 'Scene_EndTime_TimeTriggered';

let timeConfigTypeSet: Set<ConfigType> = new Set<ConfigType>()
  .add(ConfigType.TRIGGER_CONDITION_TIME)
  .add(ConfigType.TEMPORARY_TIME_CONDITION);

/**
 * 模式定时结束时间适配器，用于记录定时条件结束时间，在重启未解锁时读取
 */
export class SceneEndTimeAdapter {
  /**
   * 保存定时条件结束时间: 查询当前开启模式历史记录中AUTO_ON的所有定时条件和临时条件configId，获取config的最大endTime
   *
   * @param resultMode 当前生效的记录
   */
  public static async saveSceneStopTime(resultMode: ModeHistory): Promise<void> {
    LogUtil.showInfo(TAG, `saveSceneStopTime, current mode id: ${resultMode.modeId} ${resultMode.operType}`);
    if (resultMode.modeId === SCENE_DISABLE || resultMode.operType === FactorTypeValue.MANUAL_ON) {
      SceneEndTimeAdapter.resetSceneStopTime();
      return;
    }

    const modeId: string = resultMode.modeId;
    let autoOnRecords: ModeHistory[] =
      await HistoryDataManager.getInstance().queryDataByModeAndType(modeId, FactorTypeValue.AUTO_ON);
    const maxTimeEnd: number = await SceneEndTimeAdapter.getMaxEndTime(autoOnRecords);
    if (maxTimeEnd === 0) {
      SceneEndTimeAdapter.resetSceneStopTime();
      return;
    }
    const endTime: string = `${modeId}#${maxTimeEnd}`;
    SettingsDataUtils.setSecureValue(INTELLIGENT_SCENE_ENDTIME, endTime);
    LogUtil.showInfo(TAG, `saveSceneStopTime, end Time: ${endTime}`);
  }

  /**
   * 重置模式定时条件结束时间
   */
  public static resetSceneStopTime(): void {
    LogUtil.showInfo(TAG, 'resetSceneStopTime');
    SettingsDataUtils.setSecureValue(INTELLIGENT_SCENE_ENDTIME, '');
  }

  public static async getMaxEndTime(autoRecords: ModeHistory[]): Promise<number> {
    let maxTimeEnd: number = 0;
    let configIds: string[] = autoRecords.map((record) => record.configId);
    configIds = configIds.filter((configId) => timeConfigTypeSet.has(ModeUtil.getTypeFromConfigId(configId)));
    const configs: ConfigData[] = await ConfigDataManager.getInstance().queryConfigDataByIds(configIds);
    LogUtil.showInfo(TAG, `getMaxEndTime, autoRecords size: ${autoRecords.length}  time configIds: ${configs.length}`);

    let configMap: Map<string, ConfigData> = new Map();
    configs.forEach((config) => {
      configMap.set(config.configId, config);
    });
    for (let record of autoRecords) {
      const config: ConfigData | undefined = configMap.get(record.configId);
      if (!config) {
        LogUtil.showError(TAG, 'getMaxEndTime, config data is invalid');
        continue;
      }
      let timeInfo: TimeCondition = JsonUtil.fromJson(config.configValue) as TimeCondition;
      let timeEnd: string[] = timeInfo.timeEnd.split(':');
      if (timeEnd.length <= 1) {
        LogUtil.showError(TAG, `getMaxEndTime failed, timeEnd is invalid ${timeEnd.length}`);
        continue;
      }
      let endDate: Date = new Date();
      let nowDate: Date = new Date();
      endDate.setHours(Number(timeEnd[0]), Number(timeEnd[1]), 0, 0);
      if (nowDate.getTime() > endDate.getTime()) {
        endDate.setDate(endDate.getDate() + 1);
      }
      maxTimeEnd = Math.max(maxTimeEnd, endDate.getTime());
    }
    LogUtil.showInfo(TAG, `getMaxEndTime ${maxTimeEnd}`);
    return maxTimeEnd;
  }
}