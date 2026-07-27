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

import uiAppearance from '@ohos.uiAppearance';
import common from '@ohos.app.ability.common';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { AccessibilityUtils } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { AppStorageKey } from '@ohos/scene.common/src/main/ets/constant/AppStorageConsts';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { AbilityUtils, SettingsConstant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { ActivationManager } from '@ohos/scene.activationmanage/src/main/ets/manager/ActivationManager';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { SettingLinkageManager } from '@ohos/scene.configlinkage/src/main/ets/manager/SettingLinkageManager';
import { TitleBarComponent, TITLE_ID } from './view/TitleBarComponent';
import { ModeListComponent } from './view/ModeListComponent';
import { BottomButtonComponent } from './view/BottomButtonComponent';

/* instrument ignore file */
const TAG: string = 'ControlCenterPage:';

/**
 * 控制中心二级页面
 */
@Entry
@Component
struct ControlCenterPage {
  private session = this.getUIContext().getSharedLocalStorage()?.get<UIExtensionContentSession>('UIExtensionContentSession');
  private isShowAsDarkMode: boolean = AppStorage.get<boolean>(AppStorageKey.IS_SHOW_AS_DARK_MODE) === true;
  @State isDarkMode: boolean =
    AppStorage.get<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE) === uiAppearance.DarkMode.ALWAYS_DARK ||
      this.isShowAsDarkMode;
  // 新折叠态产品外屏显示标记位
  isPocketExternalDisplayMode: boolean = DeviceUtil.isPocketExternalDisplayMode();
  /**
   * 深浅色模式切换事件
   */
  private onDarkLightModeCallback = (colorMode: uiAppearance.DarkMode): void => {
    const isDarkMode = colorMode === uiAppearance.DarkMode.ALWAYS_DARK;
    LogUtil.showInfo(TAG, `onDarkLightModeCallback. isDarkMode:${isDarkMode}, isShowAsDarkMode: ${this.isShowAsDarkMode}`);
    this.isDarkMode = isDarkMode || this.isShowAsDarkMode;
  };

  build() {
    Column() {
      // 标题栏
      TitleBarComponent({
        isDarkMode: this.isDarkMode,
        symbolCode: 'person_crop_circle_dashed',
        title: $r('app.string.intelligent_scene'),
        isPocketExternalDisplayMode: this.isPocketExternalDisplayMode
      })
      // 模式列表
      ModeListComponent({
        isDarkMode: this.isDarkMode,
        isPocketExternalDisplayMode: this.isPocketExternalDisplayMode
      })
      // 更多设置
      if (!this.isPocketExternalDisplayMode) {
        BottomButtonComponent({
          isDarkMode: this.isDarkMode,
          onButtonClick: () => {
            this.jumpSettings();
          },
        })
      }
    }
    .size({
      width: '100%',
      height: '100%',
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear. isDarkMode:${this.isDarkMode} isPocketExternalDisplayMode:${this.isPocketExternalDisplayMode}`);
    StateManager.getInstance().init();
    // 初始化生效当前模式的关联配置项状态机
    const currentScene: string = StateManager.getInstance().getCurrentScene();
    // 初始化生效当前模式的关联配置项状态机
    SettingLinkageManager.getInstance().init(currentScene);
    EventBus.getInstance().on(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, this.onDarkLightModeCallback);
    ActivationManager.getInstance().connect();
  }

  onPageShow(): void {
    LogUtil.showInfo(TAG, 'onPageShow');
    AccessibilityUtils.requestFocusAccessibility(TITLE_ID);
  }

  onPageHide(): void {
    LogUtil.showInfo(TAG, 'onPageHide');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    ActivationManager.getInstance().disConnect();
    EventBus.getInstance().detach(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, this.onDarkLightModeCallback);
    SettingLinkageManager.getInstance().deInit();
    StateManager.getInstance().deInit();
  }

  /**
   * 跳转设置
   */
  jumpSettings(): void {
    LogUtil.showInfo(TAG, 'jumpSettings');
    // 这里不能从AbilityContextManager拿 可能会变成设置情景模式的context
    const uiExtContext = this.getUIContext().getHostContext() as common.UIExtensionContext;
    AbilityUtils.startAbility(uiExtContext, {
      bundleName: SettingsConstant.SETTINGS_BUNDLE_NAME,
      abilityName: SettingsConstant.SETTINGS_MAIN_ABILITY_NAME,
      uri: 'intelligent_scene_entry',
      parameters: {}
    }, () => {
      LogUtil.showInfo(TAG, 'jumpSettings. hideControlCenter');
      try {
        this.session?.sendData({ 'method': 'hideControlCenter' });
      } catch (err) {
        LogUtil.showError(TAG, `send data occurs error: ${err?.code}, ${err?.message}`);
      }
    });
  }
}