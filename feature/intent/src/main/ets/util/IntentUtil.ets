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
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { BaseModeConfig } from '@ohos/scene.modeconfig/src/main/ets/adapter/BaseModeConfig';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil'
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { ERROR_MSG, IntentCodeConstants } from '../constant/IntentCodeConstant';

const TAG: string = 'IntentUtil: ';

/**
 * 意图框架工具类
 */
export class IntentUtil {


  /**
   * null数据返回组装
   *
   * @returns 返回意图Result
   */
  static nullResponse(): Promise<insightIntent.ExecuteResult> {
    return Promise.reject({
      code: IntentCodeConstants.DEFAULT_CODE_FAILED,
      result: ({
        'errMsg': ERROR_MSG[IntentCodeConstants.DEFAULT_CODE_FAILED],
      } as Record<string, Object>)
    });
  }

  /**
   * error数据组装
   *
   * @param errorCode Code码
   * @returns 返回意图Result
   */
  static errorResponse(errorCode: number): insightIntent.ExecuteResult {
    return { code: errorCode, result: { 'errMsg': ERROR_MSG[errorCode] } };
  }

  /**
   * 处理Response
   *
   * @param successCode successCode码
   * @param msg 返回成功msg
   * @returns 返回意图Result
   */
  static successResponse(successCode: number, msg: string | string[]): insightIntent.ExecuteResult {
    return { code: successCode, result: { 'msg': msg } };
  }

  /**
   * 获取当前开启的模式id对应的config信息
   *
   * @returns config信息
   */
  static getCurrentOpenedModeConfig(): BaseModeConfig {
    const currentOpenedModeId: string =
      SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, NO_SCENE);
    LogUtil.showInfo(TAG, `current opened mode id is: ${currentOpenedModeId}`);
    const modeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(currentOpenedModeId);
    return modeConfig;
  }

  /**
   * 判断模式是否支持小艺语音操作
   *
   * @param modeId 模式id
   * @returns 是否支持
   */
  static isSupportAgent(modeId: string): boolean {
    const modeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(modeId);
    LogUtil.showInfo(TAG, `isSupportAgent: ${modeConfig.isSupportAgent}, modeId is ${modeId}`);
    return modeConfig.isSupportAgent;
  }

  /**
   * 判断模式是否支持重复来电开关操作
   *
   * @param modeId 模式id
   * @returns 是否支持
   */
  static async isSupportModifyRepeatRing(modeId: string): Promise<boolean> {
    const configData: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(modeId,
      ConfigType.CALL_NOT_DISTURB_POLICY);
    LogUtil.showInfo(TAG, `isSupportModifyRepeatRing: modeId ${modeId}, policy ${configData[0]?.configValue}`);
    return configData[0]?.configValue !== ContactPolicy.ALLOW_EVERYONE;
  }
}