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
import { ModalSheetKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { ItemDetailType, ItemType } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { GroupType, SettingGroupModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { HOME_MODAL_GROUP_ID } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { CALENDAR_GUIDE_DIALOG } from '@ohos/scene.common/src/main/ets/basecomponent/dialog/CalendarPermissionDialog';

const TAG: string = 'HomeModalGroupModel:';

/**
 * 首页隐藏Group （专门用来绑定半模态弹框）
 */
export function getHomeModalGroup(): SettingGroupModel {
  return {
    id: HOME_MODAL_GROUP_ID,
    type: GroupType.GROUP_TYPE_STANDARD,
    visible: false,
    items: [
      // 添加模式
      {
        id: ModalSheetKey.ADD_MODE_SHEET,
        type: ItemType.ITEM_TYPE_STANDARD,
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MODAL,
          destination: ModalSheetKey.ADD_MODE_SHEET,
          sheetOptions: {
            detents: [SheetSize.LARGE],
            onAppear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:ADD_MODE_SHEET onAppear.');
            },
            onDisappear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:ADD_MODE_SHEET onDisappear.');
            }
          }
        }
      },
      // 编辑模式
      {
        id: ModalSheetKey.EDIT_MODE_SHEET,
        type: ItemType.ITEM_TYPE_STANDARD,
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MODAL,
          destination: ModalSheetKey.EDIT_MODE_SHEET,
          sheetOptions: {
            detents: [SheetSize.LARGE],
            onAppear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:EDIT_MODE_SHEET onAppear.');
            },
            onDisappear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:EDIT_MODE_SHEET onDisappear.');
            }
          }
        }
      },
      {
        id: CALENDAR_GUIDE_DIALOG,
        type: ItemType.ITEM_TYPE_STANDARD,
        detail: {
          type: ItemDetailType.DETAIL_TYPE_DIALOG,
          dialog: {}
        },
      },
      // 定时条件
      {
        id: ModalSheetKey.TIMED_SHEET,
        type: ItemType.ITEM_TYPE_STANDARD,
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MODAL,
          destination: ModalSheetKey.TIMED_SHEET,
          sheetOptions: {
            detents: [SheetSize.LARGE],
            onAppear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:TIMED_SHEET onAppear.');
            },
            onDisappear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:TIMED_SHEET onDisappear.');
            },
          },
        },
      },
    ]
  }
}