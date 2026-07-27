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

import { PADDING_8 } from '../common/StyleConstant';
import { DefaultPageConfig } from '../common/DefaultPageConfig';
import { EventBus } from '../common/EventBus';
import { EventBusNameConstant } from '../../constant/EventBusNameConstant';
import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { PageParams } from '../common/PageLoader';
import { SettingItemModel, SettingSheetTitleStyle } from '../model/SettingItemModel';
import {
  DefaultSettingPageModel,
  SettingPageLayout,
  SettingPageModel,
  SettingSheetPageContext
} from '../model/SettingPageModel';
import { SettingBaseState, SettingCompState, SettingContentState, SettingStateType } from '../model/SettingStateModel';
import { SettingPage } from './SettingPage';
import { ResourceUtil } from '../../utils/ResourceUtil';

const TAG: string = 'SettingSheet';

@Extend(Image)
function iconStyle(length: Length, margin?: LocalizedPadding) {
  .width(length)
  .height(length)
  .draggable(false)
  .syncLoad(true)
  .matchTextDirection(true)
  .margin(margin)
}

@Component
struct SettingSheet {
  pageParam?: PageParams;
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();
  private compId: string = '';
  private layout?: SettingPageLayout;
  private sheetTitleLayout?: SettingSheetTitleStyle;
  private sheetPageCtx?: SettingSheetPageContext;
  private isSheetHome: boolean = false;
  @State pathStack: NavPathStack = new NavPathStack();
  @State pageTitle: ResourceStr = '';
  @State sheetType: SheetType = SheetType.BOTTOM;
  @State rightTitleButtonEnabled: boolean = true;
  /**
   * 模态框类型变化事件回调
   */
  private onSheetTypeChangeCallback = (sheetType: SheetType): void => {
    LogHelper.info(TAG, `onSheetTypeChangeCallback. sheetType:${sheetType}`);
    this.sheetType = sheetType;
  };

  private procTitleEvent(value: SettingBaseState): void {
    let titleContent = value as SettingContentState;
    if (!titleContent?.content) {
      LogHelper.error(TAG, 'invaild title state event');
      return;
    }
    LogHelper.info(TAG, 'enabled state change.');
    this.pageTitle = titleContent.content;
  }

  private registerRightButtonEnabledEvent(): void {
    EventBus.getInstance().on(`${this.compId}.rightConfirmButton`, (data: object) => {
      if (!(data instanceof Map)) {
        LogHelper.error(TAG, 'invalid eventbus data type.');
      }

      let eventData = data as Map<SettingStateType, SettingBaseState>;
      eventData.forEach((value: SettingBaseState, key: SettingStateType) => {
        switch (key) {
          case SettingStateType.STATE_TYPE_ITEM_ENABLED:
            const compState = value as SettingCompState;
            this.rightTitleButtonEnabled = compState.state;
            break;
          default:
            LogHelper.error(TAG, `invalid event data key: ${key}:`);
            break;
        }
      });
    });
  }

  private registerPageEvent(): void {
    EventBus.getInstance().on(this.compId, (data: object) => {
      if (!(data instanceof Map)) {
        LogHelper.error(TAG, 'invaild eventbus data type.');
      }

      let eventData = data as Map<SettingStateType, SettingBaseState>;
      eventData.forEach((value: SettingBaseState, key: SettingStateType) => {
        switch (key) {
          case SettingStateType.STATE_TYPE_PAGE_TITLE:
            this.procTitleEvent(value);
            break;
          default:
            LogHelper.error(TAG, `invaild event data key: ${key}`);
            break;
        }
      })
    });
  }

  @Builder
  sheetTitle(): void {
    Row() {
      if (this.pageInfo.titleIconLeft) {
        Button({ type: ButtonType.Circle }) {
          Image(this.pageInfo.titleIconLeft.icon)
            .iconStyle(24)
            .fillColor($r('sys.color.icon_primary'))
        }
        .width(40)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .accessibilityText(this.pageInfo.titleIconLeft?.accessibilityText ?? '')
        .onClick(() => {
          this.pageInfo.titleIconLeft?.action();
          LogHelper.info(TAG, `click to close sheet page ${this.compId}`);
          if (this.sheetPageCtx?.itemComp) {
            let item: SettingItemModel = this.sheetPageCtx.itemComp as SettingItemModel;
            item.onItemEvent?.(new Map([[
              SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingCompState
            ]]));
          }
        })
      }

      Text(this.pageTitle)
        .minFontSize(12)
        .maxFontSize(20)
        .heightAdaptivePolicy(TextHeightAdaptivePolicy.MAX_LINES_FIRST)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxFontScale(1.8)
        .margin({
          start: PADDING_8,
          end: PADDING_8
        })

      Button({ type: ButtonType.Circle }) {
        Image(this.pageInfo?.titleIconRight?.icon ?? $r('app.media.ic_close'))
          .iconStyle(this.pageInfo?.titleIconRight?.icon ? 24 : 18)
          .matchTextDirection(this.pageInfo?.titleIconRight?.matchTextDirection ?? true)
          .fillColor($r('sys.color.icon_primary'))
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .accessibilityText(this.pageInfo?.titleIconRight?.accessibilityText ?? ResourceUtil
        .getStringSync($r('app.string.close_button')))
      .id(`${this.compId}.rightConfirmButton`)
      .enabled(this.rightTitleButtonEnabled)
      .onClick(() => {
        LogHelper.info(TAG, `click to close sheet page ${this.compId}`);
        if (this.pageInfo.titleIconRight?.action) {
          const isCloseSheetPage: boolean = this.pageInfo.titleIconRight.action();
          if (isCloseSheetPage) {
            this.closeSheetPage();
          }
          return;
        }
        this.closeSheetPage();
      })
    }
    .height('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      start: this.layout?.padding?.start,
      end: this.layout?.padding?.end,
      top: this.isSheetHome ? PADDING_8 : undefined,
    })
  }

  @Builder
  sheetPageBuilder(param: PageParams): void {
    if (param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(param);
    }
  }

  @Builder
  pagesMap(name: string, param: object): void {
    if (param) {
      this.sheetPageBuilder(param as PageParams)
    }
  }

  aboutToAppear(): void {
    this.compId = `${this.pageParam?.router}.SheetPage.${this.pageInfo.id}`;
    LogHelper.info(TAG, `sheet page ${this.compId} appear`);
    this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    this.layout = PageConfig.getInstance().getPageLayout(this.pageInfo);
    this.sheetTitleLayout = DefaultPageConfig.getInstance().getDefaultSheetTitleLayout();
    this.pageTitle = this.pageInfo.title ?? '';
    this.registerPageEvent();
    this.registerRightButtonEnabledEvent();
    if (!this.sheetPageCtx.pathStack) {
      this.sheetPageCtx.pathStack = this.pathStack;
      this.isSheetHome = true;
    }
    EventBus.getInstance().on(EventBusNameConstant.SHEET_TYPE_CHANGE, this.onSheetTypeChangeCallback);
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `sheet page ${this.compId} disappear`);
    EventBus.getInstance().off(this.compId);
    EventBus.getInstance().off(`${this.compId}.rightConfirmButton`);
    EventBus.getInstance().detach(EventBusNameConstant.SHEET_TYPE_CHANGE, this.onSheetTypeChangeCallback);
  }

  build() {
    if (this.isSheetHome) {
      Navigation(this.pathStack) {
        SettingPage({
          pageParam: this.pageParam,
          pageInfo: this.pageInfo,
          sheetType: this.sheetType,
        })
      }
      .id(this.compId)
      .size({ width: '100%', height: '100%' })
      .backgroundColor(this.layout?.backgroundColor)
      .backgroundBlurStyle(this.layout?.blurStyle)
      .hideTitleBar(this.layout?.hideTitleBar)
      .title({
        builder: this.sheetTitle(),
        // 一级页面不能给边距 避免路由切换压暗不全
        height: 64,
      })
      .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      .navDestination(this.pagesMap)
    } else {
      NavDestination() {
        SettingPage({
          pageParam: this.pageParam,
          pageInfo: this.pageInfo,
          sheetType: this.sheetType,
        })
      }
      .id(this.compId)
      .size({ width: '100%', height: '100%' })
      .title({
        builder: this.sheetTitle(),
        height: this.sheetTitleLayout?.titleHeight,
      })
      .hideTitleBar(this.layout?.hideTitleBar)
      .backgroundColor(this.layout?.backgroundColor)
      .backgroundBlurStyle(this.layout?.blurStyle)
      .padding({
        top: 8
      })
    }
  }

  private closeSheetPage(): void {
    if (this.sheetPageCtx?.itemComp) {
      let item: SettingItemModel = this.sheetPageCtx.itemComp as SettingItemModel;
      item.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingCompState
      ]]));
    }
  }
}

@Builder
export function settingSheetBuilder(param: object): void {
  SettingSheet({
    pageParam: (param as PageParams),
    pageInfo: (param as PageParams).pageCtx.configGenerator(),
  });
}