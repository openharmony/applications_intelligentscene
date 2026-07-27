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
import { SingleButtonComponent } from '@ohos/scene.common/src/main/ets/basecomponent/button/SingleButtonComponent';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { HomeUtil } from '../utils/HomeUtil';

const TAG: string = 'DeleteButtonComponent:';

/**
 * 首页底部删除模式按钮业务组件
 */
@Component
export struct DeleteButtonComponent {
  build() {
    SingleButtonComponent({
      title: $r('app.string.delete_mode'),
      buttonStyle: ButtonStyleMode.NORMAL,
      buttonRole: ButtonRole.ERROR,
      action: () => {
        this.onDeleteMode();
      },
    })
      .padding({
        top: 40,
      })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }

  /**
   * 删除模式
   */
  private onDeleteMode(): void {
    const modeId = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(TAG, `onDeleteMode. modeId:${modeId}`);
    HomeUtil.openDeleteModeDialog(modeId);
  }
}