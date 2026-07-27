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
import {
  ItemResultType,
  ItemDetailType,
  ItemType,
  SettingItemModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey, ModalSheetKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { GroupType, SettingGroupModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { HomeGroupId, HomeGroupItemId } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ModeDetailAdapter, ParsedConfigData } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { IncomingCallSettingController } from '../../nodisturb/controller/IncomingCallSettingController';
import { NotDisturbNotificationController } from '../../nodisturb/controller/NotDisturbNotificationController';
import { SystemFunctionController } from '../controller/SystemFunctionController';
import { EnableWayController } from '../controller/EnableWayController';

/* instrument ignore file */
const TAG: string = 'HomeGroupModel:';

/**
 * 条件开启
 */
function getEnableWayGroup(): SettingGroupModel {
  return {
    id: HomeGroupId.ENABLE_WAY,
    type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
    header: {
      id: `${HomeGroupId.ENABLE_WAY}.header`,
      content: $r('app.string.condition_enable'),
    },
    footer: {
      id: `${HomeGroupId.ENABLE_WAY}.footer`,
      content: $r('app.string.condition_footer_tip'),
    },
    compControl: new EnableWayController(),
  };
}

/**
 * 允许打扰
 */
function getAllowedDisturbGroup(): SettingGroupModel {
  const currentModeId = ModeDetailAdapter.getInstance().getCurrentModeId();
  const allowedDisturbGroup: SettingGroupModel = {
    id: HomeGroupId.ALLOWED_DISTURB,
    type: GroupType.GROUP_TYPE_STANDARD,
    header: {
      id: `${HomeGroupId.ALLOWED_DISTURB}.header`,
      content: $r('app.string.allowed_disturb'),
    },
    items: [
      {
        id: HomeGroupItemId.APPLICATION,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: {
          content: $r('app.string.application'),
        },
        result: {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: '',
          },
        },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MODAL,
          destination: ModalSheetKey.APP_AND_META_SERVICES_SHEET,
          icon: $r('app.media.ic_settings_arrow'),
          sheetOptions: {
            detents: [SheetSize.LARGE],
            onAppear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:APP_AND_META_SERVICES_SHEET onAppear.');
            },
            onDisappear: () => {
              LogUtil.showInfo(TAG, 'modal sheet:APP_AND_META_SERVICES_SHEET onDisappear.');
            },
          },
        },
        visible: true,
        compControl: new NotDisturbNotificationController(),
      }
    ],
  };

  if (!IncomingCallUtils.isVoiceCapabilityDisable()) {
    const callItem: SettingItemModel = {
      id: HomeGroupItemId.CONTACT,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.incoming_call'),
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: $r('app.string.not_selected'),
        },
      },
      layout: {
        resultWidthRatio: '50%',
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('app.media.ic_settings_arrow'),
        destination: NavEntryKey.INCOMING_CALL_ENTRY,
      },
      compControl: new IncomingCallSettingController(),
    };

    allowedDisturbGroup.items?.push(callItem);
  }

  return allowedDisturbGroup;
}

/**
 * 关联系统功能
 */
function getSystemFunctionGroup(): SettingGroupModel {
  return {
    id: HomeGroupId.SYSTEM_FUNCTION,
    type: GroupType.GROUP_TYPE_DYNAMIC,
    header: {
      id: `${HomeGroupId.SYSTEM_FUNCTION}.header`,
      content: $r('app.string.associated_system_function'),
    },
    compControl: new SystemFunctionController(),
  }
}

/**
 * 特殊配置
 */
function getSpecialConfigGroup(): SettingGroupModel {
  return {
    id: HomeGroupId.SPECIAL_CONFIG,
    type: GroupType.GROUP_TYPE_STANDARD,
    header: {
      id: `${HomeGroupId.SPECIAL_CONFIG}.header`,
      content: $r('app.string.advanced'),
    },
    items: [
      {
        id: HomeGroupItemId.EXTREME_BATTERY_LIFE,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: {
          content: $r('app.string.extreme_battery_life'),
        },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
          icon: $r('app.media.ic_settings_arrow'),
          destination: NavEntryKey.SPECIAL_SETTING_ENTRY,
        },
      },
    ],
  }
}

/**
 * 模式详情标准控件
 */
export function getHomeGroups(): SettingGroupModel[] {
  const settingGroupModel: SettingGroupModel[] = [
    getEnableWayGroup(),
    getAllowedDisturbGroup(),
    getSystemFunctionGroup(),
    getSpecialConfigGroup(),
  ];
  return settingGroupModel;
}