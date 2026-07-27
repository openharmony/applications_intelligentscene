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
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PhoneNumberUtil } from '@ohos/scene.common/src/main/ets/utils/PhoneNumberUtil';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ContactData, ContactLabel } from '@ohos/scene.datamanage/src/main/ets/model/base/ContactModel';
import { ContactManager } from '@ohos/scene.datamanage/src/main/ets/manager/ContactManager';
import { ContactAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ContactAdapter';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';

/* instrument ignore file */
const TAG = 'SelectContactsController: ';
export const SELECT_CONTACTS_COUNT: string = 'select_contacts_count';

/**
 * 选择联系人菜单控制器
 */
export class SelectContactsController {
  private static sInstance: SelectContactsController;

  static getInstance() {
    if (SelectContactsController.sInstance == null) {
      SelectContactsController.sInstance = new SelectContactsController();
    }
    return SelectContactsController.sInstance;
  }

  onInit(): void {
    LogUtil.showInfo(TAG, 'init.');
  }

  async getLastContact(): Promise<string[]> {
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    let contactPolicy: string = IncomingCallUtils.getInstance().getContactPolicy();
    let focusModeList: string = contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ?
    ContactLabel.WHITE_LIST : ContactLabel.BLACK_LIST;
    let lastSelectContacts: string[] = await ContactAdapter.getInstance().getContactData(modeId, focusModeList);
    return lastSelectContacts;
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'destroy.');
  }

  batchSelectContactForResult(data: contact.Contact[]) {
    LogUtil.showInfo(TAG, `batchSelectContactForResult. data.length:${data.length}`);
    this.dealContactParams(data);
  }

  private async createContact(phone: string, modeId: string, focusModeList: string): Promise<ContactData> {
    let formatPhoneNumber: string = await PhoneNumberUtil.formatPhoneNumber(phone);
    let contact: ContactData = {
      modeId: modeId,
      detailInfo: phone,
      formatPhoneNumber: formatPhoneNumber,
      focusModeList: focusModeList
    };
    return contact;
  }

  private async dealContactParams(contactArr: contact.Contact[]) {
    LogUtil.showInfo(TAG, `dealContactParams start: ${contactArr.length}`);
    let contactData: ContactData[] = [];
    let contactInfoList: Set<string> = new Set<string>();
    let modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    let contactPolicy: string = IncomingCallUtils.getInstance().getContactPolicy();
    let focusModeList: string = contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ?
      ContactLabel.WHITE_LIST : ContactLabel.BLACK_LIST;
    for (let i = 0; i < contactArr?.length; i++) {
      let numbers: contact.PhoneNumber[] = contactArr[i]?.phoneNumbers || [];
      for (let phone of numbers) {
        if (StringUtil.isEmpty(phone?.phoneNumber)) {
          LogUtil.showWarn(TAG, 'phoneNumber is empty');
        } else {
          contactInfoList.add(phone.phoneNumber);
          let data: ContactData = await this.createContact(phone.phoneNumber, modeId, focusModeList);
          contactData.push(data);
        }
      }
    }
    ContactManager.getInstance().deleteContactDataByIdAndLabel(modeId, focusModeList).then(() => {
      ContactManager.getInstance().batchInsertContactData(contactData);
    });
    EventBus.getInstance().emit(SELECT_CONTACTS_COUNT, contactArr?.length ?? 0);
  }
}
