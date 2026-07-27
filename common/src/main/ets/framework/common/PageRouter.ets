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

import { HashMap } from '@kit.ArkTS';
import { EventBusNameConstant } from '../../constant/EventBusNameConstant';
import { EventBus } from './EventBus';
import { LogHelper } from './LogHelper';
import { ModalLoader } from './ModalLoader';
import { Optional } from './Optional';
import { PageConfig } from './PageConfig';
import { PageContext, PageLoader, PageParams } from './PageLoader';

/* instrument ignore file */
export type DynamicLoader = (key: string, type?: number) => Promise<void>;

export interface RouterInfo {
  /**
   * 页面配置文件根目录路径
   */
  rootDir: string;
  /**
   * 动态加载loader
   */
  loader: DynamicLoader;
  /**
   * 导航页面栈
   */
  path: NavPathStack;
  /**
   * 是否入口页面
   */
  isHomeEntryPage: (url: string) => boolean;
}

export class PushParam {
  public config?: Object | object;
  public startReason?: string;
  public subUri?: string;
  public bundleName?: string;
  public appIndex?: number;
  public itemName?: string;

  constructor(param?: Object | object, subUri?: string, bundleName?: string, appIndex?: number, itemName?: string) {
    this.config = param;
    this.subUri = subUri;
    this.bundleName = bundleName;
    this.appIndex = appIndex;
    this.itemName = itemName;
  }
}

export interface RouterPage {
  router: string;
  url: string;
  param?: object;
  isHome?: boolean;
  isEntry?: boolean;
};

const TAG: string = 'PageRouter';
const BASE_ROUTER: string = 'IntelligentScene';
const MODAL_TYPE: number = 1;

export class PageRouter {
  private static routerMap: HashMap<string, RouterInfo> = new HashMap();

  public static createRouter(router: string, routerInfo: RouterInfo): void {
    if (!router || router.length === 0) {
      return;
    }
    PageRouter.routerMap.set(router, routerInfo);
  }

  public static getRouterPath(router: string): Optional<NavPathStack> {
    return Optional.ofNullable(PageRouter.routerMap.get(router)?.path);
  }

  /**
   * 加载Model页面
   */
  public static async pushModal(url: string, param?: object, isHome: boolean = false,
    isEntry?: boolean): Promise<void> {
    let page: RouterPage = { router: BASE_ROUTER, url: url, param: param, isHome: isHome, isEntry };
    let router: RouterInfo = PageRouter.routerMap.get(page.router);
    if (!router) {
      return;
    }

    // 动态导入要跳转的页面信息，并处理准备工作
    if (!ModalLoader.getPageContext(page.url).isPresent()) {
      LogHelper.info(TAG, `ready to import modal page: ${page.url}`);
      await router.loader(page.url, MODAL_TYPE);
      LogHelper.info(TAG, `finish to import page: ${page.url}`);
    }
  }

  /**
   * 老代码中url已定义且对外暴露，为保持一致性，在loader回调中做路径转换，匹配动态加载的页面
   * push默认router为Setting，指定router请使用pushPage接口
   */
  public static async push(url: string, param?: object, isHome: boolean = false, isEntry?: boolean,
    isBack: boolean = false, animated?: boolean): Promise<void> {
    await PageRouter.pushPage({
      router: BASE_ROUTER,
      url: url,
      param: param,
      isHome: isHome,
      isEntry
    }, isBack, animated);
  }

  public static async pushPage(page: RouterPage, isBack: boolean = false, animated?: boolean): Promise<void> {
    await PageRouter.pushOrReplacePage(page, undefined, isBack, animated);
  }

  // 跳转页面是否添加动画
  public static async redirectPage(url: string, animated: boolean = true, param?: object,
    isHome: boolean = false, isEntry?: boolean, isBack: boolean = false): Promise<void> {
    let page: RouterPage = { router: BASE_ROUTER, url: url, param: param, isHome: isHome, isEntry };
    PageRouter.pushOrReplacePage(page, undefined, isBack, animated);
  }

  public static async pushOrReplacePage(page: RouterPage, isReplace?: boolean, isBack: boolean = false,
    animated?: boolean): Promise<void> {
    if (!page.url || page.url.length === 0) {
      return;
    }

    let router: RouterInfo = PageRouter.routerMap.get(page.router);
    if (!router) {
      return;
    }

    // 动态导入要跳转的页面信息，并处理准备工作
    if (!PageLoader.getPageContext(page.url).isPresent()) {
      LogHelper.info(TAG, 'ready to import page: ' + page.url);
      await router.loader(page.url);
      LogHelper.info(TAG, 'finish to import page: ' + page.url);
    }

    let pageCtxOpt = PageLoader.getPageContext(page.url);
    if (!pageCtxOpt.isPresent()) {
      LogHelper.info(TAG, `failed to import page: ${page.url}`);
      return;
    }

    let pageCtx = pageCtxOpt.get();
    if (pageCtx.getPageReady) {
      pageCtx.getPageReady();
    }

    // 若已在当前页面，不需要执行跳转
    if (router.isHomeEntryPage(page.url) && router.path.size() >= 1) {
      let pathInfo: string[] = router.path.getAllPathName();
      if (pathInfo[router.path.size() - 1] === page.url) {
        LogHelper.info(TAG, `setting page ${page.url} already in pathstack`);
        return;
      }
    }

    if (!page.isHome) {
      // 点击主页发生跳转，清理path信息；且如果是分屏模式则没有过渡动画
      let homePageNav: boolean = router.isHomeEntryPage(page.url);
      if (!isBack && homePageNav) {
        LogHelper.info(TAG, 'push to home page nav');
        router.path.clear();
      }
      if (isReplace) {
        LogHelper.info(TAG, `nav replace to ${page.url}`);
        router.path.replacePathByName(page.url, {
          router: page.router, pageUrl: page.url, pageCtx: pageCtx, param: page.param } as PageParams,
          !( PageConfig.getInstance().isSplitMode()));
        LogHelper.info(TAG, `nav replace finish`);
        return;
      }
      LogHelper.info(TAG, `nav push to ${page.url}`);
      router.path.pushPath(new NavPathInfo(page.url, {
        router: page.router,
        pageUrl: page.url,
        pageCtx: pageCtx,
        param: page.param
      } as PageParams, undefined, page.isEntry),
        animated ?? !(homePageNav && PageConfig.getInstance().isSplitMode()));
      LogHelper.info(TAG, `nav push finish`);
      PageRouter.sendRouterNameForSettings(page.url);
    }
  }

  /**
   * 匹配动态加载的页面 replace形式
   *
   * @param url 路由页面
   * @param param 传参
   * @param isHome 是否主页
   */
  public static async replace(url: string, param?: object, isHome: boolean = false): Promise<void> {
    await PageRouter.pushOrReplacePage({ router: BASE_ROUTER, url: url, param: param, isHome: isHome }, true);
  }

  public static pop(router: string): void {
    PageRouter.getRouterPath(router).ifPresent((path: NavPathStack) => {
      path.pop();
    });
  }

  public static clear(router: string): void {
    PageRouter.getRouterPath(router).ifPresent((path: NavPathStack) => {
      path.clear();
    });
  }

  public static async load(url: string, routerStr?: string): Promise<Optional<PageContext>> {
    if (!url || url.length === 0) {
      return Optional.empty();
    }

    let router: RouterInfo = PageRouter.routerMap.get(routerStr ?? BASE_ROUTER);
    if (!router) {
      return Optional.empty();
    }

    // 动态导入要跳转的页面信息，并处理准备工作
    if (!PageLoader.getPageContext(url).isPresent()) {
      LogHelper.info(TAG, `ready to import page: ${url}`);
      await router.loader(url);
      LogHelper.info(TAG, `finish to import page: ${url}`);
    }

    let pageCtxOpt = PageLoader.getPageContext(url);
    if (!pageCtxOpt.isPresent()) {
      LogHelper.info(TAG, `failed to import page: ${url}`);
      return Optional.empty();
    }
    return pageCtxOpt;
  }

  private static sendRouterNameForSettings(uri: string): boolean {
    LogHelper.info(TAG, `sendRouterNameForSettings, subPage: ${uri}`);
    EventBus.getInstance().emit(EventBusNameConstant.PAGE_ROUTER_SETTINGS, uri);
    return true;
  }
}