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

import lazy systemParameterEnhance from '@ohos.systemParameterEnhance';
import { ConfigConstant } from '../constant/ConfigConstant';
import { LogUtil } from './LogUtil';

const TAG: string = 'SystemParamUtil: ';

export class SystemParamUtil {
  public static getParam(parameter: string, defaultValue: string): string {
    try {
      return systemParameterEnhance.getSync(parameter, defaultValue);
    } catch (err) {
      LogUtil.showError(TAG, `getParam failed ${err?.code} ${err?.message}`);
      return defaultValue;
    }
  }

  public static setParam(parameter: string, value: string): void {
    try {
      systemParameterEnhance.setSync(parameter, value);
    } catch (err) {
      LogUtil.showError(TAG, `setParam failed ${err?.code} ${err?.message}`);
    }
  }

  /**
   * 是否支持情景模式
   *
   * @returns true: 支持 false: 不支持
   */
  public static isSupportIntelligentScene(): boolean {
    return SystemParamUtil.getParam(ConfigConstant.CONST_INTELLIGENT_SCENE_ENABLE, '') === 'true';
  }
}
