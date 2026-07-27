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

import rpc from '@ohos.rpc';
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import { JsonUtil } from './JsonUtil';
import { LogUtil } from './LogUtil';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { SettingsConstant } from './AbilityUtils';

const TAG: string = 'SearchUtil: ';
const SETTINGS_ENABLE_SEARCH_ITEMS: number = 2;
const METHOD_DISABLE_SEARCH_ITEM: string = 'disableSearchItems';
const METHOD_ENABLE_SEARCH_ITEM: string = 'enableSearchItems';

export class SearchUtil {
  /**
   * 启用或者禁用设置搜索项
   *
   * @param itemName seachpage.json中的itemName
   * @param enable true代表使能搜索项 false代表禁用搜索项
   */
  public static handleSearchItem(itemNames: string[], enable: boolean): void {
    LogUtil.showInfo(TAG, `handleSearchItem: ${enable}`);
    if (CheckEmptyUtils.isEmpty(itemNames) || CheckEmptyUtils.isEmptyArr(itemNames)) {
      LogUtil.showWarn(TAG, 'itemNames is empty');
      return;
    }
    SearchUtil.connect(itemNames, enable ? METHOD_ENABLE_SEARCH_ITEM : METHOD_DISABLE_SEARCH_ITEM);
  }

  private static connect(itemNames: string[], callMsg: string): void {
    const context: Context | undefined = AbilityContextManager.getContext();
    if (!context) {
      LogUtil.showWarn(TAG, 'connect failed, context is empty');
      return;
    }
    try {
      const uiContext: common.UIAbilityContext = context as common.UIAbilityContext;
      const connectionId: number = uiContext.connectServiceExtensionAbility({
        bundleName: SettingsConstant.SETTINGS_BUNDLE_NAME,
        abilityName: 'SettingsExtService',
      }, {
        onConnect(elementName, remote) {
          let option: rpc.MessageOption = new rpc.MessageOption();
          let data: rpc.MessageSequence = new rpc.MessageSequence();
          let reply: rpc.MessageSequence = new rpc.MessageSequence();
          let callMessage: CallMessage = new CallMessage(callMsg);
          let enableItems: SearchItems = new SearchItems();
          enableItems.getItemList().push(...itemNames);
          callMessage.extra = enableItems;
          data.writeString(JsonUtil.stringify(callMessage));
          remote.sendMessageRequest(SETTINGS_ENABLE_SEARCH_ITEMS, data, reply, option).then(result => {
            LogUtil.showInfo(TAG, `send request success ${result?.errCode} ${result?.reply.readInt()}`);
          }).catch((error: BusinessError) => {
            LogUtil.showError(TAG, `sendMessageRequest failed. code:${error?.code} message:${error?.message}`);
          }).finally(() => {
            SearchUtil.disconnect(connectionId);
            data.reclaim();
            reply.reclaim();
          });
        },
        onDisconnect(elementName) {
          LogUtil.showInfo(TAG, 'onDisconnect');
        },
        onFailed(code) {
          LogUtil.showError(TAG, `onFailed called ${code}`);
        }
      });
      LogUtil.showInfo(TAG, `connectSettingsService connectionId: ${connectionId}`);
    } catch (e) {
      LogUtil.showError(TAG, `connectSettingsService error: ${e?.code}, msg: ${e?.message}`);
    }
  }

  private static async disconnect(connectionId: number): Promise<void> {
    const context: Context | undefined = AbilityContextManager.getContext();
    if (!context) {
      LogUtil.showWarn(TAG, 'disconnect failed, context is empty');
      return;
    }
    try {
      const uiContext: common.UIAbilityContext = context as common.UIAbilityContext;
      await uiContext.disconnectServiceExtensionAbility(connectionId);
      LogUtil.showInfo(TAG, `disconnect success connectionId is ${connectionId}`);
    } catch (e) {
      LogUtil.showError(TAG, `disconnect error: ${e?.code}, msg: ${e?.message}`);
    }
  }
}

class CallMessage {
  /**
   * 方法名
   */
  method: string;
  /**
   * 附加参数
   */
  extra?: object;

  constructor(method: string, extra?: object) {
    this.method = method;
    this.extra = extra;
  }
}

class SearchItems {
  private itemList: Array<string> = [];

  public getItemList(): Array<string> {
    return this.itemList;
  }

  public setItemList(itemList: Array<string>): void {
    this.itemList = itemList;
  }
}