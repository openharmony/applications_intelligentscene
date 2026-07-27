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
import { DebounceUtil } from '@ohos/scene.common/src/main/ets/utils/DebounceUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { TimeUtil } from '@ohos/scene.common/src/main/ets/utils/TimeUtil';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import TriggerConditionManager from '@ohos/scene.configmanage/src/main/ets/manager/TriggerConditionManager';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { AgentSwitchType, HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { El1RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/El1RdbStoreHelper';
import { IntentConditionUtil } from '../util/IntentConditionUtil';
import { IntentCodeConstants } from '../constant/IntentCodeConstant';
import { IntentUtil } from '../util/IntentUtil';
import { VerifyPeriodUtil } from '../util/VerifyPeriodUtil';

const TAG: string = 'IntentActivateModeAdaptor: ';
const TIME_OUT: number = 200;
const ONE_DAY_END_TIME: string = '24:00';
const NEXT_DAY_START_TIME: string = '0:00';

/**
 * 意图框架激活模式转接类
 */
export class IntentActivateModeAdaptor {

  /**
   * 根据modeId打开模式
   *
   * @param modeId 模式id
   * @returns 返回意图结果
   */
  static async activateMode(modeId: string): Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showInfo(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_MODE_NOT_EXIST);
    }
    await El1RdbStoreHelper.getInstance().getRdbStore();
    let result: string = StateManager.getInstance().startScene(modeId, FactorType.USER);
    await DebounceUtil.sleep(TIME_OUT);
    result = StateManager.getInstance().getCurrentScene();
    LogUtil.showInfo(TAG, `activate mode timeout result is: ${result}`);
    if (CheckEmptyUtils.checkStrIsEmpty(result)) {
      return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_MODE_FAIL_CODE);
    }
    HiSysEventUtil.reportIntentModifySwitchBehaviorEvent(true, AgentSwitchType.MODE_STATE_CHANGE, modeId);
    return IntentUtil.successResponse(IntentCodeConstants.ACTIVATE_MODE_SUCCESS_CODE, result);
  }

  /**
   * 根据modeId关闭模式
   *
   * @param modeId 模式id
   * @returns 返回意图结果
   */
  static async deActivateMode(modeId: string): Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showError(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.DEACTIVATE_MODE_NOT_EXIST);
    }
    let openedModeId: string = StateManager.getInstance().getCurrentScene();
    if (openedModeId !== modeId) {
      LogUtil.showError(TAG, 'opened modeId is different from modeId.');
      return IntentUtil.errorResponse(IntentCodeConstants.DEACTIVATE_MODE_CLOSED);
    }
    let result: string = StateManager.getInstance().stopScene(modeId, FactorType.USER);
    await DebounceUtil.sleep(TIME_OUT);
    result = StateManager.getInstance().getCurrentScene();
    LogUtil.showInfo(TAG, `deactivate mode timeout result is: ${result}`);
    if (CheckEmptyUtils.checkStrIsEmpty(result)) {
      return IntentUtil.errorResponse(IntentCodeConstants.DEACTIVATE_MODE_FAIL_CODE);
    }
    HiSysEventUtil.reportIntentModifySwitchBehaviorEvent(false, AgentSwitchType.MODE_STATE_CHANGE, modeId);
    return IntentUtil.successResponse(IntentCodeConstants.DEACTIVATE_MODE_SUCCESS_CODE, result);
  }

  /**
   * 根据modeId添加一个立即开启X时间的时间条件
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async activateModeByTimerTiming(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showInfo(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_BY_TIMER_NOT_EXIST);
    }

    // 1、当前条件已达15，不存在单次且关闭的时间条件
    if (!(await IntentConditionUtil.hasConditionUpdate(modeId))) {
      return IntentUtil.errorResponse(IntentCodeConstants.ADD_TIME_PERIOD_MAX);
    }

    let timerTiming: number = Number(intentParam.timerTiming);
    if (isNaN(timerTiming) || timerTiming <= 0) {
      LogUtil.showError(TAG, 'activate mode by timer param is invalid.');
      return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_BY_TIMER_PARA_FAIL_CODE);
    }
    LogUtil.showInfo(TAG, `activate mode by timer timerTiming is: ${timerTiming}`);
    let condition: TimeCondition = ModeUtil.generateConditionByMinute('', timerTiming);
    // 2、当前模式条件已达15，存在单次且关闭的时间条件，替换第一个；3、当前模式条件不足15直接添加
    let configId: string = await IntentActivateModeAdaptor.updateCondition(condition, modeId);

    if (!CheckEmptyUtils.checkStrIsEmpty(configId)) {
      HiSysEventUtil.reportIntentModifySwitchBehaviorEvent(true, AgentSwitchType.MODE_STATE_CHANGE, modeId, condition);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `refresh_${configId}`);
      return IntentUtil.successResponse(IntentCodeConstants.ACTIVATE_BY_TIMER_SUCCESS_CODE, configId);
    }
    return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_BY_TIMER_FAIL_CODE);
  }

  /**
   * 根据modeId添加一个立即开启至X时间的时间条件
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async activateModeByEndTime(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showInfo(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_BY_ENDTIME_NOT_EXIST);
    }

    // 当前条件已达15，不存在单次且关闭的时间条件
    if (!(await IntentConditionUtil.hasConditionUpdate(modeId))) {
      return IntentUtil.errorResponse(IntentCodeConstants.ADD_TIME_PERIOD_MAX);
    }

    let endTime: string = String(intentParam.endTime);
    endTime = TimeUtil.remainHourAndMinute(endTime);
    LogUtil.showInfo(TAG, `activate mode by endTime endTime is: ${endTime}`);
    if (CheckEmptyUtils.checkStrIsEmpty(endTime)) {
      LogUtil.showError(TAG, 'activate mode by endTime param is invalid.');
      return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_BY_ENDTIME_PARA_FAIL_CODE);
    }
    let condition: TimeCondition = ModeUtil.generateConditionByEndTime('', endTime);
    // 2、当前模式条件已达15，存在单次且关闭的时间条件，替换第一个；3、当前模式条件不足15直接添加
    let configId: string = await IntentActivateModeAdaptor.updateCondition(condition, modeId);

    if (!CheckEmptyUtils.checkStrIsEmpty(configId)) {
      HiSysEventUtil.reportIntentModifySwitchBehaviorEvent(true, AgentSwitchType.MODE_STATE_CHANGE, modeId, condition);
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `refresh_${configId}`)
      return IntentUtil.successResponse(IntentCodeConstants.ACTIVATE_BY_ENDTIME_SUCCESS_CODE, configId);
    }
    return IntentUtil.errorResponse(IntentCodeConstants.ACTIVATE_BY_ENDTIME_FAIL);
  }

  /**
   * 根据模式条件更新时间围栏条件
   * 2、当前模式条件已达15，存在单次且关闭的时间条件，替换第一个；3、当前模式条件不足15直接添加
   *
   * @param modeId 模式id
   * @param condition 时间条件
   * @returns 返回更新时间条件的configId
   */
  static async updateCondition(condition: TimeCondition, modeId: string): Promise<string> {
    let isUpdateCondition: boolean = false;
    let isConditionCountValid: boolean = await IntentConditionUtil.isConditionCountValid(modeId);
    let configData: ConfigData | undefined = await IntentConditionUtil.getFirstSingleAndCloseCondition(modeId);
    if (!isConditionCountValid && configData) {
      let tempTimeInfo: TimeCondition = JsonUtil.fromJson(configData.configValue) as TimeCondition;
      condition.configId = tempTimeInfo.configId;
      isUpdateCondition = true;
    }
    let configId: string = await IntentActivateModeAdaptor.addTimeCondition(modeId, condition, isUpdateCondition);
    LogUtil.showInfo(TAG, `update condition configId is: ${configId}`);
    return configId;
  }

  /**
   * 根据modeId添加或更新一个时间条件
   *
   * @param modeId 模式id
   * @param condition 时间条件
   * @param isUpdateCondition 更新或添加添加
   * @returns 返回添加时间条件的configId
   */
  static async addTimeCondition(modeId: string, condition: TimeCondition, isUpdateCondition: boolean): Promise<string> {
    condition.configType = ConfigType.TRIGGER_CONDITION_TIME;
    LogUtil.showInfo(TAG, `add time condition timeStart is: ${condition.timeStart}, timeEnd is: ${condition.timeEnd}, loopDays is: ${condition.loopDays}`);
    // 情景模式内一天的截止用的是次日凌晨0:00表示，因此需要转换一下
    if (condition.timeEnd === ONE_DAY_END_TIME) {
      condition.timeEnd = NEXT_DAY_START_TIME;
    }
    let configId: string = '';
    if (isUpdateCondition) {
      configId = await TriggerConditionManager.updateAndActivateTriggerCondition(condition);
    } else {
      configId = await TriggerConditionManager.addTriggerCondition(modeId, condition);
    }
    if (StringUtil.isNotEmpty(configId)) {
      ModeDetailAdapter.getInstance().updateParsedConfigById(configId);
      EventBus.getInstance().emit(EventBusNameConstant.DB_CONFIG_DATA_REFRESH);
    }
    return configId;
  }
}