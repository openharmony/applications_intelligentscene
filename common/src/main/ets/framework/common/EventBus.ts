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

export type EventCb = (...args: any[]) => void;

interface Listener {
  callback: EventCb;
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

  public on(eventName: string, callback: EventCb): void {
    this.registerListener(eventName, callback);
  }

  public once(eventName: string, callback: EventCb): void {
    this.registerListener(eventName, callback, 1);
  }

  public exactly(eventName: string, callback: EventCb, capacity: number): void {
    this.registerListener(eventName, callback, capacity);
  }

  public off(eventName: string): void {
    this.die(eventName);
  }

  public detach(eventName: string, callback: EventCb, needDetachAll: boolean = true): void {
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

  public emit(eventName: string, ...args: any): void {
    let listeners: Listener[] = [];

    if (this.hasListeners(eventName)) {
      listeners = this.listenerMap.get(eventName);
    }

    if (listeners.length === 0) {
      return;
    }

    listeners.forEach((listener, k) => {
      if (listener.callback) {
        listener.callback(...args);
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

  private registerListener(eventName: string, cb: EventCb, triggerCnt?: number): void {
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