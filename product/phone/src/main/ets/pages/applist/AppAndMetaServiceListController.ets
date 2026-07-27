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
import i18n from '@ohos.i18n';
import { BundleStatusChangeListener } from '@ohos/scene.common/src/main/ets/bundle/BundleStatusChangeManager';
import { AppInfoDataSource } from './AppInfoDataSource';
import { AppInfo } from './AppInfo';

/* instrument ignore file */
const NO_DISTURB_WHITE_LIST: string[] = [
  'com.openharmony.ohos.clock',
  'com.ohos.callui',
];

enum AppType {
  APP,
}

export class AppAndMetaServiceListController implements BundleStatusChangeListener {
  private appGroups: AppInfoDataSource;
  private allSearchData?: AppInfoDataSource;
  private allAppList: AppInfo[] = [];
  private onAppItemClicked?: (index: number, item: AppInfo) => void;
  private selectIndex: number = 0;
  private isLoading: boolean = true;
  private hasFinishedLoad: boolean = false;
  private hasSetWhiteList: boolean = true;
  private tag: string = 'AppAndMetaServiceListController';
  private isAppLoadingProcess: boolean = false;
  private appListLoadEventCb = (data: Object) => {
    if (this.appGroups?.totalCount() > 0 || this.hasFinishedLoad) {
      return;
    }
  };
  private appListLoadCompleteEventCb = (data: Object) => {
  };

  constructor(datasource: AppInfoDataSource, allSearchData?: AppInfoDataSource,
    onAppItemClicked?: (index: number, item: AppInfo) => void) {
    this.appGroups = datasource;
    this.allSearchData = allSearchData;
    this.onAppItemClicked = onAppItemClicked;
  }

  getListenerName(): string {
    return this.tag;
  }

  onBundleAdd(bundleName: string, userId: number, appIndex: number): void {
  }

  onBundleUpdate(bundleName: string, userId: number, appIndex: number): void {
  }

  onBundleRemove(bundleName: string, userId: number, appIndex: number): void {
    if (!this.onAppItemClicked) {
      return;
    }
    if (!this.appGroups?.getArray()) {
      return;
    }
    try {
      const removeIndex: number = this.appGroups.getArray().findIndex((item) => {
        return item.name === bundleName && item.appIndex === appIndex;
      });
      const appInfo: AppInfo = this.appGroups.getData(removeIndex);
      appInfo.isSelected = false;
      // 刷新已选界面
      this.onAppItemClicked(0, appInfo);
      this.appGroups.removeDataByIndex(removeIndex);
      this.allAppList = this.allAppList.filter((item) => {
        return item.name !== bundleName || item.appIndex !== appIndex;
      });
      if (this.allSearchData) {
        this.removeFromArray(this.allSearchData, bundleName, appIndex);
      }
    } catch (error) {
    }
  }

  private removeFromArray(dataSource: AppInfoDataSource, bundleName: string, appIndex: number): void {
    const removeIndex: number = dataSource.getArray().findIndex((item) => {
      return item.name === bundleName && item.appIndex === appIndex;
    });
    dataSource.removeDataByIndex(removeIndex);
  }

  init(): void {
    this.hasFinishedLoad = false;
    if ((AppStorage.get('hasSetWhiteList') as boolean) === true) {
      this.hasSetWhiteList = true;
    }
    this.isLoading = true;
  }

  destroy(): void {
  }

  selectIndexesUpdated(selectIndex: number): void {
    this.selectIndex = selectIndex;
    if (this.isLoading) {
      return;
    }
    this.appGroups?.clearAll();
    if (selectIndex === 0) {
      for (let element of this.allAppList) {
        this.appGroups?.pushData(element);
      }
    }
    let isEmpty: boolean = this.appGroups.totalCount() === 0;
    if (isEmpty) {
      this.appGroups.notifyDataReload();
    }
  }

  async onAppListChanged(): Promise<void> {
  }
}