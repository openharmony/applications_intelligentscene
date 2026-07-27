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
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { DoubleButtonComponent } from '@ohos/scene.common/src/main/ets/basecomponent/button/DoubleButtonComponent';
import { LearningPlan } from '@ohos/scene.datamanage/src/main/ets/model/LearningPlan';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { LearningModeConstant } from '../constant/LearningModeConstant';
import { getErrorHint } from './EditLearningTaskTextComponent';

/* instrument ignore file */
const TAG: string = 'AddLearningTaskTextComponent: ';

@Builder
export function addLearningTaskTextItemBuilder(param: object): void {
  AddLearningTaskTextComponent();
}

@Component
export struct AddLearningTaskTextComponent {
  @State learningPlanName: string = '';
  @State isCanBeInput: boolean = true;
  @State errorHint: ResourceStr | undefined = undefined;
  @State confirmEnable: boolean = true;

  @Builder
  builderContent(): void {
    Column() {
      TextInput({ placeholder: $r('app.string.learning_plan_add_text') })
        .constraintSize({ minHeight: 48 })
        .lineHeight(19)
        .fontSize('16fp')
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .backgroundColor($r('app.color.transparent_color'))
        .defaultFocus(true)
        .showUnderline(true)
        .showError(this.errorHint)
        .onChange((value) => {
          LogUtil.showInfo(TAG, `onChange ${value?.length}`);
          this.learningPlanName = value.trim();
          this.errorHint = getErrorHint(value);
          this.isCanBeInput = this.errorHint === undefined;
        })
        .id('addLearningPlanInput')
    }.constraintSize({
      minHeight: 48
    })
    .width('100%')
    .padding({
      left: 8,
      right: 8,
    })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  builderBtn(): void {
    DoubleButtonComponent({
      cancelTitle: $r('app.string.cancel'),
      cancelAction: () => {
        this.cancelBtnClick();
      },
      confirmTitle: $r('app.string.dialog_submit'),
      confirmEnabled: this.confirmEnable && this.isCanBeInput && StringUtil.isNotEmpty(this.learningPlanName),
      confirmAction: () => {
        this.confirmEnable = false;
        this.addLearningTask();
      },
    })
  }

  build() {
    Column() {
      this.builderContent();
      this.builderBtn();
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }

  private async addLearningTask(): Promise<void> {
    LogUtil.showInfo(TAG, 'addLearningTask');
    if (this.learningPlanName && this.learningPlanName.trim()) {
      let learningPlan: LearningPlan = new LearningPlan();
      learningPlan.planName = this.learningPlanName;
      let planId: string = await LearningPlanManager.getInstance().addLearningPlan(learningPlan);
      LogUtil.showInfo(TAG, 'addLearningTask success');
      EventBus.getInstance().emit(LearningModeConstant.ADD_LEARNING_PLAN_EVENT, planId, learningPlan.planName);
      return;
    }
    LogUtil.showWarn(TAG, 'addLearningTask fail');
  }

  private cancelBtnClick(): void {
    EventBus.getInstance().emit(LearningModeConstant.CLOSE_ADD_LEARNING_TASK_DIALOG_EVENT);
  }
}