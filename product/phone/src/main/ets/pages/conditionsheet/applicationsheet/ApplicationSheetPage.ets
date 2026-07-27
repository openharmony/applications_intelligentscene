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

import { ModalLoader } from '@ohos/scene.common/src/main/ets/framework/common/ModalLoader';
import { PageType, SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { ApplicationSelectComponent } from './view/ApplicationSelectComponent';

/* instrument ignore file */
const APPLICATION_SHEET: string = 'application_sheet';

@Builder
export function applicationSelectComponentBuilder(item: object) {
  ApplicationSelectComponent();
}

function getSheetModel(): SettingPageModel {
  return {
    id: APPLICATION_SHEET,
    url: APPLICATION_SHEET,
    type: PageType.PAGE_TYPE_CUSTOM,
    layout: {
      blurStyle: BlurStyle.NONE,
    }
  }
}

ModalLoader.load(APPLICATION_SHEET, {
  configGenerator: getSheetModel,
  pageBuilder: wrapBuilder(applicationSelectComponentBuilder),
});
