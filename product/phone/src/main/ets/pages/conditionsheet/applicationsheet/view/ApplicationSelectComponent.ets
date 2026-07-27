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
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { SessionUtil } from '@ohos/scene.common/src/main/ets/utils/SessionUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { AppCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import TriggerConditionManager from '@ohos/scene.configmanage/src/main/ets/manager/TriggerConditionManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ObservedData, UiExtensionViewModel } from '@ohos/scene.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { ApplicationManager } from '../manager/ApplicationManager';
import { AccessibilityFocusUtil } from '../../../settinghome/utils/AccessibilityFocusUtil';
import { SettingsConstant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';

/* instrument ignore file */
const TAG: string = 'ApplicationSelectComponent: ';
const BUNDLE_NAME: string = SettingsConstant.SETTINGS_BUNDLE_NAME;
const ABILITY_NAME: string = 'IntelligentSceneAppSelectExtensionAbility';
const APP_LIST_TYPE: number = 0;

@Component
export struct ApplicationSelectComponent {
  uiExtensionProxy?: UIExtensionProxy;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private appListLoadComplete = () => {
    LogUtil.showInfo(TAG, 'app list load complete');
    const intent: Record<string, Object> = { 'action': EventBusNameConstant.APP_LIST_LOAD_COMPLETE };
    this.uiExtensionProxy?.send(intent);
  }

  build() {
    UIExtensionComponent({
      bundleName: BUNDLE_NAME,
      abilityName: ABILITY_NAME,
      parameters: {
        'appListType': APP_LIST_TYPE,
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'isAdd': ApplicationManager.getInstance().isAdd,
        'enabled': ApplicationManager.getInstance().getInfo().enable,
        'reconnect': this.observedData.reconnect,
      }
    })
      .onRemoteReady((proxy) => {
        LogUtil.showInfo(TAG, 'UIExtensionComponent onRemoteReady.');
        this.uiExtensionProxy = proxy;
      })
      .onError((error) => {
        LogUtil.showInfo(TAG, `UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
        this.viewModel.refreshing(error);
      })
      .onTerminated(() => {
      })
      .onReceive((data) => {
        LogUtil.showInfo(TAG, 'UIExtensionComponent onReceive.');
        if (!data) {
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
    EventBus.getInstance().on(EventBusNameConstant.APP_LIST_LOAD_COMPLETE, this.appListLoadComplete);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    AccessibilityFocusUtil.requestFocusAddConditionButton();
    EventBus.getInstance().detach(EventBusNameConstant.APP_LIST_LOAD_COMPLETE, this.appListLoadComplete);
  }

  private async sendData(): Promise<void> {
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    let allModeData: ModeData[] = await El1ModeDataManager.getInstance().queryAllModeData();
    let appConditions: AppCondition[] = await TriggerConditionManager.getConditionsByModeIdAndConfigType(modeId,
      ConfigType.TRIGGER_CONDITION_APP) as AppCondition[];
    let otherAppBundleNames: string[] = [];
    for (let modeData of allModeData) {
      if (modeData.modeId === modeId) {
        continue;
      }
      let appConditions: AppCondition[] =
        await TriggerConditionManager.getConditionsByModeIdAndConfigType(modeData.modeId,
          ConfigType.TRIGGER_CONDITION_APP) as AppCondition[];
      if (appConditions?.length <= 0) {
        continue;
      }
      let bundleNames: string[] = appConditions[0].appConditionList.map(condition => {
        return condition.bundleName;
      });
      otherAppBundleNames.push(...bundleNames);
    }
    if (this.uiExtensionProxy) {
      this.uiExtensionProxy.send({
        appCondition: appConditions.length === 0 ? '' : JsonUtil.stringify(appConditions[0]),
        otherAppBundleNames: otherAppBundleNames.length === 0 ? '' : JsonUtil.stringify(otherAppBundleNames),
      })
    }
  }

  private closeSheetPage(): void {
    notifyCompStateChange('home_standard_page.modal_group.application_sheet',
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState]
      ])
    );
  }

  private async dealReceivedData(data: Record<string, Object>): Promise<void> {
    if (data['action'] === 'pageReady') {
      LogUtil.showInfo(TAG, 'send page ready message.');
      this.sendData();
      return;
    }
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
      let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
      let conditions: AppCondition[] = await TriggerConditionManager.getConditionsByModeIdAndConfigType(modeId,
        ConfigType.TRIGGER_CONDITION_APP) as AppCondition[];
      LogUtil.showInfo(TAG, `modeId is ${modeId}, conditions length is ${conditions.length}`);
      try {
        let selectData: string = data['selectData'] as string;
        let newAppCondition: AppCondition = JSON.parse(selectData) as AppCondition;
        newAppCondition.configType = ConfigType.TRIGGER_CONDITION_APP;
      } catch (error) {
        LogUtil.showError(TAG, `json parse failed, error.message: ${error?.message}`);
      }
    }
  }
}