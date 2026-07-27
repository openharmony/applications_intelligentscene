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

export interface RulePostBody {
  cmd: string,
  serviceName: string,
  payload: Payload
}

export interface Payload {
  executeImediately: boolean,
  executeFrom: string,
  ruleSet: RuleSet,
  requestId?: string,
}

export interface RuleSet {
  id: string,
  name: string,
  states: RuleState[],
  rules: Rule[]
  default: DefaultRule,
  target: Target,
  isSupportEl1?: boolean,
  isAfterReboot?: boolean
}

export interface DefaultRule {
  name: string,
  result: string,
}

export interface Target {
  type: string,
  resourceId: string,
  parameters: TargetParameters
}

export interface TargetParameters {
  matchResult: '$result'
}

export interface Rule {
  name: string,
  expression: string,
  priority: number,
  result: string,
  type: string,
  status: number,
}

export interface RuleState {
  name: string,
  resourceId: string,
  parameters: StateParameter,
  type: string,
  status: number,
}

export interface StateParameter {
  awarenessProcedureId: string,
  inputParams: InputParams,
}

export interface InputParams {}

export interface TimeParam extends InputParams {
  timeFenceType: number,
  timeRange: string,
  dateRange?: string
}

export interface AppParam extends InputParams {
  bundleNames: string[],
  ancoBundleNames?: string[],
  delayMs: number
}

export interface LocationParam extends InputParams {
  latitude: string,
  longitude: string,
  radius: string,
  expiration: string,
}

export interface OutDoorTravelModeParam extends InputParams {
  switchType: string,
  switchStatus: string,
  isSupportLockScene: number,
}

export interface ExtremeBatterySaverModeParam extends InputParams {
  systemParameterName: string,
  systemParameterValue: string[],
  defaultValue: string,
  isSupportLockScene: number,
}

export interface DbParam extends InputParams {
  Uri: string;
}

export interface CommCallbackResp {
  requestId: string,
  message: string,
  token: string,
}