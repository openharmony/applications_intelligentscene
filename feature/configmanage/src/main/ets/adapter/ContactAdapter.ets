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

import settings from '@ohos.settings';
import taskpool from '@ohos.taskpool';
import dataShare from '@ohos.data.dataShare';
import { Context } from '@kit.AbilityKit';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ContactManager } from '@ohos/scene.datamanage/src/main/ets/manager/ContactManager';
import { ContactData } from '@ohos/scene.datamanage/src/main/ets/model/base/ContactModel';
import { ContactsColumns } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';

@Concurrent
async function querySettingsSelectContacts(phoneNumbers: string[], context: Context, type: number, tag: string):
  Promise<number> {
  const contentIdSet: Set<string> = new Set<string>();
  const contactDataList: ContactDataTable[] = [];
  let resultSet: DataShareResultSet | undefined = undefined;
  try {
    const dataShareHelper: dataShare.DataShareHelper = await dataShare
      .createDataShareHelper(context, ContactsColumns.CONTENT_URI, {});
    const condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(ContactsColumns.TYPE_ID, type);
    condition.in(ContactsColumns.DETAIL_INFO, phoneNumbers);
    const columns: string[] =
      [ContactsColumns.ID, ContactsColumns.CONTACT_ID, ContactsColumns.DISPLAY_NAME, ContactsColumns.DETAIL_INFO];
    LogUtil.showInfo(tag, `getSettingSelectContacts. dataShareHelper.query`);
    resultSet = await dataShareHelper.query(ContactsColumns.CONTACT_DATA_URI, condition, columns);
    while (resultSet.goToNextRow()) {
      const contactDataItem: ContactDataTable = {
        id: resultSet.getString(resultSet.getColumnIndex(ContactsColumns.ID)),
        contactId: resultSet.getString(resultSet.getColumnIndex(ContactsColumns.CONTACT_ID)),
        displayName: resultSet.getString(resultSet.getColumnIndex(ContactsColumns.DISPLAY_NAME)),
        detailInfo: resultSet.getString(resultSet.getColumnIndex(ContactsColumns.DETAIL_INFO)),
      };
      contactDataList.push(contactDataItem);
      contentIdSet.add(contactDataItem.contactId);
    }
    LogUtil.showInfo(tag,
      `getSettingSelectContacts. contactDataList.length:${contactDataList.length} contentIdSet.size:${contentIdSet.size}`);
  } catch (error) {
    LogUtil.showError(tag, `getSettingSelectContacts catch error. code:${error?.code} message:${error?.message}`);
  } finally {
    resultSet?.close();
  }
  // 非联系人号码(有号�?但是并不在本机联系人�?
  const noContactPhoneNumbers: string[] = phoneNumbers?.filter(it => !contactDataList.some(i => i.detailInfo === it));
  LogUtil.showInfo(tag, `getSettingSelectContacts. noContactPhoneNumbers.length:${noContactPhoneNumbers.length}`);
  return contentIdSet.size + noContactPhoneNumbers?.length ?? 0;
}

/**
 * 联系人数据表数据类型 (根据表结构自行拓展使�?
 */
interface ContactDataTable {
  id: string;
  contactId: string;
  displayName: string;
  detailInfo: string;
}

const INTELLIGENT_SCENE_DATA: string =
  'datashare:///com.ohos.intelligentscene/phone/IntelligentScene/CONTACT_DATA?Proxy=true&user=';
const INTELLIGENT_URI: string = 'datashareproxy://com.ohos.intelligentscene?user=';
const PHONE_TYPE_NUMBER: number = 5;

const TAG: string = 'ContactAdapter';

/**
 * 联系人数据适配�?
 */
export class ContactAdapter {
  private static instance?: ContactAdapter;

  public static getInstance(): ContactAdapter {
    if (ContactAdapter.instance == null) {
      ContactAdapter.instance = new ContactAdapter();
    }
    return ContactAdapter.instance;
  }

  public init(): void {
    LogUtil.showInfo(TAG, 'init');
    setTimeout(() => {
      SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_DATA,
        INTELLIGENT_SCENE_DATA, settings.domainName.USER_SECURITY);
      SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.INTELLIGENT_URI, INTELLIGENT_URI,
        settings.domainName.USER_SECURITY);
    });
  }

  public async getContactLength(modeId: string, focusModeList: string): Promise<number> {
    let contactList: string[] = await this.getContactData(modeId, focusModeList);
    const num: number = await this.getSettingSelectContacts(contactList);
    LogUtil.showInfo(TAG, `getContactLength. num:${num}`);
    return num;
  }

  public async getContactData(modeId: string, focusModeList: string): Promise<string[]> {
    let contactData: ContactData[] = await ContactManager.getInstance().queryModeDataByIdAndLabel(modeId,
      focusModeList);
    LogUtil.showInfo(TAG, `getContactData. contactData.length:${contactData.length}`);
    let contactList: Set<string> = new Set<string>();
    for (let data of contactData) {
      contactList.add(data.detailInfo);
    }
    return Array.from(contactList);
  }

  /**
   * 通过电话号码反查询联系人数据(避免一人多号导致联系人计算错误)
   */
  private async getSettingSelectContacts(phoneNumbers: string[]): Promise<number> {
    LogUtil.showInfo(TAG, `getSettingSelectContacts. phoneNumbers.length:${phoneNumbers.length}`);
    let count: number = 0;
    try {
      const task: taskpool.Task = new taskpool.Task(querySettingsSelectContacts, phoneNumbers,
        AbilityContextManager.getContext() as Context, PHONE_TYPE_NUMBER, TAG);
      count = await taskpool.execute(task, taskpool.Priority.MEDIUM) as number;
    } catch (error) {
      LogUtil.showError(TAG, `getSettingSelectContacts error: ${error?.code} ${error?.message}`);
    }
    return count;
  }
}