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

import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ModalLoader } from '@ohos/scene.common/src/main/ets/framework/common/ModalLoader';
import { settingSheetBuilder } from '@ohos/scene.common/src/main/ets/framework/view/SettingSheet';
import { PageType, SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { PrecastModeController } from './controller/PrecastModeController';

/* instrument ignore file */
const ADD_MODE_SHEET: string = 'add_mode_sheet';

const TAG: string = 'addModeSheetPage:';

function getSheetModel(): SettingPageModel {
  const precastModeController = new PrecastModeController();
  return {
    id: ADD_MODE_SHEET,
    url: ADD_MODE_SHEET,
    title: $r('app.string.add_intelligent_scene'),
    type: PageType.PAGE_TYPE_MODAL,
    groups: [
      {
        id: 'precast_mode_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: precastModeController,
      },
    ],
    stickBottomContent: {
      id: 'agent_mode_group',
    },
  }
}

ModalLoader.load(ADD_MODE_SHEET, {
  configGenerator: getSheetModel,
  pageBuilder: wrapBuilder(settingSheetBuilder)
});
