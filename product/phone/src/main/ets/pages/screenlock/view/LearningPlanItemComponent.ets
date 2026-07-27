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

import { LengthMetrics } from '@kit.ArkUI';
import { AccessibilityUtils } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { fixVp } from '../LearningMode';

/* instrument ignore file */
const TAG = 'LearningPlanItemComponent';

@Component
export struct LearningPlanItemComponent {
  totalCount: number = 0;
  index: number = 0;
  planId: string = '';
  @StorageLink('finishPlanCount') finishPlanCount: number = AppStorage.get('finishPlanCount') ?? 0;
  @Link defaultDpi: number;
  @State planName: string = '';
  @State enable: boolean = false;

  @Builder
  private toggleView(): void {
    Toggle({
      type: ToggleType.Checkbox,
      isOn: this.enable,
    })
      .width(fixVp(this.defaultDpi, 24))
      .height(fixVp(this.defaultDpi, 24))
      .selectedColor($r('sys.color.comp_background_emphasize'))
      .hitTestBehavior(HitTestMode.None)
      .onClick(() => {
        LogUtil.showInfo(TAG, 'Toggle onItemClick');
        this.onItemClick();
      })
  }

  build() {
    Row() {
      this.toggleView();

      Column() {
        Text(this.planName)
          .fontColor(this.enable ? $r('sys.color.font_tertiary') : $r('app.color.learning_plan_unenable_color'))
          .fontSize(fixVp(this.defaultDpi, 16))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxFontScale(1.5)
      }
      .margin({ start: new LengthMetrics(fixVp(this.defaultDpi, 8)) })
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
    .accessibilityGroup(true)
    .accessibilityDescription(this.enable ? $r('app.string.be_chosen') : $r('app.string.not_selected_click_tips'))
    .width('100%')
    .onClick(() => {
      LogUtil.showInfo(TAG, 'Row onItemClick');
      this.onItemClick();
    })
    .margin({
      top: fixVp(this.defaultDpi, this.index > 0 ? 12 : 0)
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
  }

  /**
   * item点击事件
   */
  private onItemClick(): void {
    this.enable = !this.enable;
    if (this.enable) {
      this.finishPlanCount++;
      AccessibilityUtils.announceText($r('app.string.be_chosen'));
    } else {
      this.finishPlanCount--;
      AccessibilityUtils.announceText($r('app.string.not_selected_click_tips'));
    }
    LearningPlanManager.getInstance().updateLearningPlanStatus(this.planId, this.enable ? 1 : 0);
  }
}