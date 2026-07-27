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
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { RawFileUtil } from '@ohos/scene.common/src/main/ets/utils/RawFileUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { ConfigParseUtil } from '@ohos/scene.common/src/main/ets/utils/ConfigParseUtil';
import lazy { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import lazy { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ModeData, ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { DbBaseManager, UpgradeState } from '@ohos/scene.datamanage/src/main/ets/manager/DbBaseManager';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { El1CallConfigManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1CallConfigManager';
import { CursorDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/CursorDataManager';
import { PreferencesUtil } from '@ohos/scene.common/src/main/ets/utils/PreferencesUtil';
import { ModeConfigAdapter } from '@ohos/scene.modeconfig/src/main/ets/adapter/ModeConfigAdapter';
import { BaseModeConfig } from '@ohos/scene.modeconfig/src/main/ets/adapter/BaseModeConfig';
import { DefaultModeConfig, DefaultMode } from './model/model/DefaultModeConfig';
import { ModeConfigData } from './model/model/DefaultModeConfigData';
import { ModeAdapter } from '../adapter/ModeAdapter';
import { ModeDefaultDataManager } from './ModeDefaultDataManager';
import { ModeDetailAdapter } from '../adapter/ModeDetailAdapter';

/* instrument ignore file */
const TAG: string = 'PreloadManager: ';
const LOCAL_CCM_VERSION: string = 'local_ccm_version';
const TEMPLATE_MODE: string = 'template_mode';
const PRESET_MODE_CREATE_TIME: number = 1738912402263;
const INTELLIGENT_SCENE_CCM_CONFIG = 'etc/IntelligentScene/intelligent_scene_list.json';

// 屏蔽预置模式数组
const EXCLUDE_MODE_ID_ARR: ModeType[] = [
  ModeType.SPORT_MODE,
  ModeType.GAME_MODE,
  ModeType.ENTERTAINMENT_MODE,
  ModeType.DRIVING_MODE,
  ModeType.LUNCH_BREAK_MODE,
];

export class PreloadManager {
  private static instance: PreloadManager | null = null;
  private defaultModeConfig: DefaultModeConfig | undefined;

  static getInstance(): PreloadManager {
    if (!PreloadManager.instance) {
      PreloadManager.instance = new PreloadManager();
    }
    return PreloadManager.instance;
  }

  public async getVersionFromPreference(context: Context): Promise<number> {
    const version = await PreferencesUtil.get(LOCAL_CCM_VERSION, 0) as number;
    LogUtil.showInfo(TAG, `getVersionFromPreference success: ${version}`);
    return version;
  }

  public getVersionFromCcm(): number {
    let res: string = ConfigParseUtil.getConfigSync(INTELLIGENT_SCENE_CCM_CONFIG);
    LogUtil.showInfo(TAG, `getVersionFromCcm. path:${res}`);
    let defaultModeConfig: DefaultModeConfig | undefined;
    try {
      let jsonStr: string = RawFileUtil.readJsonFile(res);
      LogUtil.showInfo(TAG, `getVersionFromCcm. jsonStr:${jsonStr}`);
      defaultModeConfig = JSON.parse(jsonStr);
      const templateModes = defaultModeConfig?.intelligentSceneList.map(it => it.modeId) || [];
      LogUtil.showInfo(TAG, `getVersionFromCcm. templateModes:${templateModes}`);
      this.addTemplateModeToPreference(templateModes);
      this.defaultModeConfig = defaultModeConfig;
    } catch (error) {
      LogUtil.showError(TAG, `getVersionFromCcm catch error. code:${error?.code} message:${error?.message}`)
    }
    return this.defaultModeConfig?.version ?? 0;
  }

  public async updateVersionToPreference(context: Context, newVersion: number): Promise<void> {
    LogUtil.showInfo(TAG, `start updateVersionToPreference, newVersion: ${newVersion}`);
    await PreferencesUtil.put(LOCAL_CCM_VERSION, newVersion);
  }

  /**
   * 批量预置ccm里面isPreset为true的模式数据
   *
   * @returns 是否有新模式被插入
   */
  public async batchPresetMode(): Promise<boolean> {
    let inserted: boolean = false;
    const presetModeIds: string[] = this.getPresetModeIds();
    LogUtil.showInfo(TAG, `batchPresetMode. presetModeIds:${presetModeIds}`);
    for (const modeId of presetModeIds) {
      if (await this.insertModeDefaultData(modeId)) {
        inserted = true;
      }
    }
    return inserted;
  }

  /**
   * 获取需要自动预置的模式id列表
   */
  private getPresetModeIds(): string[] {
    if (!this.defaultModeConfig) {
      this.getVersionFromCcm();
    }
    const presetModeIds: string[] = this.defaultModeConfig?.intelligentSceneList
      .filter((it: DefaultMode) => it.isPreset)
      .map((it: DefaultMode) => it.modeId)
      .filter((id: string) => !EXCLUDE_MODE_ID_ARR.includes(id as ModeType)) ?? [];
    if (presetModeIds.length > 0) {
      return presetModeIds;
    }
    return [ModeType.DND_MODE, ModeType.SLEEP_MODE];
  }

  /**
   * 插入预置模式默认数据
   *
   * @param modeId 模式id
   * @returns boolean 表示是否插入数据
   */
  private async insertModeDefaultData(modeId: string): Promise<boolean> {
    const oldData: ModeData | undefined = await El1ModeDataManager.getInstance().queryModeDataById(modeId);
    // 模式表已存在该模式
    if (oldData) {
      LogUtil.showWarn(TAG, `insertModeDefaultData. model data already exists. modeId:${modeId}`);
      return false;
    }
    const modeDefaultData: ModeConfigData | undefined =
      await ModeDefaultDataManager.getInstance().getModeDefaultDataByModeId(modeId);
    // 没找到默认数据
    if (!modeDefaultData) {
      LogUtil.showError(TAG, 'insertModeDefaultData. modeDefaultData is empty.');
      return false;
    }
    // 对于不支持同步的预制模式数据，仅存EL1分区，不存EL2
    const modeConfig: BaseModeConfig = ModeConfigAdapter.getInstance().getConfigByModeId(modeId);
    LogUtil.showInfo(TAG,
      `insertModeDefaultData start. modeId:${modeId} isSupportCloudSync:${modeConfig.isSupportCloudSync}`);
    const modeData: ModeData = this.createModeData(modeDefaultData);
    const configs: ConfigData[] =
      await ModeDefaultDataManager.getInstance().getModeDefaultConfigDataByModeId(modeId);
    if (modeConfig.isSupportCloudSync) {
      const modeHistory: string = await ModeDataManager.getInstance().insertModeData(modeData);
      const configResult: number = await ConfigDataManager.getInstance().batchInsertConfigData(configs);
      if (configResult > 0) {
        await El1CallConfigManager.batchInsertCallConfig(configs);
      }
      await El1ModeDataManager.getInstance().insertModeData(modeData);
      LogUtil.showInfo(TAG, `insertModeDefaultData end. modeHistory:${modeHistory} configResult:${configResult}`);
    } else {
      const el1ModeHistory: string = await El1ModeDataManager.getInstance().insertModeData(modeData);
      const el1ConfigResult: number = await El1CallConfigManager.batchInsertConfigData(configs);
      LogUtil.showInfo(TAG, `insertModeDefaultData end. modeHistory:${el1ModeHistory} configResult:${el1ConfigResult}`);
    }
    return true;
  }

  public async getTemplateModes(): Promise<ModeConfigData[]> {
    let templateModes: ModeConfigData[] = [];
    let templateModeIds = await this.getTemplateModeId();
    let modeIds: string[] = templateModeIds.split(',').filter((it: string) => it.length > 0);
    for (let modeId of modeIds) {
      let templateModeData: ModeConfigData | undefined =
        await ModeDefaultDataManager.getInstance().getModeDefaultDataByModeId(modeId);
      if (templateModeData) {
        templateModes.push(templateModeData);
      }
    }
    LogUtil.showInfo(TAG,
      `getTemplateModes. templateModeIds:${templateModeIds} templateModes.length:${templateModes.length}`);
    return templateModes;
  }

  /**
   * 数据库表结构升级及数据初始化，预置数据插入，页面刷新
   *
   * @param context Context
   * @param isNeedRefreshUi 是否刷新UI
   * @returns true 数据库初始化，或配置数据更新 false 数据库未更新，未初始化
   */
  public async initData(context: Context, isNeedRefreshUi: boolean): Promise<boolean> {
    // 数据库升级
    let upgradeStates: UpgradeState[] = await DbBaseManager.initDatabase();
    // 预置数据
    this.getVersionFromCcm();
    let isUpdatePresetData: boolean = await this.isNeedUpDatePresetData(context, upgradeStates);
    const hasNewPreset: boolean = await this.batchPresetMode();
    if (isUpdatePresetData) {
      const ccmVersion: number = this.defaultModeConfig?.version ?? 0;
      await this.updateVersionToPreference(context, ccmVersion);
    }
    // 情景模式首页、控制中心等入口打开，插入预置数据后需要刷新UI
    if ((isUpdatePresetData || hasNewPreset) && isNeedRefreshUi) {
      ModeAdapter.getInstance().initData();
    }
    if (upgradeStates.includes(UpgradeState.UPGRADE_FROM_BASE_VERSION)) {
      // 往配置表中插入当前开启模式数据
      await ConfigDataManager.getInstance().insertPresetConfig();
    }
    return isUpdatePresetData || hasNewPreset;
  }

  public async restorePresetData(): Promise<void> {
    LogUtil.showInfo(TAG, 'restorePresetData.');
    PreloadManager.getInstance().getVersionFromCcm();
    await PreloadManager.getInstance().batchPresetMode();
    await CursorDataManager.getInstance().initCursorData();
    await ModeDetailAdapter.getInstance().initData();
  }

  /**
   * 是否需要插入预置数据
   *
   * @param context
   * @param upgradeState
   * @returns 返回true: 1、数据库基础表缺失；2、预置模式数据缺失；3、预置模式CCM配置和版本号更新。其他情况返回false
   */
  private async isNeedUpDatePresetData(context: Context, upgradeStates: UpgradeState[]): Promise<boolean> {
    if (upgradeStates.includes(UpgradeState.UPGRADE_FROM_BASE_VERSION)) {
      LogUtil.showWarn(TAG, 'isNeedUpDatePresetData base table missed');
      return true;
    }

    const modeNumber: number = await El1ModeDataManager.getInstance().queryModeCount();
    if (modeNumber <= 0) {
      LogUtil.showWarn(TAG, 'isNeedUpDatePresetData mode data is empty');
      return true;
    }
    const ccmVersion: number = this.defaultModeConfig?.version ?? 0;
    const preferenceVersion: number = await this.getVersionFromPreference(context);
    LogUtil.showInfo(TAG, `isNeedUpDatePresetData. ccmVersion:${ccmVersion} preferenceVersion:${preferenceVersion}`);
    if (ccmVersion !== preferenceVersion) {
      return true;
    }
    return false;
  }

  private async getTemplateModeId(): Promise<string> {
    LogUtil.showInfo(TAG, 'start to getTemplateModeFromPreference');
    let value: string = await PreferencesUtil.get(TEMPLATE_MODE, '') as string;
    if (CheckEmptyUtils.isEmpty(value)) {
      value = this.getDefaultTemplateModeIds();
      LogUtil.showWarn(TAG, `template_mode is empty, use default: ${value}`);
    }
    // 这里代码屏蔽几个预置模式
    let templateModes: string = value.split(',')
      .filter((it: string) => it.length > 0 && !EXCLUDE_MODE_ID_ARR.includes(it as ModeType))
      .join(',');
    LogUtil.showInfo(TAG, `getTemplateModeFromPreference success. value:${value} templateModes:${templateModes}`);
    return templateModes;
  }

  /**
   * CCM未写入偏好设置时，使用默认模板列表
   */
  private getDefaultTemplateModeIds(): string {
    if (!this.defaultModeConfig) {
      this.getVersionFromCcm();
    }
    const templateModes: string[] = this.defaultModeConfig?.intelligentSceneList.map((it: DefaultMode) => it.modeId) ??
      [];
    if (templateModes.length > 0) {
      return templateModes.join(',');
    }
    return [ModeType.DND_MODE, ModeType.SLEEP_MODE, ModeType.LEARNING_MODE, ModeType.WORKING_MODE].join(',');
  }

  /**
   * 持久化保存ccm配置中的模式模板数据
   *
   * @param templateModes 模式模板
   */
  private async addTemplateModeToPreference(templateModes: Array<string>): Promise<void> {
    if (CheckEmptyUtils.isEmptyArr(templateModes)) {
      LogUtil.showWarn(TAG, 'addTemplateModeToPreference fail, the templateModes is empty.');
      return;
    }
    await PreferencesUtil.put(TEMPLATE_MODE, templateModes.toString());
    LogUtil.showInfo(TAG, `addTemplateModeToPreference success. templateModes:${templateModes}`);
  }

  private createModeData(configData: ModeConfigData): ModeData {
    const filletIcon: PixelMap | undefined =
      configData.filletIcon ? ResourceUtil.getPixelMap(configData.filletIcon) : undefined;
    const roundIcon: PixelMap | undefined =
      configData.roundIcon ? ResourceUtil.getPixelMap(configData.roundIcon) : undefined;
    LogUtil.showInfo(TAG, `createModeData filletIcon: ${filletIcon?.isEditable}, roundIcon: ${roundIcon?.isEditable}`);
    const modeData: ModeData = {
      modeId: configData.modeId,
      modeName: configData.modeName,
      iconId: configData.iconId,
      iconColor: configData.iconColor,
      filletIcon: filletIcon,
      roundIcon: roundIcon,
      isSupportDelete: configData.isSupportDelete,
      modePriority: configData.modePriority,
      createTime: PRESET_MODE_CREATE_TIME + Number(configData.modeId),
    };
    return modeData;
  }
}