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

import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { BaseServiceStub, IService } from '@ohos/scene.common/src/main/ets/stub/BaseServiceStub';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { PermissionVerifyUtil } from '@ohos/scene.common/src/main/ets/utils/PermissionVerifyUtil';
import { ModeManualEnableService } from './service/ModeManualEnableService';
/* instrument ignore file */
const TAG: string = 'IntelligentSceneServiceStub';
const ACCESS_SYSTEM_SETTINGS = 'ohos.permission.ACCESS_SYSTEM_SETTINGS';

export class IntelligentSceneServiceStub extends BaseServiceStub {
  protected getServiceTag(): string {
    return TAG;
  }

  protected initServiceMap(): Map<number, () => IService> {
    return new Map([
      [ServiceCode.MODE_MANUAL_ENABLE, (): IService => new ModeManualEnableService()],
    ]);
  }

  protected async checkPermissions(callerUid: number, callerTokenId: number, tokenId: string): Promise<boolean> {
    if (!PermissionVerifyUtil.isCallerTrusted(callerUid)) {
      LogUtil.showError(TAG, 'checkPermissions caller verify failed, caller is not trusted');
      return false;
    }

    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let grantStatus = atManager.verifyAccessTokenSync(callerTokenId, ACCESS_SYSTEM_SETTINGS);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        LogUtil.showError(TAG, 'checkPermissions fail, permission denied');
        return false;
      }
      let localDescriptor = this.getDescriptor();
      if (localDescriptor !== tokenId) {
        LogUtil.showError(TAG, 'interface check failed, not original binder call.');
        return false;
      }
    } catch (error) {
      LogUtil.showError(TAG, `checkPermissions verify error: ${error?.code} ${error?.message}`);
      return false;
    }
    LogUtil.showInfo(TAG, 'checkPermissions verify success');
    return true;
  }
}

class ServiceCode {
  public static readonly MODE_ENABLE = 1;
  public static readonly MODE_MANUAL_ENABLE = 2;
}
