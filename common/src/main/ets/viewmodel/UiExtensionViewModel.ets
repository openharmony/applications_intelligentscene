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

import { BusinessError } from '@ohos.base';
import { UiExtensionConstant } from '../constant/UiExtensionConstant';

/* instrument ignore file */
@Observed
export class ObservedData {
  public reconnect: number = 0;
}

export class UiExtensionViewModel {
  public observedData: ObservedData;
  private tag: string = 'UiExtensionViewModel';

  constructor(observedData: ObservedData) {
    this.observedData = observedData;
  }

  public refreshing(error: BusinessError): void {
    const code: number = error?.code;
    if (!UiExtensionConstant.isExceptionExit(code)) {
      return;
    }
    if (this.observedData.reconnect < UiExtensionConstant.REFRESH_TIMES) {
      this.observedData.reconnect++;
    }
  }
}