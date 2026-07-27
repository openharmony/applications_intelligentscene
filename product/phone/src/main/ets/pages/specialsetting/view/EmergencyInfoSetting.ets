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

import common from '@ohos.app.ability.common';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ObservedData, UiExtensionViewModel } from '@ohos/scene.common/src/main/ets/viewmodel/UiExtensionViewModel';

/* instrument ignore file */
const TAG: string = 'EmergencyInfoSetting:';

/**
 * 紧急联系人界面
 */
@Component
export struct EmergencyInfoSetting {
  uiExtensionProxy?: UIExtensionProxy;
  isFromExternal: boolean = false;
  private firstNavigationMode: NavigationMode = NavigationMode.Stack;
  private context = getContext(this) as common.UIAbilityContext;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State observedData: ObservedData = new ObservedData();
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: 'com.openharmony.ohos.emergencycommunication',
        abilityName: 'com.openharmony.ohos.emergencycommunication.EmergencyInfoUIExtAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'navigationMode': this.firstNavigationMode,
          'reconnect': this.observedData.reconnect,
        }
      }, {
        dpiFollowStrategy: DpiFollowStrategy.FOLLOW_HOST_DPI
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          LogUtil.showInfo(TAG, `onRemoteReady navigationMode: ${this.navigationMode}`);
          this.uiExtensionProxy = proxy;
          this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
          this.uiExtensionProxy?.on('syncReceiverRegister', () => {
            this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
          });
        })
        .onError((error) => {
          LogUtil.showInfo(TAG, `onError. code:${error?.code} message:${error?.message}`);
          this.viewModel.refreshing(error);
        })
        .onTerminated(() => {
          LogUtil.showInfo(TAG, 'onTerminated.');
          this.pathInfos.pop();
        })
        .onReceive((data) => {
          if (data?.action === 'pop') {
            LogUtil.showInfo(TAG, 'onReceive. pop');
            this.pathInfos.pop();
          }
          if (data?.action === 'jump' && data?.uri) {
            LogUtil.showInfo(TAG, 'onReceive. jump');
            try {
              LocalStorage.getShared()?.get<UIExtensionContentSession>('ExtensionContentSession')?.sendData({
                'action': 'jump',
                'uri': data.uri,
              });
            } catch (err) {
              LogUtil.showError(TAG, `onReceive sendData. code:${err?.code} message:${err?.message}`);
            }
            return;
          }
        })
        .size({
          width: '100%',
          height: '100%',
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onBackPressed(() => {
      if (this.isFromExternal) {
        LogUtil.showInfo(TAG, 'onBackPressed');
        this.termiteAbility();
        return true;
      }
      return false;
    })
    .onShown(() => {
      LogUtil.showInfo(TAG, 'onShown');
    })
  }

  onNavigationModeChange(): void {
    LogUtil.showInfo(TAG, `onNavigationModeChange navigationMode: ${this.navigationMode}`);
    this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
  }

  aboutToAppear(): void {
    this.firstNavigationMode = this.navigationMode;
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    if (this.uiExtensionProxy) {
      this.uiExtensionProxy.off('syncReceiverRegister');
    }
    if (this.isFromExternal) {
      LogUtil.showInfo(TAG, 'from external, termite ability');
      this.termiteAbility();
    }
  }

  private termiteAbility(): void {
    try {
      this.context.terminateSelf();
      LogUtil.showInfo(TAG, 'termiteAbility. success');
    } catch (e) {
      LogUtil.showError(TAG, `termiteAbility. code:${e?.code} msg:${e?.message}`);
    }
  }
}