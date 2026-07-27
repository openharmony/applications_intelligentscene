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

import call from '@ohos.telephony.call';
import { bundleManager } from '@kit.AbilityKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { ContactPolicy } from '@ohos/scene.datamanage/src/main/ets/model/IncomingCallParam';
import { ModeDetailAdapter, ParsedConfigData } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';

const TAG: string = 'IncomingCallUtils:';
const SUPPORT_ASSISTANT_AUTO_ANSWER_KEY: string = 'support_assistant_autoanswer';
const CALL_BUNDLE_NAME: string = 'com.ohos.callui';
const CALL_HAP_NAME: string = 'callui';
const VOICE_HAP_NAME: string = 'entry';

export class IncomingCallUtils {
  private static instance: IncomingCallUtils;
  private static isVoiceCapabilityEnable: boolean = call.hasVoiceCapability();

  public static getInstance(): IncomingCallUtils {
    if (IncomingCallUtils.instance) {
      return IncomingCallUtils.instance;
    }
    IncomingCallUtils.instance = new IncomingCallUtils();
    return IncomingCallUtils.instance;
  }

  public static isVoiceCapabilityDisable(): boolean {
    return !IncomingCallUtils.isVoiceCapabilityEnable;
  }

  public setMenuTitle(contactPolicy: string): string {
    let menuTitle = '';
    switch (contactPolicy) {
      case ContactPolicy.ALLOW_EVERYONE:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_everyone'));
        break;
      case ContactPolicy.ALLOW_EXISTING_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_existing_contacts'));
        break;
      case ContactPolicy.ALLOW_FAVORITE_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_favorite_contacts'));
        break;
      case ContactPolicy.ALLOW_SPECIFIED_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.allow_only_specified_contacts'));
        break;
      case ContactPolicy.FORBID_SPECIFIED_CONTACTS:
        menuTitle = ResourceUtil.getStringSync($r('app.string.forbid_only_specified_contacts'));
        break;
      default:
        menuTitle = ResourceUtil.getStringSync($r('app.string.forbid_everyone'));
        break;
    }
    return menuTitle;
  }

  public isShowRepeatCall(): boolean {
    let contactPolicy: string = this.getContactPolicy();
    return contactPolicy != ContactPolicy.ALLOW_EVERYONE;
  }

  public getContactPolicy(): string {
    const parsedConfigArr: ParsedConfigData[] =
      ModeDetailAdapter.getInstance().getParsedConfigDataByType([ConfigType.CALL_NOT_DISTURB_POLICY]);
    let contactPolicy: string = parsedConfigArr.length === 0 ? ContactPolicy.FORBID_EVERYONE :
      parsedConfigArr[0]?.configValue;
    LogUtil.showInfo(TAG, `getContactPolicy contactPolicy: ${contactPolicy}`);
    return contactPolicy;
  }

  public isSupportAutoAnswer(): boolean {
    let isSupport: boolean = false;
    LogUtil.showInfo(TAG, 'isSupportAutoAnswer begin');
    let isCallSupport: boolean = this.isMetaDataExist(SUPPORT_ASSISTANT_AUTO_ANSWER_KEY,
      CALL_BUNDLE_NAME, CALL_HAP_NAME);
    isSupport = isCallSupport && call.hasVoiceCapability();
    LogUtil.showInfo(TAG, `isCallSupport:${isCallSupport}, isSupport:${isSupport}`);
    return isSupport;
  }

  isMetaDataExist(key: string, bundleName: string, hapName: string): boolean {
    try {
      let bundleInfo = bundleManager.getBundleInfoSync(bundleName,
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA |
          bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE);
      let result: boolean = bundleInfo?.hapModulesInfo?.find((hap) => {
        return hap.name === hapName;
      })?.metadata?.find((item?) => {
        return item?.name === key;
      })?.value === 'true';
      return result;
    } catch (err) {
      LogUtil.showError(TAG, `isMetaDataExist: err code: ${err?.code}, message: ${err?.message}`);
      return false;
    }
  }
}