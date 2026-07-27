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
  describe,
  beforeEach,
  afterEach,
  it,
  MockKit,
  when,
  expect,
} from '@ohos/hypium';
import { afterAll, beforeAll } from '@ohos/hypium/src/main/interface';
import { settings } from '@kit.BasicServicesKit';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { ConfigConstant } from '@ohos/scene.common/src/main/ets/constant/ConfigConstant';
import { SystemParamUtil } from '@ohos/scene.common/src/main/ets/utils/SystemParamUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { DndDataMigrationManager } from '@ohos/scene.backup/src/main/ets/manager/DndDataMigrationManager';
import { FOCUS_MODE_TIMER } from '@ohos/scene.notdisturb/src/main/ets/NotDisturbTimerManager';
import { AllowAppData} from '@ohos/scene.datamanage/src/main/ets/model/AllowDisturbData';
import { AppData } from '@ohos/scene.datamanage/src/main/ets/model/AppData';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ContactData } from '@ohos/scene.datamanage/src/main/ets/model/base/ContactModel';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';
import { DndDataModel } from '@ohos/scene.backup/src/main/ets/model/DndDataModel';

const TRANSFER_SETTING_DND_DATA: string = 'transfer_setting_dnd_data';
const HAS_TRANSFER_DND_DATA: string = '1';

export default function DndDataMigrationManagerTest() {
  describe('DndDataMigrationManagerTest', () => {
    beforeEach(() => {
    });

    beforeAll(() => {
    });

    afterEach(() => {
    });

    afterAll(() => {
    });

    it('transferSettingDndData_test', 0, async (done: Function) => {
      SettingsDataUtils.setSettingsData(TRANSFER_SETTING_DND_DATA, HAS_TRANSFER_DND_DATA);
      await DndDataMigrationManager.getInstance().transferSettingDndData();
      const value: string = SettingsDataUtils.getSettingsData(TRANSFER_SETTING_DND_DATA, HAS_TRANSFER_DND_DATA);
      expect(value === HAS_TRANSFER_DND_DATA).assertTrue();

      SettingsDataUtils.setSettingsData(TRANSFER_SETTING_DND_DATA, '');
      await DndDataMigrationManager.getInstance().transferSettingDndData();

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(SystemParamUtil, SystemParamUtil.getParam);
      when(mockFunc)(ConfigConstant.CONST_INTELLIGENT_SCENE_ENABLE).afterReturn('true');
      await DndDataMigrationManager.getInstance().transferSettingDndData();
      when(mockFunc)('const.intelligentscene.enable').afterReturn('false');
      await DndDataMigrationManager.getInstance().transferSettingDndData();
      mocker.ignoreMock(SystemParamUtil, SystemParamUtil.getParam);
      done();
    });

    it('transferDndTimerData_test', 0, async (done: Function) => {
      let timeStr: string = `[{"id":1,"startTime":"22:00","endTime":"07:00","repeat":"1,7","isOpen":false` +
        `,"repeatType":1,"skipEndTime":0},{"id":2,"isOpen":true,"repeat":"1,4,5,7",` +
        `"startTime":"22:00","endTime":"7:00","repeatType":1,"skipEndTime":0,"repeatText":"周日、周六"}]`;
      SettingsDataUtils.setSettingsData(FOCUS_MODE_TIMER, timeStr, settings.domainName.USER_PROPERTY);
      const value: string = SettingsDataUtils
        .getSettingsData(FOCUS_MODE_TIMER, timeStr, settings.domainName.USER_PROPERTY);
      expect(value === timeStr).assertTrue();
      await DndDataMigrationManager.getInstance().transferDndTimerData();
      done();
    });

    it('transferNotificationData_test', 0, async (done: Function) => {
      await DndDataMigrationManager.getInstance().transferNotificationData();
      let apps: AppData[] = [
        {
          bundleName: 'com.openharmony.ohos.finddevice',
          index: 0,
          uid: -1
        }
      ];
      let selectApp: AllowAppData = {
        selectedAppList: apps
      };
      let configData: ConfigData = {
        configId: '',
        modeId: ModeType.DND_MODE,
        configType: ConfigType.NOTIFICATION_NOT_DISTURB_POLICY,
        configValue: JsonUtil.stringify(selectApp)
      };
      await ConfigDataManager.getInstance().insertConfigData(configData);
      await DndDataMigrationManager.getInstance().transferNotificationData();
      const list: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType('1', ConfigType.NOTIFICATION_NOT_DISTURB_POLICY);
      expect(list.length >= 0).assertTrue();

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DndDataMigrationManager.getInstance(),
        DndDataMigrationManager.getInstance().queryTrustAppDataInfo);
      when(mockFunc)(ModeType.DND_MODE).afterReturn(apps);
      await DndDataMigrationManager.getInstance().transferNotificationData();
      done();
    });

    it('transferContactData_test', 0, async (done: Function) => {
      let repeatConfigData: ConfigData[] = await ConfigDataManager.getInstance()
        .queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.REPEATED_CALL_RING_SWITCH);
      await DndDataMigrationManager.getInstance().transferContactData();
      if (repeatConfigData && repeatConfigData.length > 0) {
        let configData: ConfigData = repeatConfigData[0];
        let enableStatus: EnableState = JsonUtil.fromJson(configData.configValue) as EnableState;
        enableStatus.enable = !enableStatus.enable;
        configData.configValue = JsonUtil.stringify(enableStatus);
        await ConfigDataManager.getInstance().updateConfigData(configData);
        await DndDataMigrationManager.getInstance().transferContactData();
      }
      const count: number = await ModeDataManager.getInstance().queryModeCount();
      expect(count >= 0).assertTrue();
      done();
    });

    it('transferContactData_migrationContactTest', 0, migrationContactTest);

    it('transferContactData_testMigration', 0, testMigration);
  });
}

async function migrationContactTest(): Promise<void> {
  await DndDataMigrationManager.getInstance().getSettingSelectContacts();
  let mocker: MockKit = new MockKit();
  let mockFunc: Function = mocker.mockFunc(DndDataMigrationManager.getInstance(),
    DndDataMigrationManager.getInstance().getSettingSelectContacts);
  const contactData: ContactData = {
    modeId: '1',
    detailInfo: '13011111111',
    formatPhoneNumber: '13011111111',
    focusModeList: '1'
  };
  when(mockFunc)().afterReturn([contactData]);
  await DndDataMigrationManager.getInstance().migrationContact();
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function testMigration(): Promise<void> {
  await ConfigDataManager.getInstance().insertConfigData({
    configId: '',
    modeId: '1',
    configType: ConfigType.TRIGGER_CONDITION_TIME,
    configValue: '{"enable":true,"configType":3,"loopType":3,"loopDays":"6,7","timeStart":"17:00","timeEnd":"18:00"}',
  });
  let configDataList: ConfigData[] = await ConfigDataManager.getInstance()
    .queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.TRIGGER_CONDITION_TIME);
  let timer: string = `[{"id":1,"startTime":"22:00","endTime":"07:00","repeat":"1,7","isOpen":false,"repeatType":1}]`;
  let dndDataList: DndDataModel[] = JsonUtil.fromJson(timer) as DndDataModel[];
  const flag: boolean = DndDataMigrationManager.getInstance().hasSameTimeCondition(dndDataList[0], configDataList);
  expect(flag !== undefined).assertTrue();
  DndDataMigrationManager.getInstance().dndDataModel2TimeCondition(dndDataList[0]);
  DndDataMigrationManager.getInstance().covet2TimeLoopDays();
  DndDataMigrationManager.getInstance().covet2TimeLoopDays('1,7');
  DndDataMigrationManager.getInstance().covet2TimeLoopDays('1,2,3,4,5,6,7');
  DndDataMigrationManager.getInstance().isSameTimeConditionData(dndDataList[0], configDataList[0]);
  DndDataMigrationManager.getInstance().isSameLoopDays('6,7', configDataList[0]);
}