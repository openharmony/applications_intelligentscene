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
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ObservedData, UiExtensionViewModel } from '@ohos/scene.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { BaseModeConfig } from '@ohos/scene.modeconfig/src/main/ets/adapter/BaseModeConfig';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';

/* instrument ignore file */
const TAG: string = 'SpecialSetting : ';

/**
 * 特殊配置界面
 */
@Component
export struct SpecialSetting {
  uiExtensionProxy?: UIExtensionProxy;
  isFromExternal: boolean = false;
  private firstNavigationMode: NavigationMode = NavigationMode.Stack;
  private context = getContext(this) as common.UIAbilityContext;
  private bundleName: string = '';
  private abilityName: string = '';
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State observedData: ObservedData = new ObservedData();
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: this.bundleName,
        abilityName: this.abilityName,
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
          LogUtil.showInfo(TAG, `UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error);
        })
        .onTerminated(() => {
        })
        .onReceive((data) => {
          if (data?.action === 'pop') {
            LogUtil.showInfo(TAG, 'onReceive. pop');
            this.pathInfos.pop();
          }
          if (data?.restoreApps) {
            const restoreBundleNames: string[] = data?.restoreApps as string[];
            LogUtil.showInfo(TAG, `onReceive. restore. restoreBundleNames:${restoreBundleNames}`);
          }
        })
        .size({ width: '100%', height: '100%' })
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
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const modeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(modeId);
    this.bundleName = modeConfig.getSpecialSettingConfig()?.bundleName ?? '';
    this.abilityName = modeConfig.getSpecialSettingConfig()?.abilityName ?? '';
    LogUtil.showInfo(TAG, `aboutToAppear, modeId is ${modeId}, bundle is ${this.bundleName} ability is ${this.abilityName}`);
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