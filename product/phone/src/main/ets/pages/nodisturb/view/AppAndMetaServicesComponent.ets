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
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { SessionUtil } from '@ohos/scene.common/src/main/ets/utils/SessionUtil';
import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingResultState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import {
  HOME_PAGE_ID,
  HomeGroupId,
  HomeGroupItemId,
} from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { AppData } from '@ohos/scene.datamanage/src/main/ets/model/AppData';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ItemResultType } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { AllowDisturbDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { ObservedData, UiExtensionViewModel } from '@ohos/scene.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { NotDisturbNotificationManager } from '../manager/NotDisturbNotificationManager';
import { SettingsConstant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';

/* instrument ignore file */
const TAG: string = 'AppAndMetaServicesComponent: ';
const BUNDLE_NAME: string = SettingsConstant.SETTINGS_BUNDLE_NAME;
const ABILITY_NAME: string = 'IntelligentSceneAppSelectExtensionAbility';
const APP_META_SERVICE_TYPE: number = 1;

@Component
export struct AppAndMetaServicesComponent {
  uiExtensionProxy?: UIExtensionProxy;
  private hasSetNotificationWhiteList: boolean = false;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private appListLoadComplete = () => {
    LogUtil.showInfo(TAG, 'appListLoadComplete');
    const intent: Record<string, Object> = { 'action': EventBusNameConstant.APP_LIST_LOAD_COMPLETE };
    this.uiExtensionProxy?.send(intent);
  }

  build() {
    UIExtensionComponent({
      bundleName: BUNDLE_NAME,
      abilityName: ABILITY_NAME,
      parameters: {
        'appListType': APP_META_SERVICE_TYPE,
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'hasSetWhiteList': this.hasSetNotificationWhiteList,
        'notificationWhiteList': this.hasSetNotificationWhiteList ?
        JsonUtil.stringify(NotDisturbNotificationManager.getInstance().getCurrentNotificationWhiteList()) : undefined,
        'reconnect': this.observedData.reconnect,
      }
    })
      .onRemoteReady((proxy) => {
        LogUtil.showInfo(TAG, 'UIExtensionComponent onRemoteReady.');
        this.uiExtensionProxy = proxy;
      })
      .onError((error) => {
        LogUtil.showError(TAG, `UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
        this.viewModel.refreshing(error);
      })
      .onTerminated(() => {
      })
      .onReceive((data) => {
        LogUtil.showInfo(TAG, 'UIExtensionComponent onReceive.');
        if (!data) {
          LogUtil.showError(TAG, 'onReceive error');
          return;
        }
        this.dealReceivedData(data);
      })
      .onTouchIntercept((event: TouchEvent) => {
        return HitTestMode.Block;
      })
      .backgroundColor($r('app.color.component_ultra_thick_panel'))
      .backgroundBlurStyle(BlurStyle.NONE)
      .size({ width: '100%', height: '100%' })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.hasSetNotificationWhiteList = NotDisturbNotificationManager.getInstance().hasSetNotificationWhiteList()
    EventBus.getInstance().on(EventBusNameConstant.APP_LIST_LOAD_COMPLETE, this.appListLoadComplete);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    EventBus.getInstance().detach(EventBusNameConstant.APP_LIST_LOAD_COMPLETE, this.appListLoadComplete);
  }

  private closeSheetPage(): void {
    notifyCompStateChange(`${HOME_PAGE_ID}.${HomeGroupId.ALLOWED_DISTURB}.${HomeGroupItemId.APPLICATION}`,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState]
      ])
    );
  }

  private async dealReceivedData(data: Record<string, Object>): Promise<void> {
    // 收到关闭半模态消息
    let isCloseSheet: boolean = data['action'] === 'closeSheet';
    if (isCloseSheet) {
      LogUtil.showInfo(TAG, 'close sheet page');
      this.closeSheetPage();
    }
    if (data['action'] === 'getLoadState') {
      LogUtil.showInfo(TAG, 'getLoadState');
      SessionUtil.sendLoadStateToSetting(this.uiExtensionProxy);
      return;
    }
    if (isCloseSheet && data['isFinishEdit']) {
      try {
        let selectData: string = data['selectData'] as string;
        let newData: AppData[] = JSON.parse(selectData) as AppData[];
        this.refreshMenuText(newData);
        let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
        await AllowDisturbManager.getInstance().updateAllowNotificationList({
          selectedAppList: newData,
        }, modeId);
        await AllowDisturbDataManager.setAllowDisturbAppList(modeId);
        let notificationWhiteList: notificationManager.BundleOption[] = [];
        newData.forEach((item) => {
          notificationWhiteList.push({
            bundle: item.bundleName,
            uid: item.uid,
          });
        })
        NotDisturbNotificationManager.getInstance().setCurrentNotificationWhiteList(notificationWhiteList);
        AllowDisturbDataManager.setSoundAndVibrationWhiteListAsNeeded(modeId);
      } catch (error) {
        LogUtil.showError(TAG, `json parse failed, error.message: ${error?.message}`);
      }
    }
  }

  private refreshMenuText(newData: AppData[]): void {
    let resultText: ResourceStr = '';
    if (newData.length >= 1) {
      resultText = $r('app.plural.selected', newData.length, newData.length);
    } else {
      resultText = $r('app.string.not_selected');
    }
    notifyCompStateChange(`${HOME_PAGE_ID}.${HomeGroupId.ALLOWED_DISTURB}.${HomeGroupItemId.APPLICATION}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: resultText }
        } as SettingResultState]]
      )
    );
  }
}