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

import lazy taskpool from '@ohos.taskpool';
import relationalStore from '@ohos.data.relationalStore';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { DB_CONFIG, INVALID_VALUE } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { ContactData } from '../model/base/ContactModel';
import { DateTimeUtil } from '../utils/DateTimeUtil';

@Concurrent
async function convertResultToContactList(modeId: string, focusModeList: string, context: Context, tag: string):
  Promise<ContactData[]> {
  AbilityContextManager.addContext(context);
  let resultSet: relationalStore.ResultSet | undefined = undefined;
  let result: ContactData[] = [];
  try {
    let predicates: relationalStore.RdbPredicates =
      new relationalStore.RdbPredicates(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
    predicates.equalTo('modeId', modeId);
    predicates.equalTo('focus_mode_list', focusModeList);
    resultSet = await RdbStoreHelper.getInstance().query(predicates);
    LogUtil.showInfo(tag, `resultSet: ${resultSet?.columnCount}`);
    if (!resultSet) {
      LogUtil.showWarn(tag, `convertResultToContactList result is empty`);
      return result;
    }
    LogUtil.showInfo(tag, 'convertResultToContactList start.');
    while (resultSet.goToNextRow()) {
      const contactId = resultSet.getString(resultSet.getColumnIndex('contactId'));
      const modeId = resultSet.getString(resultSet.getColumnIndex('modeId'));
      const detailInfo = resultSet.getString(resultSet.getColumnIndex('detail_info'));
      const formatPhoneNumber = resultSet.getString(resultSet.getColumnIndex('format_phone_number'));
      const focusModeList = resultSet.getString(resultSet.getColumnIndex('focus_mode_list'));
      const updateTime = resultSet.getLong(resultSet.getColumnIndex('updateTime'));
      result.push({
        contactId,
        modeId,
        detailInfo,
        formatPhoneNumber,
        focusModeList,
        updateTime,
      });
    }
    LogUtil.showInfo(tag, 'convertResultToContactList end.');
  } catch (error) {
    LogUtil.showError(tag, `convertResultToContactList error code: ${error?.code} message: ${error?.message}`);
  } finally {
    resultSet?.close();
  }
  return result;
}

const TAG: string = 'ContactManager';

export class ContactManager {
  private static singleInstance: ContactManager;

  public static getInstance(): ContactManager {
    if (!ContactManager.singleInstance) {
      ContactManager.singleInstance = new ContactManager();
    }
    return ContactManager.singleInstance;
  }

  async batchInsertContactData(contacts: ContactData[]): Promise<number> {
    LogUtil.showInfo(TAG, `batchInsertContactData: ${contacts.length}`);
    try {
      let result: number = 0;
      let valuesBuckets: relationalStore.ValuesBucket[] = [];
      contacts.forEach((contact) => {
        const nowTime: number = DateTimeUtil.getCurrentTimeStamp();
        valuesBuckets.push({
          'contactId': this.generateContactId(contact.modeId, contact.focusModeList, contact.detailInfo),
          'modeId': contact.modeId,
          'detail_info': contact.detailInfo,
          'format_phone_number': contact.formatPhoneNumber,
          'focus_mode_list': contact.focusModeList,
          'updateTime': nowTime
        });
      });
      result = await RdbStoreHelper.getInstance().batchInsert(DB_CONFIG.CONTACT_DATA.TABLE_NAME, valuesBuckets);
      LogUtil.showInfo(TAG, `batchInsertContactData changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `batchInsertConfigData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  async deleteContactDataByModeId(modeId: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteContactDataByModeId modeId: ${modeId}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
      predicates.equalTo('modeId', modeId);
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteContactDataByModeId changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteConfigDataById error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 根据modeId和focus_mode_list删除联系人数据
   *
   * @param modeId 模式id
   * @param focusModeList 联系人黑白名单标签
   * @returns 删除成功返回模式下所有的配置行数
   */
  async deleteContactDataByIdAndLabel(modeId: string, focusModeList: string): Promise<number> {
    LogUtil.showInfo(TAG, `deleteContactDataByIdAndLabel id: ${modeId}, label: ${focusModeList}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
      predicates.equalTo('modeId', modeId);
      predicates.equalTo('focus_mode_list', focusModeList);
      let result: number = await RdbStoreHelper.getInstance().delete(predicates);
      LogUtil.showInfo(TAG, `deleteConfigDataById changeRows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `deleteConfigDataById error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 更新联系人数据
   *
   * @param modeData 模式数据
   * @returns 更新成功，返回模式id；更新失败返回-1
   */
  async updateContactData(contact: ContactData): Promise<number> {
    LogUtil.showInfo(TAG, `updateContactData: ${StringUtil.getAnonymizedContactId(contact.contactId as string)}`);
    try {
      let predicates: relationalStore.RdbPredicates =
        new relationalStore.RdbPredicates(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
      predicates.equalTo('modeId', contact.modeId);
      predicates.equalTo('detail_info', contact.detailInfo);

      const updateValueBucket: relationalStore.ValuesBucket = {
        'focus_mode_list': contact.focusModeList,
        'updateTime': DateTimeUtil.getCurrentTimeStamp(),
      };
      let result: number = await RdbStoreHelper.getInstance().update(predicates, updateValueBucket);
      LogUtil.showInfo(TAG, `updateConfigData updated change rows: ${result}`);
      return result;
    } catch (error) {
      LogUtil.showError(TAG, `updateConfigData error:${error?.code}, msg: ${error?.message}`);
      return INVALID_VALUE;
    }
  }

  /**
   * 根据模式id和联系人标签查询联系人数据
   *
   * @param modeId 模式id
   * @returns 查询成功返回模式数据；查询失败返回undefined
   */
  async queryModeDataByIdAndLabel(modeId: string, focusModeList: string): Promise<ContactData[]> {
    LogUtil.showInfo(TAG, `queryModeDataByIdAndLabel, modeId: ${modeId}, focus_mode_list: ${focusModeList}`);
    let result: ContactData[] = [];
    try {
      const task: taskpool.Task = new taskpool.Task(convertResultToContactList, modeId, focusModeList,
        AbilityContextManager.getContext() as Context, TAG);
      result = await taskpool.execute(task, taskpool.Priority.MEDIUM) as ContactData[];
      LogUtil.showInfo(TAG, `queryModeDataByIdAndLabel end: ${result?.length}`);
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `queryModeDataById error: ${err?.code} ${err?.message}`);
    }
    return result;
  }

  /**
   * 查询联系人数据是否在数据库中已存在
   *
   * @param modeName 模式名称
   * @returns 存在返回true
   */
  async isContactExists(contact: ContactData): Promise<boolean> {
    let isExists: boolean = false;
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    try {
      let predicates = new relationalStore.RdbPredicates(DB_CONFIG.CONTACT_DATA.TABLE_NAME);
      predicates.equalTo('modeId', contact.modeId);
      predicates.equalTo('detail_info', contact.detailInfo);
      predicates.equalTo('focus_mode_list', contact.focusModeList);
      resultSet = await RdbStoreHelper.getInstance().query(predicates);
      isExists = resultSet ? resultSet?.rowCount > 0 : false;
    } catch (err) {
      LogUtil.showError(TAG, `isContactExists error: ${err?.code} ${err?.message}`);
    } finally {
      resultSet?.close();
    }
    return isExists;
  }


  /**
   * @param modeId 模式Id
   * @param focusModeList 选择联系人标签（1：白名单，允许指定联系人，2：黑名单，禁止指定联系人）
   * @param detailInfo 勾选联系人
   * @returns 生成的contactId
   */
  private generateContactId(modeId: string, focusModeList: string, detailInfo: string): string {
    let contactId: string = '';
    contactId = `${modeId}_${focusModeList}_${detailInfo}`;
    return contactId;
  }
}
