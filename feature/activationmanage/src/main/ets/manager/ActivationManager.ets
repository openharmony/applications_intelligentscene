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

import { common } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';
import bundleManager from '@ohos.bundle.bundleManager';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { TimeUtil } from '@ohos/scene.common/src/main/ets/utils/TimeUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigConstant } from '@ohos/scene.common/src/main/ets/constant/ConfigConstant';
import { RuleFeedBack } from '@ohos/scene.datamanage/src/main/ets/model/base/RuleFeedback';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { El1ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ConfigDataManager';
import {
  AppCondition,
  BaseCondition,
  LoopType,
  TimeCondition
} from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import {
  DATASHARE_PROXY_CALENDAR_ADDRESS
} from '@ohos/scene.datamanage/src/main/ets/constant/DatabaseConfigConstant';
import { RuleFeedbackManager } from '@ohos/scene.datamanage/src/main/ets/manager/RuleFeedbackManager';
import { CommCallbackStub } from '../CommCallbackStub';
import {
  AppParam,
  DbParam,
  ExtremeBatterySaverModeParam,
  InputParams,
  LocationParam,
  OutDoorTravelModeParam,
  Rule,
  RulePostBody,
  RuleSet,
  RuleState,
  TimeParam
} from '../model/RulePostBody';
import { ScenarioCommBinderProxy } from '../ScenarioCommBinderProxy';
import { RuleReportUtil } from '../util/RuleReportUtil';

const TAG: string = 'ActivationManager';
const INTELLIGENT_SCENE_BUNDLE_NAME: string = 'com.ohos.intelligentscene';
const INTELLIGENT_SCENE_RULE_SET_ID: string = 'intelligentscene_rule_set';
const INTELLIGENT_SCENE_DATACHANGE_RULE_SET_ID: string = 'intelligentscene_rule_set_data_change';
const INTELLIGENT_SCENE_RULE_SET_NAME: string = 'intelligentscene';
const INTELLIGENT_SCENE_TARGET_RESOURCE_ID: string = 'actions.openharmony.sceneMode.sortAndNotifySceneMode';
const ENGINE_APP_ID: string =
  'com.openharmony.ohos.ecaengine_BDj7zbjhMpeBY6wnpfr8VrXFG1nbMK3hLXPVLiUaw4M1POF1EThsu7EXmjdsKbYhYJME4JeHkP+iWNY/+KeZaTz50hmWm1CREy3db9zl9KCW/oTSTGot8C5qIDkkSEgeiQ==';
const RECOMMENDATION_RULE_SET_NAME: string = 'intelligentscene';
const RECOMMENDATION_TARGET_RESOURCE_ID: string = 'actions.openharmony.sceneMode.SceneModeRecommendAction';
const STATE_TYPE: string = 'H_CONDITION';
const RULE_TYPE: string = 'H_RULE';
const TARGET_TYPE: string = 'H_ACTION';
const DEFAULT_RULE_NAME: string = 'default-rule-when-no-match';
const UPDATE_RULE_CMD: string = 'updateRuleSet';
const FGC_ENGINE_SERVICE_NAME: string = 'RuleSet';
const FGC_STATE_RESOURCE_ID: string = 'conditions.openharmony.awareness.awarenessProcessing';
const AI_LIFE_BUNDLE_NAME: string = 'com.openharmony.ohos.ailifesvc';
const ECA_BUNDLE_NAME: string = 'com.openharmony.ohos.ecaengine';
const SCENARIO_ABILITY_NAME: string = 'ScenarioCommonService';
const DB_CHANGE_PROCEDURE_ID: string = 'AwarenessProcessing.Device.JudgeDataShareChange';
const CONDITION_TYPE_MAP: Map<ConfigType, string> = new Map([
  [ConfigType.TRIGGER_CONDITION_TIME, 'AwarenessProcessing.Environment.JudgeTimeFence'],
  [ConfigType.TEMPORARY_TIME_CONDITION, 'AwarenessProcessing.Environment.JudgeTimeFence'],
  [ConfigType.TRIGGER_CONDITION_APP, 'AwarenessProcessing.App.JudgeActiveAppInfo'],
]);
const EXPIRATION_TIME: string = `${30 * 24 * 60 * 60 * 1000}`;
const APP_DELAY_MS: number = 1000;
const RADIUS: string = '400';
const CONDITION_ON: number = 1;
const CONDITION_OFF: number = 0;
const INVALID_CONNECTION_ID: number = -1;
const DISCONNECT_DELAY: number = 5000;
const RECOMMEND_RULE_LENGTH: number = 4;
const CONTAINER_APP_TYPE: string = '1';

export const RECOMMENDATION_RULE_SET_ID: string = 'recommendation_rule_set';
export enum ScheduleTableNames {
  Schedule = 'Schedule',
  Course = 'Course'
}
export const DB_TABLE_NAMES: string[] = [
  ScheduleTableNames.Schedule,
  ScheduleTableNames.Course
];

export class ActivationManager {
  private proxy?: ScenarioCommBinderProxy;
  private stub?: ScenarioCallBack;
  private connectionId: number = INVALID_CONNECTION_ID;
  private static singleInstance: ActivationManager;

  public static getInstance(): ActivationManager {
    if (!ActivationManager.singleInstance) {
      ActivationManager.singleInstance = new ActivationManager();
    }
    return ActivationManager.singleInstance;
  }

  /**
   * 构建情景模式更新规则参数
   */
  private buildIntelligentSceneRulePostBody(data: ConfigData[], isAfterReboot?: boolean,
    hasSchedule?: boolean): RulePostBody {
    LogUtil.showInfo(TAG, 'start buildIntelligentSceneRulePostBody.');
    let states: RuleState[] = [];
    let rules: Rule[] = [];
    let rulesInfo: Record<string, string | number>[] = [];
    data.forEach((item) => {
      let itemCondition: BaseCondition = JsonUtil.fromJson(item.configValue) as BaseCondition;
      let state: RuleState = this.buildIntelligentSceneState(item, itemCondition);
      let rule: Rule = {
        name: `${ConfigConstant.RULE_NAME_PREFIX}${item.configId}-${item.updateTime}`,
        priority: Number(item.modeId),
        expression: `{$.${state.name}} == true`,
        result: item.modeId,
        type: RULE_TYPE,
        status: itemCondition.enable ? CONDITION_ON : CONDITION_OFF
      }
      rulesInfo.push({
        'ruleName': rule.name,
        'status': rule.status
      })
      states.push(state);
      rules.push(rule);
    });
    if (hasSchedule) {
      states.push(...this.buildDBChangeState());
      rules.push(...this.buildDBChangeRule());
    }
    LogUtil.showInfo(TAG, 'build rules finished.');
    let ruleSet: RuleSet = {
      id: INTELLIGENT_SCENE_RULE_SET_ID,
      name: INTELLIGENT_SCENE_RULE_SET_NAME,
      states: states,
      rules: rules,
      default: {
        name: DEFAULT_RULE_NAME,
        result: NO_SCENE
      },
      target: {
        type: TARGET_TYPE,
        resourceId: INTELLIGENT_SCENE_TARGET_RESOURCE_ID,
        parameters: {
          matchResult: '$result'
        }
      },
      isSupportEl1: true,
      isAfterReboot: isAfterReboot ?? false
    };
    let rulePostBody: RulePostBody = {
      cmd: UPDATE_RULE_CMD,
      serviceName: FGC_ENGINE_SERVICE_NAME,
      payload: {
        executeImediately: true,
        executeFrom: INTELLIGENT_SCENE_BUNDLE_NAME,
        ruleSet: ruleSet
      }
    };
    return rulePostBody;
  }

  private buildIntelligentSceneState(item: ConfigData, itemCondition: BaseCondition) {
    let inputParams: InputParams = {};
    switch (item.configType) {
      case ConfigType.TRIGGER_CONDITION_TIME:
      case ConfigType.TEMPORARY_TIME_CONDITION:
        inputParams = this.parseTimeParam(item.configValue);
        break;
      case ConfigType.TRIGGER_CONDITION_APP:
        inputParams = this.parseAppParam(item.configValue);
        break;
      default:
        break;
    }
    let state: RuleState = {
      name: `${ConfigConstant.STATE_NAME_PREFIX}${item.configId}`,
      resourceId: FGC_STATE_RESOURCE_ID,
      parameters: {
        awarenessProcedureId: CONDITION_TYPE_MAP.get(item.configType) ?? '',
        inputParams: inputParams
      },
      type: STATE_TYPE,
      status: itemCondition.enable ? CONDITION_ON : CONDITION_OFF
    };
    return state;
  }

  private buildDBChangeState(): RuleState[] {
    let states: RuleState[] = [];
    for (let i = 0; i < DB_TABLE_NAMES.length; i++) {
      states.push({
        name: `on_set_uri_db_change_${DB_TABLE_NAMES[i]}`,
        resourceId: FGC_STATE_RESOURCE_ID,
        parameters: {
          awarenessProcedureId: DB_CHANGE_PROCEDURE_ID,
          inputParams: { Uri: `${DATASHARE_PROXY_CALENDAR_ADDRESS}${DB_TABLE_NAMES[i]}`} as DbParam,
        },
        type: STATE_TYPE,
        status: CONDITION_ON,
      });
    }
    return states;
  }

  private buildDBChangeRule(): Rule[] {
    let rules: Rule[] = [];
    for (let i = 0; i < DB_TABLE_NAMES.length; i++) {
      rules.push({
        name: `on_set_uri_db_change_${DB_TABLE_NAMES[i]}`,
        expression: `{$.on_set_uri_db_change_${DB_TABLE_NAMES[i]}} == true`,
        priority: i,
        result: `${ModeType.NO_MODE}`,
        type: RULE_TYPE,
        status: CONDITION_ON,
      });
    }
    return rules;
  }

  private buildDBChangeRulePostBody(): RulePostBody {
    let states: RuleState[] = this.buildDBChangeState();
    let rules: Rule[] = this.buildDBChangeRule();
    let ruleSet: RuleSet = {
      id: INTELLIGENT_SCENE_DATACHANGE_RULE_SET_ID,
      name: INTELLIGENT_SCENE_RULE_SET_NAME,
      states: states,
      rules: rules,
      default: {
        name: DEFAULT_RULE_NAME,
        result: NO_SCENE
      },
      target: {
        type: TARGET_TYPE,
        resourceId: INTELLIGENT_SCENE_TARGET_RESOURCE_ID,
        parameters: {
          matchResult: '$result'
        }
      },
      isSupportEl1: true,
      isAfterReboot: true
    };
    let rulePostBody: RulePostBody = {
      cmd: UPDATE_RULE_CMD,
      serviceName: FGC_ENGINE_SERVICE_NAME,
      payload: {
        executeImediately: true,
        executeFrom: INTELLIGENT_SCENE_BUNDLE_NAME,
        ruleSet: ruleSet
      }
    };
    return rulePostBody;
  }

  private parseAppParam(config: string): AppParam {
    let appInfo: AppCondition = JsonUtil.fromJson(config) as AppCondition;
    let bundleNames: string[] = [];
    let ancoBundleNames: string[] = [];
    for (let item of appInfo.appConditionList) {
      if (item.appType === CONTAINER_APP_TYPE) {
        ancoBundleNames.push(item.bundleName);
      } else {
        bundleNames.push(item.bundleName);
      }
    }
    let appParam: AppParam = {
      bundleNames: bundleNames,
      ancoBundleNames: ancoBundleNames,
      delayMs: APP_DELAY_MS
    }
    return appParam;
  }

  private parseTimeParam(config: string): TimeParam {
    let timeInfo: TimeCondition = JsonUtil.fromJson(config) as TimeCondition;
    let dateRange = '';
    if (timeInfo.loopType === LoopType.ONE_TIME) {
      dateRange = timeInfo.loopDays;
    } else if (timeInfo.loopType === LoopType.EVERY_WEEK) {
      dateRange = timeInfo.loopDays.replaceAll(',', '_');
    }
    let timeParam: TimeParam = {
      timeFenceType: timeInfo.loopType - 1,
      timeRange: timeInfo.timeStart + '-' + timeInfo.timeEnd,
      dateRange: dateRange
    }
    return timeParam;
  }

  /**
   * 构建智能推荐更新规则参数
   */
  private buildRecommendRulePostBody(cmd: string, ruleFeedback: RuleFeedBack): string {
    let states: RuleState[] = [];
    let rules: Rule[] = [];
    let expressionArray: string[] = [];

    let timeRuleState: RuleState | undefined = undefined;
    if (ruleFeedback.timeRange) {
      timeRuleState = this.createTimeRuleState(ruleFeedback);
      expressionArray.push(`{$.${timeRuleState.name}}`);
      states.push(timeRuleState);
    }

    let locationRuleState: RuleState | undefined = undefined;
    if (ruleFeedback.longitude && ruleFeedback.latitude) {
      locationRuleState = this.createLocationRuleState(ruleFeedback);
      expressionArray.push(`{$.${locationRuleState.name}}`);
      states.push(locationRuleState);
    }

    let applicationRuleState: RuleState | undefined = undefined;
    if (ruleFeedback.application) {
      applicationRuleState = this.createApplicationRuleState(ruleFeedback);
      expressionArray.push(`{$.${applicationRuleState.name}}`);
      states.push(applicationRuleState);
    }

    const expression: string = expressionArray.join(' && ');
    LogUtil.showInfo(TAG, `timeRuleState: ${timeRuleState?.name}, expression: ${expression}`);
    let rule: Rule = {
      name: ruleFeedback.ruleId,
      priority: Number(ruleFeedback.modeId),
      expression: expression,
      result: ruleFeedback.modeId,
      type: RULE_TYPE,
      status: CONDITION_ON
    };
    rules.push(rule);
    return this.generateRecommendRuleSet(cmd, ruleFeedback, states, rules);
  }

  private generateRecommendRuleSet(cmd: string, ruleFeedback: RuleFeedBack, states: RuleState[],
    rules: Rule[]): string {
    let ruleSet: RuleSet = {
      id: `${RECOMMENDATION_RULE_SET_ID}_${ruleFeedback.ruleId}`,
      name: RECOMMENDATION_RULE_SET_NAME,
      states: states,
      rules: rules,
      default: {
        name: 'default-rule-when-no-rule-match',
        result: ruleFeedback.modeId
      },
      target: {
        type: TARGET_TYPE,
        resourceId: 'actions.openharmony.sceneMode.SceneModeRecommendAction',
        parameters: {
          matchResult: '$result'
        }
      }
    };
    let rulePostBody: RulePostBody = {
      cmd: cmd,
      serviceName: FGC_ENGINE_SERVICE_NAME,
      payload: {
        executeImediately: false,
        executeFrom: INTELLIGENT_SCENE_BUNDLE_NAME,
        ruleSet: ruleSet
      },
    };
    return JsonUtil.stringify(rulePostBody);
  }

  private createLocationRuleState(ruleFeedback: RuleFeedBack): RuleState {
    let locationParams: LocationParam = {
      latitude: ruleFeedback.latitude,
      longitude: ruleFeedback.longitude,
      radius: RADIUS,
      expiration: EXPIRATION_TIME
    };

    let locationRuleState: RuleState = {
      name: `state_location_${ruleFeedback.ruleId}`,
      resourceId: FGC_STATE_RESOURCE_ID,
      parameters: {
        awarenessProcedureId: 'AwarenessProcessing.Environment.JudgeLocationFence',
        inputParams: locationParams,
      },
      type: STATE_TYPE,
      status: CONDITION_ON
    };
    return locationRuleState;
  }

  private createTimeRuleState(ruleFeedback: RuleFeedBack): RuleState {
    let timeParams: TimeParam = {
      timeFenceType: LoopType.EVERY_DAY - 1,
      timeRange: ruleFeedback.timeRange,
      dateRange: ''
    };
    const ruleIdArray: string[] = ruleFeedback.ruleId.split('_');
    if (ruleIdArray.length === RECOMMEND_RULE_LENGTH) {
      const nextDate: string = ruleIdArray[RECOMMEND_RULE_LENGTH - 1];
      const isDateInWeek: boolean = TimeUtil.isDateInWeek(nextDate);
      const weekDayRange: string = '1_2_3_4_5';
      const weekendDayRange: string = '7_6';
      timeParams.timeFenceType = LoopType.EVERY_WEEK - 1;
      timeParams.dateRange = isDateInWeek ? weekDayRange : weekendDayRange;
    }

    let timeRuleState: RuleState = {
      name: `state_time_${ruleFeedback.ruleId}`,
      resourceId: FGC_STATE_RESOURCE_ID,
      parameters: {
        awarenessProcedureId: 'AwarenessProcessing.Environment.JudgeTimeFence',
        inputParams: timeParams,
      },
      type: STATE_TYPE,
      status: CONDITION_ON
    };
    return timeRuleState;
  }

  private createApplicationRuleState(ruleFeedback: RuleFeedBack): RuleState {
    const appParams: AppParam = {
      bundleNames: ruleFeedback.application ? ruleFeedback.application.split(',') : [],
      delayMs: APP_DELAY_MS
    };

    const appRuleState: RuleState = {
      name: `state_app_${ruleFeedback.ruleId}`,
      resourceId: FGC_STATE_RESOURCE_ID,
      parameters: {
        awarenessProcedureId: CONDITION_TYPE_MAP.get(ConfigType.TRIGGER_CONDITION_APP) ?? '',
        inputParams: appParams,
      },
      type: STATE_TYPE,
      status: CONDITION_ON
    };
    return appRuleState;
  }

  /**
   * 判断方法为通过bms判断eca引擎新包名是否存在并合法；需要满足一下两点：
   * 1、获取com.openharmony.ohos.ecaengine包名存在且appId合法
   * 2、在hap模块eca_module下存在名称为metadata.support.ecaEngineStandby的metadata
   *
   * @returns 是否使用哆啦新包名
   */
  private isEcaEngineNew(): boolean {
    let bundleFlags: number = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE;
    try {
      let bundleInfo: bundleManager.BundleInfo = bundleManager.getBundleInfoSync(ECA_BUNDLE_NAME, bundleFlags);
      LogUtil.showInfo(TAG, 'isEcaEngineNew getBundle success');
      // 1.检测包名与appId是否正确
      let appId: string = bundleInfo.signatureInfo.appId;
      if (appId !== ENGINE_APP_ID) {
        LogUtil.showWarn(TAG, 'appId not correct');
        return false;
      }
      // 2.检测是否包含目标metadata
      let modules: bundleManager.HapModuleInfo[] = bundleInfo.hapModulesInfo;
      for (let module of modules) {
        if (module.name !== 'eca_module') {
          continue;
        }
        let metadatas: bundleManager.Metadata[] = module.metadata;
        if (!metadatas || metadatas.length === 0) {
          LogUtil.showWarn(TAG, 'metadata none');
          return false;
        }
        let candidates: bundleManager.Metadata[] = metadatas.filter(metadata => {
          return metadata.name === 'metadata.support.ecaEngineStandby';
        });
        if (candidates.length === 0) {
          LogUtil.showWarn(TAG, 'no candidate metadata');
          return false;
        } else {
          LogUtil.showInfo(TAG, 'find candidate metadata');
          return true;
        }
      }
      LogUtil.showWarn(TAG, 'no candidate module');
      return false;
    } catch (err) {
      LogUtil.showError(TAG, 'isEcaEngineNew getBundle failed :' + err?.message);
      return false;
    }
  }

  /**
   * 调用哆啦接口
   * @param paramData，已构建好的接口参数
   */
  private postRuleData(paramData: string): void {
    LogUtil.showInfo(TAG, 'start postRuleData.');
    if (!this.stub) {
      this.stub = new ScenarioCallBack(this.connectionId);
    }
    if (this.proxy && this.connectionId !== INVALID_CONNECTION_ID) {
      this.proxy.onScenarioCmd(paramData, this.stub);
    } else {
      this.connect(() => {
        LogUtil.showInfo(TAG, `postRuleData in new connection, connection id is: ${this.connectionId}`);
        this.proxy?.onScenarioCmd(paramData, this.stub);
      });
    }
  }

  public connect(callback?: () => void): void {
    const context: common.UIAbilityContext = AbilityContextManager.getContext() as common.UIAbilityContext;
    let fgcWant: Want = {
      'bundleName': this.isEcaEngineNew() ? ECA_BUNDLE_NAME : AI_LIFE_BUNDLE_NAME,
      'abilityName': SCENARIO_ABILITY_NAME
    }
    try {
      this.connectionId = context.connectServiceExtensionAbility(fgcWant, {
        onConnect: (elementName: bundleManager.ElementName, remote: rpc.IRemoteObject): void => {
          LogUtil.showInfo(TAG, `onConnect ${elementName.bundleName}`);
          if (remote) {
            this.proxy = new ScenarioCommBinderProxy(remote);
            if (callback) {
              callback();
            }
          }
        },
        onDisconnect: (elementName: bundleManager.ElementName): void => {
          LogUtil.showInfo(TAG, `onDisconnect ${elementName.bundleName}`);
        },
        onFailed: (code: number): void => {
          LogUtil.showError(TAG, `IDL Connect onFailed: ${code}`);
          HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_INTERNAL_ERROR,
            FaultScene.DOWN_APP_PULL_ERROR, FaultSubScene.DISPENSING_ERROR, String(code), 'postRuleData');
        }
      });
    } catch (e) {
      LogUtil.showError(TAG, `connectServiceExtensionAbility failed: ${e?.code}, ${e?.message}`);
    }
  }

  public disConnect(): void {
    const context: common.UIAbilityContext = AbilityContextManager.getContext() as common.UIAbilityContext;
    try {
      context?.disconnectServiceExtensionAbility(this.connectionId, () => {
        this.proxy = undefined;
        this.stub = undefined;
        this.connectionId = INVALID_CONNECTION_ID;
      });
    } catch (e) {
      LogUtil.showError(TAG, `disconnectServiceExtensionAbility failed: ${e?.code}, ${e?.message}`);
    }
  }
}

class ScenarioCallBack extends CommCallbackStub {
  private mConn: number;
  private timerId: number | undefined;

  constructor(conn: number) {
    super();
    this.mConn = conn;
  }

  onResult(code: number, response: string): void {
    LogUtil.showInfo(TAG, `clientOnResult: ${code}, ${response}`);
    this.debounce(() => {
      ActivationManager.getInstance().disConnect();
    }, DISCONNECT_DELAY);
  }

  private debounce(fn: () => void, delay: number): void {
    if (this.timerId !== undefined) {
      clearTimeout(this.timerId);
      this.timerId = undefined;
    }
    this.timerId = setTimeout(() => {
      fn();
    }, delay);
  }
}