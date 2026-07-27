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
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import {
  HOME_PAGE_ID,
  HomeGroupId,
  HomeGroupItemId,
} from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';

const TAG: string = 'HomeGroupController:';

/**
 * 首页所有group组件controller (控制group组件的显隐/使能变化)
 */
export class HomeGroupController implements ComponentControl {
  /**
   * 切换模式事件
   */
  private onScrollNewModeCallback = () => {
    const currentModeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    // 统一处理groups模式切换显隐状态
    let logStr: string = '';
    Object.values(HomeGroupId).forEach((groupId: HomeGroupId) => {
      const isShow: boolean = ModeConfigAdapter.getInstance().getGroupVisible(currentModeId, groupId);
      logStr = logStr + `${groupId}:${isShow} `;
      const compId: string = `${HOME_PAGE_ID}.${groupId}`;
      this.setGroupHeaderVisible(compId, isShow);
      this.setGroupVisible(compId, isShow);
      this.setGroupFooterVisible(compId, isShow);
    });
    LogUtil.showInfo(TAG, `onScrollNewModeCallback. currentModeId:${currentModeId} logStr:${logStr}`);
    this.computeItemProperty();
  }

  init(): void {
    LogUtil.showInfo(TAG, 'init.');
    EventBus.getInstance().on(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
  }

  /**
   * 保证新架构组件全部注册送显完毕后再执行首次item的使能控制
   */
  onDidDraw(): void {
    LogUtil.showInfo(TAG, 'onDidDraw.');
    this.computeItemProperty();
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'destroy.');
    EventBus.getInstance().detach(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
  }

  /**
   * 少量定制item的使能逻辑
   */
  private computeItemProperty(): void {
    const currentModeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(TAG, `computeItemProperty. currentModeId:${currentModeId}`);
  }

  /**
   * 控制Item使能
   */
  private setItemEnabled(compId: string, enabled: boolean): void {
    notifyCompStateChange(`${compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_ENABLED, { state: enabled } as SettingCompState]]
    ));
  }

  /**
   * 控制Item显隐
   */
  private setItemVisible(compId: string, isShow: boolean): void {
    notifyCompStateChange(`${compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  /**
   * 控制GroupHeader显隐
   */
  private setGroupHeaderVisible(compId: string, isShow: boolean): void {
    notifyCompStateChange(`${compId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  /**
   * 控制Group显隐
   */
  private setGroupVisible(compId: string, isShow: boolean): void {
    notifyCompStateChange(`${compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  /**
   * 控制GroupFooter显隐
   */
  private setGroupFooterVisible(compId: string, isShow: boolean): void {
    notifyCompStateChange(`${compId}.footer`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_FOOTER_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }
}