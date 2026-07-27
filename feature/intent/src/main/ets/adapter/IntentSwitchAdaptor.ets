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
import { CloudSyncSwitchHelper } from '@ohos/scene.datasync/src/main/ets/helper/CloudSyncSwitchHelper';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PrivacyStatementUtil } from '@ohos/scene.common/src/main/ets/utils/PrivacyStatementUtil';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { NotDisturbAdapter } from '@ohos/scene.notdisturb/src/main/ets/adapter/NotiDisturbAdapter';
import SystemSettingManager from '@ohos/scene.configmanage/src/main/ets/manager/SystemSettingManager';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { OLD_BUSINESS_MODE } from '@ohos/scene.datasync/src/main/ets/helper/CloudSyncSwitchHelper';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { UI_REFRESH_MSG_KEY } from '@ohos/scene.datasync/src/main/ets/constant/Constant';
import { ERROR_MSG, IntentCodeConstants } from '../constant/IntentCodeConstant';
import { IntentUtil } from '../util/IntentUtil';
import { VerifyPeriodUtil } from '../util/VerifyPeriodUtil';
import { IntentConstant } from '../constant/IntentConstant';
import { ModeListChangeType } from '../constant/IntentType';

const TAG: string = 'IntentSwitchAdaptor: '

const MODIFY_SWITCH_FUNCTION_MAP: Map<number, ((modeId: string, isOpen: boolean) =>
Promise<insightIntent.ExecuteResult>)> = new Map([
  // 修改智能体验开关状态
  [IntentConstant.INTELLIGENT_STATE_SWITCH, async (modeId: string, isOpen: boolean) => {
    return IntentSwitchAdaptor.modifyIntelligentState(modeId, isOpen);
  }],
  // 修改重复来电开关状态
  [IntentConstant.REPEAT_CALL_SWITCH, async (modeId: string, isOpen: boolean) => {
    return await IntentSwitchAdaptor.modifyRepeatRingState(modeId, isOpen);
  }],
  [IntentConstant.IMPORTANT_MESSAGE_SWITCH, (modeId: string, isOpen: boolean) => {
    return IntentSwitchAdaptor.modifyImportantMessageState(modeId, isOpen);
  }]
]);

/**
 * 意图框架操作开关转接类
 */
export class IntentSwitchAdaptor {

  /**
   * 根据modeId修改模式开关
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async modifyModeSwitch(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showInfo(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_NOT_EXIST);
    }

    let switchState: number = Number(intentParam.switchState);
    if (!IntentSwitchAdaptor.switchStateValid(switchState)) {
      LogUtil.showError(TAG, 'modify mode switch invalid switch state.');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_INVALID_STATE_CODE);
    }
    let isOpen: boolean = switchState === IntentConstant.SWITCH_VALUE[1];

    let switchName: number = Number(intentParam.switch);
    let intentFunction: ((modeId: string, isOpen: boolean) =>
    Promise<insightIntent.ExecuteResult>) | undefined = MODIFY_SWITCH_FUNCTION_MAP.get(switchName);
    if (!intentFunction) {
      LogUtil.showError(TAG, 'modify mode switch invalid switchName.');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE);
    }

    LogUtil.showInfo(TAG, `modify mode switch switchName is: ${switchName}, switchState is: ${switchState}`);
    try {
      return intentFunction(modeId, isOpen);
    } catch (exception) {
      LogUtil.showError(TAG, 'modify mode switch failed execute action function fail.');
    }
    return IntentUtil.nullResponse();
  }

  /**
   * 修改智能体验开关状态
   *
   * @param modeId 模式Id
   * @param isOpen 智能体验开关状态
   * @returns 返回意图结果
   */
  static modifyIntelligentState(modeId: string, isOpen: boolean): insightIntent.ExecuteResult {
    if (isOpen && !PrivacyStatementUtil.isIntelligentExperienceAgreedFromOtherProcess()) {
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_NO_AUTH);
    }
    const modeOpenState: ModeState = ModeUtil.getModeOpenState();
    if (ModeUtil.isCurrentModeOpened(modeId, modeOpenState)) {
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_EXPERIENCE,
        isOpen ? IntentConstant.INTELLIGENT_EXPERIENCE_ENABLE :
        IntentConstant.INTELLIGENT_EXPERIENCE_DISABLE);
    }
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE,
      `${ModeListChangeType.REFRESH_MODE}intelligent_${modeId}_${isOpen ?
      IntentConstant.SWITCH_VALUE[1] : IntentConstant.SWITCH_VALUE[0]}`);

    LogUtil.showInfo(TAG, `modeId: ${modeId}, switch refresh: ${isOpen}`);
    HiSysEventUtil.reportIntentModifySwitchBehaviorEvent(isOpen, `${IntentConstant.INTELLIGENT_STATE_SWITCH}`, modeId);
    return IntentUtil.successResponse(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
      ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE]);
  }

  /**
   * 修改重复来电开关状态
   *
   * @param modeId 模式Id
   * @param isOpen 重复来电开关状态
   * @returns 返回意图结果
   */
  static async modifyRepeatRingState(modeId: string, isOpen: boolean): Promise<insightIntent.ExecuteResult> {
    const isSupportModifyRepeatRing: boolean = await IntentUtil.isSupportModifyRepeatRing(modeId);
    if (!isSupportModifyRepeatRing) {
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG);
    }
    await ModeDetailAdapter.getInstance().queryConfigByModeId(modeId);
    NotDisturbAdapter.getInstance().updateRepeatRingState(modeId, isOpen);
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE,
      `${ModeListChangeType.REFRESH_MODE}${IntentConstant.CONTACT_REPEAT_CALL_STRING}${modeId}`);
    LogUtil.showInfo(TAG, `modeId: ${modeId}, switch refresh: ${isOpen}`);
    HiSysEventUtil.reportIntentModifySwitchBehaviorEvent(isOpen, `${IntentConstant.REPEAT_CALL_SWITCH}`, modeId);
    return IntentUtil.successResponse(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
      ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE]);
  }

  /**
   * 修改重要信息提醒开关
   *
   * @param modeId 模式Id
   * @param isOpen 重要信息提醒开关状态
   * @returns 返回意图结果
   */
  static async modifyImportantMessageState(modeId: string, isOpen: boolean): Promise<insightIntent.ExecuteResult> {
    LogUtil.showInfo(TAG, `modifyImportantMessageState modeId: ${modeId}, switch refresh: ${isOpen}`);
    const isModeExist: boolean = await El1ModeDataManager.getInstance().isModeIdExist(modeId);
    if (!isModeExist) {
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG);
    }
    const configDataList: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigByModeAndType(modeId, ConfigType.IMPORTANT_MESSAGE_REMINDER);
    if (configDataList?.length <= 0) {
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_NO_SETTING_CONFIG);
    }
    const configData: ConfigData = configDataList[0];
    const enableState: EnableState = {
      enable: isOpen
    };
    configData.configValue = JsonUtil.stringify(enableState);
    await ConfigDataManager.getInstance().updateConfigData(configData);
    SettingsDataUtils.setSecureValue(UI_REFRESH_MSG_KEY, EventBusNameConstant.DB_CONFIG_DATA_REFRESH);
    HiSysEventUtil.reportIntentModifySwitchBehaviorEvent(isOpen, `${IntentConstant.IMPORTANT_MESSAGE_SWITCH}`, modeId);
    return IntentUtil.successResponse(IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE,
      ERROR_MSG[IntentCodeConstants.MODIFY_SWITCH_SUCCESS_CODE]);
  }

  /**
   * 根据modeId修改模式关联系统模式开关
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async modifyModeAssociatedSwitch(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showInfo(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_NOT_EXIST);
    }
    let associatedSwitch: number = Number(intentParam.associatedSwitch);
    let switchState: number = Number(intentParam.switchState);
    if (!IntentSwitchAdaptor.isSwitchValid(switchState) ||
      !IntentSwitchAdaptor.isAssociatedStateValid(associatedSwitch)) {
      LogUtil.showError(TAG, 'modify mode associated switch invalid switch state.');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_TYPE_NOT_SUPPORT);
    }
    LogUtil.showInfo(TAG, `modify associated switch associatedSwitch is ${associatedSwitch} switchState is ${switchState}`);
    switch (associatedSwitch) {
      case IntentConstant.SYSTEM_DARK_MODE:
        return IntentSwitchAdaptor.modifyAssociatedSwitch(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE, switchState);
      case IntentConstant.SYSTEM_EYE_PROTECT_MODE:
        return IntentSwitchAdaptor.modifyAssociatedSwitch(modeId,
          ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE, switchState);
      default:
        LogUtil.showError(TAG, 'modify mode associated switch invalid switch type.');
    }
    return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE);
  }

  /**
   * 根据modeId修改模式关联系统模式开关
   *
   * @param modeId 模式id
   * @param configType 系统模式开关类型
   * @param switchState 开关状态
   * @returns 返回意图结果
   */
  static async modifyAssociatedSwitch(modeId: string, configType: ConfigType, switchState: number):
    Promise<insightIntent.ExecuteResult> {
    const parsedConfigArr = ModeDetailAdapter.getInstance().getParsedConfigDataByType([configType]);
    let configId: string = '';
    if (CheckEmptyUtils.isEmpty(parsedConfigArr) || CheckEmptyUtils.isEmptyArr(parsedConfigArr)) {
      configId = await SystemSettingManager.insertSystemSettingByType(modeId, configType, switchState);
    } else {
      configId = await SystemSettingManager.updateSystemSettingByType(modeId, configType, switchState);
    }
    LogUtil.showInfo(TAG, `modify associated switch configId is ${configId}`);
    if (!CheckEmptyUtils.checkStrIsEmpty(configId)) {
      SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `refresh_${configId}`);
      HiSysEventUtil.reportIntentModifyAssociatedSystemFunBehaviorEvent(switchState, configType, modeId);
      return IntentUtil.successResponse(IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS,
        ERROR_MSG[IntentCodeConstants.MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS]);
    }
    return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_SWITCH_INVALID_TYPE_CODE);
  }

  /**
   * 校验开关状态是否有效
   *
   * @param switchState 开关状态
   * @returns true开关状态有效
   */
  static switchStateValid(switchState: number): boolean {
    if (!IntentConstant.SWITCH_VALUE.includes(switchState)) {
      LogUtil.showError(TAG, 'modify mode switch invalid switch state.');
      return false;
    }
    return true;
  }

  /**
   * 校验关联模式是否有效
   *
   * @param associatedState 开关状态
   * @returns true开关状态有效
   */
  static isAssociatedStateValid(associatedState: number): boolean {
    if (associatedState !== IntentConstant.SYSTEM_DARK_MODE &&
      associatedState !== IntentConstant.SYSTEM_EYE_PROTECT_MODE) {
      LogUtil.showError(TAG, 'modify mode associated switch invalid switch state.');
      return false;
    }
    return true;
  }

  /**
   * 校验关联类型是否有效
   *
   * @param switchState 开关状态
   * @returns true开关状态有效
   */
  static isSwitchValid(switchState: number): boolean {
    if (!IntentConstant.SYSTEM_MODE_VALUE.includes(switchState)) {
      LogUtil.showError(TAG, 'switchState invalid switch state.');
      return false;
    }
    return true;
  }
}