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

import commonEventManager from '@ohos.commonEventManager';
import { common } from '@kit.AbilityKit';
import { StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import { LogUtil } from './LogUtil';
import { IntelligentSceneConstant } from './AbilityUtils';
import { IS_NEED_START_SERVICE_ACTION, SubscriberConstant } from '../constant/SubscriberConstant';
import { StringUtil } from './StringUtil';

const TAG: string = 'StaticSubscriberUtil: ';

/**
 * 静态订阅者工具类
 */
export class StaticSubscriberUtil {

  /**
   * 通过静态订阅者SettingDataTimeRestoreFinishSubscriber拉起IntelligentSceneActionServiceAbility服务，
   * 在服务中根据行为类型执行规则生效、开启关闭模式等业务
   *
   * @param context 静态订阅者上下文
   * @param action 行为类型
   * @param params 行为参数
   */
  public static startActionServiceAbility(context: StaticSubscriberExtensionContext | common.UIAbilityContext |
    common.UIExtensionContext, action: string, params?: Record<string, Object>): void {
    if (!context || !action) {
      LogUtil.showWarn(TAG, 'context or action is invalid');
      return;
    }
    const want: Want = {
      'bundleName': IntelligentSceneConstant.BUNDLE_NAME,
      'abilityName': SubscriberConstant.ABILITY_NAME,
      'action': action,
      'parameters': StaticSubscriberUtil.buildEventParams(params)
    };
    try {
      context.startAbility(want, () => {
        LogUtil.showInfo(TAG, 'startActivationServiceAbility success');
      });
    } catch (e) {
      LogUtil.showError(TAG, `startActivationServiceAbility error: ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 发送公共事件，拉起对应的静态订阅者SettingDataTimeRestoreFinishSubscriber
   *
   * @param action 行为类型
   * @param params 行为参数
   */
  public static publishEvent(action: string, params?: Record<string, Object>): void {
    let options: commonEventManager.CommonEventPublishData = {
      bundleName: IntelligentSceneConstant.BUNDLE_NAME,
      data: action,
      parameters: params || {}
    };
    try {
      commonEventManager.publish(SubscriberConstant.CUSTOM_EVENT_INTELLIGENT_SCENE_CONFIG_CHANGED, options, (error) => {
        if (error) {
          LogUtil.showError(TAG, `publish error: ${error?.code}, message is ${error?.message}`);
          return;
        }
        LogUtil.showInfo(TAG, 'publish success');
      });
    } catch (error) {
      LogUtil.showError(TAG, `publish fail: ${error?.code}, message is ${error?.message}`);
    }
  }

  /**
   * 根据广播参数判断是否需要启动服务
   *
   * @param action 规则行为
   */
  public static isActionNeedStartService(action: string): boolean {
    return IS_NEED_START_SERVICE_ACTION.indexOf(action) >= 0;
  }

  public static buildEventParams(params?: Record<string, Object>): Record<string, Object> {
    const actionId: string = StringUtil.generateUuid();
    LogUtil.showInfo(TAG, `buildEventParams actionId: ${actionId}`);
    if (!params) {
      return { 'actionId': actionId };
    }
    if (!params.actionId) {
      params.actionId = actionId;
    }
    return params;
  }
}