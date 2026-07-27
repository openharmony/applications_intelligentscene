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

import { PageLoader } from '@ohos/scene.common/src/main/ets/framework/common/PageLoader';
import { IncomingCallUtils } from '@ohos/scene.notdisturb/src/main/ets/utils/IncomingCallUtils';
import { GroupType } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { PageType, SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { NavEntryKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { PADDING_0 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { CompCtrlParam, SettingBaseModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { SelectContactsComponent } from './view/SelectContactsComponent';
import { ContactsPolicyComponent } from './view/ContactsPolicyComponent';
import { RepeatRingController } from './controller/RepeatRingController';
import { IncomingCallController } from './controller/IncomingCallController';

/* instrument ignore file */
@Builder
function contactPolicyGroupBuilder(item: object) {
  ContactsPolicyComponent();
}

@Builder
function selectContactBuilder(item: object) {
  SelectContactsComponent();
}

const REPEAT_TIME: number = 15;

// 免打扰来电界面
function incomingCallPage(): SettingPageModel {
  const isShowRepeatCall: boolean = IncomingCallUtils.getInstance().isShowRepeatCall();
  const incomingCallController: IncomingCallController = new IncomingCallController();
  return {
    id: 'IncomingCall',
    url: NavEntryKey.INCOMING_CALL_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.not_disturb_call'),
    layout: {
      padding: {
        top: PADDING_0
      },
      // 滚入「联系人」标题栏下方时，列表文字半透明渐隐
      topFadeHeight: 56,
    },
    groups: [
      {
        id: 'allow_contacts_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        header: {
          id: 'allow_contacts_header',
          content: $r('app.string.allow_contacts'),
        },
        builder: wrapBuilder(contactPolicyGroupBuilder),
      },
      {
        id: 'add_contacts_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        visible: false,
        builder: wrapBuilder(selectContactBuilder),
      },
      {
        id: 'repeat_ringing_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        footer: {
          id: 'repeat_ringing_footer',
          content: ResourceUtil.getPluralStringValueSync($r('app.plural.repeat_call_will_ring_normally'), REPEAT_TIME),
          visible: isShowRepeatCall,
        },
        visible: isShowRepeatCall,
        compControl: new RepeatRingController(),
      },
    ],
    compControl: {
      init: (param: CompCtrlParam) => {
        incomingCallController.init(param);
      },
      onPageShow: (component: SettingBaseModel) => {
        incomingCallController.onPageShow(component);
      },
      onPageHide: (component: SettingBaseModel) => {
        incomingCallController.onPageHide(component);
      },
      destroy: () => {
        incomingCallController.destroy();
      },
    }
  }
}

PageLoader.load(NavEntryKey.INCOMING_CALL_ENTRY, {
  configGenerator: incomingCallPage,
});
