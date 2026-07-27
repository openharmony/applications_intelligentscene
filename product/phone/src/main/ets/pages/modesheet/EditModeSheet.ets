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
import { settingSheetBuilder } from '@ohos/scene.common/src/main/ets/framework/view/SettingSheet';
import { PageType, SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { EditModeComponent } from './view/EditModeComponent';
import { ConfirmButtonComponent } from './view/ConfirmButtonComponent';

/* instrument ignore file */
@Builder
function confirmButtonBuilder(item: object) {
  ConfirmButtonComponent();
}

@Builder
function editModeBuilder(item: object) {
  EditModeComponent();
}

export const EDIT_MODE_SHEET: string = 'edit_mode_sheet';

const TAG: string = 'editModeSheetPage:';

function getSheetModel(): SettingPageModel {
  return {
    id: EDIT_MODE_SHEET,
    url: EDIT_MODE_SHEET,
    title: '',
    type: PageType.PAGE_TYPE_MODAL,
    groups: [
      {
        id: 'edit_mode_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(editModeBuilder),
      },
    ],
    stickBottomContent: {
      id: 'edit_mode_footer',
      builder: wrapBuilder(confirmButtonBuilder),
    },
  }
}

ModalLoader.load(EDIT_MODE_SHEET, {
  configGenerator: getSheetModel,
  pageBuilder: wrapBuilder(settingSheetBuilder)
});
