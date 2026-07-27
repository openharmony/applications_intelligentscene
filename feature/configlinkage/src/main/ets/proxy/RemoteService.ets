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

import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import bundleManager from '@ohos.bundle.bundleManager';
import rpc from '@ohos.rpc';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import IServiceProxy from './IServiceProxy';

const TAG: string = 'SceneRemoteService: ';

export class RemoteService {
  private remoteObj?: rpc.IRemoteObject;
  private proxy?: IServiceProxy;
  private connectionCode?: number;
  private context?: common.UIAbilityContext;

  public constructor(context: Context) {
    this.context = context as common.UIAbilityContext;
  }

  public async getProxy(want: Want): Promise<IServiceProxy> {
    return new Promise<IServiceProxy>((resolve, reject) => {
      if (!this.context) {
        LogUtil.showError(TAG, 'getProxyInner, context is empty');
        let error: Record<string, string | number> = {
          'message': 'context is empty'
        };
        return reject(error);
      }
      if (this.proxy) {
        return resolve(this.proxy);
      }
      try {
        LogUtil.showInfo(TAG, `getProxy, connect service: ${want?.abilityName}`);
        this.connectionCode =
          (AbilityContextManager.getContext() as common.UIExtensionContext).connectServiceExtensionAbility(want, {
            onConnect: (elementName: bundleManager.ElementName, remote: rpc.IRemoteObject): void => {
              LogUtil.showInfo(TAG, `getProxy, onConnect connectionCode: ${this.connectionCode}`);
            this.remoteObj = remote;
            this.proxy = new IServiceProxy(remote);
            resolve(this.proxy);
          },
          onDisconnect: (elementName: bundleManager.ElementName): void => {
            LogUtil.showInfo(TAG, `getProxy, onDisconnect connectionCode:${this.connectionCode}`);
            this.clean();
          },
          onFailed: (code: number): void => {
            LogUtil.showError(TAG, `getProxy, onFailed ${code}`);
            this.clean();
            let error: Record<string, string | number> = {
              'code': code,
              'message': 'getProxy failed'
            };
            reject(error);
          }
        });
      } catch (err) {
        LogUtil.showError(TAG, `connectCallerRpc catch exception, ${err?.code} ${err?.message}`);
      }
    })
  }

  private clean(): void {
    this.remoteObj = undefined;
    this.proxy = undefined;
  }

  public disConnect(): void {
    if (!this.context) {
      LogUtil.showError(TAG, 'disConnect, context is empty');
      return;
    }
    try {
      this.context.disconnectServiceExtensionAbility(this.connectionCode as number);
    } catch (err) {
      LogUtil.showError(TAG, `disconnectThemeService failed: ${err?.code}`);
    }
  }
}