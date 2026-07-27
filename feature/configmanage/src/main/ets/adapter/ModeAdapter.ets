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
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { SceneBaseDataManager } from '../manager/SceneBaseDataManager';
import { ModeDetailAdapter } from './ModeDetailAdapter';

/* instrument ignore file */
/**
 * 模式适配器
 */
export class ModeAdapter {
  private tag: string = 'ModeAdapter:';
  private static singleInstance: ModeAdapter;
  private allModeArr: ModeData[] = [];
  private timerId?: number;
  private onDbDataChange = (isDelete?: boolean): void => {
    LogUtil.showInfo(this.tag, `onDbDataChange DB_MODE_DATA_REFRESH`);
    const displayModeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const origIndex: number = this.allModeArr.findIndex(item => item.modeId === displayModeId);
    this.queryAllModeData().then(() => {
      const displayMode: ModeData | undefined = this.allModeArr.find((mode: ModeData) => {
        return mode.modeId === displayModeId;
      });

      // 云同步场景，对端设备删除当前在前台显示的模式
      if (isDelete && !displayMode) {
        this.deleteModeCacheById(displayModeId);
        let modeId: string = this.allModeArr.length >= origIndex ?
          this.allModeArr[origIndex - 1].modeId : this.allModeArr[this.allModeArr.length - 1].modeId;
        LogUtil.showInfo(this.tag, `displayModeId: ${displayModeId}, swipe to mode: ${modeId}`);
        EventBus.getInstance().emit(EventBusNameConstant.SWIPE_THIS_MODE, modeId);
      }
    });
  };

  /**
   * 单例
   */
  public static getInstance(): ModeAdapter {
    if (!ModeAdapter.singleInstance) {
      ModeAdapter.singleInstance = new ModeAdapter();
    }
    return ModeAdapter.singleInstance;
  }

  /**
   * 初始化已有模式数据
   */
  public initData(): void {
    this.clearData();
    LogUtil.showInfo(this.tag, `init`);
    this.queryAllModeData();
    EventBus.getInstance().on(EventBusNameConstant.DB_MODE_DATA_REFRESH, this.onDbDataChange);
  }

  public detach(): void {
    EventBus.getInstance().detach(EventBusNameConstant.DB_MODE_DATA_REFRESH, this.onDbDataChange);
    if (this.timerId) {
      clearTimeout(this.timerId);
    }
  }

  /**
   * 还原数据
   */
  private clearData(): void {
    LogUtil.showInfo(this.tag, `clearData`);
    this.allModeArr = [];
  }

  /**
   * 获取所有模式数据
   */
  private async queryAllModeData(): Promise<void> {
    LogUtil.showInfo(this.tag, `queryAllModeData start.`);
    const result = await SceneBaseDataManager.getAllSceneBaseData();
    LogUtil.showInfo(this.tag, `queryAllModeData end. allModeArr:${result.map(it => it.modeId)}`);
    this.allModeArr = result;
    EventBus.getInstance().emit(EventBusNameConstant.ALL_MODE_REFRESH, this.allModeArr);
    // 数据更新的时候也要通知跟新当前模式详情数据
    EventBus.getInstance().emit(EventBusNameConstant.SCROLL_NEW_MODE);
  }

  /**
   * 获取所有模式
   */
  public getAllModeArr(): ModeData[] {
    return this.allModeArr;
  }

  /**
   * 获取需要展示的模式
   *
   * @param enabledModeId 开启的模式
   */
  public getShowModeArr(enabledModeId: string): ModeData[] {
    const isShowOtherMode: boolean = ModeConfigAdapter.getInstance().getConfigByModeId(enabledModeId).isShowOtherMode;
    LogUtil.showInfo(this.tag, `getAllModeArr. enabledModeId:${enabledModeId} isShowOtherMode:${isShowOtherMode}`);
    if (enabledModeId !== NO_SCENE && !isShowOtherMode) {
      return this.allModeArr.filter(it => it.modeId === enabledModeId);
    }
    return this.allModeArr;
  }

  /**
   * 根据modeId获取modeName的字串
   */
  public getModeNameById(modeId: string, name?: string): string {
    LogUtil.showInfo(this.tag, `getModeNameById. ${modeId}`);
    let modeNameTemp = name;
    if (!modeNameTemp) {
      modeNameTemp = this.allModeArr.find(it => it.modeId === modeId)?.modeName;
    }
    if (!modeNameTemp) {
      return '';
    }
    if (ModeUtil.isPrecastMode(modeId)) {
      const code = ModeUtil.getStringResourceCode(modeNameTemp);
      return ResourceUtil.getStringByName(code);
    } else {
      return modeNameTemp;
    }
  }

  /**
   * 根据modeId更新ModeAdapter实例中的数据
   */
  public async updateModeCacheById(modeId: string): Promise<void> {
    LogUtil.showInfo(this.tag, `updateModeCacheById. modeId:${modeId}`);
    const result = await SceneBaseDataManager.getSceneDataById(modeId);
    if (!result) {
      LogUtil.showError(this.tag, `result is undefined.`);
      return;
    }
    const index = this.allModeArr.findIndex((it) => {
      return it.modeId === modeId;
    });
    LogUtil.showInfo(this.tag, `updateModeCacheById. index:${index}`);
    if (index === -1) {
      this.allModeArr.push(result);
      EventBus.getInstance().emit(EventBusNameConstant.ALL_MODE_REFRESH, this.allModeArr);
      // 先新增卡片和导航点后再滑动 (重复进入菜单场景导航点需要50ms延迟才能响应滑动事件；250ms延迟确保半模态子窗销毁不会影响到卡片滑动动画)
      setTimeout(() => {
        EventBus.getInstance().emit(EventBusNameConstant.SWIPE_THIS_MODE, modeId);
      }, 250);
    } else {
      // 修改模式后 首页更新模式卡片和背景渐变色
      this.allModeArr = this.allModeArr.map((it: ModeData, idx: number) => idx === index ? result : it);
      EventBus.getInstance().emit(EventBusNameConstant.ALL_MODE_REFRESH, this.allModeArr);
      EventBus.getInstance().emit(EventBusNameConstant.SCROLL_NEW_MODE);
    }
  }

  /**
   * 根据modeId删除ModeAdapter实例中的模式数据
   */
  public deleteModeCacheById(modeId: string): void {
    LogUtil.showInfo(this.tag, `deleteModeCacheById`);
    const index = this.allModeArr.findIndex((it) => {
      return it.modeId === modeId;
    });
    LogUtil.showInfo(this.tag, `deleteModeCacheById. index:${index}`);
    if (index !== -1) {
      EventBus.getInstance().emit(EventBusNameConstant.MODE_DELETE_ANIMATE_START, modeId, index);
      this.allModeArr = this.allModeArr.filter(it => it.modeId !== modeId);
      // 首页删除动画执行后 再发送全量刷新事件
      this.timerId = setTimeout(() => {
        this.timerId = undefined;
        EventBus.getInstance().emit(EventBusNameConstant.ALL_MODE_REFRESH, this.allModeArr);
      }, 400)
    }
  }
}