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

import Curves from '@ohos.curves';
import uiAppearance from '@ohos.uiAppearance';
import dataShare from '@ohos.data.dataShare';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { ConfirmDialogComponent } from '@ohos/scene.common/src/main/ets/basecomponent/dialog/ConfirmDialogComponent';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeData, ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { HomeUtil } from '../utils/HomeUtil';
import { ModeCardComponent, ModeCardWidth } from './ModeCardComponent';

/* instrument ignore file */
// 滑动类型
enum SwipeType {
  NONE,
  LIST,
  SWIPE,
}

// 手机滑块区域宽度阈值
const PHONE_SWIPER_WIDTH_THRESHOLD: number = 510;
// 删除按钮距离卡片间距
const DELETE_ICON_SPACE: number = 8;
// 删除按钮大小
const DELETE_ICON_SIZE: number = 40;
// 防抖间隔时间
const DEBOUNCE_INTERVAL_TIME: number = 100;

const TAG: string = 'AllModeSwiperComponent:';

@Component
export struct AllModeSwiperComponent {
  @Link isPageShowing: boolean;
  @Link gradientColor: string;
  @Link pageOpacity: number;
  // 当前已开启的modeId
  @Link enabledModeId: string;
  @State allModeArr: ModeData[] = [];
  // 当前选中的modeId
  @State currentModeId: string = ModeType.DND_MODE;
  // 顶部提示语透明度
  @State hintTextScale: number = 1;
  // 删除按钮动效
  @State deleteButtonScale: number = 0;
  @State deleteButtonOpacity: number = 0;
  // swipe组件初始index (初始化场景)
  @State swipeInitialIndex: number = 0;
  // 卡片删除中
  @State deleteModeId: string = NO_SCENE;
  // 卡片宽度
  @State cardWidth: number = DeviceUtil.isDevicePhone() ? ModeCardWidth.SMALL : ModeCardWidth.LARGE;
  private scrollerIndex: number = 0;
  // 帧数计数
  private frameNum: number = 0;
  // 上一次滑动偏移量
  private lastFrameOffset: number = 0;
  // 滑动类型
  private swipeType: SwipeType = SwipeType.NONE;
  private timerId?: number;
  private modeProfileDataHelper?: dataShare.DataShareHelper;
  private scrollerController: ListScroller = new ListScroller();
  private swiperController: SwiperController = new SwiperController();
  /**
   * 深浅色模式切换事件
   */
  private onDarkLightModeCallback = (colorMode: uiAppearance.DarkMode): void => {
    LogUtil.showInfo(TAG, `onDarkLightModeCallback. colorMode:${colorMode}`);
    // 如果模式切换涉及深浅色变换 会导致导航点组件重绘重置状态 这里把状态更新
    this.swipeInitialIndex = this.scrollerIndex;
  };
  /**
   * 所有模式数据刷新事件回调
   */
  private onRefreshAllModeCallback = (allModeArr: ModeData[]): void => {
    LogUtil.showInfo(TAG, `onRefreshAllModeCallback. allModeArr.length:${allModeArr.length}`);
    // 首次出现卡片
    if (this.allModeArr.length === 0 && allModeArr.length) {
      this.allModeArr = ModeAdapter.getInstance().getShowModeArr(this.enabledModeId);
      this.swipeInitialIndex = this.allModeArr.findIndex(it => it.modeId === this.currentModeId);
      this.updateGradientColor();
    } else {
      this.allModeArr = ModeAdapter.getInstance().getShowModeArr(this.enabledModeId);
    }
  };
  /**
   * 删除模式动效开始事件
   */
  private onModeDeleteAnimateStartCallback = (modeId: string, index: number): void => {
    const isLast = this.allModeArr.length - 1 === index;
    LogUtil.showInfo(TAG, `onModeDeleteAnimateStartCallback. modeId:${modeId} index:${index} isLast:${isLast}`);
    // 滑动变化之前先修改下 swipeInitialIndex 避免闪烁
    this.swipeInitialIndex = index;
    // 卡片下滑归位 隐藏删除按钮
    this.scrollerController.closeAllSwipeActions();
    this.deleteModeId = modeId;
    this.pageOpacity = 0;
    // 给150ms让 closeAllSwipeActions 生效
    setTimeout(() => {
      // 卡片删除动画开始
      animateTo({
        curve: Curves.interpolatingSpring(0, 0, 228, 26),
      }, () => {
        if (!isLast) {
          // 如果删除中间的卡片(右边有三个以上的卡片) 则删除的滑动不会触发onScrollIndex 需要自己来模拟
          this.currentModeId = this.allModeArr[index + 1]?.modeId;
          this.onModeDebounceChange(this.currentModeId);
        }
        // 删除卡片
        this.allModeArr = this.allModeArr.filter(it => it.modeId !== modeId);
      });
      // 200ms动画完成后状态还原
      setTimeout(() => {
        this.deleteModeId = NO_SCENE;
        this.pageOpacity = 1;
      }, 200);
    }, 150);
  };
  /**
   * 主动滑动到指定modeId事件回调
   */
  private onSwipeModeCallback = (modeId: string): void => {
    if (this.currentModeId !== modeId) {
      const index = this.allModeArr.findIndex(it => it.modeId === modeId);
      LogUtil.showInfo(TAG, `onSwipeModeCallback. modeId:${modeId} index:${index}`);
      this.swiperController.changeIndex(index, SwiperAnimationMode.DEFAULT_ANIMATION);
      this.scrollerController.scrollToIndex(index, true, ScrollAlign.CENTER);
    }
  };
  /**
   * settingsData focus_mode_profile 变化事件
   */
  private onModeProfileChangeCallback = (): void => {
    LogUtil.showInfo(TAG, 'onModeProfileChangeCallback.');
    this.getEnabledModeId();
  };

  build() {
    Column() {
      // 顶部提示语
      this.TopTipBuilder()

      if (this.allModeArr?.length) {
        // 模式滑块组件
        List({
          space: 12.8,
          initialIndex: this.swipeInitialIndex,
          scroller: this.scrollerController,
        }) {
          ForEach(this.allModeArr, (item: ModeData) => {
            ListItem() {
              ModeCardComponent({
                modeData: item,
                enabledModeId: this.enabledModeId,
                currentModeId: this.currentModeId,
                isPageShowing: this.isPageShowing,
                pageOpacity: this.pageOpacity,
                deleteModeId: this.deleteModeId,
                cardWidth: this.cardWidth,
              })
            }
            .padding({
              top: 56,
              bottom: 0,
            })
            .swipeAction(this.currentModeId === item.modeId ? {
              end: {
                builder: () => {
                  this.DeleteButtonBuilder(item);
                },
                // 上滑回弹距离
                actionAreaDistance: 8,
                onStateChange: (state: SwipeActionState) => {
                  LogUtil.showInfo(TAG, `swipeAction onStateChange. state:${state}`);
                  if (state === SwipeActionState.COLLAPSED) {
                    this.hintTextScale = 1;
                  }
                  if (state === SwipeActionState.EXPANDED) {
                    this.hintTextScale = 0;
                  }
                }
              },
              edgeEffect: SwipeEdgeEffect.None,
              onOffsetChange: (offset) => {
                if (this.currentModeId === item.modeId) {
                  this.onOffsetChange(offset);
                }
              }
            } : {})

            // 卡片的更新渲染通过改变id来实现
          }, (item: ModeData) => `${item.modeId}_${item.updateTime}`)
        }
        .friction(2.4)
        .listDirection(Axis.Horizontal)
        .edgeEffect(EdgeEffect.Spring)
        .scrollSnapAlign(ScrollSnapAlign.CENTER)
        .scrollBar(BarState.Off)
        .id('allModeSwiperList')
        .onScrollStop(() => {
          // 无障碍场景 焦点切换肯不会触发onScrollEnd 这里做兜底
          if (this.pageOpacity === 0) {
            LogUtil.showInfo(TAG, 'List onScrollStop.');
            this.pageOpacity = 1;
          }
        })
        .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
          LogUtil.showDebug(TAG, `List onDidScroll. scrollOffset:${scrollOffset} scrollState:${scrollState}`);
          // 判断滑动开始
          if (this.pageOpacity === 1 && scrollState !== ScrollState.Idle && Math.abs(scrollOffset) > 1) {
            LogUtil.showInfo(TAG, 'List onScrollStart.');
            this.pageOpacity = 0;
            this.frameNum = 0;
          }
          // 拖尾滑动阶段
          if (scrollState !== ScrollState.Scroll) {
            // 偏移量小于2且下降计数
            if (Math.abs(scrollOffset) < 2 && Math.abs(scrollOffset) < this.lastFrameOffset) {
              this.frameNum = this.frameNum + 1;
            }
            // 这里需要保证至少有6帧偏移量是下降的 确保组件处于最后的滑动拖尾中
            if (this.pageOpacity === 0 && Math.abs(scrollOffset) < 1 && this.frameNum >= 6) {
              LogUtil.showInfo(TAG, 'List onScrollEnd.');
              this.pageOpacity = 1;
            }
            this.lastFrameOffset = Math.abs(scrollOffset);
          }
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            LogUtil.showInfo(TAG, 'List onTouch. Start sliding list');
            this.swipeType = SwipeType.LIST;
          }
        })
        .onScrollIndex((start: number, end: number, center: number) => {
          this.scrollerIndex = center;
          this.currentModeId = this.allModeArr[center].modeId;
          LogUtil.showInfo(TAG,
            `List onScrollIndex. swipeType:${this.swipeType} center:${center} currentModeId:${this.currentModeId}`);
          // 文字隐藏时 直接滑动导航点场景 需要还原 hintTextScale
          if (this.hintTextScale === 0) {
            this.hintTextScale = 1;
          }
          this.listPullSwiper(center);
          this.onModeDebounceChange(this.currentModeId);
        })

        // 卡片正下方导航点
        this.NavigationPointBuilder()
      } else {
        // 初始空模式卡片 避免第一次加载高度闪烁
        ModeCardComponent({
          enabledModeId: this.enabledModeId,
          currentModeId: this.currentModeId,
          isPageShowing: this.isPageShowing,
          deleteModeId: this.deleteModeId,
          cardWidth: this.cardWidth,
        })
          .margin({
            top: 56,
            bottom: 36,
          })
      }
    }
    .margin({
      top: 16,
    })
  }

  @Builder
  TopTipBuilder(): void {
    Text($r('app.string.intelligent_scene_new_hint'))
      .opacity(this.hintTextScale)
      .animation({ duration: 150, curve: Curve.Sharp })
      .width('100%')
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Regular)
      .fontColor($r('sys.color.font_secondary'))
      .fontSize($r('sys.float.Body_M'))
      .lineHeight(LanguageUtils.getLineHeight(19))
      .padding({
        left: DeviceUtil.isDevicePhone() ? 28 : 36,
        right: DeviceUtil.isDevicePhone() ? 28 : 36,
      })
      .maxFontScale(2)
      .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
        LogUtil.showInfo(TAG, `TopTipBuilder onSizeChange. width:${newValue.width}`);
        if (DeviceUtil.isDevicePhone() && newValue.width) {
          this.cardWidth = newValue.width >= PHONE_SWIPER_WIDTH_THRESHOLD ? ModeCardWidth.MEDIUM : ModeCardWidth.SMALL;
        }
      })
  }

  /**
   * 卡片正下方导航点（与 List 联动）
   */
  @Builder
  NavigationPointBuilder(): void {
    Swiper(this.swiperController) {
      ForEach(this.allModeArr, (item: ModeData, index: number) => {
        Column()
          .height(32)
      }, (item: ModeData) => `${item.modeId}_${item.updateTime}`)
    }
    // 删除时导航点组件需要重新初始化，避免 ark 内部状态异常
    .key(`swiper_${this.deleteModeId}`)
    .margin({
      top: 4,
    })
    .index(this.swipeInitialIndex)
    .prevMargin(16)
    .nextMargin(16)
    .loop(false)
    .indicator(
      new DotIndicator()
    )
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        LogUtil.showInfo(TAG, 'Swiper onTouch. Start sliding Swiper');
        this.swipeType = SwipeType.SWIPE;
      }
    })
    .onChange((index: number) => {
      LogUtil.showInfo(TAG, `Swiper onChange. swipeType:${this.swipeType} index:${index}`);
      this.swiperPullList(index);
    })
    .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
      LogUtil.showInfo(TAG, `Swiper onAnimationStart. swipeType:${this.swipeType} targetIndex:${targetIndex}`);
      this.swiperPullList(targetIndex);
    })
    .id('swiperDotIndicator')
    .focusable(false)
  }

  @Builder
  DeleteButtonBuilder(modeData: ModeData): void {
    Column() {
      Button() {
        SymbolGlyph($r(`sys.symbol.trash_fill`))
          .fontSize('20vp')
          .fontColor([$r('sys.color.icon_on_primary')])
          .draggable(false)
      }
      .id('deleteSwipeButton')
      .visibility(this.deleteModeId !== NO_SCENE ? Visibility.None : Visibility.Visible)
      .size({
        height: DELETE_ICON_SIZE,
        width: DELETE_ICON_SIZE,
      })
      .backgroundColor('#D94838')
      .accessibilityLevel(modeData.isSupportDelete ? 'auto' : 'no')
      .accessibilityText($r('app.string.delete_mode'))
      .onClick(() => {
        if (modeData.isSupportDelete) {
          LogUtil.showInfo(TAG, `onIconClick. modeId:${modeData.modeId}`);
          HomeUtil.openDeleteModeDialog(modeData.modeId);
        }
      })
      .opacity(modeData.isSupportDelete ? 1 : 0.4)
      .scale({
        x: this.deleteButtonScale,
        y: this.deleteButtonScale,
        centerY: 0,
      })
      .monopolizeEvents(true)
    }
    .size({
      height: DELETE_ICON_SIZE,
      width: DELETE_ICON_SIZE,
    })
    .margin({
      top: DELETE_ICON_SPACE,
    })
    .opacity(this.deleteButtonOpacity)
  }

  aboutToAppear(): void {
    this.enabledModeId = ModeDetailAdapter.getInstance().getInitEnabledModeId();
    this.currentModeId = ModeDetailAdapter.getInstance().getCurrentModeId();
    this.allModeArr = ModeAdapter.getInstance().getShowModeArr(this.enabledModeId);
    LogUtil.showInfo(TAG,
      `aboutToAppear. currentModeId:${this.currentModeId} enabledModeId:${this.enabledModeId} allModeArr.length:${this.allModeArr.length}`);
    if (this.allModeArr.length > 0) {
      this.swipeInitialIndex = this.allModeArr.findIndex(it => it.modeId === this.currentModeId);
      this.updateGradientColor();
    }
    this.registerDataChange();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    if (this.timerId) {
      clearTimeout(this.timerId);
    }
    this.unRegisterDataChange();
  }

  /**
   * 注册事件
   */
  private async registerDataChange(): Promise<void> {
    LogUtil.showInfo(TAG, `registerDataChange`);
    EventBus.getInstance().on(EventBusNameConstant.ALL_MODE_REFRESH, this.onRefreshAllModeCallback);
    EventBus.getInstance().on(EventBusNameConstant.SWIPE_THIS_MODE, this.onSwipeModeCallback);
    EventBus.getInstance().on(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, this.onDarkLightModeCallback);
    EventBus.getInstance().on(EventBusNameConstant.MODE_DELETE_ANIMATE_START, this.onModeDeleteAnimateStartCallback);
    this.modeProfileDataHelper = await SettingsDataUtils.createDataHelper(SettingsDataKeyConstant.FOCUS_MODE_PROFILE);
    if (this.modeProfileDataHelper) {
      LogUtil.showInfo(TAG, `registerSecurityDataChange focus_mode_profile`);
      SettingsDataUtils.registerSecurityDataChange(this.modeProfileDataHelper,
        SettingsDataKeyConstant.FOCUS_MODE_PROFILE, this.onModeProfileChangeCallback);
    }
    // 这里查询最新结果 避免从拉起ability到组件监听完成(250ms)中间有模式切换事件
    this.getEnabledModeId();
  }

  /**
   * 卸载事件
   */
  private unRegisterDataChange(): void {
    LogUtil.showInfo(TAG, `unRegisterDataChange`);
    EventBus.getInstance().detach(EventBusNameConstant.ALL_MODE_REFRESH, this.onRefreshAllModeCallback);
    EventBus.getInstance().detach(EventBusNameConstant.SWIPE_THIS_MODE, this.onSwipeModeCallback);
    EventBus.getInstance().detach(EventBusNameConstant.DARK_LIGHT_MODE_CHANGE, this.onDarkLightModeCallback);
    EventBus.getInstance()
      .detach(EventBusNameConstant.MODE_DELETE_ANIMATE_START, this.onModeDeleteAnimateStartCallback);
    if (this.modeProfileDataHelper) {
      LogUtil.showInfo(TAG, `unRegisterSecurityDataChange focus_mode_profile`);
      SettingsDataUtils.unRegisterSecurityDataChange(this.modeProfileDataHelper,
        SettingsDataKeyConstant.FOCUS_MODE_PROFILE, this.onModeProfileChangeCallback);
    }
  }

  /**
   * 切换模式卡片(防抖)
   */
  private onModeDebounceChange(modeId: string): void {
    if (this.timerId) {
      LogUtil.showInfo(TAG, `onModeDebounceChange. timerId:${this.timerId}`);
      clearTimeout(this.timerId);
    }
    this.timerId = setTimeout(() => {
      ModeDetailAdapter.getInstance().onModeChange(modeId);
      this.timerId = undefined;
    }, DEBOUNCE_INTERVAL_TIME);
  }

  /**
   * 获取已开启的模式id
   */
  private getEnabledModeId(): void {
    const enabledModeId = ModeUtil.getModeOpenState().modeId;
    LogUtil.showInfo(TAG, `getEnabledModeId. enabledModeId:${enabledModeId}`);
    if (this.enabledModeId !== enabledModeId) {
      this.enabledModeId = enabledModeId;
      this.updateGradientColor();
      const allModeArr: ModeData[] = ModeAdapter.getInstance().getShowModeArr(this.enabledModeId);
      // 如果模式开启关闭会改变数组长度 需要避免模式卡片和导航点跳变
      if (allModeArr.length !== this.allModeArr.length) {
        this.allModeArr = allModeArr;
        const index: number = this.allModeArr.findIndex(it => it.modeId === this.currentModeId);
        this.scrollerController.scrollToIndex(index, false, ScrollAlign.CENTER);
        setTimeout(() => {
          this.swiperController.changeIndex(index, SwiperAnimationMode.NO_ANIMATION);
        })
        LogUtil.showInfo(TAG, `getEnabledModeId. currentModeId:${this.currentModeId} index:${index}`);
      }
    }
  };

  /**
   * 更新首页背景色
   */
  private updateGradientColor(): void {
    const gradientColor = this.allModeArr.find(it => it.modeId === this.enabledModeId)?.iconColor || '';
    LogUtil.showInfo(TAG, `updateGradientColor. gradientColor:${gradientColor}`);
    this.gradientColor = gradientColor;
  };

  /**
   * 开启确认弹框 勾选Checkbox
   */
  private onCheckboxChange(isChecked: boolean): void {
    LogUtil.showInfo(TAG, `onCheckboxChange. isChecked:${isChecked}`);
  }

  /**
   * list 滑动带动 swiper 滑动
   */
  private listPullSwiper(index: number): void {
    if (this.swipeType === SwipeType.LIST) {
      setTimeout(() => {
        this.swiperController.changeIndex(index, SwiperAnimationMode.DEFAULT_ANIMATION);
      })
    }
  };

  /**
   * swiper 滑动带动 list 滑动
   */
  private swiperPullList(index: number): void {
    if (this.swipeType === SwipeType.SWIPE) {
      this.scrollerController.scrollToIndex(index, true, ScrollAlign.CENTER);
    }
  };

  /**
   * 卡片上滑事件 (这里处理删除按钮相关动效)
   */
  private onOffsetChange(offset: number): void {
    const absOffset: number = Math.abs(offset);
    if (absOffset < DELETE_ICON_SPACE) {
      this.deleteButtonScale = 0;
      this.deleteButtonOpacity = 0;
    } else if (absOffset > DELETE_ICON_SIZE + DELETE_ICON_SPACE) {
      this.deleteButtonScale = 1;
      this.deleteButtonOpacity = 1;
    } else {
      let ratio = (absOffset - DELETE_ICON_SPACE) / DELETE_ICON_SIZE;
      this.deleteButtonScale = ratio;
      this.deleteButtonOpacity = ratio;
    }
  };
}