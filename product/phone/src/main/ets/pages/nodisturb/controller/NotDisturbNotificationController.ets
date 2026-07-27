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

import notificationManager from '@ohos.notificationManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager,
} from '@ohos/scene.common/src/main/ets/bundle/BundleStatusChangeManager';
import { SessionUtil } from '@ohos/scene.common/src/main/ets/utils/SessionUtil';
import { AllowDisturbDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import { NotDisturbNotificationManager } from '../manager/NotDisturbNotificationManager';

/* instrument ignore file */
const TAG: string = 'NotDisturbNotificationController: ';

/**
 * 免打扰通知和实况菜单控制器
 */
export class NotDisturbNotificationController implements ComponentControl, BundleStatusChangeListener {
  private compId: string = '';
  private onAgentModifyCallback = (): void => {
    LogUtil.showInfo(TAG, 'onAgentModifyCallback');
    this.saveAndRefreshMenuText();
  };
  private onScrollNewModeCallback = (): void => {
    LogUtil.showInfo(TAG, 'onRefreshAllModeDetailCallback');
    this.saveAndRefreshMenuText();
  };
  private onModeDeleteCallBack = (modeId: string): void => {
    LogUtil.showInfo(TAG, `onModeDeleteCallBack: ${modeId}`);
    AllowDisturbDataManager.removeAllowDisturbAppList(modeId);
  };
  private onDbDataChange = (): void => {
    LogUtil.showInfo(TAG, 'onDbDataChange');
    this.saveAndRefreshMenuText();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, 'init');
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, 'init fail, comParam is invalid.');
      return;
    }
    this.compId = compParam.compId;
    EventBus.getInstance().on(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
    EventBus.getInstance().on(EventBusNameConstant.AGENT_MODIFY_NOTIFICATION_EVENT, this.onAgentModifyCallback);
    EventBus.getInstance().on(EventBusNameConstant.DIALOG_DELETE_MODE, this.onModeDeleteCallBack);
    EventBus.getInstance().on(EventBusNameConstant.DB_NOTIFICATION_DATA_REFRESH, this.onDbDataChange);
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this);
    this.saveAndRefreshMenuText();
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'destroy');
    EventBus.getInstance().detach(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
    EventBus.getInstance().detach(EventBusNameConstant.AGENT_MODIFY_NOTIFICATION_EVENT, this.onAgentModifyCallback);
    EventBus.getInstance().detach(EventBusNameConstant.DIALOG_DELETE_MODE, this.onModeDeleteCallBack);
    EventBus.getInstance().detach(EventBusNameConstant.DB_NOTIFICATION_DATA_REFRESH, this.onDbDataChange);
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this);
  }

  onClick(component: SettingBaseModel): void {
    LogUtil.showInfo(TAG, 'onClick');
    SessionUtil.sendLoadAppListToSetting();
  }

  private saveAndRefreshMenuText(): void {
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    AllowDisturbDataManager.getNotDisturbBundleOption(Number(modeId))
      .then((allowAppData: notificationManager.BundleOption []) => {
        this.refreshMenuText(modeId, allowAppData);
        NotDisturbNotificationManager.getInstance().setCurrentNotificationWhiteList(allowAppData);
      });
  }

  private async refreshMenuText(modeId: string, allowAppData: notificationManager.BundleOption []): Promise<void> {
    let bundles: notificationManager.BundleOption[] = [];
    try {
      bundles = await notificationManager.getAllNotificationEnabledBundles();
    } catch (error) {
      LogUtil.showError(TAG, `getAllNotificationEnabledBundle fail, error: ${error?.code} message: ${error?.message}`);
    }
    let trustAppListCount: number = 0;
    for (let item of allowAppData) {
      for (let bundlesElement of bundles) {
        if (item.uid === bundlesElement.uid && item.bundle === bundlesElement.bundle) {
          trustAppListCount++;
          continue;
        }
      }
    }
    let resultText: ResourceStr = '';
    LogUtil.showInfo(TAG, `queryTrustAppDataInfotrustAppListCount: modeId: ${modeId} ${trustAppListCount}`);
    if (trustAppListCount >= 1) {
      resultText = $r('app.plural.selected', trustAppListCount, trustAppListCount);
    } else {
      resultText = $r('app.string.not_selected');
    }
    this.notifyResultRefresh(resultText);
  }

  private notifyResultRefresh(resultText: ResourceStr): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: resultText }
        } as SettingResultState]]
      )
    );
  }

  getListenerName(): string {
    return TAG;
  }

  onBundleAdd(bundleName: string, userId: number, appIndex?: number): void {
  }

  onBundleUpdate(bundleName: string, userId: number, appIndex?: number): void {
  }

  onBundleRemove(bundleName: string, userId: number, appIndex?: number): void {
    this.saveAndRefreshMenuText();
  }
}