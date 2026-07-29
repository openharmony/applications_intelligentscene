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

import HashMap from '@ohos.util.HashMap';
import { Any } from './AnyType';

/**
 * EventBus 回调调用签名。
 * 注册侧请使用 Object 承接具体业务回调，避免 ArkTS 对函数参数的逆变检查报错。
 */
export type EventCb = (...args: Any[]) => void;

interface Listener {
  callback: Object;
  triggerCnt?: number;
};

const TAG: string = 'EventBus';

export class EventBus {
  private static instance: EventBus;
  private listenerMap: HashMap<string, Listener[]> = new HashMap();

  private constructor() {
  }

  public static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus();
    }
    return EventBus.instance;
  }

  public on(eventName: string, callback: Object): void {
    this.registerListener(eventName, callback);
  }

  public once(eventName: string, callback: Object): void {
    this.registerListener(eventName, callback, 1);
  }

  public exactly(eventName: string, callback: Object, capacity: number): void {
    this.registerListener(eventName, callback, capacity);
  }

  public off(eventName: string): void {
    this.die(eventName);
  }

  public detach(eventName: string, callback: Object, needDetachAll: boolean = true): void {
    let listeners = this.listenerMap.get(eventName) ?? [];
    if (needDetachAll) {
      listeners = listeners.filter(value => value.callback !== callback);
    } else {
      const index = listeners.findIndex(listener => listener.callback === callback);
      if (index !== -1) {
        listeners.splice(index, 1);
      }
    }

    if (listeners.length === 0) {
      this.die(eventName);
      return;
    }

    this.listenerMap.set(eventName, listeners);
  }

  public emit(eventName: string, ...args: Any[]): void {
    let listeners: Listener[] = [];

    if (this.hasListeners(eventName)) {
      listeners = this.listenerMap.get(eventName);
    }

    if (listeners.length === 0) {
      return;
    }

    listeners.forEach((listener, k) => {
      if (listener.callback) {
        (listener.callback as EventCb)(...args);
      }

      if (listener.triggerCnt !== undefined) {
        listener.triggerCnt--;
        listeners[k].triggerCnt = listener.triggerCnt;
      }
      if (this.checkToRemoveListener(listener)) {
        this.listenerMap.get(eventName)?.splice(k, 1);
      }
    });
  }

  private registerListener(eventName: string, cb: Object, triggerCnt?: number): void {
    if (!this.hasListeners(eventName)) {
      this.listenerMap.set(eventName, []);
    }

    this.listenerMap.get(eventName).push({ callback: cb, triggerCnt: triggerCnt });
  }

  private die(eventName: string): void {
    this.listenerMap.remove(eventName);
  }

  private checkToRemoveListener(eventInformation: Listener): boolean {
    if (eventInformation.triggerCnt !== undefined) {
      return eventInformation.triggerCnt <= 0;
    }
    return false;
  }

  private hasListeners(eventName: string): boolean {
    return this.listenerMap.hasKey(eventName);
  }
}
