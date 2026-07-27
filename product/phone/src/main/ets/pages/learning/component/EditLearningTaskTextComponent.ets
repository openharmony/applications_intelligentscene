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

import { buffer } from '@kit.ArkTS';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { DoubleButtonComponent } from '@ohos/scene.common/src/main/ets/basecomponent/button/DoubleButtonComponent';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { LearningModeConstant } from '../constant/LearningModeConstant';

/* instrument ignore file */
const TAG: string = 'EditLearningTaskTextComponent: ';

@CustomDialog
export struct EditLearningTaskTextComponent {
  controller?: CustomDialogController;
  planName: string = '';
  planId: string = '';
  itemId: string = '';
  @State learningPlanName: string = '';
  @State isCanBeInput: boolean = true;
  @State errorHint: ResourceStr | undefined = undefined;

  @Builder
  buildTitle(): void {
    Text($r('app.string.learning_plan_edit_text'))
      .width('100%')
      .constraintSize({ minHeight: 56 })
      .fontSize($r('sys.float.Title_S'))
      .maxFontScale(2)
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .padding({
        top: 12,
        bottom: 12,
      })
  }

  @Builder
  builderContent(): void {
    Column() {
      TextInput({ placeholder: $r('app.string.learning_plan_edit_text'), text: this.learningPlanName })
        .constraintSize({ minHeight: 48 })
        .lineHeight(19)
        .fontSize('16fp')
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .backgroundColor($r('app.color.transparent_color'))
        .fontColor($r('sys.color.font_primary'))
        .defaultFocus(true)
        .showUnderline(true)
        .showError(this.errorHint)
        .onChange((value) => {
          LogUtil.showInfo(TAG, `onChange ${value?.length}`);
          this.learningPlanName = value.trim();
          this.errorHint = getErrorHint(value);
          this.isCanBeInput = this.errorHint === undefined;
        })
        .id('editLearningPlanInput')
    }
    .constraintSize({
      minHeight: 48,
    })
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding({
      left: 8,
      right: 8,
    })
  }

  @Builder
  builderBtn(): void {
    DoubleButtonComponent({
      cancelTitle: $r('app.string.cancel'),
      cancelAction: () => {
        this.cancelBtnClick();
      },
      confirmTitle: $r('app.string.dialog_submit'),
      confirmEnabled: this.isCanBeInput && StringUtil.isNotEmpty(this.learningPlanName),
      confirmAction: () => {
        this.saveLearningTask();
      },
    })
  }

  build() {
    Scroll() {
      Column() {
        this.buildTitle();
        this.builderContent();
        this.builderBtn();
      }
      .padding({
        left: 16,
        right: 16,
      })
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.learningPlanName = this.planName;
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }

  private async saveLearningTask(): Promise<void> {
    LogUtil.showInfo(TAG, 'saveLearningTask');
    this.controller?.close();
    if (this.learningPlanName && this.learningPlanName.trim()) {
      let isUpdateSuccess: boolean = await LearningPlanManager.getInstance()
        .updateLearningPlanName(this.planId, this.learningPlanName);
      if (isUpdateSuccess) {
        LogUtil.showInfo(TAG, 'updateLearningPlanName success');
        EventBus.getInstance()
          .emit(LearningModeConstant.EDIT_LEARNING_PLAN_NAME_EVENT, this.planId, this.learningPlanName, this.itemId);
      } else {
        LogUtil.showError(TAG, 'updateLearningPlanName error');
      }
      return;
    }
    LogUtil.showWarn(TAG, 'updateLearningPlanName fail');
  }

  private cancelBtnClick(): void {
    this.controller?.close();
  }
}

/**
 * 实时校验并联动按钮
 */
export function getErrorHint(title: string): ResourceStr | undefined {
  let byteLength: number = 0;
  try {
    byteLength = buffer.from(title || '', 'utf8')?.length;
    LogUtil.showInfo(TAG, `buffer.from. byteLength:${byteLength}`);
  } catch (error) {
    LogUtil.showError(TAG, `buffer.from catch error. code:${error?.code} message:${error?.message}`);
  }
  let hint: ResourceStr | undefined = undefined;
  if (byteLength > LearningModeConstant.MAX_LEARNING_PLAN_NAME_LENGTH) {
    hint = $r('app.string.input_max_length_message');
  }
  return hint;
}