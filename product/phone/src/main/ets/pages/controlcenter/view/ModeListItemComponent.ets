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

import uiEffect from '@ohos.graphics.uiEffect';
import { curves } from '@kit.ArkUI';
// import { hdsEffect } from '@hms.hds.hdsBaseComponent';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { AccessibilityUtils, SCENE_BOARD_PACKAGE_NAME } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import {
  INLINE_BACKGROUND_SECOND_LIGHT,
  INLINE_BACKGROUND_SECOND_DARK,
} from '@ohos/scene.common/src/main/ets/constant/BrightnessBlenderConstant';
import { PADDING_0, PADDING_8, PADDING_16 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { ModeType, ModeData, EMPTY_MODE_DATA } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { OpenType } from '@ohos/scene.modeconfig/src/main/ets/constant/SysDialogConstants';
import { StateManager, THROTTLE_INTERVAL_TIME } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { EffectiveSourceType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { ModeDataViewUtils } from '@ohos/scene.configmanage/src/main/ets/utils/ModeDataViewUtils';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { TimeConstant } from '@ohos/scene.common/src/main/ets/constant/TimeConstant';
import { SubTextUtil } from '../utils/SubTextUtil';
import { ModeManualEnableUtil } from '../utils/ModeManualEnableUtil';

/* instrument ignore file */
interface MenuOption {
  id: OpenType;
  title: ResourceStr;
  onClick: () => void;
}

// 通用动画时间
const ANIMATION_TIME: number = 250;
// 立即刷新动画时延
const IMMEDIATELY_TIME: number = 0;
// item缩放曲线
const ITEM_SCALE_CURVE: curves.ICurve = curves.interpolatingSpring(10, 1, 350, 35);
const ITEM_SMALL_RATIO: number = 0.95;
const ITEM_NORMAL_RATIO: number = 1;
// 图标过渡动画参数
const ICON_ANIMATION_PARAM: AnimateParam = { duration: 333, curve: Curve.Smooth };
// 文本属性动画参数
const TEXT_ANIMATION_PARAM: AnimateParam = { duration: 400, curve: Curve.Friction };
// 正常显示大小下 副文本高度
const SUB_TEXT_DEFAULT_HEIGHT: number = 18;

let timerId: number | undefined = undefined;

const TAG: string = 'ModeListItemComponent:';

@Component
export struct ModeListItemComponent {
  modeData: ModeData = EMPTY_MODE_DATA;
  @Prop isDarkMode: boolean;
  @Prop currentTime: Date = new Date();
  // 当前已开启的modeId
  @Link enabledModeId: string;
  @Prop enableReasonText: ResourceStr;
  @Prop temporaryEnableMenuType: string;
  @Prop temporaryEnableMenuText: string;
  // 新折叠态产品外屏显示标记位
  @Prop isPocketExternalDisplayMode: boolean;
  @State isHover: boolean = false;
  @State menuItemHoverId: OpenType | undefined = undefined;
  @State isShowMenu: boolean = false;
  // 下拉菜单状态
  @State menuArr: MenuOption[] = [];
  // 缩放动效状态
  @State scaleValue: number = 1;
  // 图标动画触发状态
  @State triggerValue: number = -1;
  // 是否启用动画
  @State isAnimation: boolean = false;
  // 主文本位移动画参数（初始值给的正常显示大小下副文本高度的一半）
  @State textOffsetY: number = SUB_TEXT_DEFAULT_HEIGHT / 2;
  // 副文本高度
  private subTextHeight: number = SUB_TEXT_DEFAULT_HEIGHT;

  @Styles
  normalStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  /**
   * 模式图标颜色：开启态为强调色底板，需用反色前景保证对比度
   */
  private getModeIconColor(): ResourceColor {
    return this.enabledModeId === this.modeData.modeId ? Color.White : $r('sys.color.icon_primary');
  }

  /**
   * 模式按钮 Builder
   */
  @Builder
  ModeButtonBuilder(): void {
    Button({ type: ButtonType.Circle }) {
      SymbolGlyph($r(`sys.symbol.${this.modeData.iconId}`))
        .fontSize('24vp')
        .draggable(false)
        .fontColor([this.getModeIconColor()])
        // .advancedBlendMode(uiEffect.createBrightnessBlender(
        //   hdsEffect.getBrightnessParam({
        //     scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
        //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_1,
        //     fraction: this.enabledModeId === this.modeData.modeId ? 1 : 0,
        //     isDarkMode: this.isDarkMode,
        //   })
        // ))
        .animation(ICON_ANIMATION_PARAM)
        .symbolEffect(new BounceSymbolEffect(EffectScope.LAYER, EffectDirection.UP), this.triggerValue)
    }
    .width(48)
    .height(48)
    .backgroundColor(this.enabledModeId === this.modeData.modeId ?
    $r('app.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'))
    // .visualEffect(uiEffect.createEffect().backgroundColorBlender(
    //   hdsEffect.getBrightnessParam({
    //     scenario: hdsEffect.BrightnessScenario.BACKGROUND_BRIGHTNESS,
    //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_7,
    //     fraction: this.enabledModeId === this.modeData.modeId ? 1 : 0,
    //     isDarkMode: !this.isDarkMode,
    //   })
    // ))
    .animation(ICON_ANIMATION_PARAM)
    .onClick(() => {
      LogUtil.showInfo(TAG, `Button onClick. modeId:${this.modeData.modeId}`);
      this.triggerValue = this.triggerValue + 1;
      this.onModeThrottleClick(this.modeData.modeId, OpenType.TURN_ON_NOW);
    })
  }

  /**
   * 模式文本 Builder
   */
  @Builder
  ModeTextBuilder(): void {
    Column() {
      // 模式名称
      Text(ModeUtil.getModeNameResourceStr(this.modeData))
        .offset({ y: this.textOffsetY })
        .animation(this.isAnimation ? TEXT_ANIMATION_PARAM : undefined)
        .fontSize($r('sys.float.Subtitle_M'))
        .lineHeight(LanguageUtils.getLineHeight(21))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor($r('sys.color.font_primary'))
        // .advancedBlendMode(uiEffect.createBrightnessBlender(
        //   hdsEffect.getBrightnessParam({
        //     scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
        //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_1,
        //     fraction: 0,
        //     isDarkMode: this.isDarkMode,
        //   })
        // ))

      // 开启原因提示 (至少给空格字符保证组件高度不变)
      Text(this.enabledModeId === this.modeData.modeId ? this.enableReasonText || ' ' : ' ')
        .opacity(this.enabledModeId === this.modeData.modeId ? 1 : 0)
        .animation(this.isAnimation ? TEXT_ANIMATION_PARAM : undefined)
        .fontSize($r('sys.float.Subtitle_S'))
        .lineHeight(LanguageUtils.getLineHeight(19))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.HYPHENATION)
        .fontColor($r('sys.color.font_secondary'))
        // .advancedBlendMode(uiEffect.createBrightnessBlender(
        //   hdsEffect.getBrightnessParam({
        //     scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
        //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_3,
        //     fraction: 0,
        //     isDarkMode: this.isDarkMode,
        //   })
        // ))
        .padding({
          top: 2,
        })
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          if (typeof newValue.height === 'number') {
            this.subTextHeight = newValue.height ?? this.subTextHeight;
            this.textOffsetY = this.enabledModeId === this.modeData.modeId ? 0 : this.subTextHeight / 2;
            LogUtil.showInfo(TAG,
              `onSizeChange. modeId:${this.modeData.modeId} height:${newValue.height} textOffsetY:${this.textOffsetY}`);
          }
        })
    }
    .constraintSize({
      minHeight: 48,
    })
    .padding({
      start: PADDING_16,
    })
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 下拉图标 Builder
   */
  @Builder
  MenuIconBuilder(): void {
    Column() {
      Image($r('app.media.ic_arrow_pull'))
        .width('12vp')
        .height('12vp')
        .draggable(false)
        .fillColor($r('sys.color.icon_secondary'))
        // .advancedBlendMode(uiEffect.createBrightnessBlender(
        //   hdsEffect.getBrightnessParam({
        //     scenario: hdsEffect.BrightnessScenario.FOREGROUND_BRIGHTNESS,
        //     level: hdsEffect.BrightnessLevel.BRIGHTNESS_LEVEL_1,
        //     fraction: 0,
        //     isDarkMode: this.isDarkMode,
        //   })
        // ))
    }
    .onClick(() => {
      LogUtil.showInfo(TAG, `Menu onClick. modeId:${this.modeData.modeId}`);
      this.isShowMenu = true;
    })
    // 注意 focusable 必须设置在 onClick 后才能使容器能键盘走焦
    .focusable(true)
    .accessibilityText(this.getTempAccessibilityText())
    .justifyContent(FlexAlign.Center)
    .width(48)
    .height(48)
    .responseRegion({
      x: 0,
      y: -8,
      width: 56,
      height: 64,
    })
  }

  build() {
    // 这层ListItem负责固定高度和绑定Menu(Menu必须绑定在一个不会缩放的容器上)
    ListItem() {
      // 这层Row负责缩放动效和hover态
      Row() {
        // 这层Row负责提亮按压(和hover互斥)
        Row() {
          // 按钮和文本热区
          Row() {
            this.ModeButtonBuilder()
            this.ModeTextBuilder()
          }
          .id(`List_item_id_${this.modeData.modeId}`)
          .layoutWeight(1)
          .accessibilityGroup(true)
          .onClick(() => {
            LogUtil.showInfo(TAG, `Row onClick. modeId:${this.modeData.modeId}`);
            this.onModeThrottleClick(this.modeData.modeId, OpenType.TURN_ON_NOW);
          })
          .padding({
            start: PADDING_8,
            end: PADDING_0,
            top: PADDING_8,
            bottom: PADDING_8,
          })
          this.MenuIconBuilder()
        }
        .width('100%')
        .borderRadius(40)
        .backgroundColor(Color.White)
        .visualEffect(this.isDarkMode ? INLINE_BACKGROUND_SECOND_DARK : INLINE_BACKGROUND_SECOND_LIGHT)
      }
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .borderRadius(40)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .onHover((isHover: boolean) => {
        this.startItemAnimation(isHover ? ITEM_SMALL_RATIO : ITEM_NORMAL_RATIO);
        this.isHover = isHover;
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.startItemAnimation(ITEM_SMALL_RATIO);
        } else if (event.type === TouchType.Up && !this.isHover) {
          this.startItemAnimation(ITEM_NORMAL_RATIO);
        }
      })
    }
    // 避免缩小动效导致列表高度变化
    .constraintSize({
      minHeight: 64,
    })
    .bindMenu(this.isShowMenu, this.menuBuilder, {
      placement: Placement.LeftBottom,
      aboutToAppear: () => {
        this.menuAppear();
      },
      aboutToDisappear: () => {
        this.menuDisappear();
      },
      onAppear: () => {
        this.menuOnShow();
      }
    })
  }

  @Builder
  menuBuilder() {
    Column() {
      ForEach(this.menuArr, (item: MenuOption, index: number) => {
        Column() {
          MenuItem(this.menuItemBuilder(item))
            .id(`menu_item_id_${item.id}`)
            .backgroundColor(this.menuItemHoverId === item.id ? $r('sys.color.interactive_hover') : Color.Transparent)
            .onHover((isHover: boolean) => {
              this.menuItemHoverId = isHover ? item.id : undefined;
            })
            .onClick(() => {
              item.onClick();
            })
          // 分割线
          if (index !== this.menuArr.length - 1) {
            Divider()
              .color($r('sys.color.comp_divider'))
              .strokeWidth('1px')
              .margin({
                left: 12,
                right: 12,
              })
          }
        }
      })
    }
    .width(216)
  }

  @Builder
  menuItemBuilder(item: MenuOption) {
    Row() {
      Column() {
        Text(item.title)
          .width('100%')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .lineHeight(LanguageUtils.getLineHeight(21))
          .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
          .margin({
            bottom: 2,
          })

        Text(this.getViewMenuSubTitle(item.id))
          .width('100%')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Subtitle_S'))
          .lineHeight(LanguageUtils.getLineHeight(19))
          .maxFontScale(this.isPocketExternalDisplayMode ? 1 : 1.8)
      }
      .layoutWeight(1)

      // 勾选图标
      if (this.enabledModeId === this.modeData.modeId && this.temporaryEnableMenuType === item.id) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize('24vp')
          .fontColor([$r('sys.color.icon_secondary')])
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          .draggable(false)
      }
    }
    .padding({
      left: 12,
      right: 12,
      top: 10,
      bottom: 10,
    })
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear. modeId:${this.modeData.modeId} isDarkMode:${this.isDarkMode}`);
    // 初始不做动效
    setTimeout(() => {
      this.isAnimation = true;
    }, ANIMATION_TIME);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    if (timerId) {
      clearTimeout(timerId);
      timerId = undefined;
    }
  }

  /**
   * 设置控制中心二级页面，下来箭头屏幕朗读文案
   *
   * @return 朗读文案
   */
  private getTempAccessibilityText(): string {
    let modeNameStr: string = ModeUtil.getModeNameStr(this.modeData);
    return ResourceUtil.getFormatStringSync($r('app.string.set_scene_temporary_time'), modeNameStr);
  }

  /**
   * 菜单初始化
   */
  private menuAppear(): void {
    this.menuArr = [
      {
        id: OpenType.TURN_ON_ONE_HOUR,
        title: ResourceUtil.getPluralStringByNameSync('time_hour', 1),
        onClick: () => {
          this.onModeThrottleClick(this.modeData.modeId, OpenType.TURN_ON_ONE_HOUR);
        }
      },
      {
        id: OpenType.TURN_ON_TWO_HOUR,
        title: ResourceUtil.getPluralStringByNameSync('time_hour', 2),
        onClick: () => {
          this.onModeThrottleClick(this.modeData.modeId, OpenType.TURN_ON_TWO_HOUR);
        }
      },
    ]
    if (SubTextUtil.isShowTonight()) {
      this.menuArr.push({
        id: OpenType.TURN_ON_TONIGHT,
        title: $r('app.string.to_tonight'),
        onClick: () => {
          this.onModeThrottleClick(this.modeData.modeId, OpenType.TURN_ON_TONIGHT);
        }
      })
    }
    LogUtil.showInfo(TAG, 'menuAppear');
  }

  /**
   * 菜单卸载
   */
  private menuDisappear(): void {
    LogUtil.showInfo(TAG, 'menuDisappear');
    AccessibilityUtils.requestFocusAccessibility(`List_item_id_${this.modeData.modeId}`);
    this.isShowMenu = false;
  }

  /**
   * 菜单上树显示
   */
  private menuOnShow(): void {
    LogUtil.showInfo(TAG, 'menuOnShow');
    AccessibilityUtils.requestFocusAccessibility(`menu_item_id_${OpenType.TURN_ON_ONE_HOUR}`,
      SCENE_BOARD_PACKAGE_NAME);
  }

  /**
   * 获取菜单视图文本显示
   */
  private getViewMenuSubTitle(type: OpenType): string {
    // 如果已经临时开启了 回显菜单项已生效的时间区间文本
    if (this.enabledModeId === this.modeData.modeId && type === this.temporaryEnableMenuType) {
      LogUtil.showInfo(TAG, `getViewMenuSubTitle. temporaryEnableMenuText:${this.temporaryEnableMenuText}`);
      return this.temporaryEnableMenuText;
    }
    return this.getMenuItemSubTitle(type);
  }

  /**
   * 获取 MenuItem 副文本
   */
  private getMenuItemSubTitle(type: OpenType): string {
    // 临时开启1小时
    if (type === OpenType.TURN_ON_ONE_HOUR) {
      const endDate: Date = new Date(this.currentTime.getTime() + TimeConstant.ONE_HOUR_MS_UNIT);
      return SubTextUtil.getTimeSegmentText(this.currentTime, endDate);
    }
    // 临时开启2小时
    if (type === OpenType.TURN_ON_TWO_HOUR) {
      const endDate: Date = new Date(this.currentTime.getTime() + TimeConstant.TWO_HOUR_MS_UNIT);
      return SubTextUtil.getTimeSegmentText(this.currentTime, endDate);
    }
    // 临时开启至下午7:00
    if (type === OpenType.TURN_ON_TONIGHT) {
      return SubTextUtil.getToTonightText();
    }
    return '';
  }

  /**
   * 获取 ListItem 副文本
   */
  private getListItemSubTitle(type: OpenType): string {
    // 临时开启1小时
    if (type === OpenType.TURN_ON_ONE_HOUR) {
      const endDate: Date = new Date(this.currentTime.getTime() + TimeConstant.ONE_HOUR_MS_UNIT);
      return SubTextUtil.getOpenToTimeText(endDate);
    }
    // 临时开启2小时
    if (type === OpenType.TURN_ON_TWO_HOUR) {
      const endDate: Date = new Date(this.currentTime.getTime() + TimeConstant.TWO_HOUR_MS_UNIT);
      return SubTextUtil.getOpenToTimeText(endDate);
    }
    // 临时开启至下午7:00
    if (type === OpenType.TURN_ON_TONIGHT) {
      return SubTextUtil.getToTonightText();
    }
    return '';
  }

  /**
   * 操作模式事件(节流)
   */
  private onModeThrottleClick(modeId: string, openType: OpenType): void {
    if (timerId) {
      LogUtil.showInfo(TAG, `onModeThrottleClick retrun. timerId:${timerId}`);
    } else {
      this.onModeClick(modeId, openType);
      timerId = setTimeout(() => {
        timerId = undefined;
      }, THROTTLE_INTERVAL_TIME);
    }
  }

  /**
   * 操作模式事件
   */
  private onModeClick(modeId: string, openType: OpenType): void {
    const isOpening: boolean = this.enabledModeId === modeId;
    LogUtil.showInfo(TAG, `onModeClick. modeId:${modeId} enabledModeId:${this.enabledModeId} isOpening:${isOpening}`);
    // 是否临时开启再取消操作
    const isReset: boolean = openType !== OpenType.TURN_ON_NOW && this.temporaryEnableMenuType === openType;
    LogUtil.showInfo(TAG,
      `onModeClick. openType:${openType} temporaryEnableMenuType:${this.temporaryEnableMenuType} isReset:${isReset}`);
    const currentModeId: string = ModeUtil.getModeOpenState().modeId;
    // 当前模式已开启 点击图标按钮/临时开启复位操作就是关闭模式
    if (isOpening && (openType === OpenType.TURN_ON_NOW || isReset)) {
      animateToImmediately({ duration: IMMEDIATELY_TIME }, () => {
        this.enabledModeId = NO_SCENE;
      });
      StateManager.getInstance().stopScene(modeId, FactorType.USER);
      ModeDataViewUtils.hiViewWhenOpenOrClose(modeId, false, EffectiveSourceType.CONTROL_CENTER, false,
        currentModeId);
    } else {
      animateToImmediately({ duration: IMMEDIATELY_TIME }, () => {
        this.enabledModeId = modeId;
        this.enableReasonText = this.getListItemSubTitle(openType);
        this.temporaryEnableMenuType = openType;
        this.temporaryEnableMenuText = this.getMenuItemSubTitle(openType);
      });
      ModeManualEnableUtil.manualStartScene(modeId, openType);
      ModeDataViewUtils.hiViewWhenOpenOrClose(modeId, true, EffectiveSourceType.CONTROL_CENTER, false, currentModeId);
    }
  }

  /**
   * 开始item的缩放动画
   */
  private startItemAnimation(scaleValue: number): void {
    animateTo({ curve: ITEM_SCALE_CURVE }, () => {
      this.scaleValue = scaleValue;
    });
  }
}