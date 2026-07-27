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

import { ModalSheetKey, NavEntryKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';

const PAGE_PATH_MAP: Map<string, string> = new Map<string, string>([
  [NavEntryKey.NOT_DISTURB_ENTRY, '../../pages/nodisturb/NotDisturbSettingsPage'],
  [NavEntryKey.APPLICATION_ENTRY, '../../pages/nodisturb/ApplicationSettingPage'],
  [NavEntryKey.TIME_PERIOD_ENTRY, '../../pages/nodisturb/TimerPeriodEditPage'],
  [NavEntryKey.INCOMING_CALL_ENTRY, '../../pages/nodisturb/IncomingCallSettingPage'],
  [NavEntryKey.SPECIAL_SETTING_ENTRY, '../../pages/specialsetting/SpecialSettingPage'],
  [NavEntryKey.EMERGENCY_INFO_ENTRY, '../../pages/specialsetting/EmergencyInfoPage'],
]);

const MODAL_PAGE_PATH_MAP: Map<string, string> = new Map<string, string>([
  [ModalSheetKey.MODE_GUIDE_SHEET, '../../pages/modesheet/ModeGuideSheet'],
  [ModalSheetKey.ADD_MODE_SHEET, '../../pages/modesheet/AddModeSheet'],
  [ModalSheetKey.EDIT_MODE_SHEET, '../../pages/modesheet/EditModeSheet'],
  [ModalSheetKey.TIMED_SHEET, '../../pages/conditionsheet/timedsheet/TimedSheetPage'],
  [ModalSheetKey.APP_AND_META_SERVICES_SHEET, '../../pages/nodisturb/AppAndMetaservicesSheetPage'],
  [ModalSheetKey.GAO_DE_GUIDE_SHEET, '../../pages/modesheet/GaodeModeSheet'],
  [ModalSheetKey.CALENDAR_SHEET, '../../pages/conditionsheet/calendarsheet/CalendarSheetPage'],
]);

export class PageRouteController {
  private static instance: PageRouteController | undefined = undefined;

  public static getInstance(): PageRouteController {
    if (PageRouteController.instance === undefined) {
      PageRouteController.instance = new PageRouteController();
    }
    return PageRouteController.instance;
  }

  public isPageAdapted(pageEntryKey: string): boolean {
    return PAGE_PATH_MAP.has(pageEntryKey);
  }

  public getPageUrl(pageEntryKey: string): string | undefined {
    return PAGE_PATH_MAP.get(pageEntryKey);
  }

  public getModalPageUrl(modalPageEntryKey: string): string | undefined {
    return MODAL_PAGE_PATH_MAP.get(modalPageEntryKey);
  }
}