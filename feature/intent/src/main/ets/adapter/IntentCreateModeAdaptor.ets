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
import { image } from '@kit.ImageKit';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { NotDisturbAdapter } from '@ohos/scene.notdisturb/src/main/ets/adapter/NotiDisturbAdapter';
import { SceneBaseDataManager } from '@ohos/scene.configmanage/src/main/ets/manager/SceneBaseDataManager';
import { ModeConfigData } from '@ohos/scene.configmanage/src/main/ets/preload/model/model/DefaultModeConfigData';
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { RefreshAdapter } from '@ohos/scene.recommendation/src/main/ets/adapter/RefreshAdapter';
import { COLOR_ARR } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';
import { TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import TriggerConditionManager from '@ohos/scene.configmanage/src/main/ets/manager/TriggerConditionManager';
import { IntentUtil } from '../util/IntentUtil';
import { ERROR_MSG, IntentCodeConstants } from '../constant/IntentCodeConstant';
import { IntentQueryModeAdaptor } from './IntentQueryModeAdaptor';
import { IntentModifyTimePeriodAdaptor } from './IntentModifyTimePeriodAdaptor';
import { IntentModifyModeAppAdaptor } from './IntentModifyModeAppAdaptor';
import { IntentSwitchAdaptor } from './IntentSwitchAdaptor';
import { IntentModifyModeCallAdaptor } from './IntentModifyModeCallAdaptor';
import { IntentConstant } from '../constant/IntentConstant';

const TAG: string = 'IntentCreateModeAdaptor: '
const MAX_MODE_NUMBER: number = 15;

/**
 * 意图框架创建模式转接类
 */
export class IntentCreateModeAdaptor {
  /**
   * 根据模式名称创建模式
   *
   * @param modeName 模式名称
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async createMode(modeName: string, intentParam: Record<string, Object>): Promise<insightIntent.ExecuteResult> {
    // 判断模式名称是否已创建
    let modeNameList: string[] = await IntentQueryModeAdaptor.getAllCreatedModeName();
    LogUtil.showInfo(TAG, `modeNameList length ${modeNameList.length}`);
    if (modeNameList.length >= MAX_MODE_NUMBER) {
      LogUtil.showError(TAG, 'create mode is fail, the maximum number of mode has been reached.');
      return IntentUtil.errorResponse(IntentCodeConstants.CREATE_MODE_MAX_NUMBER_FAIL_CODE);
    }
    if (modeNameList.includes(modeName)) {
      LogUtil.showError(TAG, 'create mode is fail, modeName already exists.');
      return IntentUtil.errorResponse(IntentCodeConstants.CREATE_MODE_REPEAT);
    }
    let modeId: string = await IntentCreateModeAdaptor.createModeByModeName(modeName);
    if (CheckEmptyUtils.checkStrIsEmpty(modeId) || modeId === INVALID_MODE_ID) {
      LogUtil.showError(TAG, 'create mode is fail, modeId is invalid.');
      return IntentUtil.errorResponse(IntentCodeConstants.CREATE_MODE_FAIL_CODE);
    }
    // 添加来电策略 必选条件, 添加联系人信息 有条件必选
    let addCallResult: boolean = await IntentModifyModeCallAdaptor.addCallAllowPolicy(modeId, intentParam);
    if (!addCallResult) {
      LogUtil.showError(TAG, 'create mode is fail, addCallResult is error.');
      await SceneBaseDataManager.deleteSceneData(modeId);
      return IntentUtil.errorResponse(IntentCodeConstants.CREATE_MODE_FAIL_CODE);
    }
    // 添加应用到应用白名单中
    let addNotifyResult: boolean = await IntentModifyModeAppAdaptor.addNotifyAllowByApp(modeId, intentParam);
    if (!addNotifyResult) {
      LogUtil.showError(TAG, 'create mode is fail, addNotifyResult is error.');
      await SceneBaseDataManager.deleteSceneData(modeId);
      return IntentUtil.errorResponse(IntentCodeConstants.CREATE_MODE_FAIL_CODE);
    }
    // 添加时间
    IntentCreateModeAdaptor.addTimePeriod(modeId, intentParam);
    // 修改系统配置
    IntentCreateModeAdaptor.modifySwitch(modeId, intentParam);

    LogUtil.showInfo(TAG, `create mode modeId: ${modeId}`);
    HiSysEventUtil.reportIntentCreateModeBehaviorEvent(modeId, modeName);
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `add_${modeId}`);
    return IntentUtil.successResponse(IntentCodeConstants.CREATE_MODE_SUCCESS_CODE,
      ERROR_MSG[IntentCodeConstants.CREATE_MODE_SUCCESS_CODE]);
  }

  /**
   * 添加时间条件
   *
   * @param modeName 模式名称
   * @param intentParam 意图参数
   */
  static async addTimePeriod(modeId: string, intentParam: Record<string, Object>): Promise<void> {
    let timeInfo: TimeCondition | undefined = IntentModifyTimePeriodAdaptor.modifyPeriodParmValid(intentParam);
    LogUtil.showInfo(TAG, 'add time period.')
    if (timeInfo) {
      await TriggerConditionManager.addTriggerCondition(modeId, timeInfo);
    }
  }

  /**
   * 修改模式开关配置
   *
   * @param modeName 模式名称
   * @param intentParam 意图参数
   */
  static async modifySwitch(modeId: string, intentParam: Record<string, Object>): Promise<void> {
    let darkModePolicy: number = Number(intentParam.darkModePolicy);
    LogUtil.showInfo(TAG, `create mode darkModePolicy: ${darkModePolicy}`);
    if (IntentConstant.SYSTEM_MODE_VALUE.includes(darkModePolicy)) {
      IntentSwitchAdaptor.modifyAssociatedSwitch(modeId, ConfigType.SYSTEM_SETTINGS_DARK_MODE, darkModePolicy);
    }

    let eyeProtectionPolicy: number = Number(intentParam.eyeProtectionPolicy);
    LogUtil.showInfo(TAG, `modify associated switch eyeProtectionPolicy is ${eyeProtectionPolicy}`);
    if (IntentConstant.SYSTEM_MODE_VALUE.includes(eyeProtectionPolicy)) {
      IntentSwitchAdaptor.modifyAssociatedSwitch(modeId,
        ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE, eyeProtectionPolicy);
    }

    let smartOpenSwitch: number = Number(intentParam.smartOpenSwitch);
    LogUtil.showInfo(TAG, `modify switch smartOpenSwitch is ${smartOpenSwitch}`);
    if (IntentConstant.SWITCH_VALUE.includes(smartOpenSwitch)) {
      RefreshAdapter.getInstance().updateIntelligentState(modeId, smartOpenSwitch === 1);
    }

    let repeatRingCallSwitch: number = Number(intentParam.repeatRingCallSwitch);
    LogUtil.showInfo(TAG, `modify switch repeatRingCallSwitch is ${repeatRingCallSwitch}`);
    if (IntentConstant.SWITCH_VALUE.includes(repeatRingCallSwitch)) {
      NotDisturbAdapter.getInstance().updateRepeatRingState(modeId, repeatRingCallSwitch === 1);
    }

    let autoPickupSwitch: number = Number(intentParam.autoPickupSwitch);
    LogUtil.showInfo(TAG, `modify switch autoPickupSwitch is ${autoPickupSwitch}`);
    if (IntentConstant.SWITCH_VALUE.includes(autoPickupSwitch)) {
      NotDisturbAdapter.getInstance().updateAutoAnswerState(modeId, autoPickupSwitch === 1);
    }
  }

  /**
   * 获取创建模式的模式id
   *
   * @param modeName 模式名称
   * @returns modeId 已创建模式id
   */
  static async createModeByModeName(modeName: string): Promise<string> {
    let modeId: string = '';
    // 创建模式时，首先校验模式名称是否有效
    if (!SceneBaseDataManager.isModeNameValid(modeName)) {
      return modeId;
    }
    let templateModeArr: ModeConfigData[] = await PreloadManager.getInstance().getTemplateModes();
    // 校验模式名称是否是模板名称
    let templateModeId: string = await IntentCreateModeAdaptor.getModeIdFromTemplate(modeName, templateModeArr);
    let modeData: ModeData | undefined = IntentCreateModeAdaptor.getCustomModeData(modeName);
    if (!CheckEmptyUtils.checkStrIsEmpty(templateModeId)) {
      modeData = IntentCreateModeAdaptor.getTemplateModeData(modeName, templateModeId, templateModeArr);
    }
    if (modeData) {
      modeId = await SceneBaseDataManager.createCustomScene(modeData);
    }
    return modeId;
  }

  /**
   * 获取创建模式的模版中模式id
   *
   * @param modeName 模式名称
   * @param templateModeArr 模版模式数据
   * @returns modeId 模版中的模式id
   */
  static async getModeIdFromTemplate(modeName: string, templateModeArr: ModeConfigData[]): Promise<string> {
    let modeId: string = '';
    templateModeArr?.forEach((it: ModeConfigData) => {
      const code: string = ModeUtil.getStringResourceCode(it.modeName);
      let itemModeName: string = ResourceUtil.getStringByName(code);
      if (itemModeName === modeName) {
        modeId = it.modeId;
      }
    })
    return modeId;
  }

  /**
   * 自定义模式数据
   *
   * @param modeName 模式名称
   * @returns ModeData 自定义模式数据
   */
  static getCustomModeData(modeName: string): ModeData {
    let filletIcon: PixelMap | undefined = ResourceUtil.getPixelMap('agent_create_mode');
    let roundIcon: PixelMap | undefined = ResourceUtil.getPixelMap('agent_create_mode_round');
    // 语音创建默认使用'person_fill'图标,颜色默认使用第一个'#542BD7'
    const customModeData: ModeData = {
      modeId: INVALID_MODE_ID,
      modeName: modeName,
      iconId: IntentConstant.CREATE_CUSTOM_MODE_ICON,
      // 获取一个默认的图标颜色
      iconColor: COLOR_ARR[0],
      filletIcon: filletIcon,
      roundIcon: roundIcon,
      isSupportDelete: true,
    }
    return customModeData;
  }

  /**
   * 获取模版模式数据
   *
   * @param modeName 模版模式名称
   * @param modeId 模版模式Id
   * @param templateModeArr 模版数据
   * @returns ModeData 模版数据
   */
  static getTemplateModeData(modeName: string, modeId: string, templateModeArr: ModeConfigData[]):
    ModeData | undefined {
    let templateMode: ModeConfigData | undefined = templateModeArr?.find(item => item.modeId === modeId);
    if (!templateMode) {
      LogUtil.showError(TAG, 'get template mode data fail, templateMode is invalid.')
      return undefined;
    }
    let resultTemplateMode: ModeData = IntentCreateModeAdaptor.getCustomModeData(modeName);
    resultTemplateMode.modeId = modeId;
    resultTemplateMode.iconId = templateMode.iconId;
    resultTemplateMode.modeName = templateMode.modeName;
    resultTemplateMode.iconColor = templateMode.iconColor;
    let itemFilletIcon: image.PixelMap | undefined = ResourceUtil.getPixelMap(templateMode.filletIcon);
    let itemRoundIcon: image.PixelMap | undefined = ResourceUtil.getPixelMap(templateMode.roundIcon);
    if (itemFilletIcon) {
      resultTemplateMode.filletIcon = itemFilletIcon;
    }
    if (itemRoundIcon) {
      resultTemplateMode.roundIcon = itemRoundIcon;
    }
    resultTemplateMode.isSupportDelete = templateMode.isSupportDelete;
    return resultTemplateMode;
  }
}