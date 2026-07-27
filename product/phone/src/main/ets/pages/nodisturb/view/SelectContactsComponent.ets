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

import { contact } from '@kit.ContactsKit';
import abilityAccessCtrl, { PermissionRequestResult, Permissions } from '@ohos.abilityAccessCtrl';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { BusinessError } from '@ohos.base';
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { SettingCompState } from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { NOT_DISTURB_NUMBER_MINUS } from '@ohos/scene.notdisturb/src/main/ets/utils/NotDisturbUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/scene.common/src/main/ets/utils/FontScaleUtils';
import { AbilityUtils } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { FOCUS_BOX_PADDING_METRICS, PADDING_8 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { INCOMING_CALL_SELECT_CONTACTS } from '../controller/ContactPolicyController';
import { IncomingCallSettingController, } from '../controller/IncomingCallSettingController';
import { SelectContactsController } from '../controller/SelectContactsController';

/* instrument ignore file */
const TAG: string = 'SelectContactsComponent: ';

@Component
export struct SelectMenuComponent {
  comId: string = '';
  title?: ResourceStr;
  controller?: IncomingCallSettingController;
  @State isHover: boolean = false;

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.title)
          .fontSize($r('sys.float.Subtitle_M'))
          .lineHeight(LanguageUtils.getLineHeight(21))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_emphasize'))
          .textAlign(TextAlign.Start)
          .flexShrink(1)
          .width('100%')
      }
      .onHover((hover: boolean) => {
        this.isHover = hover;
      })
      .constraintSize({ minHeight: 48 })
      .borderRadius($r('sys.float.corner_radius_level8'))
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .padding({
        top: FontScaleUtils.getSafetyPadding(),
        bottom: FontScaleUtils.getSafetyPadding(),
        start: PADDING_8,
        end: PADDING_8,
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding(4)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}

@Component
export struct SelectContactsComponent {
  @State isShowSelect: boolean = false;
  @State controller?: IncomingCallSettingController = undefined;
  @State mSelectContactController: SelectContactsController = SelectContactsController.getInstance();
  private dialogControllerConfirm?: CustomDialogController;
  private lastSelectContacts: string[] = [];
  private selectContactCallBack = (data: object) => {
    let visible = (data as SettingCompState).state;
    this.isShowSelect = visible;
  };

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.mSelectContactController.onInit();
    let contactPolicy: string = IncomingCallUtils.getInstance().getContactPolicy();
    this.isShowSelect = contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ||
      contactPolicy === ContactPolicy.FORBID_SPECIFIED_CONTACTS;
    EventBus.getInstance().on(INCOMING_CALL_SELECT_CONTACTS, this.selectContactCallBack);

    this.showContactSetPermission();
  }

  showContactSetPermission(): void {
    LogUtil.showInfo(TAG, 'showContactSetPermission');
    this.dialogControllerConfirm = new CustomDialogController({
      autoCancel: false,
      builder: AlertDialog({
        primaryTitle: $r('app.string.intelligent_scene'),
        content: $r('app.string.permission_reason_read_write_contacts'),
        primaryButton: {
          value: $r('app.string.cancel'),
          action: () => {
          },
        },
        secondaryButton: {
          value: $r('app.string.associated_system_function'),
          action: () => {
            LogUtil.showInfo(TAG, 'showContactSetPermission startAbilityIntelligent');
            AbilityUtils.startAbilityIntelligent();
          }
        },
      }),
    });
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.mSelectContactController.onDestroy();
    EventBus.getInstance().detach(INCOMING_CALL_SELECT_CONTACTS, this.selectContactCallBack);
    this.dialogControllerConfirm?.close();
  }

  refreshUi(): void {
    LogUtil.showInfo(TAG, 'refreshUi');
    this.aboutToAppear();
  }

  build() {
    Column() {
      SelectMenuComponent({
        comId: 'add_contacts',
        title: $r('app.string.add_contacts'),
      })
    }
    .defaultFocus(true)
    .margin({
      top: 12
    })
    .onClick(() => {
      this.requestPermissions();
    })
    .visibility(this.isShowSelect ? Visibility.Visible : Visibility.None)
  }

  requestPermissions() {
    let requestPermissions: Permissions[] = [
      'ohos.permission.READ_CONTACTS',
      'ohos.permission.WRITE_CONTACTS',
    ];
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(AbilityContextManager.getContext(), requestPermissions)
        .then((data) => {
          this.dealResult(data);
        })
        .catch((err: BusinessError) => {
          LogUtil.showError(TAG, `requestPermissionsFromUser err. code: ${err.code}, message: ${err.message}`);
        });
    } catch (err) {
      LogUtil.showError(TAG, `requestPermissionsFromUser, err: ${err?.code}, ${err?.message}`);
    }
    LogUtil.showInfo(TAG, 'Application requestPermissionsFromUser end');
  }

  private dealResult(data: PermissionRequestResult) {
    let authFlag: boolean = true;
    for (let i = 0; i < data.authResults.length; i++) {
      if (data.authResults[i] === NOT_DISTURB_NUMBER_MINUS) {
        authFlag = false;
      }
    }
    LogUtil.showInfo(TAG, `authFlag: ${authFlag}`);
    if (authFlag) {
      this.pullPicker();
    } else {
      LogUtil.showInfo(TAG, 'dialogControllerConfirm open');
      this.dialogControllerConfirm?.open();
    }
  }

  private pullPicker(): void {
    this.mSelectContactController.getLastContact().then((res) => {
      this.lastSelectContacts = res;
      LogUtil.showInfo(TAG, `lastSelectContacts len: ${this.lastSelectContacts.length}`);
      let options: contact.ContactSelectionOptions;
      if (CheckEmptyUtils.isEmptyArr(this.lastSelectContacts)) {
        options = {
          isMultiSelect: true,
        };
      } else {
        let filter: contact.ContactSelectionFilter = {
          filterClause: {
            dataItem: {
              field: contact.DataField.PHONE,
              options: [{
                filterCondition: contact.FilterCondition.IN,
                value: this.lastSelectContacts
              }]
            }
          },
          filterType: contact.FilterType.DEFAULT_SELECT
        };
        options = {
          isMultiSelect: true,
          filter: filter
        };
      }
      try {
        contact.selectContacts(options, (err: BusinessError, data: contact.Contact[]) => {
          if (err) {
            LogUtil.showError(TAG, `selectContact callback: err->${err?.message}, ${err?.code}`);
            return;
          }
          LogUtil.showInfo(TAG, 'selectContact callback: success');
          this.mSelectContactController.batchSelectContactForResult(data);
        });
      } catch (err) {
        LogUtil.showInfo(TAG, `selectContacts: ${err?.code}, ${err?.message}`);
      }
    });
  }
}