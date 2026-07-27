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

import insightIntent from '@ohos.app.ability.insightIntent';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PhoneNumberUtil } from '@ohos/scene.common/src/main/ets/utils/PhoneNumberUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ContactData, ContactLabel } from '@ohos/scene.datamanage/src/main/ets/model/base/ContactModel';
import { ContactManager } from '@ohos/scene.datamanage/src/main/ets/manager/ContactManager';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { NotDisturbAdapter } from '@ohos/scene.notdisturb/src/main/ets/adapter/NotiDisturbAdapter';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { ERROR_MSG, IntentCodeConstants } from '../constant/IntentCodeConstant';
import { IntentUtil } from '../util/IntentUtil';
import { VerifyPeriodUtil } from '../util/VerifyPeriodUtil';
import { ModeListChangeType } from '../constant/IntentType';
import { IntentConstant } from '../constant/IntentConstant';

const TAG: string = 'IntentModifyModeCallAdaptor: '
const ALLOW_CALL_POLICY: string[] = ['1', '2', '3', '4', '5', '6'];
const ALLOW_CONTACT_INDEX: number = 4;
const FORBID_CONTACT_INDEX: number = 5;

interface CallAllowContactInfo {
  phoneNumbers: string[],
}

/**
 * 意图框架修改允许联系人策略转接类
 */
export class IntentModifyModeCallAdaptor {
  /**
   * 根据模式id修改联系人策略
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 返回意图结果
   */
  static async modifyModeCallAllowPolicy(modeId: string, intentParam: Record<string, Object>):
    Promise<insightIntent.ExecuteResult> {
    let modeIdExist: boolean = await VerifyPeriodUtil.isModeIdExist(modeId);
    if (!modeIdExist) {
      LogUtil.showInfo(TAG, 'modeId not exist');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_CALL_POLICY_NOT_EXIST);
    }
    let callAllowPolicy: string = String(intentParam.callAllowPolicy);
    if (!ALLOW_CALL_POLICY.includes(callAllowPolicy)) {
      LogUtil.showError(TAG, 'modify mode allow call policy param is fail.');
      return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_CALL_POLICY_FAIL_CODE);
    }
    LogUtil.showInfo(TAG, `modify mode allow call policy callAllowPolicy is: ${callAllowPolicy}`);
    if (callAllowPolicy === ALLOW_CALL_POLICY[ALLOW_CONTACT_INDEX] ||
      callAllowPolicy === ALLOW_CALL_POLICY[FORBID_CONTACT_INDEX]) {
      const callContacts: CallAllowContactInfo[] = intentParam.callContacts as CallAllowContactInfo[];
      LogUtil.showInfo(TAG, `callContacts length is: ${callContacts?.length}`);
      if (callContacts?.length > 0) {
        const isSuccess: boolean =
          await IntentModifyModeCallAdaptor.modifyCallAllowContact(modeId, callContacts, callAllowPolicy);
        if (!isSuccess) {
          return IntentUtil.errorResponse(IntentCodeConstants.MODIFY_CALL_POLICY_FAIL_CODE);
        }
      }
    }
    await NotDisturbAdapter.getInstance().modifyAllowCallPolicyBy(modeId, callAllowPolicy);
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE,
      `${ModeListChangeType.REFRESH_MODE}${IntentConstant.CONTACT_POLICY_STRING}${modeId}_${callAllowPolicy}`);
    HiSysEventUtil.reportIntentModifyCallPolicyBehaviorEvent(callAllowPolicy, modeId);
    return IntentUtil.successResponse(IntentCodeConstants.MODIFY_CALL_POLICY_SUCCESS_CODE,
      ERROR_MSG[IntentCodeConstants.MODIFY_CALL_POLICY_SUCCESS_CODE]);
  }

  /**
   * 根据模式id添加允许打扰或禁止打扰联系人
   *
   * @param modeId 模式id
   * @param intentParam 意图参数
   * @returns 添加允许打扰或禁止打扰联系人成功 or 失败
   */
  static async addCallAllowPolicy(modeId: string, intentParam: Record<string, Object>): Promise<boolean> {
    let callAllowPolicy: string = String(intentParam.callAllowPolicy);
    if (!ALLOW_CALL_POLICY.includes(callAllowPolicy)) {
      LogUtil.showError(TAG, 'add allow call, callAllowPolicy is invalid.');
      return false;
    }
    LogUtil.showInfo(TAG, `add allow call, callAllowPolicy is: ${callAllowPolicy}`);
    // 修改模式策略
    await NotDisturbAdapter.getInstance().modifyAllowCallPolicyBy(modeId, callAllowPolicy);
    if (!intentParam.callContacts) {
      LogUtil.showInfo(TAG, 'param callContacts is empty.');
      return true;
    }
    const callContacts: CallAllowContactInfo[] = intentParam.callContacts as CallAllowContactInfo[];
    await IntentModifyModeCallAdaptor.modifyCallAllowContact(modeId, callContacts, callAllowPolicy);
    return true;
  }

  private static async modifyCallAllowContact(modeId: string, callContacts: CallAllowContactInfo[],
    callAllowPolicy: string): Promise<boolean> {
    LogUtil.showInfo(TAG, `modifyCallAllowContact: ${callContacts?.length}`);
    // 联系人列表参数为空
    if (!callContacts || callContacts.length === 0) {
      LogUtil.showError(TAG, 'modify mode allow call contact list is empty.');
      return false;
    }
    let phoneNumberSet: Set<string> = new Set();
    for (let item of callContacts) {
      for (let phoneNumber of item?.phoneNumbers) {
        phoneNumberSet.add(phoneNumber);
      }
    }
    let needInsertContactData: ContactData[] = [];
    let focusModeList: string = callAllowPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS ?
      ContactLabel.WHITE_LIST : ContactLabel.BLACK_LIST;
    for (let phoneNum of phoneNumberSet) {
      let formatPhoneNumber: string = await PhoneNumberUtil.formatPhoneNumber(phoneNum);
      let contactData: ContactData = {
        modeId: modeId,
        detailInfo: phoneNum,
        formatPhoneNumber: formatPhoneNumber,
        focusModeList: focusModeList,
      };
      let isContactExists: boolean = await ContactManager.getInstance().isContactExists(contactData);
      if (!isContactExists) {
        LogUtil.showInfo(TAG, 'add allow call, not exists this contact.');
        needInsertContactData.push(contactData);
      }
    }
    await ContactManager.getInstance().batchInsertContactData(needInsertContactData);
    return true;
  }
}