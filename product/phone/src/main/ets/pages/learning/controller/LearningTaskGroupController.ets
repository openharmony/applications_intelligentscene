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

import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { PADDING_16 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemType,
  SettingDialogModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { OrderedDataSource } from '@ohos/scene.common/src/main/ets/framework/model/OrderedDataSource';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingContentState,
  SettingDialogState,
  SettingStateType
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import LiveViewManager from '@ohos/scene.configlinkage/src/main/ets/manager/LiveViewManager';
import { NotificationData } from '@ohos/scene.configlinkage/src/main/ets/constant/LinkageConstants';
import { LearningPlan } from '@ohos/scene.datamanage/src/main/ets/model/LearningPlan';
import { LearningPlanManager } from '@ohos/scene.datamanage/src/main/ets/manager/LearningPlanManager';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { LearningModeConstant } from '../constant/LearningModeConstant';
import { learningTaskItemBuilder } from '../component/LearningTaskItemComponent';
import { addLearningTaskTextItemBuilder } from '../component/AddLearningTaskTextComponent';
import { LearningPlanItem } from '../model/LearningPlanItem';

/* instrument ignore file */
const TAG: string = 'LearningTaskGroupController: ';

export class LearningTaskGroupController implements ComponentControl {
  protected compId: string = '';
  private dataSource?: OrderedDataSource;
  private planList: LearningPlan[] = [];
  private isShowAddBtn: boolean = true;
  private closeAddTaskDialog = () => {
    this.closeDialog();
  };
  private addLearningPlanTaskCallback = (planId: string, learningName: string) => {
    LogUtil.showInfo(TAG, 'addLearningPlanTaskCallback');
    this.closeDialog();
    let plan: LearningPlanItem = new LearningPlanItem();
    plan.id = planId;
    plan.planName = learningName;
    plan.itemId = this.getLearningItemId({
      id: planId, planName: learningName
    });
    this.dealInsertLearningPlan(plan);
  };
  private deleteLearningPlanTaskCallback = (itemId: string) => {
    let item: ComparableSettingItemModel = {
      id: itemId,
      type: ItemType.ITEM_TYPE_CUSTOM
    };
    this.dataSource?.removeData(item);
    this.updateLearningModeLiveView();
    this.addTaskBtnMenu();
    this.refreshFooterText(false);
  }
  private saveLearningPlanNameCallback = (planId: string, learningName: string, itemId: string) => {
    LogUtil.showInfo(TAG, `saveLearningPlanNameCallback, ${planId}, ${itemId}`);
    let plan: LearningPlanItem = new LearningPlanItem();
    plan.id = planId;
    plan.planName = learningName;
    plan.itemId = this.getLearningItemId({ id: planId, planName: learningName });
    let item: ComparableSettingItemModel = {
      id: itemId,
      type: ItemType.ITEM_TYPE_CUSTOM
    };
    if (this.dataSource) {
      let index: number = this.dataSource.getDataIndex(item);
      this.dataSource.getData(index).extra = plan;
      this.dataSource.getData(index).id = plan.itemId;
      this.dataSource.notifyDataChange(index);
    }
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, 'init fail, compParam is invalid');
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as OrderedDataSource;
    this.getPlanData();
    this.registerEvent();
  }

  private async getPlanData(): Promise<void> {
    let list: LearningPlan[] = await LearningPlanManager.getInstance().getAllLearningPlans();
    this.planList = list;
    if (this.planList.length >= LearningModeConstant.MAX_LEARNING_PLAN_COUNT) {
      LogUtil.showInfo(TAG, 'no need show add btn');
      this.isShowAddBtn = false;
      this.refreshFooterText(true);
    }
    for (let plan of this.planList) {
      this.addPlanTaskItem(plan);
    }
    if (this.isShowAddBtn) {
      this.addTaskBtnMenu();
    }
  }

  private getLearningItemId(plan: LearningPlan): string {
    let hashCode: number = StringUtil.hashCode32(plan.planName);
    return `${hashCode}_${plan.id}`;
  }

  private refreshFooterText(isFullCount: boolean): void {
    let message: string = isFullCount ? ResourceUtil.getStringSync($r('app.string.learning_plan_over_limit')) :
    ResourceUtil.getStringSync($r('app.string.learning_plan_add_desc'));
    LogUtil.showInfo(TAG, `refreshFooterText ${this.compId}`);
    let refreshMap = new Map<SettingStateType, SettingBaseState>();
    refreshMap.set(SettingStateType.STATE_TYPE_GROUP_FOOTER_CONTENT, { content: message } as SettingContentState);
    notifyCompStateChange(`${this.compId}.footer`, refreshMap);
  }

  private addPlanTaskItem(plan: LearningPlan): void {
    let learningItem: LearningPlanItem = new LearningPlanItem();
    learningItem.id = plan.id;
    learningItem.planName = plan.planName;
    learningItem.itemId = this.getLearningItemId(plan);
    let item: ComparableSettingItemModel = {
      id: learningItem.itemId,
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(learningTaskItemBuilder),
      extra: learningItem
    };
    this.dataSource?.pushData(item);
  }

  private async dealInsertLearningPlan(plan: LearningPlanItem): Promise<void> {
    let item: ComparableSettingItemModel = {
      id: plan.itemId,
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(learningTaskItemBuilder),
      extra: plan
    };
    this.dataSource?.insertData(this.dataSource.length - 1, item);
    this.updateLearningModeLiveView();
    let plans = await LearningPlanManager.getInstance().getAllLearningPlans();
    if (plans.length >= LearningModeConstant.MAX_LEARNING_PLAN_COUNT) {
      LogUtil.showInfo(TAG, 'max limit');
      this.hideAddPlanBtn();
      this.refreshFooterText(true);
    }
  }

  private hideAddPlanBtn(): void {
    let item: ComparableSettingItemModel = {
      id: 'addTaskBtnMenu',
      type: ItemType.ITEM_TYPE_CUSTOM
    };
    this.dataSource?.removeData(item);
  }

  private addTaskBtnMenu(): void {
    let learningPlan: LearningPlan = new LearningPlan();
    let index = this.dataSource?.getDataIndex({
      id: 'addTaskBtnMenu',
      type: ItemType.ITEM_TYPE_STANDARD
    });
    if (index !== undefined && index >= 0) {
      LogUtil.showInfo(TAG, 'already exist add btn');
      return;
    }
    let item: ComparableSettingItemModel = {
      id: 'addTaskBtnMenu',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.learning_plan_add_text'),
        style: { fontColor: $r('sys.color.font_emphasize') }
      },
      extra: learningPlan,
      detail: {
        type: ItemDetailType.DETAIL_TYPE_DIALOG,
        dialog: {
          title: $r('app.string.learning_plan_add_text'),
          contentBuilder: wrapBuilder(addLearningTaskTextItemBuilder),
          style: {
            padding: {
              start: PADDING_16,
              end: PADDING_16,
            },
            autoCancel: true,
          },
          isShowInSubWindow: true,
          buttons: [],
        }
      }
    };
    this.dataSource?.pushData(item);
  }

  private async updateLearningModeLiveView(): Promise<void> {
    const value: string = SettingsDataUtils.getSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, '');
    if (StringUtil.isEmpty(value)) {
      LogUtil.showWarn(TAG, 'notify data is empty');
      return;
    }
    const currentModeId: string = StateManager.getInstance().getCurrentScene();
    if (currentModeId !== ModeType.LEARNING_MODE) {
      LogUtil.showWarn(TAG, 'current mode is not learning mode');
      return;
    }

    let ntfData: NotificationData = JsonUtil.fromJson(value) as NotificationData;
    LiveViewManager.fillLearningNtfData(ntfData);
    LiveViewManager.updateLiveView(ntfData);
  }

  private registerEvent(): void {
    EventBus.getInstance().on(LearningModeConstant.CLOSE_ADD_LEARNING_TASK_DIALOG_EVENT, this.closeAddTaskDialog);
    EventBus.getInstance().on(LearningModeConstant.ADD_LEARNING_PLAN_EVENT, this.addLearningPlanTaskCallback);
    EventBus.getInstance().on(LearningModeConstant.DELETE_LEARNING_PLAN_EVENT, this.deleteLearningPlanTaskCallback);
    EventBus.getInstance().on(LearningModeConstant.EDIT_LEARNING_PLAN_NAME_EVENT, this.saveLearningPlanNameCallback);
  }

  private unRegisterEvent(): void {
    EventBus.getInstance().detach(LearningModeConstant.CLOSE_ADD_LEARNING_TASK_DIALOG_EVENT, this.closeAddTaskDialog);
    EventBus.getInstance().detach(LearningModeConstant.ADD_LEARNING_PLAN_EVENT, this.addLearningPlanTaskCallback);
    EventBus.getInstance().detach(LearningModeConstant.DELETE_LEARNING_PLAN_EVENT, this.deleteLearningPlanTaskCallback);
    EventBus.getInstance()
      .detach(LearningModeConstant.EDIT_LEARNING_PLAN_NAME_EVENT, this.saveLearningPlanNameCallback);
  }

  private closeDialog(): void {
    notifyCompStateChange(`${this.compId}.addTaskBtnMenu`,
      new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
        {} as SettingDialogState]]
      ));
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    this.unRegisterEvent();
  }
}