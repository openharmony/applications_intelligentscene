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

import notificationManager from '@ohos.notificationManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { AppData } from '@ohos/scene.datamanage/src/main/ets/model/AppData';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { AllowDisturbDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/AllowDisturbDataManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { AllowDisturbManager } from '@ohos/scene.configmanage/src/main/ets/manager/AllowDisturbManager';
import { MODE_SUPPORT_CATEGORY } from '../constant/AppCategoryConstant';

/* instrument ignore file */
const TAG: string = 'AppCategoryNotificationManager: ';

interface AppCategoryInfo {
  bundleName: string;
  primaryCategoryId: number;
  secondaryCategoryId: number;
  appQueryCode: number;
}

/**
 * 应用分类通知管理类
 */
export class AppCategoryNotificationManager {
  private static instance: AppCategoryNotificationManager;

  public static getInstance(): AppCategoryNotificationManager {
    if (!AppCategoryNotificationManager.instance) {
      AppCategoryNotificationManager.instance = new AppCategoryNotificationManager();
    }
    return AppCategoryNotificationManager.instance;
  }

  /**
   * 初始化模式时，给对应类型模式添加对应类型通知白名单应用
   *
   * @param modeId 模式id
   */
  public async initModeAppNotificationConfigData(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `initModeAppNotificationConfigData ${modeId}`);
    if (!ModeUtil.isPrecastMode(modeId)) {
      LogUtil.showInfo(TAG, 'not precast mode');
      return;
    }
    let supportCategory: number[] | undefined = MODE_SUPPORT_CATEGORY.get(modeId);
    if (!supportCategory?.length) {
      LogUtil.showWarn(TAG, 'current mode not support category');
      return;
    }
    let bundles: notificationManager.BundleOption[] = [];
    let bundleNames: string[] = [];
    try {
      let data: notificationManager.BundleOption[] = await notificationManager.getAllNotificationEnabledBundles();
      LogUtil.showInfo(TAG, `bundleOption length: ${data?.length}`);
      for (let bundleOption of data) {
        let bundleName: string = JsonUtil.stringify(bundleOption.bundle).replace(/"/g, '');
        let uid: number = parseInt(JsonUtil.stringify(bundleOption.uid).replace(/"/g, ''));
        bundles.push({ bundle: bundleName, uid: uid });
        bundleNames.push(bundleName);
      }
    } catch (e) {
      LogUtil.showError(TAG, `getAllNotificationEnabledBundles error ${e?.code} ${e?.message}`);
    }
    if (bundleNames.length === 0) {
      LogUtil.showError(TAG, 'not open notification');
      return;
    }
    let appCategoryInfoList: AppCategoryInfo[] = await this.getAppCategory(bundleNames);
    let supportCategoryInfoList: AppCategoryInfo[] = this.filterCategoryByMode(modeId,
      appCategoryInfoList);
    if (!supportCategoryInfoList?.length) {
      LogUtil.showWarn(TAG, 'supportCategoryInfoList is empty');
      return;
    }
    let appData: AppData[] = this.mergeNotificationInfo2AppData(bundles, supportCategoryInfoList);
    if (appData.length === 0) {
      LogUtil.showWarn(TAG, 'not has appData');
      return;
    }
    LogUtil.showInfo(TAG, `add notification appData ${appData.length}`);
    await AllowDisturbManager.getInstance().updateAllowNotificationList({ selectedAppList: appData }, modeId);
    await AllowDisturbDataManager.setAllowDisturbAppList(modeId);
    EventBus.getInstance().emit(EventBusNameConstant.DB_NOTIFICATION_DATA_REFRESH);
  }

  /**
   * 根据包名获取应用分类信息
   *
   * @param bundleNames 包名列表
   * @return 应用分类信息列表
   */
  private async getAppCategory(bundleNames: string[]): Promise<AppCategoryInfo[]> {
    LogUtil.showWarn(TAG, `getAppCategory is not supported, bundle count: ${bundleNames.length}`);
    return [];
  }

  private mergeNotificationInfo2AppData(bundles: notificationManager.BundleOption[],
    appCategoryInfoList: AppCategoryInfo[]): AppData[] {
    let result: AppData[] = [];
    for (let bundle of bundles) {
      if (this.isBundleNameInCategoryInfoList(bundle.bundle, appCategoryInfoList)) {
        result.push({
          bundleName: bundle.bundle,
          uid: bundle.uid ?? 0,
          index: 0
        });
      }
    }
    return result;
  }

  private isBundleNameInCategoryInfoList(bundleName: string,
    appCategoryInfoList: AppCategoryInfo[]): boolean {
    for (let category of appCategoryInfoList) {
      if (bundleName === category.bundleName) {
        return true;
      }
    }
    return false;
  }

  /**
   * 根据配置的模式支持的应用分类 过滤掉不匹配的应用
   *
   * @param modeId 模式id
   * @param appCategoryInfoList 通知应用分类信息列表
   * @return 与模式匹配的应用类型列表
   */
  private filterCategoryByMode(modeId: string,
    appCategoryInfoList: AppCategoryInfo[]): AppCategoryInfo[] {
    let modeSupportCategory = MODE_SUPPORT_CATEGORY.get(modeId);
    if (!modeSupportCategory) {
      LogUtil.showWarn(TAG, 'filterCategoryByMode not config support category');
      return [];
    }
    if (modeId === ModeType.GAME_MODE) {
      return appCategoryInfoList.filter((i) => {
        return modeSupportCategory && modeSupportCategory.indexOf(i.primaryCategoryId) >= 0;
      });
    }

    return appCategoryInfoList.filter((i) => {
      return modeSupportCategory && modeSupportCategory.indexOf(i.secondaryCategoryId) >= 0;
    });
  }
}
