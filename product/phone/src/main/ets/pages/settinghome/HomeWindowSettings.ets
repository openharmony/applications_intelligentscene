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

import dataShare from '@ohos.data.dataShare';
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit';
import { NavEntryKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { DefaultPageConfig } from '@ohos/scene.common/src/main/ets/framework/common/DefaultPageConfig';
import { PageConfig, ScreenType } from '@ohos/scene.common/src/main/ets/framework/common/PageConfig';
import { PageParams } from '@ohos/scene.common/src/main/ets/framework/common/PageLoader';
import { PageRouter, PushParam } from '@ohos/scene.common/src/main/ets/framework/common/PageRouter';
import { settingPageBuilder } from '@ohos/scene.common/src/main/ets/framework/view/SettingPage';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { TraceConstant } from '@ohos/scene.common/src/main/ets/constant/TraceConstant';
import { TraceUtil } from '@ohos/scene.common/src/main/ets/utils/TraceUtil';
import lazy { locationGuide } from '@ohos/scene.common/src/main/ets/basecomponent/dialog/LocationCheckDialog';
import { PrivacyStatementUtil } from '@ohos/scene.common/src/main/ets/utils/PrivacyStatementUtil';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import lazy { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import { ContactAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ContactAdapter';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { PageStartReason } from '@ohos/scene.common/src/main/ets/constant/UiExtensionConstant';
import { UiExtensionConstant } from '@ohos/scene.common/src/main/ets/constant/UiExtensionConstant';
import { PageRouteController } from './controller/PageRouteController';
import { HomePageComponent } from './view/HomePageComponent';
import { REDIRECT_WHITE_LIST, OPEN_LOCATION_DIALOG_DELAY } from './constant/HomeConstant';

const TAG: string = 'HomeWindowSettings : ';

@Entry
@Component
struct HomeWindowSettings {
  private dataHelper?: dataShare.DataShareHelper;
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @StorageLink('navigationMode') navMode: NavigationMode =
    AppStorage.get(UiExtensionConstant.NAVIGATION_MODE) ?? NavigationMode.Stack;
  @StorageLink('startReason') startReason: string =
    AppStorage.get(UiExtensionConstant.START_REASON) ?? PageStartReason.DEFAULT;
  private settingsWindowStatusChange = () => {
    let windowStatus: string = SettingsDataUtils.getSettingsData(SettingsDataKeyConstant.SETTINGS_WINDOW_MODE, '');
    LogUtil.showInfo(TAG, `settingsWindowStatusChange ${windowStatus}`);
    EventBus.getInstance().emit(EventBusNameConstant.SETTINGS_WINDOW_STATUS_CHANGE, windowStatus);
  };

  @Builder
  pageBuilder(param: PageParams): void {
    if (param && param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(param);
    }
  }

  @Builder
  myRouter(name: string, param?: Object) {
    if (name === NavEntryKey.INTELLIGENT_SCENE_HOME_ENTRY) {
      HomePageComponent();
    } else {
      this.pageBuilder(param as PageParams);
    }
  }

  build() {
    Navigation(this.pathInfos) {
    }
    .navDestination(this.myRouter)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideNavBar(this.navMode === NavigationMode.Split || this.startReason === PageStartReason.FROM_STABILITY)
    // 允许子页面背景扩展到系统状态栏区域，配合首页沉浸式渐变
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  aboutToAppear(): void {
    TraceUtil.start(TraceConstant.HOME_PAGE_ABOUT_TO_APPEAR);
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.initDefaultScene();
    this.pageRouterInit();
    this.initShowPage();
    this.registerWindowStatusListener();
    this.openLocationRequestDialogIfNeed();
    TraceUtil.end(TraceConstant.HOME_PAGE_ABOUT_TO_APPEAR);
  }

  private initShowPage(): void {
    const url: string = AppStorage.get<string>(UiExtensionConstant.NAVIGATION_URL) || NavEntryKey.INTELLIGENT_SCENE_HOME_ENTRY;
    const isRedirect: boolean = url !== NavEntryKey.INTELLIGENT_SCENE_HOME_ENTRY && REDIRECT_WHITE_LIST.includes(url);
    const isEntry: boolean = this.startReason === PageStartReason.FROM_EXTERNAL;
    this.pathInfos.pushPath({ name: NavEntryKey.INTELLIGENT_SCENE_HOME_ENTRY, isEntry: isEntry }, true);
    if (isRedirect) {
      let params: PushParam = new PushParam();
      params.startReason = this.startReason;
      PageRouter.push(url, params, false, true, false, false);
    }
  }

  private async openLocationRequestDialogIfNeed(): Promise<void> {
    if (PrivacyStatementUtil.isIntelligentExperienceAgreed()) {
      setTimeout(() => {
        locationGuide(() => {});
      }, OPEN_LOCATION_DIALOG_DELAY);
    }
  }

  private initDefaultScene(): void {
    ModeAdapter.getInstance().initData();
    ContactAdapter.getInstance().init();
    StateManager.getInstance().init();
    // 初始化生效当前模式的关联配置项状态机
    const currentScene: string = StateManager.getInstance().getCurrentScene();
    // 初始化生效当前模式的关联配置项状态机
    SettingLinkageManager.getInstance().init(currentScene);
  }

  private registerWindowStatusListener(): void {
    SettingsDataUtils.registerKeyObserver(SettingsDataKeyConstant.SETTINGS_WINDOW_MODE,
      this.settingsWindowStatusChange);
  }

  private unRegisterWindowStatusListener(): void {
    SettingsDataUtils.unregisterKeyObserver(SettingsDataKeyConstant.SETTINGS_WINDOW_MODE);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    ModeAdapter.getInstance().detach();
    ModeDetailAdapter.getInstance().detach();
    this.unRegisterWindowStatusListener();
    if (this.dataHelper) {
      SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper, SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE);
    }
    SettingLinkageManager.getInstance().deInit();
    StateManager.getInstance().deInit();
  }

  onPageShow(): void {
    LogUtil.showInfo(TAG, 'onPageShow');
  }

  onPageHide(): void {
    LogUtil.showInfo(TAG, 'onPageHide');
  }

  pageRouterInit(): void {
    PageConfig.getInstance().setPageConfigGlobal({
      defaultPageConfig: DefaultPageConfig.getInstance(),
      defaultPageBuilder: wrapBuilder(settingPageBuilder),
      screenType: ScreenType.SCREEN_TYPE_SMALL,
      navMode: NavigationMode.Auto
    });
    PageRouter.createRouter('IntelligentScene', {
      rootDir: '../../',
      loader: async (entry: string, type?: number): Promise<void> => {
        let path: string = PageRouteController.getInstance().getPageUrl(entry) as string;
        if (type) {
          path = PageRouteController.getInstance().getModalPageUrl(entry) as string;
        }
        LogUtil.showInfo(TAG, `import page ${entry} start`);
        await import(path);
        LogUtil.showInfo(TAG, `import page ${entry} end`);
      },
      path: this.pathInfos,
      isHomeEntryPage: (url: string): boolean => {
        return false;
      }
    });
  }
}