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

import lazy taskpool from '@ohos.taskpool';
import Want from '@ohos.app.ability.Want';
import { uiExtension, window } from '@kit.ArkUI';
import lazy workScheduler from '@ohos.resourceschedule.workScheduler';
import uiAppearance from '@ohos.uiAppearance';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/scene.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { AppStorageKey } from '@ohos/scene.common/src/main/ets/constant/AppStorageConsts';
import { PageStartReason, UiExtensionConstant } from '@ohos/scene.common/src/main/ets/constant/UiExtensionConstant';
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

/* instrument ignore file */
const INVALID_CALLBACK_ID: number = -1;

const TAG: string = 'IntelligentSceneUIExtSettingAbility :';

@Concurrent
function startWork(): void {
  const TAG: string = 'IntelligentSceneUIExtSettingAbility:';
  const SEVEN_DAY_IN_MILLIS: number = 7 * 24 * 60 * 60 * 1000;
  const workInfo: workScheduler.WorkInfo = {
    workId: 1,
    bundleName: 'com.ohos.intelligentscene',
    abilityName: 'SceneStatusReportSchedulerExtensionAbility',
    isRepeat: true,
    repeatCycleTime: SEVEN_DAY_IN_MILLIS,
  }
  try {
    workScheduler.startWork(workInfo);
    LogUtil.showInfo(TAG, 'statusReportWorker success');
  } catch (error) {
    LogUtil.showError(TAG, `statusReportWorker failed. code:${error?.code} message:${error?.message}`);
  }
}

/**
 * 设置二级页面入口
 */
export default class IntelligentSceneUIExtSettingAbility extends UIExtensionAbility {
  private storage: LocalStorage = new LocalStorage();
  private environmentCallbackId: number = INVALID_CALLBACK_ID;
  private extensionWindow?: uiExtension.WindowProxy;
  /**
   * 将当前所在二级界面uri传给设置
   */
  private pageRouterSettings = (subPageEntryKey: string): void => {
    LogUtil.showInfo(TAG, `pageRouterSettings subPageEntryKey: ${subPageEntryKey}`);
    const intent: Record<string, Object> = { 'sub_page_entry_key': subPageEntryKey };
    try {
      LocalStorage.getShared()?.get<UIExtensionContentSession>('ExtensionContentSession')?.sendData(intent);
    } catch (error) {
      LogUtil.showError(TAG, `send sub_page_entry_key error: ${error?.code}, ${error?.message}`);
    }
  };

  async onCreate(): Promise<void> {
    LogUtil.showInfo(TAG, 'onCreate.');
    AbilityContextManager.addContext(this.context);
    this.setColorMode();
    if (!this.context.config.fontSizeScale) {
      FontScaleUtils.setConfig(FontScaleUtils.DEFAULT_FONT_SCALE);
    } else {
      FontScaleUtils.setConfig(this.context.config.fontSizeScale);
    }
    this.initColorMode();
    this.registerEnvironmentChange();
    PreloadManager.getInstance().initData(this.context, true);
    this.tryStartStatusReportWorker();
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.showInfo(TAG, 'onSessionCreate.');
    if (!PermissionVerifyUtil.isLocalDevice(want?.deviceId)) {
      LogUtil.showError(TAG, 'not local device');
      return;
    }
    this.asyncSessionCreate(session, want);
  }

  private async asyncSessionCreate(session: UIExtensionContentSession, want: Want): Promise<void> {
    this.storage.setOrCreate<UIExtensionContentSession>('ExtensionContentSession', session);
    this.initWantInfo(want);
    await this.initModeId(want);
    try {
      session.loadContent('pages/settinghome/HomeWindowSettings', this.storage);
      this.extensionWindow = session.getUIExtensionWindowProxy();
      session.setReceiveDataCallback((data: Record<string, Object>) => {
        this.onReceiveDataChange(data);
      });
      session.sendData({ 'action': 'getNavigationMode' });
    } catch (err) {
      LogUtil.showError(TAG, `session.loadContent catch err. code:${err?.code} message:${err?.message}`);
    }
    EventBus.getInstance().on(EventBusNameConstant.PAGE_ROUTER_SETTINGS, this.pageRouterSettings);
    this.initAvoidArea();
    this.registerAvoidAreaChange();
  }

  onSessionDestroy(): void {
    LogUtil.showInfo(TAG, 'onSessionDestroy.');
    EventBus.getInstance().detach(EventBusNameConstant.PAGE_ROUTER_SETTINGS, this.pageRouterSettings);
    this.unregisterAvoidAreaChange();
    this.storage.clear();
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy.');
    this.unRegisterEnvironmentChange();
    AbilityContextManager.removeContext(this.context);
  }

  onForeground(): void {
    LogUtil.showInfo(TAG, 'onForeground.');
    EventBus.getInstance().emit(EventBusNameConstant.APPLICATION_ON_FOREGROUND);
  }

  /**
   * 冷启�?处理want参数
   */
  private initWantInfo(want: Want): void {
    if (want?.parameters?.pushParams) {
      const pushParams: string[] = (want.parameters.pushParams as string).split(',');
      // 设置传参pushParams中第一个元素为url
      const navigationUrl: string = pushParams[0] ? pushParams[0] : NavEntryKey.INTELLIGENT_SCENE_HOME_ENTRY;
      LogUtil.showInfo(TAG, `initWantInfo. navigationUrl:${navigationUrl}`);
      AppStorage.setOrCreate(UiExtensionConstant.NAVIGATION_URL, navigationUrl);
    }
    // 路由模式
    const navigationMode: NavigationMode = want?.parameters?.navigationMode as NavigationMode ?? NavigationMode.Stack;
    AppStorage.setOrCreate(UiExtensionConstant.NAVIGATION_MODE, navigationMode);
    // 开启原�?
    const startReason: string = want?.parameters?.startReason as string ?? PageStartReason.DEFAULT;
    AppStorage.setOrCreate(UiExtensionConstant.START_REASON, startReason);
    LogUtil.showInfo(TAG,
      `initWantInfo. navigationMode:${navigationMode} startReason:${startReason}`);
  }

  /**
   * 指定模式
   */
  private async initModeId(want: Want): Promise<void> {
    let specifiedModeId: string = want?.parameters?.specifiedModeId as string ?? '';
    LogUtil.showInfo(TAG, `initWantInfo. specifiedModeId:${specifiedModeId}`);
    // 非学习模式不需要判断模式是否存�?
    if (specifiedModeId !== ModeType.LEARNING_MODE) {
      ModeDetailAdapter.getInstance().initData(specifiedModeId);
      return;
    }
    const isModeIdExist: boolean = await El1ModeDataManager.getInstance().isModeIdExist(specifiedModeId);
    ModeDetailAdapter.getInstance().initData(isModeIdExist ? specifiedModeId : '');
  }

  /**
   * 热启�?处理接受参数
   */
  private onReceiveDataChange(data: Record<string, Object>): void {
    if (data?.navigationMode !== undefined) {
      LogUtil.showInfo(TAG, `onReceiveDataChange. navigationMode:${data.navigationMode}`);
      AppStorage.setOrCreate(UiExtensionConstant.NAVIGATION_MODE, data.navigationMode);
    }
    if (data?.titleAnimationDuration !== undefined) {
      LogUtil.showInfo(TAG, `onReceiveDataChange. titleAnimationDuration:${data.titleAnimationDuration}`);
      AppStorage.setOrCreate(UiExtensionConstant.TITLE_ANIMATION_DURATION, data.titleAnimationDuration);
    }
    if (data?.specifiedModeId !== undefined) {
      LogUtil.showInfo(TAG, `onReceiveDataChange. specifiedModeId:${data.specifiedModeId}`);
      // 滑动到指定模�?
      EventBus.getInstance().emit(EventBusNameConstant.SWIPE_THIS_MODE, data.specifiedModeId);
    }
    if (data?.action === EventBusNameConstant.APP_LIST_LOAD_COMPLETE) {
      LogUtil.showInfo(TAG, 'receive setting app list load complete message');
      EventBus.getInstance().emit(EventBusNameConstant.APP_LIST_LOAD_COMPLETE);
      AppStorage.setOrCreate('isAppListLoadComplete', true);
    }
  }

  /**
   * 设置应用自动跟随系统深浅色模�?(小艺组件需�?
   */
  private setColorMode(): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      LogUtil.showError(TAG, `setColorMode occurs error: code:${err?.code} message:${err?.message}`);
    }
  }

  /**
   * 初始化深浅色状�?
   */
  private initColorMode(): void {
    try {
      const colorMode: uiAppearance.DarkMode = uiAppearance.getDarkMode();
      LogUtil.showInfo(TAG, `initColorMode. colorMode:${colorMode}`);
      AppStorage.setOrCreate<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE, colorMode);
    } catch (err) {
      LogUtil.showError(TAG, `initColorMode. code:${err?.code} message:${err?.message}`);
    }
  }

  /**
   * 注册监听
   */
  private registerEnvironmentChange(): void {
    LogUtil.showInfo(TAG, 'registerEnvironmentChange.');
    try {
      this.environmentCallbackId = this.context.getApplicationContext().on('environment', {
        onConfigurationUpdated(config): void {
          LogUtil.showInfo(TAG, 'onConfigurationUpdated start.');
          if (config) {
            if (config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) {
              LogUtil.showInfo(TAG, 'onConfigurationUpdated. config.colorMode is invalid');
              return;
            }
            const newColorMode: uiAppearance.DarkMode =
              config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ?
              uiAppearance.DarkMode.ALWAYS_DARK : uiAppearance.DarkMode.ALWAYS_LIGHT;
            let oldColorMode: uiAppearance.DarkMode | undefined =
              AppStorage.get<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE);
            LogUtil.showInfo(TAG, `onConfigurationUpdated. newColorMode:${newColorMode} oldColorMode:${oldColorMode}`);
            if (newColorMode !== oldColorMode) {
              AppStorage.setOrCreate<uiAppearance.DarkMode>(AppStorageKey.COLOR_MODE, newColorMode);
              // 通过事件总线通知应用
              EventBus.getInstance().emit(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, newColorMode);
            }
          }
          LogUtil.showInfo(TAG, 'onConfigurationUpdated end.');
        },
        onMemoryLevel(level): void {
          LogUtil.showInfo(TAG, `onMemoryLevel. level:${level}`);
        }
      });
      LogUtil.showInfo(TAG, `registerEnvironmentChange. environmentCallbackId:${this.environmentCallbackId}`);
    } catch (err) {
      LogUtil.showError(TAG, `registerEnvironmentChange catch err. code:${err?.code} message:${err?.message}`);
    }
  }

  /**
   * 卸载监听
   */
  private unRegisterEnvironmentChange(): void {
    LogUtil.showInfo(TAG, 'unRegisterEnvironmentChange.');
    if (this.environmentCallbackId === INVALID_CALLBACK_ID) {
      LogUtil.showWarn(TAG, 'environmentCallbackId is invalid.');
      return;
    }
    try {
      this.context.getApplicationContext().off('environment', this.environmentCallbackId, (err) => {
        if (err) {
          LogUtil.showError(TAG, `off environment catch err. code:${err.code} message:${err.message}`);
        }
      });
    } catch (error) {
      LogUtil.showError(TAG, `unRegisterEnvironmentChange catch err. code:${error?.code}  message:${error?.message}`);
    }
  }

  /**
   * 初始化避让区域相关数�?
   */
  private initAvoidArea(): void {
    try {
      const avoidArea: window.AvoidArea | undefined =
        this.extensionWindow?.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      const navigationBarHeight: number = px2vp(avoidArea?.bottomRect.height || 0);
      AppStorage.setOrCreate<number>(AppStorageKey.NAVIGATION_BAR_HEIGHT, navigationBarHeight);
      LogUtil.showInfo(TAG, `initAvoidArea. navigationBarHeight:${navigationBarHeight}`);
    } catch (error) {
      LogUtil.showError(TAG, `initAvoidArea catch err. code:${error?.code} message:${error?.message}`);
    }
  }

  /**
   * 监听窗口避让区域事件
   */
  private registerAvoidAreaChange(): void {
    try {
      this.extensionWindow?.on('avoidAreaChange', (info: uiExtension.AvoidAreaInfo) => {
        if (info.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          const navigationBarHeight: number = px2vp(info.area.bottomRect.height);
          LogUtil.showInfo(TAG, `registerAvoidAreaChange. navigationBarHeight:${navigationBarHeight}`);
          AppStorage.setOrCreate<number>(AppStorageKey.NAVIGATION_BAR_HEIGHT, navigationBarHeight);
        }
      });
    } catch (error) {
      LogUtil.showError(TAG, `registerAvoidAreaChange catch err. code:${error?.code} message:${error?.message}`);
    }
  }

  /**
   * 卸载窗口避让区域事件
   */
  private unregisterAvoidAreaChange(): void {
    try {
      this.extensionWindow?.off('avoidAreaChange');
    } catch (error) {
      LogUtil.showError(TAG, `unregisterAvoidAreaChange catch err. code:${error?.code} message:${error?.message}`);
    }
  }

  private async tryStartStatusReportWorker(): Promise<void> {
    await workScheduler.obtainAllWorks().then((workList) => {
      if (workList.length) {
        LogUtil.showInfo(TAG, `statusReportWorker already exist. workList.length:${workList.length}`);
        return
      }
      let task: taskpool.Task = new taskpool.Task(startWork);
      try {
        taskpool.execute(task, taskpool.Priority.MEDIUM);
      } catch (e) {
        LogUtil.showError(TAG, `taskpool.execute catch err. code:${e?.code} message:${e?.message}`);
      }
    }).catch((reason: Error) => {
      LogUtil.showError(TAG, `statusReportWorker failed, reason name: ${reason.name}, message: ${reason.message}`);
    });
  }
}