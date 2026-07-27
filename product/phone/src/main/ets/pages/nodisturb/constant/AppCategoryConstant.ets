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

import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';

export class AppCategoryConstant {
  //游戏
  public static readonly GAME: number = 2;

  // 工具
  public static readonly TOOLS: number = 10000000;

  // 商务
  public static readonly BUSINESS: number = 10000001;

  // 效率
  public static readonly EFFICIENCY: number = 10000002;

  // 金融理财
  public static readonly FINANCIAL_MANAGEMENT: number = 10000003;

  // 教育
  public static readonly EDUCATION: number = 10000004;

  // 儿童
  public static readonly CHILDREN: number = 10000005;

  // 新闻
  public static readonly NEWS: number = 10000006;

  // 资讯
  public static readonly INFORMATION: number = 10000007;

  // 阅读与工具书
  public static readonly READING_AND_REFERENCE_BOOKS: number = 10000008;

  // 体育
  public static readonly SPORTS: number = 10000009;

  // 汽车
  public static readonly CARS: number = 10000010;

  // 医疗
  public static readonly HEALTHCARE: number = 10000011;

  // 运动健康
  public static readonly SPORTS_HEALTH: number = 10000012;

  // 影视与直播
  public static readonly FILM_AND_TELEVISION_AND_LIVE_BROADCAST: number = 10000013;

  // 音乐
  public static readonly MUSIC: number = 10000014;

  // 休闲娱乐
  public static readonly LEISURE_AND_ENTERTAINMENT: number = 10000015;

  // 社交
  public static readonly SOCIALIZING: number = 10000016;

  // 拍摄美化
  public static readonly SHOOTING_BEAUTIFICATION: number = 10000017;

  // 艺术与设计
  public static readonly ART_AND_DESIGN: number = 10000018;

  // 主题
  public static readonly THEME: number = 10000019;

  // 生活服务
  public static readonly LIFE_SERVICES: number = 10000020;

  // 房产与装修
  public static readonly PROPERTY_AND_RENOVATION: number = 10000021;

  // 购物
  public static readonly SHOPPING: number = 10000022;

  // 美食
  public static readonly GOURMET_FOOD: number = 10000023;

  // 旅游
  public static readonly TRAVELLING: number = 10000024;
}

// 配置各模式支持的 分类类型
export const MODE_SUPPORT_CATEGORY: Map<string, Array<number>> = new Map([
  [ModeType.DND_MODE, []], // 免打扰
  [ModeType.SLEEP_MODE, []], // 睡眠模式
  [ModeType.LEARNING_MODE, [AppCategoryConstant.EDUCATION]], // 学习模式
  [ModeType.WORKING_MODE, []], // 工作模式
  [ModeType.SPORT_MODE, [AppCategoryConstant.SPORTS, AppCategoryConstant.SPORTS_HEALTH]], // 运动模式
  [ModeType.GAME_MODE, [AppCategoryConstant.GAME]], // 游戏模式
  [ModeType.ENTERTAINMENT_MODE, [AppCategoryConstant.FILM_AND_TELEVISION_AND_LIVE_BROADCAST]], // 影音模式
  [ModeType.DRIVING_MODE, []], // 驾驶模式
  [ModeType.LUNCH_BREAK_MODE, []], // 午休模式
]);