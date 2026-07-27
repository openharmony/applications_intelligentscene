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

import { SettingBaseModel } from './SettingBaseModel';
import { SettingContentModel, SettingGroupModel } from './SettingGroupModel';
import { SettingIconModel, SettingMenuStyle } from './SettingItemModel';
import { SettingTabsModel } from './SettingTabsModel';

export enum PageType {
  /**
   * 自定义页面
   */
  PAGE_TYPE_CUSTOM = 0,

  /**
   * 标准页面
   */
  PAGE_TYPE_STANDARD = 1,

  /**
   * 首页
   */
  PAGE_TYPE_HOME = 2,

  /**
   * 模态页面，需绑定到设置项上
   */
  PAGE_TYPE_MODAL = 3,
}

export interface SettingPageLayout {
  /**
   * 页面背景颜色
   */
  backgroundColor?: ResourceColor;
  blurStyle?: BlurStyle;

  /**
   * 页面内间距
   */
  padding?: LocalizedPadding;

  /**
   * 页面宽高限制
   */
  constraintSize?: ConstraintSizeOptions;
  hideTitleBar?: boolean;
  barState?: BarState;

  /**
   * 页面内容list不满一页时候是否支持弹性滑动
   */
  alwaysEnabled?: boolean;

  /**
   * 页面菜单项排列顺序
   */
  pageAlign?: Alignment;

  /**
   * 列表顶部内容渐隐高度（vp）。
   * 内容滚入标题栏下方时，列表文字/内容做半透明渐隐，避免与标题重叠。
   */
  topFadeHeight?: number;
}

export interface ListScrollListener {
  onScrollStart?: () => void;
  onScrollStop?: () => void;
  onReachStart?: () => void;
  onScroll?: (scrollOffset: number, scrollState: ScrollState) => void;
}

export interface SettingPageMenu extends SettingIconModel {
  bindMenu?: MenuElement[];
  menuStyle?: SettingMenuStyle;
  onClick?: () => void;
  builder?: WrappedBuilder<[object]>;
}

export interface SettingPageModel extends SettingBaseModel {
  url: string;
  type: PageType;
  title?: ResourceStr;
  header?: SettingContentModel;
  footer?: SettingContentModel;
  layout?: SettingPageLayout;
  scrollListener?: ListScrollListener;
  menus?: SettingPageMenu[];
  fixedGroups?: SettingGroupModel[];
  groups?: SettingGroupModel[];
  groupForeground?: SettingContentModel;
  stickBottomContent?: SettingContentModel;
  tabs?: SettingTabsModel[];
  onTabSelected?: (selectedIndex: number) => void;
  titleIconLeft?: SettingSheetTitleIcon;
  titleIconRight?: SettingSheetTitleIcon;
}

export interface SettingSheetTitleIcon {
  icon: ResourceStr;
  action: () => boolean;
  matchTextDirection?: boolean,
  accessibilityText?: string,
}

export interface SettingSheetPageContext {
  itemComp: SettingBaseModel;
  pathStack?: NavPathStack;
}

export class DefaultSettingPageModel implements SettingPageModel {
  public id: string = '';
  public title: ResourceStr = '';
  public url: string = '';
  public type: PageType = PageType.PAGE_TYPE_STANDARD;
  private static instance: DefaultSettingPageModel;

  private constructor() {
  }

  public static get(): DefaultSettingPageModel {
    if (!DefaultSettingPageModel.instance) {
      DefaultSettingPageModel.instance = new DefaultSettingPageModel();
    }
    return DefaultSettingPageModel.instance;
  }
}
