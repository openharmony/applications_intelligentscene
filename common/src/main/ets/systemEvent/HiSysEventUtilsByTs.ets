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

import lazy hiSysEvent from '@ohos.hiSysEvent';
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { BusinessError } from '@ohos.base';
import taskpool from '@ohos.taskpool';
import { LogUtil } from '../utils/LogUtil';
import { JsonUtil } from '../utils/JsonUtil';
import { ActionType } from './EventRsultConstsByTs';
import { HiSysIntelligentSceneEvent } from './BehaviorEventConstsByTs';
import { DeviceUtil } from '../utils/DeviceUtil';
import { EffectiveSourceType } from '../model/FactorModel';
import { ScheduleFunctionParams, ScheduleParams } from './ScheduleSysReportUtils';

/* instrument ignore file */
/**
 * 应用打点工具�?
 *
 * @since 2022-11-8
 */

export interface ModeParams {
  PACKAGE_NAME?: string;
  PROCESS_NAME?: string;
  MODE_NAME?: string;
  STATUS?:string;
  SOURCES?: number;
  TIMERS?: string;
  CALL_POLICY?: string;
  RING_STATUS?: string;
  PKGSUM?: number;
  PKGNAME?: string;
  SMART_ENABLE?: string;
  APP_ENABLED?: number;
  APPROACH_LOCATION?: string;
  HELP_CALL?: string;
  DARK_MODE?: string;
  EYE_PROTECT?: string;
  STUDY_PLAN?: number;
  REPETITION_RULES?: string;
  TIME?: string;
  IS_LOCKED?: string;
  CURRENT_CUSTOM_MODE?: string;
  EXISTS_CUSTOM_MODE_DETAIL?: string;
  EXISTS_CUSTOM_MODE_SIZE?: string;
  ACTION_TYPE?: string;
  ANS_PKGSUM?: string;
  FOCUS_PROFILE_ID?: string;
  FOCUS_MODE_ENABLE?: string;
  SMART_ROAD_CONDITIONS?: string;
  AUTO_HANDS_FREE_CALL?: string;
  HIGH_VOLUME?: string;
  CLEAR_BROADCASTING?: string;
  SMART_HIGH_LIGHTING?: string;
  SCREEN_OFF_TIMEOUT?: string;
  IMPORTANT_MESSAGE?: string;
  HOLIDAY_TIMES?: string;
  WORKING_DAY_TIMES?: string;
}

interface UeReportParams {
  PNAMEID: string;
  PVERSIONID: string;
  VALUE?: string | string[];
}

interface FaultParams {
  PACKAGE_NAME: string;
  PROCESS_NAME: string;
  NAME?: string;
  DETAIL?: string;
  CODE?: string;
  MESSAGE?: string;
  EXTEND1?: string;
  EXTEND2?: string;
  EXTEND3?: string;
  EXTEND4?: string;
}

interface RecommendModeParams {
  PNAMEID: string;
  PVERSIONID: string;
  ACTION_TYPE: string;
  RECOMMEND_ACTION: string;
  SOURCE: string;
  VALUE: string;
  BUSINESS_ID?: string;
  NOTIFY_TYPE?: string;
}

interface IntentParams {
  // 包名�?
  PNAMEID: string;
  // 应用版本
  PVERSIONID: string;
  // 操作类型�?开关类操作 2.编辑触发条件 3.查询类操�?4关联系统功能 5创建模式 6来电策略修改�?
  ACTION_TYPE: string;
  // 操作来源
  SOURCE: string;
  // 模式id
  MODEID?: string;
  // 开关类型（1智能体验 2重复来电 3自动接听 5模式开启关闭）
  SWITCH_TYPE?: string;
  // 开关状态（off 关闭 on开启）
  STATUS?: string;
  // 操作�?新增 2修改 3删除�?
  OPERATION_TYPE?: string;
  // 数据类型�?时间围栏�?3深色模式 14护眼模式�?
  CONFIG_TYPE?: string;
  // 深色模式/护眼模式关联功能�?：不关联�?：开启，3：关闭）
  CONTACTS?: string;
  // 来电策略
  CALL_POLICY?: string;
  // 操作�?
  VALUE?: string;
  // 额外参数
  EXTRA?: string;
}

interface RulesActionParams {
  PNAMEID: string;
  PVERSIONID: string;
  ACTION_TYPE: string;
  SOURCE: string;
  REQUESTID?: string,
  ACTION_RESULT?: string;
  VALUE?: string;
}

interface AddFormParams {
  PNAMEID: string;
  PVERSIONID: string;
  ROTATIONMODE: number;
  MODULENAME: string;
  FORMID: string;
  PACKAGENAME: string;
  ADDTYPE: number;
  CELLSIZE: string;
  DEVICETYPE: number;
  DPSIZE: string;
  FORMNAME: string;
}

/**
 * 执行结果
 */
export class ActionResult {
  static readonly SUCCESS: string = '1';
  static readonly FAIL: string = '0';
}

export class RecommendActionType {
  static readonly RECOMMEND_OPEN: string = '1';
  static readonly RECOMMEND_CLOSE: string = '2';
}

export class AgentSwitchType {
  // 模式开启关�?
  static readonly MODE_STATE_CHANGE: string = '5';
}

export class AgentActionType {
  // 语音开关类操作
  static readonly SWITCH: string = '1';
  // 语音编辑触发条件
  static readonly EDIT_CONDITION: string = '2';
  // 查询模式
  static readonly QUERY_MODE: string = '3';
  // 语音关联系统功能
  static readonly ASSOCIATED_SYSTEM_FUNCTIONS: string = '4';
  // 创建模式
  static readonly CREATE_MODE: string = '5';
  // 语音来电策略
  static readonly CALL_POLICY: string = '6';
  // 修改允许打扰应用
  static readonly MODIFY_NOTIFICATION_APP: string = '7';
}

export class AgentOperationType {
  // 语音添加操作
  static readonly ADD: string = '1';
  // 语音修改操作
  static readonly MODIFY: string = '2';
  // 语音删除操作
  static readonly DELETE: string = '3';
}

export class AgentConfigType {
  // 时间条件
  static readonly TIME_CONDITION: string = '3';
  // 应用条件
  static readonly APP_CONDITION: string = '5';
  // 深色模式
  static readonly SYSTEM_DARK_MODE: string = '13';
  // 护眼模式
  static readonly SYSTEM_EYE_PROTECT_MODE: string = '14';
}

export class RecommendAction {
  static readonly NOT_OPEN: string = '1';
  static readonly OPEN: string = '2';
  static readonly KEEP_OPEN: string = '3';
  static readonly CLOSED: string = '4';
  static readonly PUBLISH_NOTIFICATION: string = '5';
  static readonly DO_NOT_REMIND: string = '6';
  static readonly INTERCEPT_NOTIFICATION: string = '7';
}

/**
 * 通知类型
 */
export enum NotifyType {
  PRE_RESEARCH = '1',
  UG = '2',
}

/**
 * 规则处理操作类型
 */
export class ProcessRulesAction {
  static readonly UPDATE: string = '1';
  static readonly CREATE: string = '2';
  static readonly DELETE: string = '3';
  static readonly RESULT: string = '4';
}

/**
 * 规则处理来源
 */
export class ProcessRulesSource {
  static readonly OTA: string = '1';
  static readonly CLONE: string = '2';
  static readonly CLOUD_SYNC: string = '3';
  static readonly USER_OPERATION: string = '4';
}

/**
 * 设备类型
 */
export class DeviceType {
  static readonly PHONE : number = 0;
  static readonly PAD : number = 1;
  static readonly FOLDABLE : number = 2;
}

export enum ScheduleActionType {
  ADD = '0',
  UPDATE = '1',
  DELETE = '2',
  DISABLE  = '3',
  ENABLE = '4'
}

const OPEN: string = 'OPEN';
const KEEP_OPEN: string = 'KEEP_OPEN';
const CLOSE_MODE: string = 'CLOSE_MODE';
const TIME_STATE: string = '1';
const LOCATION_STATE: string = '2';
const APP_STATE: string = '3';
const SLEEP_FORM_CELLSIZE: string = '2*2';
const SLEEP_FORM_DPSIZE: string = '140*140';
const PORTRAIT: number = 0;
const LANDSCAPE : number = 1;
const ADD_TYPE_DEFAULT : number = 2;
let abilityDelegatorArguments: AbilityDelegatorRegistry.AbilityDelegatorArgs;

async function getApplicationVersionConcurrent(): Promise<string> {
  'use concurrent';
  const bundleManager = await import('@ohos.bundle.bundleManager');
  let bundleInfo =
    await bundleManager.default.getBundleInfoForSelf(bundleManager.default.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
  LogUtil.showInfo('HiSysEventUtil', `getApplicationVersion ${bundleInfo?.versionName}`);

  return bundleInfo?.versionName;
}

function writeHiSysEvent(info: hiSysEvent.SysEventInfo): void {
  'use concurrent';
  hiSysEvent.write(info).then(() => {
    LogUtil.showInfo('HiSysEventUtil', `HiSysEventUtil write ${info.name} success.`);
  }).catch((err: BusinessError) => {
    LogUtil.showError('HiSysEventUtil', `write ${info.name}  error. code: ${err?.code} ,message: ${err?.message}`);
  });
}

export class HiSysEventUtil {
  private static tag: string = 'HiSysEventUtil: ';
  private static applicationVersion: string;
  private static readonly SCENARIO_DOMAIN: string = 'SCENARIO_MODE';
  private static readonly SCENARIO_MODE_UE: string = 'SCENARIO_MODE_UE';
  private static readonly FORM_UE: string = 'FORM_UE';
  private static PACKAGE_NAME: string = 'com.ohos.intelligentscene';
  private static PROCESS_NAME: string = 'Intelligent_scene';
  private static readonly SCHEDULE_EVENT_NAME: string = 'SCHEDULE_POLICY_CHANGE';

  private static async reportEvent(eventType: hiSysEvent.EventType, eventName: string,
    msg: Object, name: string, domain?: string): Promise<void> {
    LogUtil.showInfo(HiSysEventUtil.tag, `event_name: ${eventName} ; name: ${name} ;`);
    let info: hiSysEvent.SysEventInfo = {
      domain: domain ?? HiSysEventUtil.SCENARIO_DOMAIN,
      name: eventName,
      eventType: eventType,
      params: msg
    };
    try {
      let writeTask: taskpool.Task = new taskpool.Task(writeHiSysEvent, info);
      taskpool.execute(writeTask, taskpool.Priority.MEDIUM);
    } catch (error) {
      LogUtil.showError(HiSysEventUtil.tag, `catch exception when writeHiSysEvent, errmsg: ${error?.message}`);
    }
    return;
  }

  static async reportModeChangeOrCloseBehaviorEvent(eventName: string, params: ModeParams): Promise<void> {
    let param: ModeParams = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      MODE_NAME: params.MODE_NAME,
      STATUS: params.STATUS,
      SOURCES: params.SOURCES,
      TIMERS: params.TIMERS,
      CALL_POLICY: params.CALL_POLICY,
      RING_STATUS: params.RING_STATUS,
      PKGSUM: params.PKGSUM,
      PKGNAME: params.PKGNAME,
      SMART_ENABLE: params.SMART_ENABLE,
      APP_ENABLED: params.APP_ENABLED,
      APPROACH_LOCATION: params.APPROACH_LOCATION,
      HELP_CALL: params.HELP_CALL,
      DARK_MODE: params.DARK_MODE,
      EYE_PROTECT: params.EYE_PROTECT,
      STUDY_PLAN: params.STUDY_PLAN,
      REPETITION_RULES: params.REPETITION_RULES,
      TIME: params.TIME,
      IS_LOCKED: params.IS_LOCKED,
      CURRENT_CUSTOM_MODE: params.CURRENT_CUSTOM_MODE,
      EXISTS_CUSTOM_MODE_DETAIL: params.EXISTS_CUSTOM_MODE_DETAIL,
      EXISTS_CUSTOM_MODE_SIZE: params.EXISTS_CUSTOM_MODE_SIZE,
      FOCUS_PROFILE_ID: params.FOCUS_PROFILE_ID,
      FOCUS_MODE_ENABLE: params.FOCUS_MODE_ENABLE,
      ACTION_TYPE: params.ACTION_TYPE,
      ANS_PKGSUM: params.ANS_PKGSUM,
      SMART_ROAD_CONDITIONS: params.SMART_ROAD_CONDITIONS,
      AUTO_HANDS_FREE_CALL: params.AUTO_HANDS_FREE_CALL,
      HIGH_VOLUME: params.HIGH_VOLUME,
      CLEAR_BROADCASTING: params.CLEAR_BROADCASTING,
      SMART_HIGH_LIGHTING: params.SMART_HIGH_LIGHTING,
      SCREEN_OFF_TIMEOUT: params.SCREEN_OFF_TIMEOUT,
      IMPORTANT_MESSAGE: params.IMPORTANT_MESSAGE,
      HOLIDAY_TIMES: params.HOLIDAY_TIMES,
      WORKING_DAY_TIMES: params.WORKING_DAY_TIMES,
    };
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, eventName, param, eventName,
      HiSysEventUtil.SCENARIO_MODE_UE);
    return;
  }

  static async reportDefaultBehaviorEvent(eventName: string, name: string, detail?: string, code?: string,
    message?: string, extend1?: string, extend2?: string, extend3?: string, extend4?: string): Promise<void> {
    let params: FaultParams = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      NAME: name,
      DETAIL: detail,
      CODE: code,
      MESSAGE: message,
      EXTEND1: extend1,
      EXTEND2: extend2,
      EXTEND3: extend3,
      EXTEND4: extend4,
    };
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.FAULT, eventName, params, name);
    return;
  }

  static async reportDefaultBehaviorEventByUE(evenName: string, value?: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: UeReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      VALUE: value
    };
    await HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, param, evenName, HiSysEventUtil.SCENARIO_MODE_UE);
    return;
  }

  static async reportBehaviorEventByUE(evenName: string, param: Record<string, Object>): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      HiSysEventUtil.getApplicationVersion();
    }
    param.PNAMEID = HiSysEventUtil.getPkgName();
    param.PVERSIONID = HiSysEventUtil.applicationVersion;
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR,
      evenName, param, evenName, HiSysEventUtil.SCENARIO_MODE_UE);
    return;
  }

  public static async getApplicationVersion(): Promise<void> {
    let versionTask: taskpool.Task = new taskpool.Task(getApplicationVersionConcurrent);
    try {
      let versionName: string = await taskpool.execute(versionTask, taskpool.Priority.MEDIUM) as string;
      HiSysEventUtil.applicationVersion = versionName;
    } catch (error) {
      LogUtil.showError(HiSysEventUtil.tag, `getApplicationVersion error: ${error?.code}, msg: ${error?.message}`);
      HiSysEventUtil.applicationVersion = '';
    }
  }

  static async reportUEStatisticEvent(eventName: string, value: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let params: UeReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      VALUE: value,
    };
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.STATISTIC, eventName,
      params, eventName, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  static getPkgName(): string {
    return HiSysEventUtil.PACKAGE_NAME;
  }

  static getProcessName(): string {
    return HiSysEventUtil.PROCESS_NAME;
  }

  static async reportModeChangeBehaviorEvent(modeId: string, isOpen: boolean, source: number): Promise<void> {
    let param: ModeParams = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      MODE_NAME: modeId,
      STATUS: isOpen ? ActionType.SWITCH_ON : ActionType.SWITCH_OFF,
      SOURCES: source,
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `reportModeChangeEvent mode: ${modeId},isStart: ${isOpen},source: ${source}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.CURRENT_MODE_DATA, param,
      HiSysIntelligentSceneEvent.CURRENT_MODE_DATA, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  static async reportRecommendModeBehaviorEvent(status: string, modeId: string, timeState: boolean,
    locationState: boolean, appState: boolean): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let actionType: string = RecommendActionType.RECOMMEND_OPEN;
    let sourceArray: string[] = [];
    if (status === KEEP_OPEN || status === CLOSE_MODE) {
      actionType = RecommendActionType.RECOMMEND_CLOSE;
      if (timeState === false) {
        sourceArray.push(TIME_STATE);
      }
      if (locationState === false) {
        sourceArray.push(LOCATION_STATE);
      }
      if (appState === false) {
        sourceArray.push(APP_STATE);
      }
    } else {
      if (timeState) {
        sourceArray.push(TIME_STATE);
      }
      if (locationState) {
        sourceArray.push(LOCATION_STATE);
      }
      if (appState) {
        sourceArray.push(APP_STATE);
      }
    }
    let recommendAction: string = '';
    if (status === OPEN) {
      recommendAction = RecommendAction.OPEN;
    } else if (status === KEEP_OPEN) {
      recommendAction = RecommendAction.KEEP_OPEN;
    } else if (status === CLOSE_MODE) {
      recommendAction = RecommendAction.CLOSED;
    } else {
      recommendAction = RecommendAction.NOT_OPEN;
    }
    const source: string = sourceArray.join(',');
    let param: RecommendModeParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: actionType,
      RECOMMEND_ACTION: recommendAction,
      SOURCE: source,
      VALUE: modeId,
      NOTIFY_TYPE: NotifyType.PRE_RESEARCH,
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `reportRecommendMode ${modeId}, ${actionType}, ${recommendAction}, ${source}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.RECOMMEND_NOTIFICATION, param,
      HiSysIntelligentSceneEvent.RECOMMEND_NOTIFICATION, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  static async reportRecommendOpenNotifyBehaviorEvent(isOpen: boolean, modeId: string,
    businessId?: string, isUgType?: boolean): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let actionType: string = isOpen ? RecommendActionType.RECOMMEND_OPEN : RecommendActionType.RECOMMEND_CLOSE;
    let recommendAction: string = RecommendAction.PUBLISH_NOTIFICATION;
    let param: RecommendModeParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: actionType,
      RECOMMEND_ACTION: recommendAction,
      SOURCE: '',
      VALUE: modeId,
      BUSINESS_ID: businessId ?? '',
      NOTIFY_TYPE: isUgType ? NotifyType.UG : NotifyType.PRE_RESEARCH,
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report recommend notification ${modeId}, ${recommendAction}, ${actionType}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.RECOMMEND_NOTIFICATION, param,
      HiSysIntelligentSceneEvent.RECOMMEND_NOTIFICATION, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  static async reportProcessUGNotifyBehaviorEvent(isOpen: boolean, recommendAction: string,
    modeId: string, businessId: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let actionType: string = isOpen ? RecommendActionType.RECOMMEND_OPEN : RecommendActionType.RECOMMEND_CLOSE;
    let param: RecommendModeParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: actionType,
      RECOMMEND_ACTION: recommendAction,
      SOURCE: '',
      VALUE: modeId,
      BUSINESS_ID: businessId,
      NOTIFY_TYPE: NotifyType.UG,
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report recommend notification ${modeId}, ${recommendAction}, ${actionType}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.RECOMMEND_NOTIFICATION, param,
      HiSysIntelligentSceneEvent.RECOMMEND_NOTIFICATION, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  /**
   * 语音助手修改开关状态打点方�?
   *
   * @param isOpen 是否开启开�?
   * @param switchType 开关类�?
   * @param modeId 模式id
   * @param extra 携带参数
   */
  static async reportIntentModifySwitchBehaviorEvent(isOpen: boolean, switchType: string, modeId?: string,
    extras?: object): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: IntentParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: AgentActionType.SWITCH,
      SOURCE: `${EffectiveSourceType.INTENT}`,
      SWITCH_TYPE: switchType,
      STATUS: isOpen ? ActionType.SWITCH_ON : ActionType.SWITCH_OFF,
      MODEID: modeId ?? '',
      EXTRA: extras ? JsonUtil.stringify(extras) : '',
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report intent modify switch event modeId: ${modeId}, switchType: ${switchType}, isOpen: ${isOpen}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.INTENT, param,
      HiSysIntelligentSceneEvent.INTENT, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  /**
   * 语音助手修改模式关联项目打点
   *
   * @param switchState 深色、护眼模式关联功�?
   * @param configType 关联模式类型
   * @param modeId 模式id
   */
  static async reportIntentModifyAssociatedSystemFunBehaviorEvent(switchState: number, configType: number,
    modeId: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: IntentParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      SOURCE: `${EffectiveSourceType.INTENT}`,
      ACTION_TYPE: AgentActionType.ASSOCIATED_SYSTEM_FUNCTIONS,
      OPERATION_TYPE: AgentOperationType.MODIFY,
      CONFIG_TYPE: `${configType}`,
      MODEID: modeId,
      CONTACTS: `${switchState}`
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report intent associated fun event modeId: ${modeId}, switchState: ${switchState}, configType: ${configType}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.INTENT, param,
      HiSysIntelligentSceneEvent.INTENT, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  /**
   * 语音助手修改来电策略打点
   *
   * @param callPolicy 来电策略
   * @param modeId 模式id
   */
  static async reportIntentModifyCallPolicyBehaviorEvent(callPolicy: string, modeId: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: IntentParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: AgentActionType.CALL_POLICY,
      SOURCE: `${EffectiveSourceType.INTENT}`,
      OPERATION_TYPE: AgentOperationType.MODIFY,
      MODEID: modeId,
      CALL_POLICY: callPolicy,
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report intent call policy event modeId: ${modeId}, callPolicy: ${callPolicy}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.INTENT, param,
      HiSysIntelligentSceneEvent.INTENT, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  /**
   * 语音助手编辑触发条件打点
   *
   * @param operationType 操作类型
   * @param configType 数据类型
   * @param modeId 模式id
   * @param extras 携带参数
   */
  static async reportIntentEditConditionBehaviorEvent(operationType: string, configType: string, modeId: string,
    extras: object): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: IntentParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: AgentActionType.EDIT_CONDITION,
      SOURCE: `${EffectiveSourceType.INTENT}`,
      OPERATION_TYPE: operationType,
      CONFIG_TYPE: configType,
      MODEID: modeId,
      EXTRA: extras ? JsonUtil.stringify(extras) : '',
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report intent edit condition event modeId: ${modeId}, configType: ${configType}, operationType: ${operationType}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.INTENT, param,
      HiSysIntelligentSceneEvent.INTENT, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  /**
   * 语音助手创建模式打点
   *
   * @param modeId 模式id
   * @param modeName 模式名称
   */
  static async reportIntentCreateModeBehaviorEvent(modeId: string, modeName: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: IntentParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: AgentActionType.CREATE_MODE,
      SOURCE: `${EffectiveSourceType.INTENT}`,
      MODEID: modeId,
      EXTRA: '',
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report intent create mode event modeId: ${modeId}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.INTENT, param,
      HiSysIntelligentSceneEvent.INTENT, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  /**
   * 语音助手修改允许通知应用行为打点
   *
   * @param modeId 模式id
   */
  static async reportIntentModifyNotificationAppBehaviorEvent(modeId: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: IntentParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: AgentActionType.MODIFY_NOTIFICATION_APP,
      SOURCE: `${EffectiveSourceType.INTENT}`,
      MODEID: modeId,
    };
    LogUtil.showInfo(HiSysEventUtil.tag, `report intent modify notification event modeId: ${modeId}`);
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.INTENT, param,
      HiSysIntelligentSceneEvent.INTENT, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  static async reportRulesProcess(source: string, actionType: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: RulesActionParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: actionType,
      SOURCE: source,
    };
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.PROCESS_RULES_ACTION, param,
      HiSysIntelligentSceneEvent.PROCESS_RULES_ACTION, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  static async reportRequestProcess(requestId: string, source: string, actionType: string,
    actionResult?: string, value?: string): Promise<void> {
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: RulesActionParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: actionType,
      SOURCE: source,
      REQUESTID: requestId,
    };
    param.ACTION_RESULT = actionResult ?? '';
    param.VALUE = value ?? '';
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.PROCESS_RULES_ACTION, param,
      HiSysIntelligentSceneEvent.PROCESS_RULES_ACTION, HiSysEventUtil.SCENARIO_MODE_UE);
  }

  /**
   * 情景模式添加卡片打点
   */
  static async reportFormAddEvent(formId: string, formName: string): Promise<void> {
    LogUtil.showInfo('HiSysEventUtil', 'reportFormAddEvent');
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments();
    let moduleName: string = abilityDelegatorArguments?.parameters['-m'];
    let isDevicePortrait: boolean = DeviceUtil.isDevicePortrait();
    let deviceType: number = DeviceType.PHONE;
    if (DeviceUtil.isDevicePad()) {
      deviceType = DeviceType.PAD;
    } else if (DeviceUtil.isFoldable()) {
      deviceType = DeviceType.FOLDABLE;
    }
    let param: AddFormParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ROTATIONMODE: isDevicePortrait ? PORTRAIT : LANDSCAPE,
      MODULENAME: moduleName,
      FORMID: formId,
      PACKAGENAME: HiSysEventUtil.PACKAGE_NAME,
      ADDTYPE: ADD_TYPE_DEFAULT,
      CELLSIZE: SLEEP_FORM_CELLSIZE,
      DEVICETYPE: deviceType,
      DPSIZE: SLEEP_FORM_DPSIZE,
      FORMNAME: formName
    };
    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysIntelligentSceneEvent.ADD_CARD_TO_DESKTOP_BY_CLICK_UE, param,
      HiSysIntelligentSceneEvent.ADD_CARD_TO_DESKTOP_BY_CLICK_UE, HiSysEventUtil.FORM_UE);
    LogUtil.showInfo('HiSysEventUtil', 'reportFormAddEvent success');
  }

  static async reportScheduleEvent(params: ScheduleFunctionParams): Promise<void> {
    LogUtil.showInfo('HiSysEventUtil', 'reportScheduleEvent');
    if (params === null || params === undefined) {
      LogUtil.showError('HiSysEventUtil', 'Invalid params');
      return;
    }
    let eventName: string = "";

    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }

    let dottingParams: ScheduleParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      ACTION_TYPE: params.actionType
    };

    switch (params.actionType) {
      case ScheduleActionType.ADD:
        eventName = HiSysIntelligentSceneEvent.ADD_SCHEDULE;
        break;

      case ScheduleActionType.DELETE:
        eventName = HiSysIntelligentSceneEvent.DELETE_SCHEDULE;
        break;

      case ScheduleActionType.UPDATE:
        eventName = HiSysIntelligentSceneEvent.UPDATE_SCHEDULE;
        break;

      case ScheduleActionType.ENABLE:
        dottingParams.NUM_CURRENT = params.numberCurrent;
        eventName = HiSysIntelligentSceneEvent.ENABLE_SCHEDULE;
        break;

      case ScheduleActionType.DISABLE:
        dottingParams.NUM_CURRENT = params.numberCurrent;
        eventName = HiSysIntelligentSceneEvent.DISABLE_SCHEDULE;
        break;
    }

    HiSysEventUtil.reportEvent(hiSysEvent.EventType.BEHAVIOR, HiSysEventUtil.SCHEDULE_EVENT_NAME, dottingParams,
      eventName, HiSysEventUtil.SCENARIO_MODE_UE);
  }
}
