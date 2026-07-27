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

import { inspector } from '@kit.ArkUI';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/scene.common/src/main/ets/utils/DeviceUtil';
import { PageConfig } from '@ohos/scene.common/src/main/ets/framework/common/PageConfig';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { SettingGroupHeader } from '@ohos/scene.common/src/main/ets/framework/view/SettingGroupHeader';
import { SettingGroup } from '@ohos/scene.common/src/main/ets/framework/view/SettingGroup';
import { SettingGroupFooter } from '@ohos/scene.common/src/main/ets/framework/view/SettingGroupFooter';
import { SettingGroupModel } from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { HOME_PAGE_ID, HomeGroupId } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import { getHomeGroups } from '../model/HomeGroupModel';
import { getHomeModalGroup } from '../model/HomeModalGroupModel';
import { HomeGroupController } from '../controller/HomeGroupController';
import { DeleteButtonComponent } from './DeleteButtonComponent';
import { GuideCardComponent } from './GuideCardComponent';

const HOME_ALL_GROUP_COM_ID: string = 'HomeAllGroupCom';

const TAG: string = 'HomeGroupComponent:';

@Component
export struct HomeGroupComponent {
  private controller: HomeGroupController = new HomeGroupController();
  @State groups: SettingGroupModel[] = [];
  @State modalGroup: SettingGroupModel | undefined = undefined;
  @State currentMode: ModeData | undefined = undefined;
  private listener: inspector.ComponentObserver =
    this.getUIContext().getUIInspector().createComponentObserver(HOME_ALL_GROUP_COM_ID);
  /**
   * 模式卡片切换事件
   */
  private onScrollNewModeCallback = (): void => {
    LogUtil.showInfo(TAG, `onScrollNewModeCallback.`);
    this.getCurrentMode();
  };
  /**
   * 整体送显完毕后回调
   */
  private onDidDraw = (): void => {
    LogUtil.showInfo(TAG, `onDidDraw.`);
    this.controller.onDidDraw();
  };

  build() {
    Column() {
      // 隐藏group 用来绑定半模态弹框
      if (this.modalGroup) {
        SettingGroup({
          groupInfo: this.modalGroup,
          compId: `${HOME_PAGE_ID}.${this.modalGroup.id}`,
          fixed: true,
          layout: PageConfig.getInstance().getGroupLayout(this.modalGroup, undefined),
        })
      }
      // 标准组件
      List() {
        // 引导卡片
        GuideCardComponent();

        // 新架构标准组件
        ForEach(this.groups, (group: SettingGroupModel, index: number) => {
          if (group.header) {
            SettingGroupHeader({
              group: group,
              compId: `${HOME_PAGE_ID}.${group.id}.header`,
            })
          }
          SettingGroup({
            groupInfo: group,
            compId: `${HOME_PAGE_ID}.${group.id}`,
            layout: PageConfig.getInstance().getGroupLayout(group, index > 0 ? this.groups[index - 1] : undefined),
          })
          if (group.footer) {
            SettingGroupFooter({
              group: group,
              compId: `${HOME_PAGE_ID}.${group.id}.footer`
            })
          }
        }, (item: SettingGroupModel) => item.id)

        // 删除按钮
        ListItem() {
          if (this.currentMode?.isSupportDelete ?? false) {
            DeleteButtonComponent();
          } else {
            Column()
              .height(16)
          }
        }
      }
    }
    .padding({
      left: DeviceUtil.isDevicePhone() ? 16 : 24,
      right: DeviceUtil.isDevicePhone() ? 16 : 24,
    })
    .id(HOME_ALL_GROUP_COM_ID)
  }

  aboutToAppear(): void {
    const groups: SettingGroupModel[] = getHomeGroups();
    const currentModeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(TAG, `aboutToAppear. currentModeId:${currentModeId}`);
    // 统一处理groups初始显隐状态
    let logStr: string = '';
    groups.forEach((it: SettingGroupModel) => {
      it.visible = ModeConfigAdapter.getInstance().getGroupVisible(currentModeId, it.id as HomeGroupId);
      logStr = logStr + `${it.id}:${it.visible} `;
    })
    LogUtil.showInfo(TAG, `aboutToAppear getGroupVisible. ${logStr}`);
    this.groups = groups;
    this.modalGroup = getHomeModalGroup();
    this.getCurrentMode();
    this.controller.init();
    this.listener.on('draw', this.onDidDraw);
    EventBus.getInstance().on(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.controller.destroy();
    this.listener.off('draw', this.onDidDraw);
    EventBus.getInstance().detach(EventBusNameConstant.SCROLL_NEW_MODE, this.onScrollNewModeCallback);
  }

  /**
   * 获取当前模式
   */
  private getCurrentMode(): void {
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const allModeArr: ModeData[] = ModeAdapter.getInstance().getAllModeArr();
    LogUtil.showInfo(TAG, `getCurrentMode. modeId:${modeId} allModeArr:${allModeArr.length}`);
    this.currentMode = allModeArr.find((it) => it.modeId === modeId);
  }
}