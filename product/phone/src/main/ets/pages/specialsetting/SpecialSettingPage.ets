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

import { NavEntryKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { PageLoader } from '@ohos/scene.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { SpecialSetting } from './view/SpecialSetting';

/* instrument ignore file */
@Builder function specialSettingBuilder(param: object): void {
  SpecialSetting();
}

function customPage(): SettingPageModel {
  return {
    id: 'special_setting',
    url: NavEntryKey.SPECIAL_SETTING_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: '',
  }
}

PageLoader.load(NavEntryKey.SPECIAL_SETTING_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(specialSettingBuilder),
});