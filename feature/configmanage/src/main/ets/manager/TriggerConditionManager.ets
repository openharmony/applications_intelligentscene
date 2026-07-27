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

import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { ActivationManager } from '@ohos/scene.activationmanage/src/main/ets/manager/ActivationManager';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import {
  AppCondition,
  BaseCondition,
  TimeCondition,
} from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { DateTimeUtil, SCHEDULED_POWER_TIME_NOT_SET } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { HistoryDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/HistoryDataManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import {
  getCalendarPermissionStatus
} from '@ohos/scene.common/src/main/ets/basecomponent/dialog/CalendarPermissionDialog';
import { SceneBaseDataManager } from '../manager/SceneBaseDataManager';
import { ModeDetailAdapter } from '../adapter/ModeDetailAdapter';

const TAG = 'TriggerConditionManager';
const FIVE_DECIMAL_PLACES: number = 5;

/**
 * 触发条件数据管理类
 */
class TriggerConditionManager {
  public async getConditionsByModeIdAndConfigType(modeId: string, configType: ConfigType): Promise<BaseCondition[]> {
    LogUtil.showInfo(TAG, `getConditionsByModeIdAndConfigType, modeId: ${modeId}, configType:${configType} `);
    const configManager: ConfigDataManager = ModeConfigAdapter.getInstance().getConfigDataManager(modeId);
    let configList: ConfigData[] = await configManager.queryConfigByModeAndType(modeId, configType);
    let res: BaseCondition[] = [];
    for (let config of configList) {
      if (configType === ConfigType.TRIGGER_CONDITION_TIME) {
        let timeInfo: TimeCondition = JsonUtil.fromJson(config.configValue) as TimeCondition;
        timeInfo.configId = config.configId;
        res.push(timeInfo);
      } else if (configType === ConfigType.TRIGGER_CONDITION_APP) {
        let appInfo: AppCondition = JsonUtil.fromJson(config.configValue) as AppCondition;
        appInfo.configId = config.configId;
        res.push(appInfo);
      } else {
        LogUtil.showWarn(TAG, `config: ${config.configId} is not condition`);
      }
    }
    return res;
  }

  public async addTriggerCondition(modeId: string, condition: BaseCondition,
    needUpdate: boolean = true): Promise<string> {
    let configValue: string = '';
    switch (condition.configType) {
      case ConfigType.TRIGGER_CONDITION_TIME:
        let timeInfo: TimeCondition = condition as TimeCondition;
        timeInfo = this.dealTimeConfigData(timeInfo);
        configValue = JsonUtil.stringify(timeInfo);
        break;
      case ConfigType.TEMPORARY_TIME_CONDITION:
        let tempTimeInfo: TimeCondition = condition as TimeCondition;
        configValue = JsonUtil.stringify(tempTimeInfo);
        // 临时开启条件只能有一条
        await this.clearTemporaryTimeCondition();
        break;
      case ConfigType.TRIGGER_CONDITION_APP:
        let appCondition: AppCondition = condition as AppCondition;
        configValue = JsonUtil.stringify(appCondition);
        break;
      default:
        break;
    }
    let data: ConfigData = {
      configId: CheckEmptyUtils.checkStrIsEmpty(condition.configId) ? '' : condition.configId,
      modeId: modeId,
      configType: condition.configType,
      configValue: configValue,
    };
    const configManager: ConfigDataManager = ModeConfigAdapter.getInstance()
      .getConfigDataManager(modeId, condition.configType);
    let configId: string = await configManager.insertConfigData(data);
    let logInfo: string = `configId: ${configId}`;
    LogUtil.showWarn(TAG, `addTriggerCondition, ${logInfo}`);
    return configId;
  }

  public async updateAndActivateTriggerCondition(condition: BaseCondition,
    needUpdate: boolean = true): Promise<string> {
    LogUtil.showInfo(TAG, 'updateAndActivateTriggerCondition');
    let configId: string = await this.updateTriggerCondition(condition);
    if (StringUtil.isNotEmpty(configId) && needUpdate) {
      SceneBaseDataManager.setIntelligentUsedState();
    }
    return configId;
  }

  public async updateTriggerCondition(condition: BaseCondition): Promise<string> {
    if (condition.configType === ConfigType.TRIGGER_CONDITION_TIME) {
      condition = this.dealTimeConfigData(condition as TimeCondition);
    }
    const configValue: string = JsonUtil.stringify(condition);
    let logInfo: string = `configId: ${condition.configId}`;
    LogUtil.showWarn(TAG, `updateTriggerCondition: ${logInfo}`);
    let data: ConfigData = {
      configId: condition.configId,
      modeId: '0',
      configType: condition.configType,
      configValue: configValue,
    };
    const modeId: string = ModeUtil.getModeIdFromConfigId(condition.configId);
    const configManager: ConfigDataManager = ModeConfigAdapter.getInstance()
      .getConfigDataManager(modeId, condition.configType);
    let configId: string = await configManager.updateConfigData(data);
    return configId;
  }

  public async updateTimeOnceCondition(operType: number): Promise<void> {
    LogUtil.showInfo(TAG, `updateTimeOnceCondition, operType: ${operType}`);
    const configTypes: ConfigType[] = [
      ConfigType.TRIGGER_CONDITION_TIME
    ];
    const el1ConfigData: ConfigData[] =
      await El1ConfigDataManager.getInstance().queryConfigDataByConfigType(configTypes);
    const el2ConfigData: ConfigData[] = await ConfigDataManager.getInstance().queryConfigDataByConfigType(configTypes);
    const configs: ConfigData[] = [...el1ConfigData, ...el2ConfigData];
    LogUtil.showInfo(TAG, `updateTimeOnceCondition. el1ConfigData length: ${el1ConfigData.length},
     el2ConfigData length: ${el2ConfigData.length}`);
    let updateCount: number = 0;
    if (!configs || configs.length === 0) {
      return;
    }
    for (const config of configs) {
      let condition = JsonUtil.fromJson(config.configValue) as TimeCondition;
      condition.configId = config.configId;
      const isNeedUpdate: boolean = this.isNeedUpdateTimeOnceCondition(condition, operType);
      if (isNeedUpdate) {
        condition.enable = false;
        updateCount++;
        await this.updateTriggerCondition(condition);
      }
    }
    if (updateCount > 0) {
      LogUtil.showInfo(TAG, `updateConditionCount: ${updateCount}`);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_CONFIG_DATA, '1');
    }
  }

  private isNeedUpdateTimeOnceCondition(condition: TimeCondition, operType: number): boolean {
    if (condition.loopType !== LoopType.ONE_TIME || !condition.enable) {
      return false;
    }
    const dateRange: Date[] = DateTimeUtil.parseTimeRange(DateTimeUtil.parseStringToDate(condition.loopDays),
      condition.timeStart, condition.timeEnd);
    const dateEnd: Date = dateRange[1];
    const dateStart: Date = dateRange[0];
    LogUtil.showInfo(TAG, `configId: ${condition.configId}, dateRange: ${dateStart}-${dateEnd}`);
    const dateCurrent: Date = new Date();

    //自动启停时，单次条件达到结束时间才会刷新关闭
    if (operType === FactorType.AUTO && dateEnd > dateCurrent) {
      return false;
    }

    //手动启停时，单次条件若已开始生效，则状态刷新为关闭
    if ([FactorType.USER, FactorType.RECOMMENDATION].includes(operType) && dateCurrent < dateStart) {
      return false;
    }
    return true;
  }

  public async deleteTriggerCondition(configId: string): Promise<number> {
    if (CheckEmptyUtils.checkStrIsEmpty(configId)) {
      return INVALID_VALUE;
    }
    const modeId: string = ModeUtil.getModeIdFromConfigId(configId);
    let configType: ConfigType = ModeUtil.getTypeFromConfigId(configId);
    LogUtil.showWarn(TAG, `deleteTriggerCondition, modeId: ${modeId}, configId: ${configId}`);
    const configManager: ConfigDataManager = ModeConfigAdapter.getInstance().getConfigDataManager(modeId, configType);
    let res: number = await configManager.deleteConfigDataById(configId);
    if (res !== INVALID_VALUE) {
      HistoryDataManager.getInstance().deleteInValidRecord();
      SceneBaseDataManager.setIntelligentUsedState();
    }
    return res;
  }

  public async getConditionUpdateTime(modeId: string, configId: string, configType?: ConfigType): Promise<number> {
    let configManager: ConfigDataManager;
    if (configType) {
      configManager = ModeConfigAdapter.getInstance().getConfigDataManager(modeId, configType);
    } else {
      configManager = ModeConfigAdapter.getInstance().getConfigDataManager(modeId);
    }
    try {
      let configData: ConfigData | undefined = await configManager.queryConfigDataById(configId);
      if (configData === undefined || configData.updateTime === undefined) {
        return INVALID_VALUE;
      }
      return configData.updateTime;
    } catch (err) {
      LogUtil.showInfo(TAG, `getConditionUpdateTime failed error code: ${err?.code}, message: ${err?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 获取临时开启条件configValue(数据库最多只有一条数据)
   */
  private async getTemporaryTimeConditionByManager(manager: ConfigDataManager): Promise<BaseCondition | undefined> {
    const config: ConfigData[] = await manager.queryConfigDataByConfigType([ConfigType.TEMPORARY_TIME_CONDITION]);
    if (config.length === 0) {
      return undefined;
    }
    LogUtil.showInfo(TAG, `getTemporaryTimeCondition. length:${config.length}`);
    return JsonUtil.fromJson(config[0]?.configValue) as BaseCondition;
  }

  /**
   * 删除临时开启条件(数据库最多只有一条数据)
   */
  private async deleteTemporaryTimeConditionByManager(manager: ConfigDataManager): Promise<number> {
    const res: number = await manager.deleteConfigDataByConfigType(ConfigType.TEMPORARY_TIME_CONDITION);
    LogUtil.showInfo(TAG, `deleteTemporaryTimeCondition. res:${res}`);
    return res;
  }

  /**
   * 清空临时开启的条件数据 避免影响下次规则下发
   */
  public async clearTemporaryTimeCondition(): Promise<void> {
    const el2Condition: BaseCondition | undefined =
      await this.getTemporaryTimeConditionByManager(ConfigDataManager.getInstance());
    if (el2Condition) {
      LogUtil.showInfo(TAG, `clearTemporaryTimeCondition. el2Condition.configId: ${el2Condition.configId}`);
      await this.deleteTemporaryTimeConditionByManager(ConfigDataManager.getInstance());
      return;
    }
    const el1Condition: BaseCondition | undefined =
      await this.getTemporaryTimeConditionByManager(El1ConfigDataManager.getInstance());
    if (el1Condition) {
      LogUtil.showInfo(TAG, `clearTemporaryTimeCondition. el1Condition.configId: ${el1Condition.configId}`);
      await this.deleteTemporaryTimeConditionByManager(El1ConfigDataManager.getInstance());
      return;
    }
    LogUtil.showWarn(TAG, 'clearTemporaryTimeCondition. condition is empty');
  }

  private async addHolidayInfo(): Promise<boolean> {
    const holidayData: string = DateTimeUtil.getHolidayInfo();
    if (holidayData === SCHEDULED_POWER_TIME_NOT_SET) {
      return false;
    }
    let configData: ConfigData | undefined =
      await ConfigDataManager.getInstance().queryConfigDataById(ConfigType.HOLIDAY_INFO.toString());
    if (configData && holidayData === configData.configValue) {
      LogUtil.showInfo(TAG, 'already has the same holiday info');
      return false;
    }
    if (configData) {
      LogUtil.showInfo(TAG, 'update holiday info');
      configData.configValue = holidayData;
      await ConfigDataManager.getInstance().updateConfigData(configData);
      return true;
    }
    let data: ConfigData = {
      configId: '',
      modeId: '0',
      configType: ConfigType.HOLIDAY_INFO,
      configValue: holidayData,
    };
    let configId: string = await ConfigDataManager.getInstance().insertConfigData(data);
    return !CheckEmptyUtils.isEmpty(configId);
  }

  private dealTimeConfigData(timeInfo: TimeCondition): TimeCondition {
    if (timeInfo.loopType === LoopType.WORKDAY || timeInfo.loopType === LoopType.HOLIDAY) {
      LogUtil.showInfo(TAG, 'add holiday');
      this.addHolidayInfo();
    }

    // loopType为week，但loopDays内容内容为空或者包括日期符号‘-’时则转为单次类型
    if (timeInfo.loopType === LoopType.EVERY_WEEK &&
      (StringUtil.isEmpty(timeInfo.loopDays) || timeInfo.loopDays.includes('-'))) {
      timeInfo.loopType = LoopType.ONE_TIME;
    }
    if (timeInfo.loopType === LoopType.ONE_TIME) {
      timeInfo.loopDays = DateTimeUtil.getNearestDateInRange(timeInfo.timeStart, timeInfo.timeEnd);
      LogUtil.showInfo(TAG, `one time date: ${timeInfo.loopDays}`);
    }
    if (![LoopType.ONE_TIME, LoopType.EVERY_WEEK].includes(timeInfo.loopType)) {
      timeInfo.loopDays = '';
    }
    return timeInfo;
  }
}

export default new TriggerConditionManager();