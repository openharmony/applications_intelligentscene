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

import { EventBus } from '../common/EventBus';
import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { SettingContentTextStyle, SettingGroupModel } from '../model/SettingGroupModel';
import {
  SettingBaseState,
  SettingCompState,
  SettingContentState,
  SettingStateType
} from '../model/SettingStateModel';
import { SettingGroupFooterEventHandler, SettingGroupVM } from './SettingGroupVM';

const TAG: string = 'SettingGroupFooter';

@Component
export struct SettingGroupFooter {
  group: SettingGroupModel = { type: 0, id: '' };
  compId: string = '';
  private style: SettingContentTextStyle = {};
  @State groupVM: SettingGroupVM = new SettingGroupVM();
  @State footerContent: ResourceStr = '';
  private eventHandler: SettingGroupFooterEventHandler = new SettingGroupFooterEventHandler(this.groupVM);
  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogHelper.error(TAG, 'invaild eventbus data type.');
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };

  aboutToAppear(): void {
    this.style = PageConfig.getInstance().getGroupFooterStyle(this.group.footer);
    this.footerContent = this.group.footer?.content ?? '';
    LogHelper.info(TAG, `group footer ${this.compId} appear.`);
    this.eventHandler.init(this.group, this.compId);
    EventBus.getInstance().on(this.compId, this.eventCb);
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `group footer ${this.compId} disappear.`);
    EventBus.getInstance().detach(this.compId, this.eventCb);
    this.eventHandler.destroy();
  }

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      if (!value) {
        return;
      }

      switch (key) {
        case SettingStateType.STATE_TYPE_GROUP_FOOTER_CONTENT:
          this.procContentEvent(value);
          break;
        case SettingStateType.STATE_TYPE_GROUP_FOOTER_VISIBLE:
          this.procVisibleChange(value as SettingCompState);
          break;
        default:
          LogHelper.error(TAG, `invaild event data key: ${key}`);
          break;
      }
    })
  }

  private procContentEvent(value: SettingBaseState): void {
    let footerContent = value as SettingContentState;
    if (!footerContent?.content) {
      LogHelper.error(TAG, 'invaild title state event');
      return;
    }
    LogHelper.info(TAG, 'enabled state change');
    this.footerContent = footerContent.content;
  }

  private procVisibleChange(value: SettingCompState): void {
    if (this.groupVM) {
      LogHelper.info(TAG, `${this.compId} visible change from ${this.groupVM.visible} to ${value.state}`);
      this.groupVM.visible = value.state;
    }
  }

  build() {
    if (this.group.footer) {
      Column() {
        if (this.group.footer.builder) {
          this.group.footer.builder.builder(this.group.footer);
        } else {
          Text(this.footerContent)
            .width('100%')
            .fontSize(this.style.fontSize)
            .fontWeight(this.style.fontWeight)
            .fontColor(this.style.fontColor)
            .fontFamily(this.style.fontFamily)
            .textAlign(this.style.textAlign)
            .lineHeight(this.style.lineHeight)
            .opacity(this.style.opacity)
        }
      }
      .width('100%')
      .padding(this.style.padding)
      .visibility(this.groupVM.visible ? Visibility.Visible : Visibility.None)
    }
  }
}