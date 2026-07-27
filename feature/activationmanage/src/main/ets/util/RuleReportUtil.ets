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

import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import {
  HiSysEventUtil,
  ActionResult,
  ProcessRulesAction,
  ProcessRulesSource,
} from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { CommCallbackResp } from '../model/RulePostBody';

/* instrument ignore file */
const TAG: string = 'RuleReportUtil: ';
const SUCCESS: string = 'success';

// 类型-数量结构
interface ValueItem {
  type: string,
  nums: number,
}

/**
 * 规则打点工具
 */
export class RuleReportUtil {
  /**
   * 规则下发打点
   *
   * @param requestId 请求id
   * @param configList 配置数据
   */
  public static reportRuleIssue(requestId: string, configList: ConfigData[]): void {
    LogUtil.showInfo(TAG, 'report issue rule');
    HiSysEventUtil.reportRequestProcess(requestId, ProcessRulesSource.USER_OPERATION, ProcessRulesAction.UPDATE, '',
      RuleReportUtil.configs2Value(configList));
  }

  /**
   * 下发结果接收上报打点
   *
   * @param callbackResp 多啦返回数据
   */
  public static reportResultReceive(callbackResp?: CommCallbackResp): void {
    if (!callbackResp) {
      LogUtil.showWarn(TAG, 'resp is empty');
      return;
    }
    HiSysEventUtil.reportRequestProcess(callbackResp.requestId, ProcessRulesSource.USER_OPERATION,
      ProcessRulesAction.RESULT, callbackResp.message === SUCCESS ? ActionResult.SUCCESS : ActionResult.FAIL);
  }
  
  /**
   * 规则数据转字符串
   *
   * @param configList 配置数据
   * @returns 配置数据字符串
   */
  private static configs2Value(configList: ConfigData[]): string {
    let result: ValueItem[] = [];
    let timeItem: ValueItem = {
      type: ConfigType.TRIGGER_CONDITION_TIME.toString(),
      nums: 0,
    };
    let appItem: ValueItem = {
      type: ConfigType.TRIGGER_CONDITION_APP.toString(),
      nums: 0,
    };
    let temporaryItem: ValueItem = {
      type: ConfigType.TEMPORARY_TIME_CONDITION.toString(),
      nums: 0,
    };
    for (let config of configList) {
      switch (config.configType) {
        case ConfigType.TRIGGER_CONDITION_TIME:
          timeItem.nums++;
          break;
        case ConfigType.TRIGGER_CONDITION_APP:
          appItem.nums++;
          break;
        case ConfigType.TEMPORARY_TIME_CONDITION:
          temporaryItem.nums++;
          break;
        default:
          break;
      }
    }
    result.push(timeItem);
    result.push(appItem);
    result.push(temporaryItem);
    return JsonUtil.stringify(result);
  }
}
