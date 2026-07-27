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
import { notificationManager } from '@kit.NotificationKit';
import {
  NotDisturbNotificationManager
} from '../../../../../main/ets/pages/nodisturb/manager/NotDisturbNotificationManager';

const TAG: string = 'NotDisturbNotificationManagerTest: ';

export default function NotDisturbNotificationManagerTest() {
  describe('NotDisturbNotificationManagerTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('not_disturb_notification_manager_get_instance_test', 0, (done: Function) => {
      try {
        const instance: NotDisturbNotificationManager = NotDisturbNotificationManager.getInstance();
        expect(instance !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `not_disturb_notification_manager_get_instance_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('get_current_notification_white_list_test', 0, async (done: Function) => {
      try {
        const instance: NotDisturbNotificationManager = NotDisturbNotificationManager.getInstance();
        const allowAppData: notificationManager.BundleOption[] | undefined = (instance as object)['allowAppData'];
        const notificationList: notificationManager.BundleOption[] | undefined =
          instance.getCurrentNotificationWhiteList();
        if (allowAppData) {
          expect(allowAppData.length).assertEqual(notificationList?.length);
        } else {
          expect(allowAppData).assertUndefined();
        }
      } catch (err) {
        LogUtil.showError(TAG,
          `get_current_notification_white_list_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('has_set_notification_white_list_test', 0, async (done: Function) => {
      try {
        const instance: NotDisturbNotificationManager = NotDisturbNotificationManager.getInstance();
        const allowAppData: notificationManager.BundleOption[] | undefined = (instance as object)['allowAppData'];
        const hasSetNotificationWhiteList: boolean = instance.hasSetNotificationWhiteList();
        if (!allowAppData) {
          expect(hasSetNotificationWhiteList).assertFalse();
        } else {
          expect(allowAppData.length > 0).assertEqual(hasSetNotificationWhiteList);
        }
      } catch (err) {
        LogUtil.showError(TAG,
          `has_set_notification_white_list_test error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });
  });
}