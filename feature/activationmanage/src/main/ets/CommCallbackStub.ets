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

import rpc from '@ohos.rpc';
import util from '@ohos.util';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { CommCallback } from './CommCallback';
import { CommCallbackResp } from './model/RulePostBody';
import { RuleReportUtil } from './util/RuleReportUtil';

const TAG: string = 'CommCallbackStub';
const DESCRIPTOR: string = 'com.openharmony.ohos.hiscenario.CommCallback';
const RPC_CALLBACK_CODE: number = 200;
const ACCESS_SYSTEM_SETTINGS: Permissions = 'ohos.permission.ACCESS_SYSTEM_SETTINGS';
const INTERFACE_TOKEN: string = 'com.openharmony.ohos.hiscenario.Ruleset';
const RPC_REQUEST_SUCCESS: string = 'success';

/**
 * 通用回调stub;该代码放在客户端
 *
 * @since 2024/12/30
 */
export class CommCallbackStub extends rpc.RemoteObject implements CommCallback {
  private mTextDecoder: util.TextDecoder;

  /*
   * 构造器
   *
   * @param remote IRemoteObject接口
   */
  public constructor() {
    super(DESCRIPTOR);
    this.mTextDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
  }

  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
    option: rpc.MessageOption): Promise<boolean> {
    LogUtil.showInfo(TAG, `onRemoteMessageRequest called, code:${code}`);
    if (!data) {
      LogUtil.showError(TAG, `onRemoteMessageRequest data is invalid code: ${code}`);
      return false;
    }
    let interfaceToken: string = '';
    let callbackResp: CommCallbackResp | undefined = undefined;
    try {
      const respStr: string = data.readInterfaceToken();
      if (respStr === RPC_REQUEST_SUCCESS) {
        // 兼容多啦老版本
        interfaceToken = INTERFACE_TOKEN;
      } else {
        // 多啦回调新版本
        callbackResp = JsonUtil.fromJson(respStr) as CommCallbackResp;
        interfaceToken = callbackResp.token;
      }
    } catch (err) {
      LogUtil.showError(TAG, `onRemoteMessageRequest readInterfaceToken failed ${err?.code},${err?.message}`);
      return false;
    }

    const isCallerValid: boolean =
      this.isCallerVerified(rpc.IPCSkeleton.getCallingUid(), rpc.IPCSkeleton.getCallingTokenId(), interfaceToken);
    if (!isCallerValid) {
      LogUtil.showError(TAG, 'onRemoteMessageRequest caller is invalid');
      return false;
    }

    try {
      RuleReportUtil.reportResultReceive(callbackResp);
      switch (code) {
        case RPC_CALLBACK_CODE:
          let respCode = data.readInt();
          let respText = this.readStringData(data);
          this.onResult(respCode, respText);
          return true;
        default:
          return super.onRemoteMessageRequest(code, data, reply, option);
      }
    } catch (err) {
      LogUtil.showError(TAG, `readData failed, err->${err?.message},${err?.code}`);
      return false;
    }
  }

  private isCallerVerified(callerUid: number, callerTokenId: number, interfaceToken: string): boolean {
    if (!PermissionVerifyUtil.isCallerTrusted(callerUid)) {
      LogUtil.showError(TAG, 'caller verify failed, caller is not trusted');
      return false;
    }
    if (interfaceToken !== INTERFACE_TOKEN) {
      LogUtil.showError(TAG, 'caller verify failed, token is invalid');
      return false;
    }

    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let grantStatus = atManager.verifyAccessTokenSync(callerTokenId, ACCESS_SYSTEM_SETTINGS);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        LogUtil.showError(TAG, 'Verify fail, permission denied');
        return false;
      }
    } catch (error) {
      LogUtil.showError(TAG, `Verify error: ${error?.code} ${error?.message}`);
      return false;
    }
    LogUtil.showInfo(TAG, 'Verify caller success');
    return true;
  }

  private readStringData(data: rpc.MessageSequence): string {
    try {
      let needReadRawData = data.readBoolean();
      if (needReadRawData) {
        let size = data.readInt();
        return this.bytesToString(data.readRawData(size));
      } else {
        return data.readString();
      }
    } catch (e) {
      let err: BusinessError = e as BusinessError;
      LogUtil.showError(TAG, `readData failed, err->${err?.message},${err?.code}`);
      return ''
    }
  }

  private bytesToString(arr: Array<number>): string {
    if (arr.length) {
      return '';
    }
    let data = new Uint8Array(arr);
    return this.mTextDecoder.decodeToString(data);
  }

  onResult(code: number, response: string) {
    // 空实现，由调用客户端具体覆盖实现
  }
}