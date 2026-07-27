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

import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { CONTACT_POLICY_MAP, ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ContactAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ContactAdapter';
import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { SELECT_CONTACTS_COUNT } from './SelectContactsController';

/* instrument ignore file */
const TAG: string = 'IncomingCallSettingController: ';
const ALLOW_SELECT: string = 'allowed_selected';
const FORBID_SELECT: string = 'forbid_selected';
// 仅允许指定联系人
const ALLOW_SPECIFY_CONTACTS: string = '1';
// 仅禁止指定联系人
const FORBID_SPECIFY_CONTACTS: string = '2';

/**
 * 免打扰来电设置控制器
 */
export class IncomingCallSettingController implements ComponentControl {
  private compId: string = '';
  private contactLens: number = 0;

  private selectContactsCountCallBack = (value: number) => {
    this.contactLens = value;
    let contactPolicy = IncomingCallUtils.getInstance().getContactPolicy();
    LogUtil.showInfo(TAG, `contactPolicy: ${contactPolicy}`);
    let resource: string = contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ?
      ALLOW_SELECT : FORBID_SELECT;
    let status: string = ResourceUtil.getPluralStringByNameSync(resource, this.contactLens);
    this.updateSelectContactShow(status);
  }

  private onDbDataChange = (): void => {
    LogUtil.showInfo(TAG, 'onDbDataChange');
    this.dbDataChange();
  };

  private scrollNewModeCallBack = () => {
    LogUtil.showInfo(TAG, `scrollNewModeCallBack`);
    this.initData();
  }

  private policyChangeCallBack = (value: string) => {
    LogUtil.showInfo(TAG, `policyChangeCallBack, value: ${value}`);
    this.updateStatus(value);
  }

  async initData(): Promise<string> {
    // 读取数据库中的来电策略
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(TAG, `initData, modeId: ${modeId}`);
    let contactPolicy: string = '';
    if (this.isModeSupportCloudSync(modeId)) {
      contactPolicy = await AllowDisturbManager.getInstance().getContactPolicy(modeId);
    } else {
      contactPolicy = await AllowDisturbManager.getInstance().getEl1ContactPolicy(modeId);
    }
    LogUtil.showInfo(TAG, `contactPolicy: ${contactPolicy}`);
    this.updateStatus(contactPolicy);
    return contactPolicy;
  }

  async dbDataChange(): Promise<void> {
    let contactPolicy: string = await this.initData();
    LogUtil.showInfo(TAG, `dbDataChange: ${contactPolicy}`);
    EventBus.getInstance().emit(EventBusNameConstant.ALLOW_CONTACTS_CHANGE, {
      data: {
        settingsValue: contactPolicy
      }
    });
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, 'init fail, comParam is invalid.');
      return;
    }
    this.compId = compParam.compId;
    this.initContactPolicy();
    EventBus.getInstance().on(SELECT_CONTACTS_COUNT, this.selectContactsCountCallBack);
    EventBus.getInstance().on(EventBusNameConstant.SCROLL_NEW_MODE, this.scrollNewModeCallBack);
    EventBus.getInstance().on(EventBusNameConstant.CONTACT_POLICY_REFRESH, this.policyChangeCallBack);
    EventBus.getInstance().on(EventBusNameConstant.DB_CONTACT_DATA_REFRESH, this.onDbDataChange);
    EventBus.getInstance().on(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onDbDataChange);
    EventBus.getInstance().on(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onDbDataChange);
    EventBus.getInstance().on(EventBusNameConstant.AGENT_MODIFY_CONTACT_POLICY_EVENT, this.policyChangeCallBack);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, `destroy`);
    EventBus.getInstance().detach(SELECT_CONTACTS_COUNT, this.selectContactsCountCallBack);
    EventBus.getInstance().detach(EventBusNameConstant.SCROLL_NEW_MODE, this.scrollNewModeCallBack);
    EventBus.getInstance().detach(EventBusNameConstant.CONTACT_POLICY_REFRESH, this.policyChangeCallBack);
    EventBus.getInstance().detach(EventBusNameConstant.DB_CONTACT_DATA_REFRESH, this.onDbDataChange);
    EventBus.getInstance().detach(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onDbDataChange);
    EventBus.getInstance().detach(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onDbDataChange);
    EventBus.getInstance().detach(EventBusNameConstant.AGENT_MODIFY_CONTACT_POLICY_EVENT, this.policyChangeCallBack);
  }

  private refreshUi(result: ResourceStr): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: result } } as SettingResultState]]));
  }

  private isModeSupportCloudSync(modeId: string): boolean {
    LogUtil.showInfo(TAG, `current modeId is: ${modeId}`);
    return ModeConfigAdapter.getInstance().getConfigByModeId(modeId).isSupportCloudSync;
  }

  private initContactPolicy(): void {
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    if (this.isModeSupportCloudSync(modeId)) {
      AllowDisturbManager.getInstance().getContactPolicy(modeId).then((contactPolicy) => {
        LogUtil.showInfo(TAG, `contactPolicy: ${contactPolicy}`);
        this.updateStatus(contactPolicy);
      });
      return;
    }
    AllowDisturbManager.getInstance().getEl1ContactPolicy(modeId).then((contactPolicy) => {
      LogUtil.showInfo(TAG, `el1 contactPolicy: ${contactPolicy}`);
      this.updateStatus(contactPolicy);
    });
  }

  async updateStatus(contactPolicy: string): Promise<void> {
    LogUtil.showInfo(TAG, `updateStatus`);
    let contactPolicyValue: string = '';
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(TAG, `contactPolicy: ${contactPolicy}`);
    if (CONTACT_POLICY_MAP.has(contactPolicy)) {
      contactPolicyValue = CONTACT_POLICY_MAP.get(contactPolicy) as string;
      if (contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ||
        contactPolicy === ContactPolicy.FORBID_SPECIFIED_CONTACTS) {
        let focusModeList: string = contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ?
          ALLOW_SPECIFY_CONTACTS : FORBID_SPECIFY_CONTACTS;
        ContactAdapter.getInstance().getContactLength(modeId, focusModeList).then((res) => {
          this.contactLens = res;
          LogUtil.showInfo(TAG, `contacts len: ${this.contactLens}`);
          let resource: string = contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ?
            ALLOW_SELECT : FORBID_SELECT;
          let status: string = ResourceUtil.getPluralStringByNameSync(resource, this.contactLens);
          this.updateSelectContactShow(status);
        });
      } else {
        this.refreshUi(IncomingCallUtils.getInstance().setMenuTitle(contactPolicyValue));
      }
    }
  }

  updateSelectContactShow(status: string): void {
    LogUtil.showInfo(TAG, `updateSelectContactShow, contacts len: ${this.contactLens}`);
    if (this.contactLens === 0) {
      this.refreshUi($r('app.string.not_selected'));
    } else {
      this.refreshUi(status);
    }
  }
}


