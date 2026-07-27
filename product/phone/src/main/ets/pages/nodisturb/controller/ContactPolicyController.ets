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

import emitter from '@ohos.events.emitter';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

/* instrument ignore file */
const TAG: string = 'ContactPolicyController';
export const FOCUS_MODE_CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy';
export const INCOMING_CALL_SELECT_CONTACTS: string = 'incoming_call_select_contacts';

/**
 * 免打扰来电策略选择控制器
 */
export class ContactPolicyController {
  private settingsValue: string = '';
  private isShowSelect: boolean = false;
  private isShowRepeat: boolean = false;
  private policyChangeCallBack = (contactPolicy: string, modeId: string) => {
    const currentModeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(TAG, `policyChangeCallBack, value: ${contactPolicy}, modeId: ${modeId}, currentModeId: ${currentModeId}`);
    if (currentModeId === modeId) {
      this.refreshUiByAllowContactsChange(contactPolicy);
    }
  }

  /**
   * 联系人策略修改回调
   */
  private allowContactsCallback = (eventData: emitter.EventData) => {
    const settingsValue: string = eventData.data?.settingsValue;
    this.refreshUiByAllowContactsChange(settingsValue);
  }

  constructor(value: string) {
    this.settingsValue = value;
  }

  init(): void {
    LogUtil.showInfo(TAG, `init settingsValue is: ${this.settingsValue}`);
    EventBus.getInstance().on(EventBusNameConstant.ALLOW_CONTACTS_CHANGE, this.allowContactsCallback);
    EventBus.getInstance().on(EventBusNameConstant.AGENT_MODIFY_CONTACT_POLICY_EVENT, this.policyChangeCallBack);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'destroy');
    EventBus.getInstance().detach(EventBusNameConstant.ALLOW_CONTACTS_CHANGE, this.allowContactsCallback);
    EventBus.getInstance().detach(EventBusNameConstant.AGENT_MODIFY_CONTACT_POLICY_EVENT, this.policyChangeCallBack);
  }

  private refreshUiByAllowContactsChange(settingsValue: string): void {
    LogUtil.showInfo(TAG, `receive event: ${settingsValue}, ${this.settingsValue}`);
    this.isShowSelect = settingsValue === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ||
      settingsValue === ContactPolicy.FORBID_SPECIFIED_CONTACTS;
    this.isShowRepeat = settingsValue !== ContactPolicy.ALLOW_EVERYONE;
    this.showOrHideRepeat(this.isShowRepeat);
    EventBus.getInstance().emit(INCOMING_CALL_SELECT_CONTACTS, { state: this.isShowSelect } as SettingCompState);
  }

  public onRadioChecked(policyKey: string): void {
    this.settingsValue = policyKey;
    LogUtil.showInfo(TAG, `onRadioChecked value:${policyKey}`);
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const modeOpenState: ModeState = ModeUtil.getModeOpenState();
    AllowDisturbManager.getInstance().updateContactPolicy(modeId, this.settingsValue).then((configId) => {
      LogUtil.showInfo(TAG, `onRadioChange configId: ${configId}, settingsValue: ${this.settingsValue}`);
      ModeDetailAdapter.getInstance().updateParsedConfigById(configId);
      // 如果开关是开的，同步存到数据库中
      if (ModeUtil.isCurrentModeOpened(modeId, modeOpenState)) {
        SettingsDataUtils.setSystemValue(FOCUS_MODE_CALL_MESSAGE_POLICY, this.settingsValue);
      }
    });
    this.isShowSelect = this.settingsValue === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ||
      this.settingsValue === ContactPolicy.FORBID_SPECIFIED_CONTACTS;
    this.isShowRepeat = this.settingsValue != ContactPolicy.ALLOW_EVERYONE;
    this.showOrHideRepeat(this.isShowRepeat);
    let param: Record<string, Object> = {};
    param.MODE = modeId;
    param.CALL_POLICY = this.settingsValue;
    HiSysEventUtil.reportBehaviorEventByUE(HiSysIntelligentSceneEvent.CALL_POLICY_CHANGE, param);
    EventBus.getInstance().emit(INCOMING_CALL_SELECT_CONTACTS, { state: this.isShowSelect } as SettingCompState);
    EventBus.getInstance().emit(EventBusNameConstant.CONTACT_POLICY_REFRESH, this.settingsValue);
  }

  private showOrHideRepeat(isShow: boolean): void {
    let state: boolean = isShow;
    notifyCompStateChange(`IntelligentScene.IncomingCall.repeat_ringing_group`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
    notifyCompStateChange(`IntelligentScene.IncomingCall.repeat_ringing_group.footer`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
      ));
    notifyCompStateChange(`IntelligentScene.IncomingCall.automatic_answering_group`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
          { state: state } as SettingCompState]]
      ));
    notifyCompStateChange(`IntelligentScene.IncomingCall.automatic_answering_group.footer`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
          { state: state } as SettingCompState]]
      ));
  }
}
