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

import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
} from '@ohos/hypium';
import { LogUtil } from '@ohos/scene.common';
import { appInfoManager } from '@kit.StoreKit';
import { notificationManager } from '@kit.NotificationKit';
import { AppData, ModeDataManager, ModeUtil } from '@ohos/scene.datamanage';
import {
  AppCategoryNotificationManager
} from '../../../../../main/ets/pages/nodisturb/manager/AppCategoryNotificationManager';

const TAG: string = 'ACNotificationManagerTest: ';

export default function ACNotificationManagerTest() {
  describe('ACNotificationManagerTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('acn_get_instance_test', 0, (done: Function) => {
      try {
        const instance: AppCategoryNotificationManager = AppCategoryNotificationManager.getInstance();
        expect(instance !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG, `error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('acn_init_mode_app_notification_configData_test', 0, async (done: Function) => {
      try {
        const instance: AppCategoryNotificationManager = AppCategoryNotificationManager.getInstance();
        const errorModeId: string = "-1";
        instance.initModeAppNotificationConfigData(errorModeId);
        const isModeIdExist: boolean = await ModeDataManager.getInstance().isModeIdExist("1");
        if (isModeIdExist) {
          instance.initModeAppNotificationConfigData("1");
        }
        expect(ModeUtil.isPrecastMode(errorModeId)).assertFalse();
      } catch (err) {
        LogUtil.showError(TAG,
          `error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('acn_is_bundleName_inCategory_infoList_test', 0, async (done: Function) => {
      try {
        const instance: AppCategoryNotificationManager = AppCategoryNotificationManager.getInstance();
        const testName: string = 'com.openharmony.ohos.settings';
        const isBundleNameInCategoryInfoList: boolean =
          (instance as object)['isBundleNameInCategoryInfoList'](testName, [{
            bundleName: 'com.ohos.intelligentscene',
            primaryCategoryId: 1,
            secondaryCategoryId: 2,
            appQueryCode: 0,
          }]);
        expect(isBundleNameInCategoryInfoList).assertFalse();

        const testName2: string = 'com.ohos.intelligentscene';
        const isBundleNameInCategoryInfoList2: boolean =
          (instance as object)['isBundleNameInCategoryInfoList'](testName2, [{
            bundleName: 'com.ohos.intelligentscene',
            primaryCategoryId: 1,
            secondaryCategoryId: 2,
            appQueryCode: 0,
          }]);
        expect(isBundleNameInCategoryInfoList2).assertTrue();

        const testName3: string = '';
        const isBundleNameInCategoryInfoList3: boolean =
          (instance as object)['isBundleNameInCategoryInfoList'](testName3, [{
            bundleName: 'com.ohos.intelligentscene2',
            primaryCategoryId: 1,
            secondaryCategoryId: 2,
            appQueryCode: 0,
          }]);
        expect(isBundleNameInCategoryInfoList3).assertFalse();

        const testName4: string = 'com.ohos.intelligentscene';
        const isBundleNameInCategoryInfoList4: boolean =
          (instance as object)['isBundleNameInCategoryInfoList'](testName4, [{
            bundleName: 'com.ohos.intelligentscene',
            primaryCategoryId: 0,
            secondaryCategoryId: 0,
            appQueryCode: 0,
          }]);
        expect(isBundleNameInCategoryInfoList4).assertTrue();

        const testName5: string = 'com.openharmony.ohos.settings';
        const isBundleNameInCategoryInfoList5: boolean =
          (instance as object)['isBundleNameInCategoryInfoList'](testName5, [{
            bundleName: 'com.openharmony.ohos.settings',
            primaryCategoryId: 0,
            secondaryCategoryId: 0,
            appQueryCode: 0,
          }]);
        expect(isBundleNameInCategoryInfoList5).assertTrue();

      } catch (err) {
        LogUtil.showError(TAG, `error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('acn_merge_notification_info2AppData_test', 0, async (done: Function) => {
      try {
        const instance: AppCategoryNotificationManager = AppCategoryNotificationManager.getInstance();
        let testInputBundle1: notificationManager.BundleOption[] = [{
          bundle: 'test',
          uid: 100,
        },
          {
            bundle: 'test1',
            uid: 100,
          },
          {
            bundle: 'test2',
            uid: 100,
          },
          {
            bundle: 'test3',
            uid: 100,
          }];
        let appCategoryInfoList1: appInfoManager.AppCategoryInfo[] = [];
        const result: AppData[] =
          await (instance as object)['mergeNotificationInfo2AppData'](testInputBundle1, appCategoryInfoList1);
        expect(result.length === 0).assertTrue();

        let testInputBundle2: notificationManager.BundleOption[] = [{
          bundle: 'test',
          uid: 100,
        }];
        let appCategoryInfoList2: appInfoManager.AppCategoryInfo[] = [{
          bundleName: 'test',
          primaryCategoryId: 1,
          secondaryCategoryId: 1,
          appQueryCode: 1,
        }, {
          bundleName: 'test2',
          primaryCategoryId: 1,
          secondaryCategoryId: 1,
          appQueryCode: 1,
        }, {
          bundleName: 'test3',
          primaryCategoryId: 1,
          secondaryCategoryId: 1,
          appQueryCode: 1,
        }
        ];
        const result2: AppData[] =
          await (instance as object)['mergeNotificationInfo2AppData'](testInputBundle2, appCategoryInfoList2);
        expect(result2.length > 0).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG, `test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('acn_filter_category_by_mode_test', 0, async (done: Function) => {
      try {
        const instance: AppCategoryNotificationManager = AppCategoryNotificationManager.getInstance();
        const testModeId: string = '1';
        let appCategoryInfoList1: appInfoManager.AppCategoryInfo[] = [];
        const result: appInfoManager.AppCategoryInfo[] =
          await (instance as object)['filterCategoryByMode'](testModeId, appCategoryInfoList1);
        expect(result.length === 0).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `acn_filter_category_by_mode_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });
  });
}
