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

import CommonEvent from '@ohos.commonEvent';
import commonEventManager from '@ohos.commonEventManager';
import { AsyncCallback, BusinessError } from '@ohos.base';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'CommonEventHelper:';

/**
 * 公共事件工具类
 */
export class CommonEventHelper {
  /**
   * 订阅者
   */
  public subscriber?: commonEventManager.CommonEventSubscriber;
  /**
   * 订阅者信息
   */
  public subscribeInfo?: commonEventManager.CommonEventSubscribeInfo;
  /**
   * 事件回调
   */
  public subscribeCallBack?: AsyncCallback<commonEventManager.CommonEventData>;
  private isRegister: boolean = false;

  constructor(subscribeInfo: commonEventManager.CommonEventSubscribeInfo, subscribeCallBack:
    AsyncCallback<commonEventManager.CommonEventData>) {
    this.subscribeInfo = subscribeInfo;
    this.subscribeCallBack = subscribeCallBack;
  }

  /**
   * 取消订阅公共事件回调
   */
  private unsubscribeCallBack = (err: BusinessError) => {
    if (err?.code) {
      LogUtil.showInfo(TAG, `unsubscribe failed ${err?.message}`);
    } else {
      LogUtil.showInfo(TAG, `unsubscribe success`);
    }
  }
  /**
   * 创建订阅者回调
   */
  private createSubscriberCallBack = (err: BusinessError, commonEventSubscriber:
    commonEventManager.CommonEventSubscriber) => {
    if (err?.code) {
      LogUtil.showError(TAG, `createSubscriber failed. code:${err?.code} message:${err?.message}`);
    } else {
      LogUtil.showInfo(TAG, `createSubscriber success`);
      this.subscriber = commonEventSubscriber;
      //订阅公共事件回调
      CommonEvent.subscribe(this.subscriber, this.subscribeCallBack);
    }
  }

  registerCommonEvent(): void {
    if (this.isRegister) {
      LogUtil.showInfo(TAG, `registerCommonEvent`);
      return;
    }
    CommonEvent.createSubscriber(this.subscribeInfo, this.createSubscriberCallBack);
    this.isRegister = true;
  }

  unRegisterCommonEvent(): void {
    if (!this.isRegister) {
      LogUtil.showInfo(TAG, `unRegisterCommonEvent`);
      return;
    }
    CommonEvent.unsubscribe(this.subscriber, this.unsubscribeCallBack);
    this.isRegister = false;
  }
}