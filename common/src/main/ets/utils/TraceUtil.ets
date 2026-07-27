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

import byTrace from '@ohos.hiTraceMeter';
import { LogUtil } from './LogUtil';
import { GlobalContext } from './GlobalContext';
import { GlobalCtxKey } from './GlobalContext';

/* instrument ignore file */
const TRACE_TAG: string = 'IntelligentScene_Trace:';
const NEXT_INTERVAL: number = 1;

export class TraceUtil {
  public static readonly CORE_METHOD_START_GET_SUPPORTED_REFRESH_RATES: string = 'getSupportedRefreshRates';
  public static readonly CORE_METHOD_START_GET_CURRENT_REFRESH_RATE: string = 'getCurrentRefreshRate';
  private static readonly RECORD_TRACE: boolean = true;
  private static readonly TRACE_BASE_INDEX: number = 20000;

  /**
   * Trace开始节点
   *
   * @param methodName trace点名称
   */
  public static start(methodName: string): void {
    if (!TraceUtil.RECORD_TRACE) {
      return;
    }
    let taskMap: Object | undefined = GlobalContext.getInstance().get(GlobalCtxKey.GLOBAL_KEY_TASK_ID_MAP);
    let traceIndex: Object | undefined = GlobalContext.getInstance().get(GlobalCtxKey.GLOBAL_KEY_TRACE_INDEX);
    if (!taskMap || !traceIndex) {
      TraceUtil.init();
    }
    let taskIdMap = GlobalContext.getInstance().get(GlobalCtxKey.GLOBAL_KEY_TASK_ID_MAP) as Map<string, number>;
    let taskId = taskIdMap.get(methodName);
    if (!taskId) {
      taskId = GlobalContext.getInstance().get(GlobalCtxKey.GLOBAL_KEY_TRACE_INDEX) as number;
      GlobalContext.getInstance().set(GlobalCtxKey.GLOBAL_KEY_TRACE_INDEX, taskId + NEXT_INTERVAL);
      taskIdMap.set(methodName, taskId);
      GlobalContext.getInstance().set(GlobalCtxKey.GLOBAL_KEY_TASK_ID_MAP, taskIdMap);
    }
    LogUtil.showInfo(TRACE_TAG, `start trace ${taskId}, methodName: ${methodName}`);
    try {
      byTrace.startTrace(`${TRACE_TAG}${methodName}`, taskId);
    } catch (e) {
      LogUtil.showError(TRACE_TAG, `start trace error, methodName: ${methodName} code: ${e?.code}`);
    }
  }

  /**
   * Trace结束节点
   *
   * @param methodName trace点名称
   */
  public static end(methodName: string): void {
    if (!TraceUtil.RECORD_TRACE) {
      return;
    }
    if (!GlobalContext.getInstance().get<string>(GlobalCtxKey.GLOBAL_KEY_TASK_ID_MAP)) {
      return;
    }
    let taskIdMap = GlobalContext.getInstance().get(GlobalCtxKey.GLOBAL_KEY_TASK_ID_MAP) as Map<string, number>;
    let taskId: undefined|number = taskIdMap.get(methodName);
    if (!taskId) {
      LogUtil.showInfo(TRACE_TAG, `fail to end trace name ${methodName}`);
      return;
    }
    try {
      taskIdMap.delete(methodName);
      GlobalContext.getInstance().set(GlobalCtxKey.GLOBAL_KEY_TASK_ID_MAP, taskIdMap);
      LogUtil.showInfo(TRACE_TAG, `end trace ${taskId}`);
      byTrace.finishTrace(`${TRACE_TAG}${methodName}`, taskId);
    } catch (e) {
      LogUtil.showError(TRACE_TAG, `end error ${e?.code}, msg: ${e?.message}`);
    }
  }

  private static init(): void {
    LogUtil.showInfo(TRACE_TAG, 'init trace parameters');
    GlobalContext.getInstance().set(GlobalCtxKey.GLOBAL_KEY_TASK_ID_MAP, new Map<string, number>());
    GlobalContext.getInstance().set(GlobalCtxKey.GLOBAL_KEY_TRACE_INDEX, TraceUtil.TRACE_BASE_INDEX);
  }
}