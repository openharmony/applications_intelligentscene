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

/**
 * 预置模式最小id
 */
export const MODE_TYPE_MIN_ID: number = 1;

/**
 * 预置模式最大id
 */
export const MODE_TYPE_MAX_ID: number = 50;

// 初始空数据
export const EMPTY_MODE_DATA: ModeData = {
  modeId: '',
  modeName: '',
  iconId: '',
  iconColor: '',
  isSupportDelete: false,
};

/**
 * 情景模式基础数据
 */
export interface ModeData {
  /**
   * 预留id, 给配置表与模式无关的配置数据使用：-1
   * 预置模式id：1~50
   * 自定义模式id：时间戳
   */
  modeId: string;
  /**
   * 模式名称
   */
  modeName: string;
  /**
   * 模式图标symbol资源id
   */
  iconId: string;
  /**
   * 模式图标颜色
   */
  iconColor: string;
  /**
   * 通知圆角矩形显示图标
   */
  filletIcon?: PixelMap;
  /**
   * 通知圆角矩形显示图标base64字串
   */
  filletIconStr?: string;
  /**
   * 即时实况通知圆形显示图标
   */
  roundIcon?: PixelMap;
  /**
   * 即时实况通知圆形显示图标base64字串
   */
  roundIconStr?: string;
  /**
   * 模式优先级
   */
  modePriority?: number;
  /**
   * 模式信息更新时间
   */
  updateTime?: number;
  /**
   * 模式创建时间
   */
  createTime?: number;
  /**
   * 模式是否支持删除
   */
  isSupportDelete: boolean;
}

/**
 * 预置情景模式类型，枚举值对应数据库modeId
 */

export enum ModeType {
  /**
   * 无模式
   */
  NO_MODE = '0',
  /**
   * 免打扰模式
   */
  DND_MODE = '1',
  /**
   * 睡眠模式
   */
  SLEEP_MODE = '2',
  /**
   * 学习模式
   */
  LEARNING_MODE = '3',
  /**
   * 工作模式
   */
  WORKING_MODE = '4',
  /**
   * 运动模式
   */
  SPORT_MODE = '5',
  /**
   * 游戏模式
   */
  GAME_MODE = '6',
  /**
   * 影音模式
   */
  ENTERTAINMENT_MODE = '7',
  /**
   * 驾驶模式
   */
  DRIVING_MODE = '8',
  /**
   * 午休模式
   */
  LUNCH_BREAK_MODE = '9',
}

/**
 * 预置情景模式名称
 */
export enum ModeName {
  /**
   * 无模式
   */
  NO_MODE_NAME = '无模式',
  /**
   * 免打扰模式
   */
  DND_MODE_NAME = '免打扰模式',
  /**
   * 睡眠模式
   */
  SLEEP_MODE_NAME = '睡眠模式',
  /**
   * 学习模式
   */
  LEARNING_MODE_NAME = '学习模式',
  /**
   * 工作模式
   */
  WORKING_MODE_NAME = '工作模式',
  /**
   * 运动模式
   */
  SPORT_MODE_NAME = '运动模式',
  /**
   * 游戏模式
   */
  GAME_MODE_NAME = '游戏模式',
  /**
   * 影音模式
   */
  ENTERTAINMENT_MODE_NAME = '影音模式',
  /**
   * 驾驶模式
   */
  DRIVING_MODE_NAME = '驾驶模式',
}

/**
 * 模式搜索itemName
 */
export enum ModeSearchName {
  WORKING_MODE = 'working_mode',
  LEARNING_MODE = 'learning_mode',
}
