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
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LoopType } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { TimeUtil } from '@ohos/scene.common/src/main/ets/utils/TimeUtil';
import TriggerConditionManager from '@ohos/scene.configmanage/src/main/ets/manager/TriggerConditionManager';
import {
  AgentConfigType,
  AgentOperationType,
  HiSysEventUtil,
} from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { ERROR_MSG, IntentCodeConstants } from '../constant/IntentCodeConstant';
import { IntentUtil } from '../util/IntentUtil';
import { VerifyPeriodUtil } from '../util/VerifyPeriodUtil';
import { IntentConditionUtil } from '../util/IntentConditionUtil';

const TAG: string = 'IntentModifyTimePeriodAdaptor: '

const DEFAULT_START: string = '22:00';
const DEFAULT_END: string = '7:00';
const MAX_HOURS: number = 24;
const DEFAULT_REPEAT: string = '';
const REPEAT_DAYS: string[] = ['1', '2', '3', '4', '5', '6', '7'];
const PERIOD_POLICY: number[] = [1, 2, 3, 4, 5];

/**
 * 意图框架修改时间条件转接类
 */
export class IntentModifyTimePeriodAdaptor {

  /**
   * 根据模式id修改时间条件
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async modifyModePeriod(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    LogUtil.showInfo(TAG, `modifyModePeriod, modeId: ${modeId}`);
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showInfo(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_TIME_PERIOD_NOT_EXIST);
    }
    LogUtil.showInfo(TAG, 'modify mode period');
    let configDataList: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndTypes(modeId, [ConfigType.TRIGGER_CONDITION_TIME]);
    LogUtil.showInfo(TAG, `modify mode period configDataList len: ${configDataList.length}`);
    if (!CheckEmptyUtils.isEmptyArr(configDataList)) {
      // 修改第一条时间
      return IntentModifyTimePeriodAdaptor.updateTimePeriod(configDataList[0], intentParam, modeId);
    }
    // 新增一条时间条件
    return IntentModifyTimePeriodAdaptor.modifyModeAddNewPeriod(modeId, intentParam, true);
  }

  /**
   * 根据模式id新增时间条件
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @param isFromModifyIntent 模式无时间条件，用户输入修改该模式时间条件场景下为true
   * @returns 返回意图结果
   */
  static async modifyModeAddNewPeriod(modeId: string, intentParam: Record<string, Object>,
    isFromModifyIntent?: boolean):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showError(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.ADD_TIME_PERIOD_NOT_EXIST);
    }
    let periodPolicyParam: number = Number(intentParam.periodPolicy);
    // 4和5表示法定假日、工作日
    if ((periodPolicyParam === PERIOD_POLICY[3] || periodPolicyParam === PERIOD_POLICY[4]) &&
      !DateTimeUtil.hasHolidayInfo()) {
      return IntentUtil.errorResponse(IntentCodeConstants.ADD_HOLIDAY_INFO_NOT_EXIST);
    }
    LogUtil.showInfo(TAG, 'add new period');
    let isConditionCountValid: boolean = await IntentConditionUtil.isConditionCountValid(modeId);
    if (isConditionCountValid) {
      return IntentModifyTimePeriodAdaptor.addTimePeriod(modeId, intentParam, isFromModifyIntent);
    }
    // 当前条件已达15
    let configData: ConfigData | undefined = await IntentConditionUtil.getFirstSingleAndCloseCondition(modeId);
    if (configData) {
      LogUtil.showInfo(TAG, 'the condition has reached the maximum count. modify the first single and close condition.');
      return IntentModifyTimePeriodAdaptor.updateTimePeriod(configData, intentParam, modeId);
    }
    return IntentUtil.errorResponse(IntentCodeConstants.ADD_TIME_PERIOD_MAX);
  }

  /**
   * 更新时间条件
   *
   * @param configData 待更新数据
   * @param intentParam 意图参数
   * @param modeId 模式id
   * @returns 返回意图结果
   */
  static async updateTimePeriod(configData: ConfigData, intentParam: Record<string, Object>, modeId: string):
    Promise<insightIntent.ExecuteResult> {
    if (CheckEmptyUtils.isEmpty(configData)) {
      LogUtil.showError(TAG, 'update time period configData is error.');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_TIME_PERIOD_FAIL_CODE);
    }
    let tempTimeInfo: TimeCondition = JsonUtil.fromJson(configData.configValue) as TimeCondition;
    LogUtil.showInfo(TAG, `update time period timeInfo: ${tempTimeInfo}`);
    let updateTimeInfo: TimeCondition | undefined = IntentModifyTimePeriodAdaptor
      .modifyPeriodParmValid(intentParam, tempTimeInfo);
    if (!updateTimeInfo) {
      LogUtil.showError(TAG, 'update time period updateTimeInfo is error.');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_TIME_PERIOD_FAIL_CODE);
    }
    updateTimeInfo.configId = configData.configId;
    LogUtil.showInfo(TAG, `update time period updateTimeInfo: ${updateTimeInfo}`);
    let configId: string = await TriggerConditionManager.updateAndActivateTriggerCondition(updateTimeInfo);
    LogUtil.showInfo(TAG, `update time period configId: ${configId}`);
    if (!CheckEmptyUtils.checkStrIsEmpty(configId)) {
      HiSysEventUtil.reportIntentEditConditionBehaviorEvent(AgentOperationType.MODIFY,
        AgentConfigType.TIME_CONDITION, modeId, updateTimeInfo);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `refresh_${configId}`)
      return IntentUtil.successResponse(IntentCodeConstants.MODIFY_TIME_PERIOD_SUCCESS_CODE,
        ERROR_MSG[IntentCodeConstants.MODIFY_TIME_PERIOD_SUCCESS_CODE]);
    }
    return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_TIME_PERIOD_FAIL_CODE);
  }

  /**
   * 添加时间条件
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @param isFromModifyIntent 模式无时间条件，用户输入修改该模式时间条件场景下为true
   * @returns 返回意图结果
   */
  static async addTimePeriod(modeId: string, intentParam: Record<string, Object>, isFromModifyIntent?: boolean):
    Promise<insightIntent.ExecuteResult> {
    let timeInfo: TimeCondition | undefined = IntentModifyTimePeriodAdaptor.modifyPeriodParmValid(intentParam);
    if (!timeInfo) {
      LogUtil.showError(TAG, 'add time period timeInfo is error.');
      return IntentUtil.errorResponse(IntentCodeConstants.ADD_TIME_PERIOD_FAIL_CODE);
    }
    let configId: string = await TriggerConditionManager.addTriggerCondition(modeId, timeInfo);
    LogUtil.showInfo(TAG, `add time period configId: ${configId}`);
    if (CheckEmptyUtils.checkStrIsEmpty(configId)) {
      return IntentUtil.errorResponse(IntentCodeConstants.ADD_TIME_PERIOD_FAIL_CODE);
    }
    HiSysEventUtil.reportIntentEditConditionBehaviorEvent(AgentOperationType.ADD,
      AgentConfigType.TIME_CONDITION, modeId, timeInfo);
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `refresh_${configId}`);
    if (isFromModifyIntent) {
      return IntentUtil.successResponse(IntentCodeConstants.MODIFY_TIME_PERIOD_SUCCESS_CODE,
        ERROR_MSG[IntentCodeConstants.MODIFY_TIME_PERIOD_SUCCESS_CODE]);
    }
    return IntentUtil.successResponse(IntentCodeConstants.ADD_TIME_PERIOD_SUCCESS_CODE,
      ERROR_MSG[IntentCodeConstants.ADD_TIME_PERIOD_SUCCESS_CODE]);
  }

  /**
   * 时间条件参数校验
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static modifyPeriodParmValid(intentParam: Record<string, Object>, tempTimeInfo?: TimeCondition):
    TimeCondition | undefined {
    let periodSwitchParam: number = Number(intentParam.periodswitch);
    let periodPolicyParam: number = Number(intentParam.periodPolicy);
    let repeatDaysParam: string[] = Array.isArray(intentParam.repeatDays) ? intentParam.repeatDays : [];
    let startTimeParam: string = String(intentParam.startTime);
    let endTimeParam: string = String(intentParam.endTime);

    LogUtil.showInfo(TAG, `modifyPeriodParmValid periodSwitchParam: ${periodSwitchParam},
    periodPolicyParam: ${periodPolicyParam},repeatDaysParam: ${repeatDaysParam},startTimeParam: ${startTimeParam},
    endTimeParam: ${endTimeParam}`);

    let startTime: string = TimeUtil.remainHourAndMinute(startTimeParam);
    let endTime: string = TimeUtil.remainHourAndMinute(endTimeParam);
    if (CheckEmptyUtils.checkStrIsEmpty(startTime) || CheckEmptyUtils.checkStrIsEmpty(endTime)) {
      LogUtil.showError(TAG, 'verify time period startTime or endTime is exceeds maxTime.');
      return undefined;
    }
    if (Number(startTime) > MAX_HOURS || Number(endTime) > MAX_HOURS) {
      LogUtil.showError(TAG, 'verify time period startTime or endTime .');
      return undefined;
    }
    let timeInfo: TimeCondition = !tempTimeInfo ?
      IntentModifyTimePeriodAdaptor.getDefaultCondition() : tempTimeInfo;
    timeInfo.enable = periodSwitchParam !== 0;
    timeInfo.timeStart = startTime;
    timeInfo.timeEnd = endTime;
    if (periodPolicyParam === PERIOD_POLICY[2]) {
      if (CheckEmptyUtils.isEmptyArr(repeatDaysParam)) {
        LogUtil.showError(TAG, 'verify time period repeatDaysParam is error.');
        return undefined;
      }
      for (let index = 0; index < repeatDaysParam.length; index++) {
        if (!REPEAT_DAYS.includes(`${repeatDaysParam[index]}`)) {
          LogUtil.showError(TAG, 'verify time period repeatDaysParam is error.');
          return undefined;
        }
      }
      timeInfo.loopDays = String(repeatDaysParam);
    }
    if (PERIOD_POLICY.includes(periodPolicyParam)) {
      timeInfo.loopType = periodPolicyParam;
    } else {
      LogUtil.showWarn(TAG, `periodPolicyParam is incorrect:  ${periodPolicyParam}`);
    }
    return timeInfo;
  }

  static getDefaultCondition(): TimeCondition {
    return {
      enable: true,
      configId: '',
      configType: ConfigType.TRIGGER_CONDITION_TIME,
      loopType: LoopType.ONE_TIME,
      loopDays: DEFAULT_REPEAT,
      timeStart: DEFAULT_START,
      timeEnd: DEFAULT_END
    }
  }
}