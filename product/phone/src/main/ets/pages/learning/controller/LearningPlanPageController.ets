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
import { SettingPageModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType, SettingGroupModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { LearningTaskGroupController } from './LearningTaskGroupController';

/* instrument ignore file */
const TAG: string = 'LearningPageController: ';

export class LearningPageController implements ComponentControl {
  protected compId: string = '';
  private settingPageModel?: SettingPageModel;
  protected darkModeChangeCallback = () => {
    LogUtil.showInfo(TAG, `darkModeChangeCallback`);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, 'init fail, compParam is invalid');
      return;
    }
    this.compId = compParam.compId;
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    this.initMenus();
  }

  private initMenus(): void {
    this.addLearningPlanGroup();
  }

  private addLearningPlanGroup(): void {
    let item: SettingGroupModel = {
      id: 'plan',
      type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
      header: {
        id: 'addTaskHeader',
        content: $r('app.string.learning_plan_add_header'),
      },
      footer: {
        id: 'addTaskFooter',
        content: $r('app.string.learning_plan_add_desc'),
      },
      compControl: new LearningTaskGroupController()
    };
    this.settingPageModel?.groups?.push(item);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
  }
}