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

export class IntentCodeConstants {
  // 执行成功
  public static readonly DEFAULT_CODE_SUCCESS = 0;
  // 执行失败
  public static readonly DEFAULT_CODE_FAILED = 10010001;
  // 功能不支持
  public static readonly DEFAULT_CODE_UNSUPPORTED = 10010003;
  // 参数错误
  public static readonly DEFAULT_CODE_PARAM_ERROR = 10010010;
  // 参数缺失
  public static readonly DEFAULT_CODE_PARAM_MISSING = 10010011;
  // 需要用户二次确认
  public static readonly DEFAULT_CODE_REQUIRE_USER_CONFIRMATION = 10010017;
  // 隐私空间下不支持
  public static readonly PRIVATE_SPACE = 10010112;
  // 打开模式成功
  public static readonly ACTIVATE_MODE_SUCCESS_CODE = 10220001;
  // 打开模式失败
  public static readonly ACTIVATE_MODE_FAIL_CODE = 10220002;
  // 打开模式-模式不存在
  public static readonly ACTIVATE_MODE_NOT_EXIST = 10220003;
  // 关闭模式成功
  public static readonly DEACTIVATE_MODE_SUCCESS_CODE = 10220011;
  // 关闭模式失败
  public static readonly DEACTIVATE_MODE_FAIL_CODE = 10220012;
  // 关闭模式-模式不存在
  public static readonly DEACTIVATE_MODE_NOT_EXIST = 10220013;
  // 关闭模式-模式已处于关闭状态
  public static readonly DEACTIVATE_MODE_CLOSED = 10220014;
  // 查询模式列表成功
  public static readonly QUERY_MODE_LIST_SUCCESS_CODE = 10220121;
  // 查询模式列表失败
  public static readonly QUERY_MODE_LIST_FAIL_CODE = 10220122;
  // 查询模式配置成功
  public static readonly QUERY_MODE_SUCCESS_CODE = 10220131;
  // 查询模式配置失败
  public static readonly QUERY_MODE_FAIL_CODE = 10220132;
  // 计时打开模式成功
  public static readonly ACTIVATE_BY_TIMER_SUCCESS_CODE = 10220021;
  // 计时打开模式失败
  public static readonly ACTIVATE_BY_TIMER_FAIL_CODE = 10220022;
  // 计时打开模式-模式不存在
  public static readonly ACTIVATE_BY_TIMER_NOT_EXIST = 10220023;
  // 计时打开模式时间参数错误
  public static readonly ACTIVATE_BY_TIMER_PARA_FAIL_CODE = 10220024;
  // 截止时间打开模式成功
  public static readonly ACTIVATE_BY_ENDTIME_SUCCESS_CODE = 10220031;
  // 截止时间打开-执行失败
  public static readonly ACTIVATE_BY_ENDTIME_FAIL = 10220032;
  // 截止时间打开模式-模式不存在
  public static readonly ACTIVATE_BY_ENDTIME_NOT_EXIST = 10220033;
  // 截止时间打开模式时间参数错误
  public static readonly ACTIVATE_BY_ENDTIME_PARA_FAIL_CODE = 10220034;
  // 打开开关成功
  public static readonly MODIFY_SWITCH_SUCCESS_CODE = 10220081;
  // 打开开关-模式不存在
  public static readonly MODIFY_SWITCH_NOT_EXIST = 10220083;
  // 打开开关失败,不支持的开关类型
  public static readonly MODIFY_SWITCH_INVALID_TYPE_CODE = 10220084;
  // 打开开关失败,不支持的开关状态
  public static readonly MODIFY_SWITCH_INVALID_STATE_CODE = 10220085;
  // 打开开关失败，请先前往界面进行授权后再使用
  public static readonly MODIFY_SWITCH_NO_AUTH = 10220086;
  // 打开开关失败，无相关设置项可配置
  public static readonly MODIFY_SWITCH_NO_SETTING_CONFIG = 10220087;
  // 打开开关失败，请先升级云空间全新服务模式
  public static readonly MODIFY_SWITCH_NEED_UPGRADE = 10220088;
  // 打开开关失败，请先开启云空间
  public static readonly MODIFY_SWITCH_NEED_OPEN_CLOUD_SPACE = 10220089;
  // 创建模式成功
  public static readonly CREATE_MODE_SUCCESS_CODE = 10220041;
  // 创建模式失败
  public static readonly CREATE_MODE_FAIL_CODE = 10220042;
  // 创建模式-模式已存在-重复命名
  public static readonly CREATE_MODE_REPEAT = 10220043;
  // 创建模式参数错误
  public static readonly CREATE_MODE_PARA_FAIL_CODE = 10220044;
  // 创建模式失败-模式数量已达到最大值
  public static readonly CREATE_MODE_MAX_NUMBER_FAIL_CODE = 10220045;
  // 修改来电策略成功
  public static readonly MODIFY_CALL_POLICY_SUCCESS_CODE = 10220091;
  // 修改来电策略失败
  public static readonly MODIFY_CALL_POLICY_FAIL_CODE = 10220092;
  // 修改来电策略-模式不存在
  public static readonly MODIFY_CALL_POLICY_NOT_EXIST = 10220093;
  // 修改勿扰策略-模式不存在
  public static readonly MODIFY_NOT_DISTURB_POLICY_NOT_EXIST = 10220163;
  // 修改勿扰策略-参数错误
  public static readonly MODIFY_NOT_DISTURB_POLICY_PARAM_ERROR = 10220164;
  // 修改勿扰策略-执行成功
  public static readonly MODIFY_NOT_DISTURB_POLICY_SUCCESS = 10220161;
  // 修改勿扰策略-执行失败
  public static readonly MODIFY_NOT_DISTURB_POLICY_FAILED = 10220162;

  // 添加应用到勿扰清单成功
  public static readonly MODIFY_CALL_APP_SUCCESS_CODE = 10220171;
  // 添加应用到勿扰清单失败
  public static readonly MODIFY_CALL_APP_FAIL_CODE = 10220172;

  // 更新时间成功
  public static readonly MODIFY_TIME_PERIOD_SUCCESS_CODE = 10220071;
  // 更新时间失败
  public static readonly MODIFY_TIME_PERIOD_FAIL_CODE = 10220072;
  // 更新时间-模式不存在
  public static readonly MODIFY_TIME_PERIOD_NOT_EXIST = 10220073;
  // 添加时间成功
  public static readonly ADD_TIME_PERIOD_SUCCESS_CODE = 10220061;
  // 添加时间失败
  public static readonly ADD_TIME_PERIOD_FAIL_CODE = 10220062;
  // 添加时间-模式不存在
  public static readonly ADD_TIME_PERIOD_NOT_EXIST = 10220063;
  // 添加时间-法定节假日信息不存在
  public static readonly ADD_HOLIDAY_INFO_NOT_EXIST = 10220066;
  // 添加时间-开启方式个数达到最大值
  public static readonly ADD_TIME_PERIOD_MAX = 10220055;

  // 修改关联设置 - 执行成功
  public static readonly MODIFY_MODE_ASSOCIATED_SWITCH_SUCCESS = 10220111;
  // 修改关联设置 - 执行失败
  public static readonly MODIFY_MODE_ASSOCIATED_SWITCH_FAIL = 10220112;
  // 修改关联设置 - 模式不存在
  public static readonly MODIFY_MODE_ASSOCIATED_SWITCH_NOT_EXIST = 10220113;
  // 修改关联设置 - 不支持关联该设置项
  public static readonly MODIFY_MODE_ASSOCIATED_SWITCH_THIS_NOT_SUPPORT = 10220114;
  // 修改关联设置 - 不支持的关联类型
  public static readonly MODIFY_MODE_ASSOCIATED_SWITCH_TYPE_NOT_SUPPORT = 10220115;
}

export const ERROR_MSG: Record<number, string> = {
  0: '执行成功',
  10010001: '执行失败',
  10010003: '设备不支持',
  10010010: '参数错误',
  10010011: '参数缺失',
  10010017: '需要用户二次确认',
  10220001: '打开模式成功',
  10220002: '打开模式失败',
  10220003: '打开模式-模式不存在',
  10220011: '关闭模式成功',
  10220012: '关闭模式失败',
  10220013: '关闭模式-模式不存在',
  10220121: '查询模式列表成功',
  10220122: '查询模式列表失败',
  10220131: '查询模式配置成功',
  10220132: '查询模式配置失败',
  10220021: '计时打开模式成功',
  10220022: '计时打开模式失败',
  10220023: '计时打开模式-模式不存在',
  10220024: '计时打开模式时间参数错误',
  10220031: '截止时间打开模式成功',
  10220033: '截止时间打开模式-模式不存在',
  10220034: '截止时间打开模式时间参数错误',
  10220081: '打开开关成功',
  10220083: '打开开关-模式不存在',
  10220084: '打开开关失败-不支持的开关类型',
  10220085: '打开开关失败-不支持的开关状态',
  10220041: '创建模式成功',
  10220042: '创建模式失败',
  10220043: '创建模式-模式已存在-重复命名',
  10220044: '创建模式参数错误',
  10220045: '创建模式失败-模式数量达到最大值',
  10220091: '修改来电策略成功',
  10220092: '修改来电策略失败',
  10220093: '修改来电策略-模式不存在',
  10220071: '更新时间成功',
  10220072: '更新时间失败',
  10220073: '更新时间-模式不存在',
  10220061: '添加时间成功',
  10220062: '添加时间失败',
  10220063: '添加时间-模式不存在',
  10220111: '修改关联设置 - 执行成功',
  10220112: '修改关联设置 - 执行失败',
  10220113: '修改关联设置 - 模式不存在',
  10220114: '修改关联设置 - 不支持关联该设置项',
  10220115: '修改关联设置 - 不支持的关联类型',
  10220171: '添加应用到勿扰清单成功',
  10220172: '添加应用到勿扰清单失败',
  10220161: '修改通知策略成功',
}