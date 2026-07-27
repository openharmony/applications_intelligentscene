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
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeConfigData } from '@ohos/scene.configmanage/src/main/ets/preload/model/model/DefaultModeConfigData';
import { PreloadManager } from '@ohos/scene.configmanage/src/main/ets/preload/PreloadManager';

/**
 * 预置模式适配器
 */
export class TemplateModeAdapter {
  private tag: string = 'TemplateModeAdapter:';
  private static singleInstance: TemplateModeAdapter;
  private templateModeArr: ModeConfigData[] = [];
  private templateModeNameArr: string[] = [];
  private loadPromise?: Promise<void>;

  /**
   * 单例
   */
  public static getInstance(): TemplateModeAdapter {
    if (!TemplateModeAdapter.singleInstance) {
      TemplateModeAdapter.singleInstance = new TemplateModeAdapter();
    }
    return TemplateModeAdapter.singleInstance;
  }

  /**
   * 初始化预置模式数据
   */
  public initData(): void {
    LogUtil.showInfo(this.tag, `initData.`);
    void this.ensureDataLoaded(true);
  }

  /**
   * 确保预置模板数据已加载完成
   */
  public ensureDataLoaded(forceReload: boolean = false): Promise<void> {
    if (!forceReload && this.templateModeArr.length > 0) {
      return Promise.resolve();
    }
    if (!forceReload && this.loadPromise) {
      return this.loadPromise;
    }
    this.loadPromise = this.queryTemplateMode().finally(() => {
      this.loadPromise = undefined;
    });
    return this.loadPromise;
  }

  /**
   * 清空数据
   */
  private clearData(): void {
    LogUtil.showInfo(this.tag, `clear`);
    this.templateModeArr = [];
    this.templateModeNameArr = [];
  }

  /**
   * 获取预置模板数据
   */
  private async queryTemplateMode(): Promise<void> {
    LogUtil.showInfo(this.tag, `queryTemplateModeArr start.`);
    this.clearData();
    this.templateModeArr = await PreloadManager.getInstance().getTemplateModes();
    this.templateModeNameArr = this.templateModeArr.map(it => {
      const code = ModeUtil.getStringResourceCode(it.modeName);
      const modeName = ResourceUtil.getStringByName(code);
      return modeName;
    })
    LogUtil.showInfo(this.tag,
      `queryTemplateModeArr. templateModeArr:${this.templateModeArr.length} templateModeNameArr:${this.templateModeNameArr}`);
  }

  /**
   * 获取预置模式数组
   */
  public getTemplateModeArr(): ModeConfigData[] {
    return this.templateModeArr;
  }

  /**
   * 获取预置模式名称
   */
  public getTemplateModeNameArr(): string[] {
    return this.templateModeNameArr;
  }

  /**
   * 根据 modeId 获取预置模式初始图标
   */
  public getTemplateModeIconId(modeId: string): string {
    return this.templateModeArr.find(it => it.modeId === modeId)?.iconId || '';
  }
}