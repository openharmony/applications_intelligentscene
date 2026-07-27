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
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { ModalLoader } from '@ohos/scene.common/src/main/ets/framework/common/ModalLoader';
import { settingSheetBuilder } from '@ohos/scene.common/src/main/ets/framework/view/SettingSheet';
import { PageType, SettingPageModel, SettingSheetTitleIcon } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { ModalSheetKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { HOME_MODAL_GROUP_ID } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingModalState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import TriggerConditionManager from '@ohos/scene.configmanage/src/main/ets/manager/TriggerConditionManager';
import { SceneBaseDataManager } from '@ohos/scene.configmanage/src/main/ets/manager/SceneBaseDataManager';
import { HOME_PAGE_ID } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { TimedRepeatController } from './controller/TimerRepeatController';
import { TimedDetailController } from './controller/TimedDetailController';
import { TimeManager } from './manager/TimeManager';
import { timedSheetDeleteBuilder } from './view/TimedSheetDeleteComponent';

/* instrument ignore file */
const TIMED_SHEET: string = ModalSheetKey.TIMED_SHEET;
const TAG: string = 'TimedSheetPage:';

async function saveTimeCondition(): Promise<boolean> {
  const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
  const timeInfo = TimeManager.getInstance().getInfo();
  let configId: string = '';
  if (TimeManager.getInstance().isAdd) {
    configId = await TriggerConditionManager.addTriggerCondition(modeId, timeInfo);
    if (StringUtil.isNotEmpty(configId)) {
      SceneBaseDataManager.setIntelligentUsedState();
    }
  } else {
    configId = await TriggerConditionManager.updateAndActivateTriggerCondition(timeInfo);
  }
  LogUtil.showInfo(TAG, `saveTimeCondition configId:${configId}`);
  if (StringUtil.isEmpty(configId)) {
    return false;
  }
  await ModeDetailAdapter.getInstance().updateParsedConfigById(configId);
  SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_REFRESH_MODE, `refresh_${configId}`);
  return true;
}

function closeTimedSheet(): void {
  notifyCompStateChange(`${HOME_PAGE_ID}.${HOME_MODAL_GROUP_ID}.${TIMED_SHEET}`,
    new Map<SettingStateType, SettingBaseState>([
      [SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState],
    ]));
}

function getSheetModel(): SettingPageModel {
  const titleIconLeft: SettingSheetTitleIcon = {
    icon: $r('app.media.ic_close'),
    accessibilityText: ResourceUtil.getStringSync($r('app.string.cancel')),
    action: (): boolean => {
      // SettingSheet 左侧按钮点击后会关闭半模态，此处仅做占位
      return true;
    },
  };
  const titleIconRight: SettingSheetTitleIcon = {
    icon: $r('app.media.ic_ok'),
    accessibilityText: ResourceUtil.getStringSync($r('app.string.save')),
    action: (): boolean => {
      const timeInfo = TimeManager.getInstance().getInfo();
      timeInfo.enable = true;
      saveTimeCondition().then((success: boolean) => {
        if (success) {
          closeTimedSheet();
        }
      });
      return false;
    },
  };
  return {
    id: TIMED_SHEET,
    url: TIMED_SHEET,
    title: $r('app.string.timed'),
    type: PageType.PAGE_TYPE_MODAL,
    titleIconLeft: titleIconLeft,
    titleIconRight: titleIconRight,
    groups: [
      {
        id: 'repeat_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: new TimedRepeatController(),
      },
      {
        id: 'time_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        compControl: new TimedDetailController(),
      },
    ],
    stickBottomContent: {
      id: 'timed_sheet_footer',
      builder: wrapBuilder(timedSheetDeleteBuilder),
    },
  };
}

ModalLoader.load(TIMED_SHEET, {
  configGenerator: getSheetModel,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});
