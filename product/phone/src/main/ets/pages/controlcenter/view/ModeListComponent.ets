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
import uiEffect from '@ohos.graphics.uiEffect';
// import { hdsEffect } from '@hms.hds.hdsBaseComponent';
import commonEventManager from '@ohos.commonEventManager';
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';
import { CommonEventHelper } from '@ohos/scene.common/src/main/ets/commonevent/CommonEventHelper';
import { ConfigConstant } from '@ohos/scene.common/src/main/ets/constant/ConfigConstant';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { BaseCondition, TimeCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { OpenType } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { PADDING_0, PADDING_16 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { ModeListItemComponent } from './ModeListItemComponent';
import { SubTextUtil } from '../utils/SubTextUtil';

/* instrument ignore file */
const TAG: string = 'ModeListComponent:';

/**
 * 模式列表组件
 */
@Component
export struct ModeListComponent {
  @Prop isDarkMode: boolean;
  @State allModeArr: ModeData[] = [];
  // 当前已开启的modeId
  @State enabledModeId: string = NO_SCENE;
  @State enableReasonText: ResourceStr = '';
  // 临时开启类型与时间区间文本
  @State temporaryEnableMenuType: string = '';
  @State temporaryEnableMenuText: string = '';
  @State currentTime: Date = new Date();
  private modeProfileDataHelper?: dataShare.DataShareHelper;
  private configIdInEffectDataHelper?: dataShare.DataShareHelper;
  // 新折叠态产品外屏显示标记位
  private isPocketExternalDisplayMode: boolean = false;
  /**
   * 系统分钟时间改变事件
   */
  private onMinuteChangeEventHelper: CommonEventHelper = new CommonEventHelper({
    events: [commonEventManager.Support.COMMON_EVENT_TIME_TICK],
  }, (err, data) => {
    if (err?.code) {
      LogUtil.showWarn(TAG, `onMinuteChangeEventHelper failed. code:${err?.code} message:${err?.message}`);
    } else {
      LogUtil.showInfo(TAG, `onMinuteChangeEventHelper change`);
      this.currentTime = new Date();
    }
  });
  /**
   * 所有模式数据刷新事件回调
   */
  private onRefreshAllModeCallback = (allModeArr: ModeData[]): void => {
    LogUtil.showInfo(TAG, `onRefreshAllModeCallback. allModeArr.length:${allModeArr.length}`);
    this.allModeArr = ModeAdapter.getInstance().getShowModeArr(this.enabledModeId);
  };
  /**
   * settingsData focus_mode_profile 变化事件
   */
  private onModeProfileChangeCallback = (): void => {
    LogUtil.showInfo(TAG, 'onModeProfileChangeCallback.');
    this.getEnabledModeId();
  };
  /**
   * settingsData config_id_in_effect 变化事件
   */
  private onConfigIdInEffectChangeCallback = (): void => {
    LogUtil.showInfo(TAG, `onConfigIdInEffectChangeCallback.`);
    this.getEnableReasonState();
  };

  @Builder
  buildTipMessage(): void {
    ListItem() {
      Text($r('app.string.intelligent_scene_new_hint'))
        .width('100%')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize(12)
        .lineHeight(LanguageUtils.getLineHeight(19))
        .maxFontScale(1.8)
        .fontColor($r('sys.color.font_secondary'))
        // .advancedBlendMode(uiEffect.createBrightnessBlender(
        //   hdsEffect.getBrightnessParam({
        //     scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
        //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_3,
        //     fraction: 0,
        //     isDarkMode: this.isDarkMode,
        //   })
        // ))
    }
    .margin({
      left: 12,
      right: 12,
      bottom: 0,
    })
  }

  build() {
    // 列表
    List({ space: 12 }) {
      // 提示语
      if (!this.isPocketExternalDisplayMode) {
        this.buildTipMessage();
      }

      // 模式item
      ForEach(this.allModeArr, (item: ModeData) => {
        ModeListItemComponent({
          isDarkMode: this.isDarkMode,
          currentTime: this.currentTime,
          modeData: item,
          enabledModeId: this.enabledModeId,
          enableReasonText: this.enableReasonText,
          temporaryEnableMenuType: this.temporaryEnableMenuType,
          temporaryEnableMenuText: this.temporaryEnableMenuText,
          isPocketExternalDisplayMode: this.isPocketExternalDisplayMode,
        })
      }, (item: ModeData) => item.modeId)
    }
    .edgeEffect(EdgeEffect.Spring, {
      alwaysEnabled: true,
    })
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      bottom: this.isPocketExternalDisplayMode ? 4 : 0
    })
    .layoutWeight(1)
    .alignSelf(ItemAlign.Start)
    .scrollBarMargin({
      end: this.isPocketExternalDisplayMode ? PADDING_16 : PADDING_0
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear. allModeArr.length:${this.allModeArr.length}`);
    this.getEnabledModeId();
    this.registerDataChange();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
    this.unRegisterDataChange();
  }

  /**
   * 注册事件
   */
  private async registerDataChange(): Promise<void> {
    LogUtil.showInfo(TAG, `registerDataChange`);
    EventBus.getInstance().on(EventBusNameConstant.ALL_MODE_REFRESH, this.onRefreshAllModeCallback);
    this.onMinuteChangeEventHelper.registerCommonEvent();
    try {
      this.modeProfileDataHelper = await SettingsDataUtils.createDataHelper(SettingsDataKeyConstant.FOCUS_MODE_PROFILE);
    } catch (err) {
      LogUtil.showError(TAG, `createDataHelper error code: ${err?.code} msg: ${err?.message}`);
    }
    if (this.modeProfileDataHelper) {
      LogUtil.showInfo(TAG, `registerSecurityDataChange focus_mode_profile`);
      SettingsDataUtils.registerSecurityDataChange(this.modeProfileDataHelper,
        SettingsDataKeyConstant.FOCUS_MODE_PROFILE, this.onModeProfileChangeCallback);
    }
    this.configIdInEffectDataHelper =
      await SettingsDataUtils.createDataHelper(SettingsDataKeyConstant.INTELLIGENT_CONFIG_ID_IN_EFFECT);
    if (this.configIdInEffectDataHelper) {
      LogUtil.showInfo(TAG, `registerSecurityDataChange config_id_in_effect`);
      SettingsDataUtils.registerSecurityDataChange(this.configIdInEffectDataHelper,
        SettingsDataKeyConstant.INTELLIGENT_CONFIG_ID_IN_EFFECT, this.onConfigIdInEffectChangeCallback);
    }
  }

  /**
   * 卸载事件
   */
  private unRegisterDataChange(): void {
    LogUtil.showInfo(TAG, `unRegisterDataChange`);
    EventBus.getInstance().detach(EventBusNameConstant.ALL_MODE_REFRESH, this.onRefreshAllModeCallback);
    this.onMinuteChangeEventHelper.unRegisterCommonEvent();
    if (this.modeProfileDataHelper) {
      LogUtil.showInfo(TAG, `unRegisterSecurityDataChange focus_mode_profile`);
      SettingsDataUtils.unRegisterSecurityDataChange(this.modeProfileDataHelper,
        SettingsDataKeyConstant.FOCUS_MODE_PROFILE, this.onModeProfileChangeCallback);
    }
    if (this.configIdInEffectDataHelper) {
      LogUtil.showInfo(TAG, `unRegisterSecurityDataChange config_id_in_effect`);
      SettingsDataUtils.unRegisterSecurityDataChange(this.configIdInEffectDataHelper,
        SettingsDataKeyConstant.INTELLIGENT_CONFIG_ID_IN_EFFECT, this.onConfigIdInEffectChangeCallback
      );
    }
  }

  /**
   * 获取已开启的模式id
   */
  private getEnabledModeId(): void {
    const enabledModeId = ModeUtil.getModeOpenState().modeId;
    LogUtil.showInfo(TAG, `getEnabledModeId. this.enabledModeId:${this.enabledModeId} enabledModeId:${enabledModeId}`);
    if (this.enabledModeId !== enabledModeId) {
      // 这里一定要先赋值再获取开启原因
      this.enabledModeId = enabledModeId;
      this.getEnableReasonState();
    }
    this.allModeArr = ModeAdapter.getInstance().getShowModeArr(this.enabledModeId);
  }

  /**
   * 获取开启原因文本 (注意:如果是围栏开启 这里只处理modeId能对应上的情况)
   */
  private async getEnableReasonState(): Promise<void> {
    const configId: string = StateManager.getInstance().getEffectiveConfigId();
    LogUtil.showInfo(TAG, `getEnableReasonText. this.enabledModeId:${this.enabledModeId} configId:${configId}`);
    // 无模式开启时
    if (this.enabledModeId === NO_SCENE) {
      this.setEnableReasonState('', '', '');
      return;
    }
    // 注意：以下都是有模式开启的情况
    // configId为空兜底处理(升级场景) || 手动开启
    if (!configId || configId === ConfigConstant.RULE_NAME_SCENE_MANUAL_START) {
      this.setEnableReasonState('', '', $r('app.string.not_disturb_turnedon'));
      return;
    }
    const modeId: string = ModeUtil.getModeIdFromConfigId(configId);
    const configType: ConfigType = ModeUtil.getTypeFromConfigId(configId);
    LogUtil.showInfo(TAG, `getEnableReasonText. modeId:${modeId} configType:${configType}`);
    // 如果是切换了模式 则交给切换getEnabledModeId将组件状态modeId同步后再处理 避免开启模式和开启原因视图不一致情况
    if (this.enabledModeId !== modeId) {
      LogUtil.showInfo(TAG, 'getEnableReasonText modeId is different.');
      return;
    }
    // 最后兜底成手动开启
    LogUtil.showInfo(TAG, `getEnableReasonText. other reason.`);
    this.setEnableReasonState('', '', $r('app.string.not_disturb_turnedon'));
  }

  /**
   * 设置开启原因状态
   */
  private setEnableReasonState(menuType: string, menuText: string, reasonText: ResourceStr): void {
    LogUtil.showInfo(TAG,
      `setEnableReasonState. menuType:${menuType} menuText:${menuText} reasonText:${ResourceUtil.getStringSync(reasonText)}`);
    this.temporaryEnableMenuType = menuType;
    this.temporaryEnableMenuText = menuText;
    this.enableReasonText = reasonText;
  }
}