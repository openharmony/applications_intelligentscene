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

import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { SettingContentTextStyle, SettingGroupModel } from '../model/SettingGroupModel';
import { SettingGroupEventHandler, SettingGroupVM } from './SettingGroupVM';

const TAG: string = 'SettingGroupHeader';

@Component
export struct SettingGroupHeader {
  group: SettingGroupModel = { type: 0, id: '' };
  compId: string = '';
  fixedPreviousGroup: boolean = false;
  private style: SettingContentTextStyle = {};
  @State groupVM: SettingGroupVM = new SettingGroupVM();
  private eventHandler: SettingGroupEventHandler = new SettingGroupEventHandler(this.groupVM);

  private getHeight(cfgHeight: number): number {
    return this.fixedPreviousGroup ? (cfgHeight - 8) : cfgHeight;
  }

  aboutToAppear(): void {
    this.eventHandler.init(this.group, this.compId);
    this.style = PageConfig.getInstance().getGroupHeaderStyle(this.group.header);
    LogHelper.info(TAG, `group header ${this.compId} appear, visible: ${this.groupVM.visible}.`);
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `group header ${this.compId} disappear.`);
    this.eventHandler.destroy();
  }

  build() {
    if (this.group.header) {
      Column() {
        if (this.group.header.builder) {
          this.group.header.builder.builder(this.group.header);
        } else {
          Text(this.group.header.content)
            .width('100%')
            .fontSize(this.style.fontSize)
            .fontWeight(this.style.fontWeight)
            .fontColor(this.style.fontColor)
            .fontFamily(this.style.fontFamily)
            .textAlign(this.style.textAlign)
            .lineHeight(this.style.lineHeight)
            .opacity(this.style.opacity)
            .id(this.compId)
            .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
        }
      }
      .width('100%')
      .constraintSize({ minHeight: this.getHeight(this.style.height as number) })
      .padding(this.style.padding)
      .justifyContent(FlexAlign.End)
      .visibility(this.groupVM.visible ? Visibility.Visible : Visibility.None)
    }
  }
}