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

import DataShareResultSet from '@ohos.data.DataShareResultSet';
import contact from '@ohos.contact';

export enum ContactPolicyKey {
  FORBID_EVERYONE_KEY = 'forbid_everyone',
  ALLOW_EVERYONE_KEY = 'allow_everyone',
  ALLOW_EXISTING_CONTACTS_KEY = 'allow_existing_contacts',
  ALLOW_FAVORITE_CONTACTS_KEY = 'allow_favorite_contacts',
  ALLOW_SPECIFIED_CONTACTS_KEY = 'allow_specified_contacts',
  FORBID_SPECIFIED_CONTACTS_KEY = 'forbid_specified_contacts',
}

export enum ContactPolicy {
  FORBID_EVERYONE = '1',
  ALLOW_EVERYONE = '2',
  ALLOW_EXISTING_CONTACTS = '3',
  ALLOW_FAVORITE_CONTACTS = '4',
  ALLOW_SPECIFIED_CONTACTS = '5',
  FORBID_SPECIFIED_CONTACTS = '6',
}

export const CONTACT_POLICY_KEY_MAP: Map<string, string> = new Map([
  [ContactPolicyKey.FORBID_EVERYONE_KEY, ContactPolicy.FORBID_EVERYONE],
  [ContactPolicyKey.ALLOW_EVERYONE_KEY, ContactPolicy.ALLOW_EVERYONE],
  [ContactPolicyKey.ALLOW_EXISTING_CONTACTS_KEY, ContactPolicy.ALLOW_EXISTING_CONTACTS],
  [ContactPolicyKey.ALLOW_FAVORITE_CONTACTS_KEY, ContactPolicy.ALLOW_FAVORITE_CONTACTS],
  [ContactPolicyKey.ALLOW_SPECIFIED_CONTACTS_KEY, ContactPolicy.ALLOW_SPECIFIED_CONTACTS],
  [ContactPolicyKey.FORBID_SPECIFIED_CONTACTS_KEY, ContactPolicy.FORBID_SPECIFIED_CONTACTS],
]);

export const CONTACT_POLICY_MAP: Map<string, string> = new Map([
  [ContactPolicy.FORBID_EVERYONE, ContactPolicy.FORBID_EVERYONE],
  [ContactPolicy.ALLOW_EVERYONE, ContactPolicy.ALLOW_EVERYONE],
  [ContactPolicy.ALLOW_EXISTING_CONTACTS, ContactPolicy.ALLOW_EXISTING_CONTACTS],
  [ContactPolicy.ALLOW_FAVORITE_CONTACTS, ContactPolicy.ALLOW_FAVORITE_CONTACTS],
  [ContactPolicy.ALLOW_SPECIFIED_CONTACTS, ContactPolicy.ALLOW_SPECIFIED_CONTACTS],
  [ContactPolicy.FORBID_SPECIFIED_CONTACTS, ContactPolicy.FORBID_SPECIFIED_CONTACTS],
]);

export class ContactObject {
  public 'contactName': string = ''
  public 'telephone': string = ''
  public 'id': number = 0
  public 'contactId': number = 0
  public 'pickerData': contact.Contact
}

export class SpecifiedBean {
  public contactId: number = 0;
  public displayName: string | Resource;
  public phoneNum: string;
  public focusModeList: string;
  public id: number = -1;

  constructor(
    contactId: number, displayName: string, phoneNum: string, focusModeList: string, id: number
  ) {
    this.contactId = contactId;
    this.displayName = displayName;
    this.phoneNum = phoneNum;
    this.focusModeList = focusModeList;
    this.id = id;
  }
}

export class ContactsColumns {
  public static readonly CONTENT_URI: string = 'datashare:///com.ohos.contactsdataability';
  public static readonly CONTACT_DATA_URI: string = ContactsColumns.CONTENT_URI + '/contacts/contact_data';
  public static readonly ID: string = 'id';
  public static readonly CONTACT_ID: string = 'contact_id';
  public static readonly NAME_RAW_CONTACT_ID: string = 'name_raw_contact_id';
  public static readonly DISPLAY_NAME: string = 'display_name';
  public static readonly FAVORITE: string = 'favorite';
  public static readonly FOCUS_MODE_LIST: string = 'focus_mode_list';
  public static readonly IS_DELETED: string = 'is_deleted';
  public static readonly SORT: string = 'sort';
  public static readonly SORT_KEY: string = 'sort_key';
  public static readonly DETAIL_INFO: string = 'detail_info';
  public static readonly TYPE_ID: string = 'type_id';
}

export class ContactListItem {
  public static readonly COLUMNS: string[] = [ContactsColumns.ID, ContactsColumns.NAME_RAW_CONTACT_ID,
    ContactsColumns.DISPLAY_NAME, ContactsColumns.FOCUS_MODE_LIST];
  public readonly id: number;
  public readonly nameRawContactId: number;
  public readonly displayName: string;
  public readonly focusModeList: string;

  constructor(resultSet: DataShareResultSet) {
    this.id = resultSet.getLong(resultSet.getColumnIndex(ContactsColumns.ID));
    this.nameRawContactId = resultSet.getLong(resultSet.getColumnIndex(ContactsColumns.NAME_RAW_CONTACT_ID));
    this.displayName = resultSet.getString(resultSet.getColumnIndex(ContactsColumns.DISPLAY_NAME));
    this.focusModeList = resultSet.getString(resultSet.getColumnIndex(ContactsColumns.FOCUS_MODE_LIST));
  }
}

export class PushParam {
  public config?: Object | object;
  public startReason?: string;
  public subUri?: string;
  public bundleName?: string;
  public appIndex?: number;
  public itemName?: string;

  constructor(param?: Object | object, subUri?: string, bundleName?: string, appIndex?: number, itemName?: string) {
    this.config = param;
    this.subUri = subUri;
    this.bundleName = bundleName;
    this.appIndex = appIndex;
    this.itemName = itemName;
  }
}