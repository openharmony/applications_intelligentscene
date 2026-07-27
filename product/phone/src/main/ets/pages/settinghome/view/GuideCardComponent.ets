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

import { curves } from '@kit.ArkUI';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/scene.common/src/main/ets/utils/PreferencesUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { PopupComponent } from '@ohos/scene.common/src/main/ets/basecomponent/popup/PopupComponent';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { GuideCardConfig } from '@ohos/scene.modeconfig/src/main/ets/model/ModeConfigModel';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';

/* instrument ignore file */
// item缩放曲线
const ITEM_SCALE_CURVE: curves.ICurve = curves.interpolatingSpring(0, 1, 400, 38);

const TAG: string = 'GuideCardComponent:';

/**
 * 引导卡片业务组件
 */
@Component
export struct GuideCardComponent {
  @State guideCardConfig: GuideCardConfig | undefined = undefined;
  @State isNeedAnimation: boolean = true;
  @State isVisible: boolean = false;
  // 已经关闭过的引导卡片keys
  private operatedCardKeys: string[] = [];
  /**
   * 模式卡片切换事件
   */
  private onScrollNewModeCallback = (): void => {
    LogUtil.showInfo(TAG, `onScrollNewModeCallback.`);
    this.refreshUI();
  };

  build() {
    ListItem() {
      PopupComponent({
        icon: this.guideCardConfig?.icon,
        iconBackgroundColor: this.guideCardConfig?.iconBackgroundColor,
        title: this.guideCardConfig?.title,
        message: this.guideCardConfig?.message,
        linkText: this.guideCardConfig?.linkText,
        isSupportClose: this.guideCardConfig?.isSupportClose,
        close: () => {
          this.onClose();
        },
        action: () => {
          this.onAction();
        }
      })
        .scale(this.isVisible ? undefined : { x: 0.75, y: 0.75 })
        .animation(this.isNeedAnimation ? { curve: ITEM_SCALE_CURVE } : undefined)
        .padding({
          top: 4,
        })
        .margin({
          top: 13,
        })
    }
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
    .animation(this.isNeedAnimation ? {
      curve: ITEM_SCALE_CURVE,
      onFinish: () => {
        LogUtil.showInfo(TAG, 'animation onFinish.');
        // 1.如果首次需要卡片 动画执行完后把动画关闭
        this.isNeedAnimation = false;
      },
    } : undefined)
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
    this.refreshUI();
    EventBus.getInstance().on(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
    EventBus.getInstance().detach(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
  }

  /**
   * 刷新引导卡片
   */
  private refreshUI(): void {
    const modeData: ModeData | undefined = this.getCurrentMode();
    if (!modeData) {
      LogUtil.showWarn(TAG, `refreshUI. modeData is empty`);
      return;
    }
    LogUtil.showInfo(TAG, `refreshUI. modeId:${modeData.modeId} operatedCardKeys:${this.operatedCardKeys}`);
    // 应用生命周期内一个模式如果关闭过引导卡片 则不再展示其他引导卡片了
    this.guideCardConfig = this.operatedCardKeys.includes(`${modeData.modeId}-${modeData.createTime}`) ? undefined :
    this.getGuideCardConfig(modeData);
    LogUtil.showInfo(TAG, `refreshUI. preferencesKey:${this.guideCardConfig?.preferencesKey}`);
    if (this.guideCardConfig) {
      this.isVisible = true;
    } else {
      this.isVisible = false;
      // 2.如果首次不需要卡片 则关闭动画
      this.isNeedAnimation = false;
    }
  }

  /**
   * 点击超链接
   */
  private onAction(): void {
    LogUtil.showInfo(TAG, 'onAction.');
    this.guideCardConfig?.action();
    if (this.guideCardConfig?.isSupportClose) {
      this.onClose();
    }
  }

  /**
   * 关闭卡片
   */
  private onClose(): void {
    const modeData: ModeData | undefined = this.getCurrentMode();
    if (!modeData) {
      LogUtil.showWarn(TAG, `onClose. modeData is empty`);
      return;
    }
    LogUtil.showInfo(TAG, `onClose. modeId:${modeData.modeId} createTime:${modeData.createTime}`);
    // 3.关闭卡片时需要打开动画
    this.isNeedAnimation = true;
    this.isVisible = false;
    if (this.guideCardConfig) {
      this.operatedCardKeys.push(`${modeData.modeId}-${modeData.createTime}`);
      LogUtil.showInfo(TAG, `onClose putSync. preferencesKey:${this.guideCardConfig.preferencesKey}`);
      // 将模式的创建时间戳写入首选项
      PreferencesUtil.putSync(this.guideCardConfig.preferencesKey, modeData.createTime as number);
    }
  }

  /**
   * 获取当前模式
   */
  private getCurrentMode(): ModeData | undefined {
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const allModeArr: ModeData[] = ModeAdapter.getInstance().getAllModeArr();
    LogUtil.showInfo(TAG, `getCurrentMode. modeId:${modeId} allModeArr:${allModeArr.length}`);
    return allModeArr.find((it) => it.modeId === modeId);
  }

  /**
   * 获取当前模式需要显示第一个引导卡片配置
   *
   * 引导卡片配置可能会有多个
   * 按数组顺序找第一个没有关闭过的显示
   */
  private getGuideCardConfig(modeData: ModeData): GuideCardConfig | undefined {
    const guideCardConfigs: GuideCardConfig[] =
      ModeConfigAdapter.getInstance().getConfigByModeId(modeData.modeId).getGuideCardConfigs();
    for (let index = 0; index < guideCardConfigs.length; index++) {
      const guideCardConfig: GuideCardConfig = guideCardConfigs[index];
      // 获取引导卡片首选项的时间戳
      const preferencesValue: number = PreferencesUtil.getSync(guideCardConfig.preferencesKey, 0) as number;
      LogUtil.showInfo(TAG,
        `getGuideCardConfig. preferencesKey:${guideCardConfig.preferencesKey} preferencesValue:${preferencesValue} createTime:${modeData.createTime}`);
      // 如果首选项里面有该模式的创建时间戳 则说明该模式 用户已经点击过关闭引导卡片了
      if (modeData.createTime !== preferencesValue) {
        return guideCardConfig;
      }
    }
    return undefined;
  }
}