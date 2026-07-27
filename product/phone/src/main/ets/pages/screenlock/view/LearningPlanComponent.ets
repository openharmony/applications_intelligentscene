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
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { LearningPlan } from '@ohos/scene.datamanage/src/main/ets/model/LearningPlan';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { LearningPlanItemComponent } from './LearningPlanItemComponent';
import { fixVp } from '../LearningMode';

/* instrument ignore file */
const TAG = 'LearningPlanComponent';

@Component
export struct LearningPlanComponent {
  @State learningPlans: Array<LearningPlan> = [];
  @StorageLink('finishPlanCount') finishPlanCount: number = AppStorage.get('finishPlanCount') ?? 0;
  @Link @Watch('onDarkChange') isDarkMode: boolean;
  @Link defaultDpi: number;
  @State isLoading: boolean = true;
  private textController: TextController = new TextController();

  onDarkChange() {
    LogUtil.showInfo(TAG, `onDarkChange, isDarkMode : ${this.isDarkMode}`);
    this.onFinishALlTask();
  }

  private onFinishALlTask(): void {
    LogUtil.showInfo(TAG, 'onFinishALlTask');
    let countString: string = this.learningPlans.length.toString();
    let summarize = ResourceUtil.getPluralStringByNameSync('learning_finish_task_count', this.learningPlans.length);
    let fontStyleAttr: TextStyle = new TextStyle({
      fontColor: $r('sys.color.font_primary'),
      fontFamily: 'HarmonyHeiTi',
      fontSize: LengthMetrics.vp(fixVp(this.defaultDpi, 28)),
      fontWeight: 600
    });
    let mutableStyledString: MutableStyledString = new MutableStyledString(summarize,
      [{
        start: summarize.indexOf(countString),
        length: countString.length,
        styledKey: StyledStringKey.FONT,
        styledValue: fontStyleAttr
      }]
    );
    this.textController.setStyledString(mutableStyledString);
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.learningPlans = await LearningPlanManager.getInstance().getAllLearningPlans();
    this.finishPlanCount = (await LearningPlanManager.getInstance().getFinishLearningPlans()).length;
    this.isLoading = false;
    this.onFinishALlTask();
    LogUtil.showInfo(TAG, `length: ${this.learningPlans.length}`);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }

  build() {
    Column() {
      if (!this.isLoading) {
        if (this.learningPlans.length > 0) {
          if (this.finishPlanCount === this.learningPlans.length) {
            this.encourage()
          } else {
            this.planList()
          }
        } else {
          this.addPlanIcon()
        }
      }
    }
    .padding({
      left: fixVp(this.defaultDpi, 24),
      right: fixVp(this.defaultDpi, 24)
    })
    .height(fixVp(this.defaultDpi, 190))
    .width('100%')
  }

  @Builder
  private planList() {
    List({ scroller: new Scroller() }) {
      ListItemGroup() {
        ForEach(this.learningPlans, (item: LearningPlan, index) => {
          ListItem() {
            LearningPlanItemComponent({
              defaultDpi: this.defaultDpi,
              planId: item.id,
              planName: item.planName,
              enable: item.status === 1,
              index: index
            })
          }
        })
      }
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .layoutWeight(1)
    .transition(
      TransitionEffect.asymmetric(
        undefined,
        TransitionEffect.OPACITY.animation({ duration: 200 }),
      )
    )
  }

  @Builder
  private encourage() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image($r('app.media.learning_encourage_icon'))
        .draggable(false)
        .width(fixVp(this.defaultDpi, 72))
        .height(fixVp(this.defaultDpi, 72))

      Text($r('app.string.learning_encourage_text'))
        .margin({
          top: fixVp(this.defaultDpi, 4),
          bottom: fixVp(this.defaultDpi, 4),
        })
        .fontSize(fixVp(this.defaultDpi, 24))
        .lineHeight(30)
        .fontWeight(600)
        .maxFontScale(1)
        .fontColor($r('sys.color.font_primary'))
        .flexShrink(0)

      Text(undefined, { controller: this.textController })
        .fontSize(fixVp(this.defaultDpi, 16))
        .lineHeight(21)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .maxFontScale(1)
        .flexShrink(0)
    }
    .transition(
      TransitionEffect.asymmetric(
        TransitionEffect.OPACITY.animation({ delay: 100, duration: 250 }),
        undefined
      )
    )
  }

  @Builder
  private addPlanIcon() {
    Column() {
      Image(this.isDarkMode ? $r('app.media.add_learning_plan_dark') : $r('app.media.add_learning_plan'))
        .draggable(false)
        .width(fixVp(this.defaultDpi, 120))
        .height(fixVp(this.defaultDpi, 120))
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)

  }
}