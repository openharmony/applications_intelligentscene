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

import { ObservedData, UiExtensionViewModel } from '@ohos/scene.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { UiExtensionConstant } from '@ohos/scene.common/src/main/ets/constant/UiExtensionConstant';

/* instrument ignore file */
const TAG: string = 'IntelligentServiceComponent : ';

@Component
export struct IntelligentServiceComponent {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink(UiExtensionConstant.TITLE_ANIMATION_DURATION) titleAnimationDuration?: number = undefined;
  @State observedData: ObservedData = new ObservedData();
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private scrollerController: Scroller = new Scroller();

  @Builder
  buildContent(): void {
    UIExtensionComponent({
      bundleName: 'com.openharmony.ohos.aidataservice',
      abilityName: 'PersonalizationIntelligentAbility',
      parameters: {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
      }
    }, {
      dpiFollowStrategy: DpiFollowStrategy.FOLLOW_HOST_DPI
    })
      .defaultFocus(true)
      .onRemoteReady((proxy) => {
        LogUtil.showInfo(TAG, `onRemoteReady navigationMode: ${this.navigationMode}`);
        this.uiExtensionProxy = proxy;
        this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
      })
      .onError((error) => {
        LogUtil.showInfo(TAG, `UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
        this.viewModel.refreshing(error);
      })
      .onTerminated(()=>{
        this.uiExtensionProxy = undefined;
      })
      .onReceive((data) => {
        if (data?.action === 'pop') {
          LogUtil.showInfo(TAG, 'onReceive. pop');
          this.pathInfos?.pop();
        }
      })
      .size({ width: '100%', height: '100%' })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Scroll(this.scrollerController) {
          this.buildContent();
        }.clip(false)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }.layoutWeight(1)
    }
    .hideTitleBar(false)
    .title($r('app.string.intelligent_service_title'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .bindToScrollable([this.scrollerController])
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
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
    LogUtil.showInfo(TAG, 'aboutToAppear');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }
}
