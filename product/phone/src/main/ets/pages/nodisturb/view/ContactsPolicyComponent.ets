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

import { emitter } from '@kit.BasicServicesKit';
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';
import { CONTACT_POLICY_KEY_MAP } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AccessibilityUtils } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { FontScaleUtils } from '@ohos/scene.common/src/main/ets/utils/FontScaleUtils';
import { PADDING_0, PADDING_8, PADDING_16 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ContactPolicyController } from '../controller/ContactPolicyController';

/* instrument ignore file */
@Styles
function pressedStateStyles() {
  .backgroundColor($r('sys.color.interactive_click'))
}

@Component
struct RadioComponent {
  compId: string = '';
  title: string = '';
  @State controller?: ContactPolicyController = undefined;
  @State isHover: boolean = false;
  @State isChecked: boolean = false;
  private policyChangeCallBack = (value: string, modifyModeId: string) => {
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const policy: string = CONTACT_POLICY_KEY_MAP.get(this.compId) ?? '';
    LogUtil.showInfo(TAG,
      `policyChangeCallBack, value: ${value}, policy ${policy}, modeId: ${modeId}, modifyModeId: ${modifyModeId}`);
    this.isChecked = modifyModeId === modeId && value === policy;
  }
  /**
   * 联系人策略修改回调
   */
  private allowContactsCallback = (eventData: emitter.EventData) => {
    const settingsValue: string = eventData.data?.settingsValue;
    LogUtil.showInfo(TAG, `receive event: ${settingsValue} ${this.title}, ${this.isChecked}`);
    this.isChecked = settingsValue === CONTACT_POLICY_KEY_MAP.get(this.compId);
  }

  aboutToAppear(): void {
    EventBus.getInstance().on(EventBusNameConstant.ALLOW_CONTACTS_CHANGE, this.allowContactsCallback);
    EventBus.getInstance().on(EventBusNameConstant.AGENT_MODIFY_CONTACT_POLICY_EVENT, this.policyChangeCallBack);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(EventBusNameConstant.ALLOW_CONTACTS_CHANGE, this.allowContactsCallback);
    EventBus.getInstance().detach(EventBusNameConstant.AGENT_MODIFY_CONTACT_POLICY_EVENT, this.policyChangeCallBack);
  }

  build() {
    Row() {
      // 文本
      Text(this.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .lineHeight(LanguageUtils.getLineHeight(21))
        .textAlign(TextAlign.Start)
        .flexShrink(0)
        .flexGrow(1)
        .layoutWeight(1)
      // 勾选框
      if (this.isChecked) {
        Radio({
          value: this.compId,
          group: 'dormancy_dialog_group'
        })
          .accessibilityLevel('no')
          .checked(true)
          .margin({
            start: PADDING_16,
            top: PADDING_0,
            bottom: PADDING_0,
            end: PADDING_0,
          })
          .size({
            height: 20,
            width: 20,
          })
          .hitTestBehavior(HitTestMode.None)
          .id(`contacts_radiomenu_radio_${this.compId}`)
      }
    }
    .padding({
      top: FontScaleUtils.getSafetyPadding(),
      bottom: FontScaleUtils.getSafetyPadding(),
      start: PADDING_8,
      end: PADDING_8,
    })
    .constraintSize({ minHeight: 48 })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
    .stateStyles({
      normal: {
        .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
      },
      pressed: pressedStateStyles,
    })
    .defaultFocus(true)
    .id(this.compId)
    .accessibilityChecked(this.isChecked)
    .accessibilityGroup(true)
    .onClick((event) => {
      if (this.isChecked) {
        return;
      }
      AccessibilityUtils.announceText($r('app.string.be_chosen'));
      this.controller?.onRadioChecked(CONTACT_POLICY_KEY_MAP.get(this.compId) ?? '');
    })
  }
}

const TAG: string = 'ContactsPolicyComponent';

@Component
export struct ContactsPolicyComponent {
  private contactPolicy: string = '1';
  private policyKeyArray: string[] = [];
  private contactPolicyArray: string[] = [];
  private contactPolicyController: ContactPolicyController | undefined = undefined;

  @Builder
  itemDividerBuilder(): void {
    Divider()
      .strokeWidth('2px')
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .padding({
        left: $r('sys.float.padding_level4'),
        right: $r('sys.float.padding_level4'),
      })
  }

  build() {
    Column() {
      ForEach(this.policyKeyArray, (key: string, index: number) => {
        RadioComponent({
          compId: key,
          title: IncomingCallUtils.getInstance().setMenuTitle(this.contactPolicyArray[index]),
          controller: this.contactPolicyController,
          isChecked: this.contactPolicy === this.contactPolicyArray[index],
        })
        if (index !== this.policyKeyArray.length - 1) {
          this.itemDividerBuilder()
        }
      })
    }
    .padding($r('sys.float.padding_level2'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  aboutToAppear(): void {
    for (const key of CONTACT_POLICY_KEY_MAP.keys()) {
      this.policyKeyArray.push(key);
      this.contactPolicyArray.push(CONTACT_POLICY_KEY_MAP.get(key) ?? '');
    }
    this.contactPolicy = IncomingCallUtils.getInstance().getContactPolicy();
    if (!this.contactPolicy) {
      LogUtil.showWarn(TAG, `parse config data failed.`);
    }
    this.contactPolicyController = new ContactPolicyController(this.contactPolicy);
    LogUtil.showInfo(TAG, `aboutToAppear current contactPolicy is: ${this.contactPolicy}`);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }
}