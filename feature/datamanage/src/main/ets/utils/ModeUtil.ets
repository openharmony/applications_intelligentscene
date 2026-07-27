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

import lazy { TimeConstant } from '@ohos/scene.common/src/main/ets/constant/TimeConstant';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';
import { CheckEmptyUtils } from '@ohos/scene.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { StringUtil } from '@ohos/scene.common/src/main/ets/utils/StringUtil';
import { NO_SCENE } from '@ohos/scene.common/src/main/ets/constant/ModeConstant';
import { ConfigType } from '../model/base/ConfigType';
import { MODE_TYPE_MAX_ID, MODE_TYPE_MIN_ID, ModeData } from '../model/base/ModeModel';
import { LoopType, TimeCondition } from '../model/TriggerCondition';
import { DateTimeUtil } from './DateTimeUtil';

const GLOBAL_CONFIG_TYPES: ConfigType[] = [
  ConfigType.CURRENT_OPENED_MODE,
  ConfigType.CURRENT_OPENED_MODE_EL1,
  ConfigType.HOLIDAY_INFO
];

const NOT_UNIQUE_CONFIG_TYPES: ConfigType[] = [
  ConfigType.TRIGGER_CONDITION_TIME,
];

/**
 * 首页显示的三个触发条件类型
 */
export const CONDITION_LIST: ConfigType[] = [
  ConfigType.TRIGGER_CONDITION_TIME,
  ConfigType.TRIGGER_CONDITION_APP,
];

/**
 * 所有触发条件类型，包括首页显示的三个触发条件和控制中心临时开启的定时条件
 */
export const ALL_CONDITION_TYPE: ConfigType[] = [
  ConfigType.TRIGGER_CONDITION_TIME,
  ConfigType.TRIGGER_CONDITION_APP,
  ConfigType.TEMPORARY_TIME_CONDITION,
];

export const SETTING_LINKAGE_LIST: ConfigType[] = [
  ConfigType.SYSTEM_SETTINGS_DARK_MODE,
  ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE,
];

const TAG: string = 'ModeUtil:';

export interface ModeState {
  /**
   * 模式是否已开启
   */
  isOpened: boolean;
  /**
   * 模式id，模式开启时为已开启的模式id，模式关闭为NO_SCENE('0')
   */
  modeId: string;
}

export class ModeUtil {
  /**
   * 是否预置模式
   */
  public static isPrecastMode(id: string): boolean {
    return MODE_TYPE_MIN_ID <= Number(id) && Number(id) <= MODE_TYPE_MAX_ID;
  }

  /**
   * 是否自定义模式
   */
  public static isCustomMode(id: string): boolean {
    return Number(id) === -1 || Number(id) > MODE_TYPE_MAX_ID;
  }

  /**
   * 获取字串资源code
   */
  public static getStringResourceCode(str: string): string {
    return str.replace('$string:', '');
  }

  /**
   * 获取标题 预置模式走字串 自定义走数据
   */
  public static getModeNameResourceStr(item: ModeData): ResourceStr {
    if (ModeUtil.isPrecastMode(item.modeId)) {
      const code = ModeUtil.getStringResourceCode(item.modeName);
      return $r(`app.string.${code}`);
    } else {
      return item.modeName;
    }
  }

  /**
   * 获取模式标题字串
   */
  public static getModeNameStr(item: ModeData): string {
    if (ModeUtil.isPrecastMode(item.modeId)) {
      const code = ModeUtil.getStringResourceCode(item.modeName);
      return ResourceUtil.getStringByName(code);
    } else {
      return item.modeName;
    }
  }

  /**
   * 根据模式id和配置类型生成配置id
   * 同一模式，同一个类型有多个配置： configId = modeId_configType_uuid；
   * 同一模式，同一个类型只有一个配置：configId = modeId_configType；
   * 全局配置，和模式无关： configId = configType；
   *
   * @param modeId 模式id
   * @param configType 配置类型
   * @returns 配置id字符串
   */
  public static generateConfigId(modeId: string, configType: number): string {
    let configId: string = '';
    if (GLOBAL_CONFIG_TYPES.includes(configType)) {
      configId = `${configType}`;
    } else if (NOT_UNIQUE_CONFIG_TYPES.includes(configType)) {
      let uuid: string = StringUtil.generateUuid();
      configId = `${modeId}_${configType}_${uuid}`;
    } else {
      configId = `${modeId}_${configType}`;
    }
    return configId;
  }

  /**
   * 从configId中获取modeId
   */
  public static getModeIdFromConfigId(configId: string): string {
    let ids: string[] = configId.split('_');
    if (CheckEmptyUtils.isEmptyArr(ids) || ids.length <= 1) {
      return INVALID_MODE_ID;
    }
    return ids[0];
  }

  /**
   * 从configId中获取configType
   */
  public static getTypeFromConfigId(configId: string): ConfigType {
    let ids: string[] = configId.split('_');
    return Number(ids.length === 1 ? ids[0] : ids[1]);
  }

  /**
   * 根据 timeEnd 生成 TimeCondition 条件参数
   *
   * @param configId 条件id
   * @param timeEnd 结束时间 xx:xx (24小时制/数字形式)
   * @returns (当前时间 -> timeEnd) 时间段的 TimeCondition 条件参数
   */
  public static generateConditionByEndTime(configId: string, timeEnd: string): TimeCondition {
    const date: Date = new Date();
    const timeStart: string = TimeConstant.zhTimeFormat.format(date);
    return ModeUtil.generateTimeCondition(configId, timeStart, timeEnd);
  }

  /**
   * 根据 minute 生成 TimeCondition 条件参数
   *
   * @param configId 条件id
   * @param minute 分钟数
   * @returns [当前时间 -> minute分钟后] 时间段的 TimeCondition 条件参数
   */
  public static generateConditionByMinute(configId: string, minute: number): TimeCondition {
    const date: Date = new Date();
    const timeStart: string = TimeConstant.zhTimeFormat.format(date);
    const endDate = new Date(date.getTime() + TimeConstant.ONE_MINUTE_MS_UNIT * minute);
    const timeEnd: string = TimeConstant.zhTimeFormat.format(endDate);
    return ModeUtil.generateTimeCondition(configId, timeStart, timeEnd);
  }

  /**
   * 生成 TimeCondition 条件参数
   *
   * @param configId 条件id
   * @param timeStart 开始时间 xx:xx (24小时制/数字形式)
   * @param timeEnd 结束时间 xx:xx (24小时制/数字形式)
   */
  public static generateTimeCondition(configId: string, timeStart: string, timeEnd: string): TimeCondition {
    LogUtil.showInfo(TAG, `generateTimeCondition. configId:${configId} timeStart:${timeStart} timeEnd:${timeEnd}`);
    let condition: TimeCondition = {
      configId: configId ?? '',
      configType: configId ? ModeUtil.getTypeFromConfigId(configId) : ConfigType.TEMPORARY_TIME_CONDITION,
      loopType: LoopType.ONE_TIME,
      loopDays: DateTimeUtil.formatDateToString(new Date()),
      timeStart: timeStart,
      timeEnd: timeEnd,
      enable: true
    };
    return condition;
  }

  /**
   * 获取系统当前模式状态，模式是否开启，开启模式id
   *
   * @returns 模式状态：{开启模式id，是否开启}
   */
  public static getModeOpenState(): ModeState {
    let modeId: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, NO_SCENE);
    LogUtil.showInfo(TAG, `current opened mode: ${modeId}`);
    return {
      isOpened: modeId !== NO_SCENE,
      modeId: modeId
    };
  }

  /**
   * 判断指定模式是否已开启
   *
   * @param modeId 模式id
   * @param openModeState 已开启模式状态, 可选参数，为空时从数据库查询
   * @returns true: 指定模式已开启；false: 指定模式未开启
   */
  public static isCurrentModeOpened(modeId: string, openModeState?: ModeState): boolean {
    const modeState: ModeState = openModeState ?? ModeUtil.getModeOpenState();
    return modeState.isOpened && modeId === modeState.modeId;
  }
}