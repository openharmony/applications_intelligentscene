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

import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import {
  FillResourceListItem,
  LinkTextComponent
} from '@ohos/scene.common/src/main/ets/basecomponent/text/LinkTextComponent';
import { AbilityUtils } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { HomeSheetCompId } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { SettingsLinkageState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';

const TAG: string = 'GaodeGuideButtonComponent:';
const BLUE_COLOR: string = '#0A59F7';
// 禁用状态下的颜色
const FONT_ON_PRIMARY: string = '#8E8E8E';
const BUTTON_BG_COLOR: string = 'rgba(0, 0, 0, 0.05)';

interface ButtonCommonParam {
  text: ResourceStr;
  bgColor: ResourceStr;
  fontColor: ResourceStr | Color;
  enabled: boolean;
  callBack: () => void;
}

/**
 * 高德智能路况开启提示-立即体验按钮
 */
@Component
export struct GaodeGuideButtonComponent {
  private isDevicePhone: boolean = DeviceUtil.isDevicePhone();
  private isGaoDeAppStatus: boolean = false;
  @StorageProp('occupationIsCheckGaoDeProtocol') isCheckGaoDeProtocol: boolean = false;
  @State protocolList: FillResourceListItem[] = [];

  private isButtonEnabled(): boolean {
    return !this.isGaoDeAppStatus || this.isCheckGaoDeProtocol;
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Checkbox()
          .select(this.isCheckGaoDeProtocol)
          .width(20)
          .height(20)
          .margin({ left: 0, right: 0 })
          .onClick(() => {
            this.isCheckGaoDeProtocol = !this.isCheckGaoDeProtocol;
            LogUtil.showInfo(TAG, `gaode protocol isCheck: ${this.isCheckGaoDeProtocol}`);
          })

        LinkTextComponent({
          fullResource: $r('app.string.smart_road_condition_alerts_mode_four'),
          fillResourceList: this.protocolList
        })
          .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .padding({
        top: 12,
        left: this.isDevicePhone ? 16 : 8,
        right: this.isDevicePhone ? 16 : 8,
      })
      .visibility(this.isGaoDeAppStatus ? Visibility.Visible : Visibility.Hidden)

      this.buttonCommon({
        text: this.isGaoDeAppStatus ? $r('app.string.enable_now') : $r('app.string.delegation'),
        bgColor: this.isButtonEnabled() ? BLUE_COLOR : FONT_ON_PRIMARY,
        fontColor: Color.White,
        enabled: this.isButtonEnabled(),
        callBack: this.onConfirm
      });
      this.buttonCommon({
        text: $r('app.string.dialog_cancel'),
        bgColor: BUTTON_BG_COLOR,
        fontColor: BLUE_COLOR,
        enabled: true,
        callBack: this.onCancel
      });
    }
    .width('100%')
    .padding({
      left: this.isDevicePhone ? 16 : 24,
      right: this.isDevicePhone ? 16 : 24,
      bottom: this.isDevicePhone ? 16 : 24,
    })
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }

  /**
   * 关闭模态框
   */
  private closeSheet(compId: string): void {
    notifyCompStateChange(compId,
      new Map<SettingStateType, SettingBaseState>([
        [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState]
      ])
    );
  }

  private onConfirm = (): void => {
    LogUtil.showInfo(TAG, `onConfirm. gaoDeAppStatus: ${this.isGaoDeAppStatus}`);
    this.closeSheet(HomeSheetCompId.GAO_DE_SHEET_COMP_ID);
  }

  private onCancel = (): void => {
    LogUtil.showInfo(TAG, 'onCancel.');
    // 关闭模态窗
    this.closeSheet(HomeSheetCompId.GAO_DE_SHEET_COMP_ID);
  }

  @Builder
  buttonCommon(params: ButtonCommonParam) {
    Button(params.text)
      .backgroundColor(params.bgColor)
      .fontColor(params.fontColor)
      .fontSize($r('sys.float.Body_L'))
      .labelStyle({
        maxLines: 1,
        overflow: TextOverflow.Ellipsis,
        minFontSize: 8,
        maxFontSize: 16,
        heightAdaptivePolicy: TextHeightAdaptivePolicy.MAX_LINES_FIRST,
      })
      .onClick(() => {
        params.callBack();
      })
      .padding({
        top: 10,
        bottom: 10
      })
      .margin({
        top: 8
      })
      .width('100%')
      .fontWeight(FontWeight.Medium)
      .maxFontScale(1.5)
      .type(ButtonType.Capsule)
      .enabled(params.enabled)
  }
}