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

import { relationalStore } from '@kit.ArkData';
import { RdbStoreHelper } from '@ohos/scene.common/src/main/ets/rdbstore/RdbStoreHelper';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { PRECAST_MODE_ROUND_ICON_MAP } from '../constant/ModeConstant';
import { CursorDataManager } from '../manager/CursorDataManager';
import { ModeDataManager } from '../manager/ModeDataManager';
import { El1ModeDataManager } from '../manager/El1ModeDataManager';
import { ModeData } from '../model/base/ModeModel';
import { UpgradeAdapter } from './UpgradeAdapter';
import { ConfigDataManager } from '../manager/ConfigDataManager';
import { ConfigData } from '../model/base/ConfigModel';
import { ConfigType } from '../model/base/ConfigType';
import { ModeUtil } from '../utils/ModeUtil';

/**
 * 手机产品EL2数据库版本升级版本号，数据表数据初始化函数映射map
 */
const PHONE_EL2_FUNCTION_MAP: Map<number, (() => Promise<boolean>)> = new Map([
  [6, async () => {
    return await PhoneEl2Adapter.initCursorData();
  }],
  [7, async () => {
    return await PhoneEl2Adapter.insertRoundIconData();
  }],
  [9, async () => {
    return await PhoneEl2Adapter.splitIntelligentExperienceSwitch();
  }],
]);
const TAG: string = 'PhoneUpgradeConfig: ';

export class PhoneEl2Adapter extends UpgradeAdapter {
  async upgradeData(dbVersion: number): Promise<boolean> {
    return await UpgradeAdapter.initUpgradedDbData(PHONE_EL2_FUNCTION_MAP, dbVersion);
  }

  static async initCursorData(): Promise<boolean> {
    const result: number = await CursorDataManager.getInstance().initCursorData();
    return result > 0;
  }

  static async insertRoundIconData(): Promise<boolean> {
    const isAddColumSuccess: boolean = await PhoneEl2Adapter.addRoundIconColumn();
    if (!isAddColumSuccess) {
      return true;
    }
    return await PhoneEl2Adapter.generateRoundIcon();
  }

  static async generateRoundIcon(): Promise<boolean> {
    try {
      let modeDataList: ModeData[] = await ModeDataManager.getInstance().queryAllModeData();
      for (let modeData of modeDataList) {
        if (modeData.roundIcon) {
          continue;
        }
        let roundIconStr: string | undefined = PRECAST_MODE_ROUND_ICON_MAP.get(modeData.modeId);
        if (!roundIconStr) {
          LogUtil.showWarn(TAG, 'insertRoundIconData roundIconStr invalid');
          continue;
        }
        const roundIcon: PixelMap | undefined = ResourceUtil.getPixelMap(roundIconStr);
        modeData.roundIcon = roundIcon;
        await ModeDataManager.getInstance().updateModeData(modeData);
        await El1ModeDataManager.getInstance().updateModeData(modeData);
      }
    } catch (error) {
      LogUtil.showError(TAG, `insertRoundIconData faild. code: ${error?.code}, message: ${error?.message}`);
      return false;
    }
    return true;
  }

  static async addRoundIconColumn(): Promise<boolean> {
    let store: relationalStore.RdbStore | undefined = await RdbStoreHelper.getInstance().getRdbStore();
    try {
      if (!store) {
        LogUtil.showError(TAG, 'Upgrade fail ,rdbStore is undefined');
        return false;
      }
      await store.executeSql('ALTER TABLE MODE_DATA_TABLE ADD COLUMN roundIcon TEXT;');
    } catch (error) {
      LogUtil.showError(TAG, `addRoundIconColumn faild. code: ${error?.code}, message: ${error?.message}`);
      return false;
    }
    return true;
  }

  /**
   * 智能体验开关状态同步拆分至重要信息提醒
   */
  static async splitIntelligentExperienceSwitch(): Promise<boolean> {
    const configDataList: ConfigData[] = await ConfigDataManager.getInstance()
      .queryConfigDataByConfigType([ConfigType.INTELLIGENT_EXPERIENCE_SWITCH]);
    const insertConfigData: ConfigData[] = [];
    for (let configData of configDataList) {
      let configId: string = ModeUtil.generateConfigId(configData.modeId, ConfigType.IMPORTANT_MESSAGE_REMINDER);
      const importantMsgConfigData: ConfigData | undefined = await ConfigDataManager.getInstance()
        .queryConfigDataById(configId);
      if (importantMsgConfigData) {
        LogUtil.showWarn(TAG, `configId already exist: ${configId}`);
        continue;
      }
      insertConfigData.push({
        configId: '',
        modeId: configData.modeId,
        configType: ConfigType.IMPORTANT_MESSAGE_REMINDER,
        configValue: configData.configValue,
      });
    }
    LogUtil.showInfo(TAG, `splitIntelligentExperienceSwitch length: ${insertConfigData.length}`);
    if (insertConfigData.length === 0) {
      return true;
    }
    const result: number = await ConfigDataManager.getInstance().batchInsertConfigData(insertConfigData);
    return result > 0;
  }
}
