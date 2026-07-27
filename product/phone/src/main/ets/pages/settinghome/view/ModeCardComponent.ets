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

import i18n from '@ohos.i18n';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/scene.common/src/main/ets/utils/FontScaleUtils';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { EffectiveSourceType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { PromptManager } from '@ohos/scene.common/src/main/ets/basecomponent/prompt/PromptManager';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { HomeSheetCompId } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ModeData, ModeType, EMPTY_MODE_DATA } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { OperateType } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';
import { StateManager, THROTTLE_INTERVAL_TIME } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { ModeDataViewUtils } from '@ohos/scene.configmanage/src/main/ets/utils/ModeDataViewUtils';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';
import { MODE_HINT_MAP } from '../constant/HomeConstant';
import { EditModeAdapter } from '../../modesheet/adapter/EditModeAdapter';

/* instrument ignore file */
// 卡片宽度
export enum ModeCardWidth {
  SMALL = 244,
  MEDIUM = 320,
  LARGE = 360,
}

// 模式标题样式属性
const TITLE_LINE_HEIGHT: number = 30;
const TITLE_MAX_FONT_SCALE: number = 1.6;
// 动效时间
const ANIMATION_TIME: number = 250;

const TAG: string = 'ModeCardComponent:';

/**
 * 模式卡片
 */
@Component
export struct ModeCardComponent {
  modeData: ModeData = EMPTY_MODE_DATA;
  // 生命周期状态
  @State isFirst: boolean = true;
  @Link isPageShowing: boolean;
  @Link deleteModeId: string;
  // 当前选中的modeId
  @Link currentModeId: string;
  // 当前已开启的modeId
  @Link enabledModeId: string;
  // 这里用来做按钮透明度
  @Prop pageOpacity: number = 1;
  // 卡片宽度
  @Prop cardWidth: number = DeviceUtil.isDevicePad() ? ModeCardWidth.LARGE : ModeCardWidth.SMALL;
  @State cardHeight: Length = 0;
  @State isHover: boolean = false;
  private timerId?: number;

  /**
   * 模式图标 Builder
   */
  @Builder
  ModeIconBuilder(): void {
    Stack({ alignContent: Alignment.BottomEnd }) {
      if (this.modeData.iconId) {
        SymbolGlyph($r(`sys.symbol.${this.modeData.iconId}`))
          .fontSize('42vp')
          .fontColor([$r('sys.color.icon_on_primary')])
          .draggable(false)
          .margin(11)
      }
      // 右下角是否可编辑图标
      if (this.modeData.isSupportDelete) {
        SymbolGlyph($r(`sys.symbol.small_triangle_arrow_down_right_fill`))
          .fontSize('24vp')
          .fontColor([$r('sys.color.icon_fourth')])
          .draggable(false)
      }
    }
    .size({
      height: 64,
      width: 64,
    })
    .margin({
      bottom: 12,
    })
    .borderRadius(32)
    .backgroundColor(this.modeData.iconColor)
  }

  /**
   * 模式名称与提示语 Builder
   */
  @Builder
  ModeTextBuilder(): void {
    Column() {
      // 模式名称
      Text(ModeUtil.getModeNameResourceStr(this.modeData))
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize('24fp')
        .lineHeight(TITLE_LINE_HEIGHT)
        .constraintSize({
          minHeight: 32,
        })
        .maxFontScale(TITLE_MAX_FONT_SCALE)
        .maxLines(ModeUtil.isPrecastMode(this.modeData.modeId) ? 1 : 2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onVisibleAreaChange([0], (isVisible: boolean, currentRatio: number) => {
          if (this.currentModeId === this.modeData.modeId) {
            LogUtil.showInfo(TAG,
              `onVisibleAreaChange. isPageShowing:${this.isPageShowing} modeId:${this.modeData.modeId} isVisible:${isVisible} currentRatio:${currentRatio}`);
            if (!this.isPageShowing || this.deleteModeId !== NO_SCENE || !this.modeData.updateTime) {
              return;
            }
            if (!isVisible && currentRatio <= 0.0) {
              EventBus.getInstance()
                .emit(EventBusNameConstant.HOME_TITLE_CHANGE, ModeUtil.getModeNameResourceStr(this.modeData));
            } else {
              EventBus.getInstance()
                .emit(EventBusNameConstant.HOME_TITLE_CHANGE, $r('app.string.intelligent_scene'));
            }
          }
        })

      // 模式提示语
      if (MODE_HINT_MAP.get(this.modeData.modeId as ModeType)) {
        Text(MODE_HINT_MAP.get(this.modeData.modeId as ModeType))
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(19)
          .maxFontScale(2)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({
            top: i18n.System.getSystemLocale() === 'bo-CN' ? 8 : 2,
          })
      }
    }
    // 保证没有提示语的时候 整个文本组件高度不变
    .constraintSize({
      minHeight: FontScaleUtils.getTextRealHeight(TITLE_LINE_HEIGHT, TITLE_MAX_FONT_SCALE) * 2,
    })
  }

  /**
   * 模式启停按钮 Builder
   */
  @Builder
  ModeButtonBuilder(): void {
    Button(this.getButtonText())
      .type(ButtonType.ROUNDED_RECTANGLE)
      .constraintSize({
        minHeight: 40,
        maxHeight: 48,
      })
      .labelStyle({
        maxLines: 1,
        overflow: TextOverflow.Ellipsis,
        minFontSize: 8,
        maxFontSize: 16,
        heightAdaptivePolicy: TextHeightAdaptivePolicy.MAX_LINES_FIRST,
      })
      .opacity(this.pageOpacity)
      .animation({ duration: 150, curve: Curve.Sharp })
      .buttonStyle(ButtonStyleMode.NORMAL)
      .width('100%')
      .onClick(() => {
        this.onModeThrottleToggle(this.modeData.modeId);
      })
  }

  build() {
    Stack() {
      // 透明背景
      if (this.cardHeight) {
        Column() {
        }
        .scale(this.isCurrentMode() ? undefined : { x: 0.9, y: 0.9 })
        .width(this.cardWidth)
        .animation(this.isFirst ? undefined : { duration: ANIMATION_TIME, curve: Curve.Sharp })
        .height(this.cardHeight)
        .borderRadius($r('sys.float.corner_radius_level12'))
        .borderWidth(1.5)
        .borderColor('#33FFFFFF')
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .opacity(this.isCurrentMode() ? 0.8 : 0.6)
      }

      // 卡片内容
      Column() {
        // 编辑模式热区
        Column() {
          // 模式图标
          this.ModeIconBuilder()
          // 模式名称与提示语
          this.ModeTextBuilder()
        }
        .accessibilityDescription(this.modeData.isSupportDelete ? '' : ' ')
        .stateStyles({
          normal: {
            .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
          },
          pressed: {
            .backgroundColor(this.modeData.isSupportDelete ? $r('sys.color.interactive_click') : Color.Transparent)
          }
        })
        .onClick(() => {
          this.openEditModeSheet(this.modeData);
        })
        .borderRadius($r('sys.float.corner_radius_level8'))
        .padding({
          top: 8,
        })
        .margin({
          bottom: DeviceUtil.isDevicePad() ? 12 : 8,
        })
        .onHover((hover: boolean) => {
          this.isHover = hover && this.modeData.isSupportDelete;
        })

        // 模式启停按钮
        this.ModeButtonBuilder()
      }
      .scale(this.isCurrentMode() ? undefined : { x: 0.9, y: 0.9 })
      .width(this.cardWidth)
      .animation(this.isFirst ? undefined : { duration: ANIMATION_TIME, curve: Curve.Sharp })
      .padding({
        top: DeviceUtil.isDevicePad() ? 12 : 8,
        bottom: DeviceUtil.isDevicePad() ? 20 : 16,
        left: DeviceUtil.isDevicePad() ? 20 : 16,
        right: DeviceUtil.isDevicePad() ? 20 : 16,
      })
      .borderRadius($r('sys.float.corner_radius_level12'))
      .backgroundColor(this.cardHeight ? Color.Transparent : $r('sys.color.comp_background_list_card'))
      .opacity(this.cardHeight ? 1 : 0.8)
      .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
        LogUtil.showInfo(TAG, `onSizeChange. width:${newValue.width} height:${newValue.height}`);
        this.cardHeight = newValue.height ?? this.cardHeight;
      })
    }
    .scale(this.deleteModeId === this.modeData.modeId ? { x: 0.6, y: 0.6 } : undefined)
    .opacity(this.deleteModeId === this.modeData.modeId ? 0 : 1)
    .animation({ duration: ANIMATION_TIME, curve: Curve.Sharp })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear. modeId:${this.modeData.modeId}`);
  }

  onDidBuild(): void {
    LogUtil.showInfo(TAG, `onDidBuild. modeId:${this.modeData.modeId}`);
    // 首次渲染后才启用动画
    setTimeout(() => {
      this.isFirst = false;
    }, ANIMATION_TIME)
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, `aboutToDisappear. modeId:${this.modeData.modeId}`);
    if (this.timerId) {
      clearTimeout(this.timerId);
    }
  }

  /**
   * 判断是否当前选中模式
   */
  private isCurrentMode(): boolean {
    if (this.modeData.modeId === EMPTY_MODE_DATA.modeId) {
      return true;
    }
    return this.currentModeId === this.modeData.modeId;
  }

  /**
   * 获取按钮文本
   */
  private getButtonText(): ResourceStr {
    if (this.modeData.modeId === EMPTY_MODE_DATA.modeId) {
      // 空格字串撑开组件
      return ' ';
    }
    if (this.enabledModeId === this.modeData.modeId) {
      return $r('app.string.close_now');
    }
    return $r('app.string.enable_now');
  }

  /**
   * 模式开启/关闭(节流)
   */
  private onModeThrottleToggle(modeId: string): void {
    if (this.timerId) {
      LogUtil.showInfo(TAG, `onModeThrottleToggle. timerId:${this.timerId}`);
    } else {
      this.onModeToggle(modeId);
      this.timerId = setTimeout(() => {
        this.timerId = undefined;
      }, THROTTLE_INTERVAL_TIME);
    }
  }

  /**
   * 模式开启/关闭
   */
  private onModeToggle(modeId: string): void {
    LogUtil.showInfo(TAG, `onModeToggle modeId:${modeId} enabledModeId:${this.enabledModeId}`);
    let isStopScene: boolean = this.enabledModeId === modeId;
    EventBus.getInstance().emit(EventBusNameConstant.SWIPE_THIS_MODE, modeId);
    ModeDataViewUtils.hiViewWhenOpenOrClose(modeId, !isStopScene, EffectiveSourceType.INTELLIGENT_SCENE_HOME);
    if (isStopScene) {
      StateManager.getInstance().stopScene(modeId, FactorType.USER);
    } else {
      // 切换模式
      StateManager.getInstance().startScene(modeId, FactorType.USER);
    }
  }

  /**
   * 拉起编辑模式模态框
   */
  private openEditModeSheet(data: ModeData): void {
    LogUtil.showInfo(TAG, `openEditModeSheet. isSupportDelete:${this.modeData.isSupportDelete}`);
    // 不支持删除的模式也不可编辑
    if (!this.modeData.isSupportDelete) {
      return;
    }
    EventBus.getInstance().emit(EventBusNameConstant.SWIPE_THIS_MODE, this.modeData.modeId);
    if (this.enabledModeId === data.modeId) {
      PromptManager.getInstance().showToastWithThrottle($r('app.string.edit_enable_mode_hint'));
      return;
    }
    EditModeAdapter.getInstance().initData(OperateType.EDIT, data);
    notifyCompStateChange(HomeSheetCompId.EDIT_SHEET_COMP_ID,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: true } as SettingModalState]
      ])
    );
  }
}