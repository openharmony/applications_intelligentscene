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
import { GroupType } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { PageType, SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { PADDING_0 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';

@Builder
function guideSwiperBuilder(item: object) {
}

export const MODE_GUIDE_SHEET: string = 'mode_guide_sheet';

function getSheetModel(): SettingPageModel {
  return {
    id: MODE_GUIDE_SHEET,
    url: MODE_GUIDE_SHEET,
    title: '',
    type: PageType.PAGE_TYPE_MODAL,
    layout: {
      hideTitleBar: true,
      alwaysEnabled: false,
      padding: {
        top: PADDING_0,
        bottom: PADDING_0,
        start: PADDING_0,
        end: PADDING_0,
      },
      backgroundColor: $r('sys.color.background_primary'),
    },
    groups: [
      {
        id: 'mode_guide_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(guideSwiperBuilder),
      },
    ],
  }
}

ModalLoader.load(MODE_GUIDE_SHEET, {
  configGenerator: getSheetModel,
  pageBuilder: wrapBuilder(settingSheetBuilder)
});
