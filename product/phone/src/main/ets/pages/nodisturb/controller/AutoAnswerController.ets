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

import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import {
  ItemResultType,
  SettingItemModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import {
  NOT_DISTURB_VALUE_DISABLE,
  NOT_DISTURB_VALUE_ENABLE
} from '@ohos/scene.notdisturb/src/main/ets/utils/NotDisturbUtils';
import { NotDisturbAdapter } from '@ohos/scene.notdisturb/src/main/ets/adapter/NotiDisturbAdapter';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import {
  notifyCompStateChange,
  SettingDialogState,
  SettingResultState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { PageRouter } from '@ohos/scene.common/src/main/ets/framework/common/PageRouter';
import { CallAssistantKey, NavEntryKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { PrivacyStatementUtil } from '@ohos/scene.common/src/main/ets/utils/PrivacyStatementUtil';
import { EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';

/* instrument ignore file */
const TAG: string = 'AutoAnswerController: ';
const AUTO_ANSWER_ENABLE: string = 'true';
const AUTO_ANSWER_DISABLE: string = 'false';

/**
 * 自动接听控制器
 */
export class AutoAnswerController implements ComponentControl {
  private isToggleOpened: boolean = false;
  private isAutoAnswerPrivacyAgree: boolean = true;
  private openedMode: string = '';

  private onConfigDataChange = (): void => {
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    this.isToggleOpened = this.getToggleState();
    LogUtil.showInfo(TAG, `onConfigDataChange ${modeId} isOpen: ${this.isToggleOpened}`);

    this.isAutoAnswerPrivacyAgree = PrivacyStatementUtil.isAutoAnswerAgreed();
    if (!this.isAutoAnswerPrivacyAgree && this.isToggleOpened) {
      LogUtil.showError(TAG, 'not agree privacy statement, switch displayed as closed.');
      return;
    }
    this.refreshToggleState(this.isToggleOpened);
    this.setAutoSettingsData(this.isToggleOpened);
  };

  private onPrivacyAgreeChange = (): void => {
    LogUtil.showInfo(TAG, 'onPrivacyAgreeChange');
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    AllowDisturbManager.getInstance().getAutoAnswerState(modeId).then((isChecked) => {
      this.setAutoSettingsData(isChecked);
    });
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, 'init fail, compParam is invalid');
      return;
    }

    EventBus.getInstance().on(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onConfigDataChange);
    EventBus.getInstance().on(EventBusNameConstant.AGENT_MODIFY_AUTO_ANSWER_EVENT, this.onConfigDataChange);
    SettingsDataUtils.registerKeyObserver(SettingsDataKeyConstant.AUTO_ANSWER_PRIVACY_IS_AGREE,
      this.onPrivacyAgreeChange);
  }

  onPageShow(): void {
    this.isAutoAnswerPrivacyAgree = PrivacyStatementUtil.isAutoAnswerAgreed();
    LogUtil.showInfo(TAG, `onPageShow isAutoAnswerPrivacyAgree ${this.isAutoAnswerPrivacyAgree}`);
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const modeOpenState: ModeState = ModeUtil.getModeOpenState();
    this.openedMode = modeOpenState.modeId;
    if (modeOpenState.isOpened && modeId === this.openedMode) {
      // 当模式开启时，以settings data数据为准
      const isAutoAnswerEnable: boolean =
        SettingsDataUtils.getSystemValue(SettingsDataKeyConstant.AUTOMATIC_ANSWERING_ENABLE,
          NOT_DISTURB_VALUE_DISABLE) === NOT_DISTURB_VALUE_ENABLE;
      LogUtil.showInfo(TAG, `current mode is open, isAutoAnswerEnable: ${isAutoAnswerEnable}`);
      this.refreshToggleState(this.isAutoAnswerPrivacyAgree && isAutoAnswerEnable);
    } else {
      this.isToggleOpened = this.getToggleState();
      this.refreshToggleState(this.isAutoAnswerPrivacyAgree && this.isToggleOpened);
    }
  }

  onToggleChanged(isOn: boolean): void {
    this.isToggleOpened = this.getToggleState();
    LogUtil.showInfo(TAG, `onToggleChange. oldIsOn:${this.isToggleOpened} isOn:${isOn}`);
    if (this.isToggleOpened === isOn) {
      return;
    }

    this.isToggleOpened = isOn;
    this.isAutoAnswerPrivacyAgree = PrivacyStatementUtil.isAutoAnswerAgreed();
    if (this.isAutoAnswerPrivacyAgree) {
      this.saveAutoAnswerStateToRdb(isOn);
    }
    this.setAutoSettingsData(this.isAutoAnswerPrivacyAgree && isOn);
  }

  onToggleAllowChanged(isOn: boolean): boolean {
    LogUtil.showInfo(TAG, `onToggleAllowChanged. isOn:${isOn}`);
    if (!isOn) {
      return true;
    }
    this.isAutoAnswerPrivacyAgree = PrivacyStatementUtil.isAutoAnswerAgreed();
    if (this.isAutoAnswerPrivacyAgree) {
      return true;
    }
    this.openAuthDialog();
    return false;
  }

  private refreshToggleState(isOpen: boolean): void {
    notifyCompStateChange('IntelligentScene.IncomingCall.automatic_answering_group.automatic_answering',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: isOpen } } as SettingResultState]]));
  }

  private getToggleState(): boolean {
    const parsedConfigArr =
      ModeDetailAdapter.getInstance().getParsedConfigDataByType([ConfigType.CALL_INTELLIGENT_ANSWER_SWITCH]);
    const parsedValue = parsedConfigArr[0]?.parsedValue as EnableState;
    return parsedValue?.enable ?? false;
  }

  private setAutoSettingsData(isChecked: boolean) {
    const modeOpenState: ModeState = ModeUtil.getModeOpenState();
    this.openedMode = modeOpenState.modeId;
    const displayModeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    if (ModeUtil.isCurrentModeOpened(displayModeId, modeOpenState)) {
      LogUtil.showInfo(TAG, `setAutoSettingsData: isChecked: ${isChecked}`);
      SettingsDataUtils.setSystemValue(SettingsDataKeyConstant.AUTOMATIC_ANSWERING_ENABLE,
        isChecked ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE);
      if (isChecked) {
        SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.AUTO_ANSWER_IS_ON, AUTO_ANSWER_ENABLE);
      } else if (!IncomingCallUtils.isAutoAnswerOpen(isChecked)) {
        // 四个开关都关的时候，总开关关闭
        LogUtil.showInfo(TAG, 'set auto_answer_ison false.');
        SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.AUTO_ANSWER_IS_ON, AUTO_ANSWER_DISABLE);
      }
    }
  }

  destroy(): void {
    EventBus.getInstance().detach(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onConfigDataChange);
    EventBus.getInstance().detach(EventBusNameConstant.AGENT_MODIFY_AUTO_ANSWER_EVENT, this.onConfigDataChange);
    SettingsDataUtils.unregisterKeyObserver(SettingsDataKeyConstant.AUTO_ANSWER_PRIVACY_IS_AGREE);
  }

  protected saveAutoAnswerStateToRdb(isChecked: boolean): void {
    LogUtil.showInfo(TAG, `saveAutoAnswerStateToRdb ${isChecked}`);
    let modeId = ModeDetailAdapter.getInstance().getCurrentModeId();
    NotDisturbAdapter.getInstance().updateAutoAnswerState(modeId, isChecked);
  }

  private openAuthDialog(): void {
    notifyCompStateChange('IntelligentScene.IncomingCall.automatic_answering_group.automatic_answering', new Map([
      [SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        message: ResourceUtil.getStringSync($r('app.string.intelligent_helpConnect_authorize_hint')),
        buttons: [
          {
            value: $r('app.string.back'),
            action: async (component: SettingItemModel) => {
              LogUtil.showInfo(TAG, 'onClick back');
            },
          },
          {
            value: $r('app.string.open'),
            action: (component: SettingItemModel) => {
            },
          },
        ],
        style: {
          autoCancel: true,
          contentStyle: {
            fontWeight: FontWeight.Medium
          }
        },
        isShowInSubWindow: true
      } as SettingDialogState]
    ]));
  }
}