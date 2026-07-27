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

import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsLinkageState as State } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { ACTION } from '../constant/LinkageConstants';

const TAG: string = 'LinkageStateMachine';

export class LinkageStateMachine {
  private tag: string = TAG;

  private state: State = State.NOT_LINK;

  private type: string = '';

  private actionMap: Map<ACTION, Function> = new Map();

  constructor(type: string) {
    this.type = type;
    this.tag = `${TAG}_${this.type}`;
  }

  /**
   * 添加action对应的回调执行方法
   *
   * @param action
   * @param callback
   */
  public addCallback(action: ACTION, callback: Function) {
    if (callback) {
      this.actionMap.set(action, callback);
    }
  }

  /**
   * 初始化当前状态
   *
   * @param state
   * @returns
   */
  public initCurrentState(state: State): State {
    let storageStateStr: string = SettingsDataUtils.getSystemValue(`linkedage_state_${this.type}`,
      String(state)) as string;
    LogUtil.showInfo(this.tag, `initCurrentState state: ${state}, storage: ${storageStateStr}`);
    return Number(storageStateStr);
  }

  /**
   * 设置当前状态
   *
   * @param state
   */
  public setCurrentState(state: State): void {
    LogUtil.showInfo(this.tag, `setCurrentState: ${state}`);
    this.state = state;
    SettingsDataUtils.setSystemValue(`linkedage_state_${this.type}`, String(state));
  }

  /**
   * 配置项状态机切换，返回切换时需要执行的操作类型
   *
   * @param nextState
   * @returns 需要执行的操作类型
   */
  public convertState(nextState: State): void {
    let storageStateStr: string = SettingsDataUtils.getSystemValue(`linkedage_state_${this.type}`,
      String(this.state)) as string;
    this.state = Number(storageStateStr);
    LogUtil.showInfo(this.tag, `${this.type} convertState current state:${this.state} nextState is ${nextState}`);
    let action: ACTION = ACTION.NO_ACTION;
    if (this.state === State.NOT_LINK && nextState === State.LINK_ENABLE) {
      action = ACTION.CACHE_AND_ON;
    } else if (this.state === State.LINK_ENABLE && nextState === State.NOT_LINK) {
      action = ACTION.ON_TO_DEFAULT;
    } else if (this.state === State.LINK_DISABLE && nextState === State.LINK_ENABLE) {
      action = ACTION.OFF_TO_ON;
    } else if (this.state === State.LINK_ENABLE && nextState === State.LINK_DISABLE) {
      action = ACTION.ON_TO_OFF;
    } else if (this.state === State.LINK_DISABLE && nextState === State.NOT_LINK) {
      action = ACTION.OFF_TO_DEFAULT;
    } else if (this.state === State.NOT_LINK && nextState === State.LINK_DISABLE) {
      action = ACTION.CACHE_AND_OFF;
    } else {
      LogUtil.showInfo(this.tag, 'no action');
    }
    this.setCurrentState(nextState);
    this.actionMap.get(action)?.();
  }
}