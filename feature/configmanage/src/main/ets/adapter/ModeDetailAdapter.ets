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

import { dataShare } from '@kit.ArkData';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import {
  ConfigData,
  EnableState,
  SettingsLinkageState,
} from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { AllowAppData } from '@ohos/scene.datamanage/src/main/ets/model/AllowDisturbData';
import { AppData } from '@ohos/scene.datamanage/src/main/ets/model/AppData';
import { RemindMode } from '@ohos/scene.datamanage/src/main/ets/model/RemindMode';
import { BaseCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ModeState, ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';

/* instrument ignore file */
type ParsedValue = RemindMode | BaseCondition | AllowAppData | AppData | EnableState
  | SettingsLinkageState;

export interface ParsedConfigData extends ConfigData {
  parsedValue: ParsedValue,
}

const NO_SCENE: string = '0';

/**
 * 模式适配器
 */
export class ModeDetailAdapter {
  private tag: string = 'ModeDetailAdapter:';
  private static singleInstance: ModeDetailAdapter;
  private dataHelper?: dataShare.DataShareHelper;
  // 解析后的初始数据
  private parsedConfigDataArr: ParsedConfigData[] = [];
  // 初始已开启模式
  private initEnabledModeId: string = NO_SCENE;
  // 当前页面的模式
  private modeId: string = ModeType.DND_MODE;
  private onDbDataChange = (): void => {
    LogUtil.showInfo(this.tag, `onDbDataChange ${this.modeId}`);
    this.queryConfigByModeId(this.modeId);
  };
  // 查询的最新modeId；
  private latestModeId: string = NO_SCENE;

  /**
   * 单例
   */
  public static getInstance(): ModeDetailAdapter {
    if (!ModeDetailAdapter.singleInstance) {
      ModeDetailAdapter.singleInstance = new ModeDetailAdapter();
    }
    return ModeDetailAdapter.singleInstance;
  }

  /**
   * 初始化当前模式config数据
   *
   * @param specifiedModeId 指定模式
   */
  public initData(specifiedModeId?: string): void {
    this.clearData();
    const modeOpenState: ModeState = ModeUtil.getModeOpenState();
    this.initEnabledModeId = modeOpenState.modeId;
    if (specifiedModeId) {
      // 有指定模式则首帧切到指定模式上
      this.modeId = specifiedModeId;
    } else {
      // 没有指定模式则切到开启模式上 否则切到免打扰
      this.modeId = modeOpenState.isOpened ? this.initEnabledModeId : ModeType.DND_MODE;
    }
    LogUtil.showInfo(this.tag,
      `initData. specifiedModeId:${specifiedModeId} initEnabledModeId:${this.initEnabledModeId} modeId:${this.modeId}`);
    this.queryConfigByModeId(this.modeId);
    this.registerDataChange();
  }

  public detach(): void {
    this.unRegisterDataChange();
  }

  public async registerDataChange(): Promise<void> {
    LogUtil.showInfo(this.tag, 'registerDataChange');
    EventBus.getInstance().on(EventBusNameConstant.DB_CONFIG_DATA_REFRESH, this.onDbDataChange);
    this.dataHelper = await SettingsDataUtils.createDataHelper(SettingsDataKeyConstant.INTELLIGENT_REFRESH_CONFIG_DATA);
    if (this.dataHelper) {
      LogUtil.showInfo(this.tag, 'registerSecurityDataChange intelligent_refresh_config_data');
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper,
        SettingsDataKeyConstant.INTELLIGENT_REFRESH_CONFIG_DATA, this.onDbDataChange);
    }
  }

  private unRegisterDataChange(): void {
    LogUtil.showInfo(this.tag, 'unRegisterDataChange');
    EventBus.getInstance().detach(EventBusNameConstant.DB_CONFIG_DATA_REFRESH, this.onDbDataChange);
    if (this.dataHelper) {
      LogUtil.showInfo(this.tag, 'unRegisterSecurityDataChange intelligent_refresh_config_data');
      SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper,
        SettingsDataKeyConstant.INTELLIGENT_REFRESH_CONFIG_DATA, this.onDbDataChange);
    }
  }

  /**
   * 还原数据
   */
  private clearData(): void {
    LogUtil.showInfo(this.tag, 'clearData.');
    this.initEnabledModeId = NO_SCENE;
    this.modeId = ModeType.DND_MODE;
    this.parsedConfigDataArr = [];
  }

  /**
   * 首页切换模式回调
   */
  public onModeChange(modeId?: string): void {
    LogUtil.showInfo(this.tag, `onModeChange. old:${this.modeId} new:${modeId}`);
    if (modeId && this.modeId !== modeId) {
      this.modeId = modeId;
      EventBus.getInstance().emit(EventBusNameConstant.SCROLL_NEW_MODE);
      this.queryConfigByModeId(modeId);
    }
  }

  /**
   * 根据modeId查询模式详情数据
   */
  public async queryConfigByModeId(modeId: string): Promise<void> {
    LogUtil.showInfo(this.tag, `queryConfigByModeId start. modeId:${modeId}`);
    this.latestModeId = modeId;
    let result: ConfigData[] = await ModeConfigAdapter.getInstance().queryConfigByModeAndType(modeId);
    // latestModeId会实时刷新，modeId为异步查询前闭包保存的Id；
    if (this.latestModeId !== modeId) {
      LogUtil.showError(this.tag, `error this.latestModeId: ${this.latestModeId}, modeId: ${modeId}`);
      return;
    }
    LogUtil.showInfo(this.tag, `queryConfigByModeId end. result.length:${result.length}`);
    const parsedConfigDataArr = this.getParsedConfigDataArr(result);
    // 整体替换掉数据
    this.parsedConfigDataArr = parsedConfigDataArr;
    EventBus.getInstance().emit(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH);
  }

  /**
   * 根据configId更新ModeDetailAdapter实例中的数据
   */
  public async updateParsedConfigById(configId: string): Promise<void> {
    LogUtil.showInfo(this.tag, `updateParsedConfigDataArr. configId:${configId}`);
    const result: ConfigData | undefined = await ModeConfigAdapter.getInstance().queryConfigDataById(configId);
    if (!result) {
      LogUtil.showError(this.tag, 'result is undefined.');
      return;
    }
    const parsedConfigDataArr = this.getParsedConfigDataArr([result]);
    const index = this.parsedConfigDataArr.findIndex((it) => {
      return it.configId === configId;
    });
    LogUtil.showInfo(this.tag, `updateParsedConfigDataArr. index:${index}`);
    if (index === -1) {
      this.parsedConfigDataArr.push(parsedConfigDataArr[0]);
    } else {
      this.parsedConfigDataArr.splice(index, 1, parsedConfigDataArr[0]);
    }
    // 单独给这个类型发通知给组件更新
    EventBus.getInstance().emit(EventBusNameConstant.MODE_DETAIL_REFRESH, parsedConfigDataArr[0].configType);
  }

  /**
   * 根据configId刪除ModeDetailAdapter实例中的数据
   */
  public async deleteConfigById(configId: string): Promise<void> {
    LogUtil.showInfo(this.tag, `deleteConfigById. configId:${configId}`);
    const index = this.parsedConfigDataArr.findIndex((it) => {
      return it.configId === configId;
    });
    LogUtil.showInfo(this.tag, `deleteConfigById. index:${index}`);
    if (index !== -1) {
      let configType = this.parsedConfigDataArr[index].configType;
      this.parsedConfigDataArr.splice(index, 1);
      // 单独给这个类型发通知给组件更新
      EventBus.getInstance().emit(EventBusNameConstant.MODE_DETAIL_REFRESH, configType);
    }
  }

  /**
   * 解析ConfigData数据
   */
  private getParsedConfigDataArr(configDataArr: ConfigData[]): ParsedConfigData[] {
    LogUtil.showInfo(this.tag, 'getParsedConfigDataArr start.');
    const parsedConfigDataArr: ParsedConfigData[] = [];
    configDataArr.forEach((configData) => {
      try {
        LogUtil.showDebug(this.tag,
          `JSON.parse start. configId:${configData.configId} configType:${configData.configType} configValue:${configData.configValue}`);
        const parsedValue = JSON.parse(configData.configValue) as ParsedValue;
        const parsedConfigData: ParsedConfigData = {
          configId: configData.configId,
          modeId: configData.modeId,
          configType: configData.configType,
          configValue: configData.configValue,
          updateTime: configData.updateTime,
          createTime: configData.createTime,
          parsedValue,
        }
        parsedConfigDataArr.push(parsedConfigData);
      } catch (e) {
        LogUtil.showWarn(this.tag,
          `JSON.parse failed. configId:${configData.configId} configType:${configData.configType} configValue:${configData.configValue}`);
      }
    });
    LogUtil.showInfo(this.tag, 'getParsedConfigDataArr end.');
    return parsedConfigDataArr;
  }

  /**
   * 根据configType获取数据
   */
  public getParsedConfigDataByType(configTypeArr: ConfigType[]): ParsedConfigData[] {
    if (CheckEmptyUtils.isEmptyArr(configTypeArr)) {
      LogUtil.showError(this.tag, 'getParsedConfigDataByType fail, configTypeArr is invalid.');
      return [];
    }
    return this.parsedConfigDataArr.filter(it => configTypeArr.includes(it.configType));
  }

  /**
   * 获取当前所属modeId
   */
  public getCurrentModeId(): string {
    return this.modeId;
  }

  /**
   * 获取initEnabledModeId
   */
  public getInitEnabledModeId(): string {
    return this.initEnabledModeId;
  }
}