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

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from './LogUtil';

const TAG: string = 'SessionUtil: ';

/**
 * UEC session通信工具类
 */
export class SessionUtil {
  /**
   * 发送消息给设置宿主UEC
   *
   * @param intent 消息对象
   */
  public static sendMessageToSetting(intent: Record<string, Object>): void {
    try {
      LocalStorage.getShared()?.get<UIExtensionContentSession>('ExtensionContentSession')?.sendData(intent);
    } catch (error) {
      LogUtil.showError(TAG, `sendMessageToSetting error: ${error?.code}, ${error?.message}`);
    }
  }

  /**
   * 给设置主进程发送加载应用列表消息
   */
  public static sendLoadAppListToSetting(): void {
    const intent: Record<string, Object> = { 'action': 'loadAppList' };
    SessionUtil.sendMessageToSetting(intent);
  }

  /**
   * 给设置发送获取列表加载状态消息
   *
   * @param uiExtensionProxy uec代理
   */
  public static sendLoadStateToSetting(uiExtensionProxy?: UIExtensionProxy): void {
    if (!uiExtensionProxy) {
      LogUtil.showError(TAG, 'send load state to setting error, proxy is undefined');
      return;
    }
    const isAppListLoadComplete: boolean = AppStorage.get('isAppListLoadComplete') as boolean ;
    const intent: Record<string, Object> = { 'action': 'getLoadState', 'loadState': isAppListLoadComplete };
    uiExtensionProxy?.send(intent);
  }
}
