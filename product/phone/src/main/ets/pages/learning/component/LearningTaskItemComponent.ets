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

import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ComparableSettingItemModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { PADDING_24 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { LearningModeConstant } from '../constant/LearningModeConstant';
import { EditLearningTaskTextComponent } from './EditLearningTaskTextComponent';
import { LearningPlanItem } from '../model/LearningPlanItem';

/* instrument ignore file */
const TAG: string = 'LearnTaskItemComponent: ';

@Builder
export function learningTaskItemBuilder(param: object): void {
  LearnTaskItemComponent({ param: (param as ComparableSettingItemModel).extra as LearningPlanItem });
}

@Styles
function pressedStateStyles() {
  .backgroundColor($r('sys.color.interactive_click'))
}

@Styles
function normalStateStyles() {
  .backgroundColor(Color.Transparent)
}

@Component
export struct LearnTaskItemComponent {
  @State isHover: boolean = false;
  @State hoveItem: string = '';
  public param?: LearningPlanItem;
  private planId: string = '';
  private learningPlanName: string = '';
  private itemId: string = '';
  dialogController?: CustomDialogController;

  build() {
    Row() {
      // 任务描述
      Text(this.learningPlanName)
        .layoutWeight(1)
        .fontColor($r('sys.color.font_primary'))
        .constraintSize({
          minHeight: 48
        })
        .lineHeight(19)
        .fontSize('16fp')
        .borderRadius($r('sys.float.corner_radius_level8'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .defaultFocus(true)
        .focusable(true)
        .padding({
          left: 8,
          right: 8,
          top: 12,
          bottom: 12,
        })
        .direction(LanguageUtils.isRtlDirection() ? Direction.Rtl : Direction.Ltr)
      // 删除按钮
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontColor([$r('sys.color.font_secondary')])
        .fontSize('18vp')
        .width(48)
        .height(48)
        .borderRadius($r('sys.float.corner_radius_level8'))
        .padding({start: PADDING_24})
        .monopolizeEvents(true)
        .accessibilityText(this.getDeleteAccessibilityText())
        .onClick(() => {
          this.deleteItem();
        })
    }
    .accessibilityText(this.learningPlanName)
    .constraintSize({
      minHeight: 48
    })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .onHover((hover: boolean) => {
      this.isHover = hover;
      this.hoveItem = this.learningPlanName as string;
    })
    .onClick(() => {
      this.editLearningName();
    })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .stateStyles({
      normal: {
        .backgroundColor(this.hoveItem === this.learningPlanName &&
        this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
      },
      pressed: pressedStateStyles,
    })
    .id('learningTaskItem')
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.learningPlanName = this.param?.planName ?? '';
    this.planId = this.param?.id ?? '';
    this.itemId = this.param?.itemId ?? '';
    LogUtil.showInfo(TAG, `learningPlanId, ${this.planId}, ${this.itemId}`);
  }

  aboutToDisappear(): void {
  }

  private deleteItem(): void {
    LogUtil.showInfo(TAG, `deleteItem ${this.planId}`);
    LearningPlanManager.getInstance().deleteLearningPlan(this.planId).then((result: boolean) => {
      LogUtil.showInfo(TAG, `deleteItem result : ${result}`);
      if (result) {
        EventBus.getInstance().emit(LearningModeConstant.DELETE_LEARNING_PLAN_EVENT, this.itemId);
      }
    });
  }

  private editLearningName(): void {
    LogUtil.showInfo(TAG, 'editLearningName');
    this.showEditDialog();
  }

  private showEditDialog(): void {
    this.dialogController = new CustomDialogController({
      builder: EditLearningTaskTextComponent({
        planName: this.learningPlanName,
        planId: this.planId,
        controller: this.dialogController,
        itemId: this.itemId
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      showInSubWindow: true
    });
    this.dialogController.open();
  }

  private getDeleteAccessibilityText(): string {
    return ResourceUtil.getStringSync($r('app.string.delete')) + ',' + this.learningPlanName;
  }
}