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
 * EventBus 事件名称
 */
export class EventBusNameConstant {
  /**
   * 公用弹框确认按钮使能
   */
  public static readonly COMMON_DIALOG_CONFIRM_ENABLE = 'COMMON_DIALOG_CONFIRM_ENABLE';
  /**
   * 模式应用内开启确认弹框
   */
  public static readonly OPEN_MODE_ENABLE_DIALOG = 'OPEN_MODE_ENABLE_DIALOG';
  /**
   * 模式删除动效开始
   */
  public static readonly MODE_DELETE_ANIMATE_START = 'IntelligentScene.Mode.Delete.Animate.Start';
  /**
   * 深浅色模式切换事件 (控制中心二级页面使用)
   */
  public static readonly DARK_LIGHT_MODE_CHANGE = 'IntelligentScene.Dark.Light.Mode.Change';
  /**
   * 首页主页主动滚动事件
   */
  public static readonly HOME_SCROLL_TO = 'IntelligentScene.Home.Scroll.To';
  /**
   * 首页标题修改事件
   */
  public static readonly HOME_TITLE_CHANGE = 'IntelligentScene.Home.Title.Change';
  /**
   * 架构模态框type改变通知(单栏切双栏模态框变中心弹框)
   */
  public static readonly SHEET_TYPE_CHANGE = 'IntelligentScene.Sheet.Type.Change';
  /**
   * 所有mode数据刷新完成通知
   */
  public static readonly ALL_MODE_REFRESH = 'IntelligentScene.All.Mode.Refresh';
  /**
   * 主动滑动到指定modeId模式卡片通知(通知组件主动滑动到指定模式卡片)
   */
  public static readonly SWIPE_THIS_MODE = 'IntelligentScene.Swipe.This.Mode';
  /**
   * 被动滑动到新的模式卡片通知(已经滑动到新的模式卡片 后续准备请求config数据)
   */
  public static readonly SCROLL_NEW_MODE = 'IntelligentScene.Scroll.New.Mode';
  /**
   * 当前选中模式config数据刷新完成通知
   */
  public static readonly ALL_MODE_DETAIL_REFRESH = 'IntelligentScene.All.Mode.Detail.Refresh';
  /**
   * 当前选中模式配置数据中某个configType类型数据刷新完成通知
   */
  public static readonly MODE_DETAIL_REFRESH = 'IntelligentScene.Mode.Detail.Refresh';
  /**
   * 设置应用列表加载完成事件
   */
  public static readonly APP_LIST_LOAD_COMPLETE = 'appListLoadComplete';
  /**
   * 编辑模式模态框按钮可用事件
   */
  public static readonly EDIT_MODE_BUTTON_ENABLED = 'IntelligentScene.Edit.Mode.Button.Enabled';
  /**
   * 地图卡片刷新事件
   */
  public static readonly MAP_UPDATE = 'IntelligentScene.MAP.UPDATE';
  /**
   * 点击删除模式事件
   */
  public static readonly DIALOG_DELETE_MODE = 'IntelligentScene.DIALOG.DELETE_MODE';

  /**
   * 联系人策略切换刷新事件
   */
  public static readonly CONTACT_POLICY_REFRESH: string = 'IntelligentScene.Contact.Policy.Refresh';

  /**
   * 允许联系人刷新事件
   */
  public static readonly ALLOW_CONTACTS_CHANGE: string = 'IntelligentScene.ALLOW.CONTACTS';

  /**
   * 数据库数据更新事件-模式基础数据
   */
  public static readonly DB_MODE_DATA_REFRESH = 'DB_MODE_DATA_REFRESH';
  /**
   * 数据库数据更新事件-配置数据
   */
  public static readonly DB_CONFIG_DATA_REFRESH = 'DB_CONFIG_DATA_REFRESH';
  /**
   * 数据库数据更新事件-通知免打扰数据
   */
  public static readonly DB_NOTIFICATION_DATA_REFRESH = 'DB_NOTIFICATION_DATA_REFRESH';
  /**
   * 数据库数据更新事件-来电免打扰联系人数据
   */
  public static readonly DB_CONTACT_DATA_REFRESH = 'DB_CONTACT_DATA_REFRESH';
  /**
   * 数据库数据更新事件-关联系统功能数据
   */
  public static readonly DB_SYS_FUNCTION_DATA_REFRESH = 'DB_SYS_FUNCTION_DATA_REFRESH';
  /**
   * 开启关闭模式事件
   */
  public static readonly MODE_STATUS_CHANGE = 'MODE_STATUS_CHANGE';
  /**
   * 设置窗口状态变化
   */
  public static readonly SETTINGS_WINDOW_STATUS_CHANGE: string = 'SETTINGS_WINDOW_STATUS_CHANGE';
  /**
   * 模式管理：模式启动全局事件
   */
  public static readonly MODE_START_EVENT: string = 'MODE_START_EVENT';
  /**
   * 模式管理：模式停止全局事件
   */
  public static readonly MODE_STOP_EVENT: string = 'MODE_STOP_EVENT';
  /**
   * 模式管理：模式切换全局事件
   */
  public static readonly MODE_CHANGE_EVENT: string = 'MODE_CHANGE_EVENT';
  /**
   * 模式管理：保存模式基础数据事件
   */
  public static readonly MODE_DATA_SAVE_EVENT: string = 'MODE_DATA_SAVE_EVENT';
  /**
   * 数据同步：账号退出恢复预置数据事件
   */
  public static readonly RESTORE_PRESET_DATA_EVENT: string = 'RESTORE_PRESET_DATA_EVENT';
  /**
   * 跳转透传URI
   */
  public static readonly PAGE_ROUTER_SETTINGS: string = 'PAGE_ROUTER_SETTINGS';
  /**
   * 小艺：修改联系人策略事件
   */
  public static readonly AGENT_MODIFY_CONTACT_POLICY_EVENT: string = 'AGENT_MODIFY_CONTACT_POLICY_EVENT';
  /**
   * 小艺：修改重复来电响铃
   */
  public static readonly AGENT_MODIFY_REPEAT_RINGING_EVENT: string = 'AGENT_MODIFY_REPEAT_RINGING_EVENT';
  /**
   * 小艺：修改通知勿扰事件
   */
  public static readonly AGENT_MODIFY_NOTIFICATION_EVENT: string = 'AGENT_MODIFY_NOTIFICATION_EVENT';
  /**
   * 智感职业模式：高德路况提醒UX刷新通知
   */
  public static readonly SMART_ROAD_CONDITIONS_EVENT: string = 'SMART_ROAD_CONDITIONS_EVENT';
  /**
   * 应用在前台功能——UIAbility在前台事件。
   */
  public static readonly APPLICATION_ON_FOREGROUND: string = 'APPLICATION_ON_FOREGROUND';
}