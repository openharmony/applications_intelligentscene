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

import abilityTest from './Ability.test';
import MapLocationUtilTest from './activationmanager/util/MapLocationUtil.test';
import IntentQueryAdaptorTest from './intent/adapter/IntentQueryAdaptor.test';
import DndDataMigrationManagerTest from './backup/manager/DndDataMigrationManager.test';
import AbilityUtilTest from './common/util/AbilityUtil.test';
import AccessibilityUtilTest from './common/util/AccessibilityUtils.test';
import BackgroundTaskUtilTest from './common/util/BackgroundTaskUtil.test';
import CheckEmptyUtilsTest from './common/util/CheckEmptyUtils.test';
import ConfigParseUtilTest from './common/util/ConfigParseUtil.test';
import DebounceUtilTest from './common/util/DebounceUtil.test';
import DeviceUtilTest from './common/util/DeviceUtil.test';
import FontScaleUtilTest from './common/util/FontScaleUtil.test';
import ImageUtilTest from './common/util/ImageUtil.test';
import JsonUtilTest from './common/util/JsonUtil.test';
import LanguageUtilTest from './common/util/LanguageUtil.test';
import LogUtilTest from './common/util/LogUtil.test';
import PackageUtilTest from './common/util/PackageUtil.test';
import PhoneNumberUtilTest from './common/util/PhoneNumberUtil.test';
import PreferencesUtilTest from './common/util/PreferencesUtil.test';
import ResourceUtilTest from './common/util/ResourceUtil.test';
import SettingsDataUtilTest from './common/util/SettingsDataUtil.test';
import StaticSubscriberUtilTest from './common/util/StaticSubscriberUtil.test';
import StringUtilTest from './common/util/StringUtil.test';
import TimeUtilTest from './common/util/TimeUtil.test';
import LiveViewManagerTest from './configlinkage/manager/LiveViewManager.test';
import SettingLinkageManagerTest from './configlinkage/manager/SettingLinkageManager.test';
import ConfigDataManagerTest from './datamanager/manager/ConfigDataManager.test';
import CursorDataManagerTest from './datamanager/manager/CursorDataManager.test';
import HistoryDataManagerTest from './datamanager/manager/HistoryDataManager.test';
import LearningPlanManagerTest from './datamanager/manager/LearningPlanManager.test';
import ModeDataManagerTest from './datamanager/manager/ModeDataManager.test';
import ModeUtilTest from './datamanager/utils/ModeUtil.test';
import ChangeInfoHelperTest from './datasync/template/ChangeInfoHelper.test';
import ConditionManagerTest from './phone/ut/ConditionManager.test';
import StateManagerTest from './statemanager/manager/StateManager.test';
import IntentUtilTest from './intent/util/IntentUtil.test';
import IntentSwitchAdaptorTest from './intent/adapter/IntentSwitchAdaptor.test';
import HiSysEventUtilTest from './common/util/HiSysEventUtil.test';
import RdbStoreHelperTest from './common/util/RdbStoreHelper.test';
import IntentConditionUtilTest from './intent/util/IntentConditionUtil.test';
import IntentCreateModeAdaptorTest from './intent/adapter/IntentCreateModeAdaptor.test';
import IntentModifyModeAppAdaptorTest from './intent/adapter/IntentModifyModeAppAdaptor.test';
import IntentModifyModeCallAdaptorTest from './intent/adapter/IntentModifyModeCallAdaptor.test';
import ContactDataManagerTest from './datamanager/manager/ContactDataManager.test';
import RuleFeedbackManagerTest from './datamanager/manager/RuleFeedbackManager.test';
import AllowDisturbDataManagerTest from './datamanager/manager/AllowDisturbDataManager.test';
import DbBaseManagerTest from './datamanager/manager/DbBaseManager.test';
import RefreshAdapterTest from './recommendation/adapter/RefreshAdapterTest.test';
import NotificationManagerTest from './recommendation/manager/NotificationManagerTest.test';
import PermissionManagerTest from './recommendation/manager/PermissionManagerTest.test';
import UserOperationManagerTest from './recommendation/manager/UserOperationManagerTest.test';
import DateUtilsTest from './recommendation/utils/DateUtilsTest.test';
import LocationUtilsTest from './recommendation/utils/LocationUtilsTest.test';
import SceneBaseDataManagerTest from './configmanager/manager/SceneBaseDataManager.test';
import ModeIdUtilTest from './intent/util/ModeIdUtil.test';
import VerifyPeriodUtilTest from './intent/util/VerifyPeriodUtil.test';
import UpdateConditionUtilTest from './statemanager/utils/UpdateConditionUtil.test';
import SceneEndTimeAdapterTest from './statemanager/adapter/SceneEndTimeAdapter.test';
import MigrateUtilTest from './datamanager/utils/MigrateUtil.test';
import DateTimeUtilTest from './datamanager/utils/DateTimeUtil.test';
import PhoneEl2AdapterTest from './datamanager/adapter/PhoneEl2Adapter.test';
import OperationDataManagerTest from './datamanager/manager/OperationDataManager.test';
import AllowDisturbManagerTest from './configmanager/manager/AllowDisturbManager.test';
import ModeEffectiveAdapterTest from './statemanager/adapter/ModeEffectiveAdapter.test';
import ModeConfigAdapterTest from './modeconfig/adapter/ModeConfigAdapter.test';
import SessionUtilTest from './common/util/SessionUtil.test';
import SystemParamUtilTest from './common/util/SystemParamUtil.test';
import PresetModeTest from './modeconfig/presetmode/PresetMode.test';
import LearningTaskGroupControllerTest from './phone/controller/LearningTaskGroupController.test';
import SubTextUtilTest from './phone/util/SubTextUtil.test';
import ModeManualEnableUtilTest from './phone/util/ModeManualEnableUtil.test';
import PrecastModeControllerTest from './phone/controller/PrecastModeController.test';
import RecentTimeConditionCalUtilsTest from './form/utils/RecentTimeConditionCalUtils.test';
import FormManagerTest from './form/manager/FormManager.test';
import FormDataManagerTest from './datamanager/manager/FormDataManager.test';
import TemplateModeAdapterTest from './phone/modesheet/TemplateModeAdapter.test';
import LearningPlanPageControllerTest from './phone/controller/LearningPlanPageController.test';
import IncomingCallControllerTest from './phone/controller/IncomingCallController.test';
import AppCategoryNotificationManagerTest from './phone/manager/AppCategoryNotificationManagerTest.test';
import NotDisturbNotificationManagerTest from './phone/manager/NotDisturbNotificationManagerTest.test';
import ApplicationManagerTest from './phone/manager/ApplicationManagerTest.test';
import TimeManagerTest from './phone/manager/TimeManagerTest.test';
import DefaultPageConfigTest from './common/DefaultPageConfigTest.test';
import UiExtensionViewModelTest from './common/UiExtensionViewModelTest.test';
import ModeAdapterTest from './configmanager/adapter/ModeAdapter.test';
import PhoneModeUtilTest from './phone/util/PhoneModeUtil.test';
import PhoneStringUtilTest from './phone/util/PhoneStringUtil.test';
import PhoneCheckEmptyUtilsTest from './phone/util/PhoneCheckEmptyUtils.test';
import LearningPageControllerTest from './phone/controller/LearningPageController.test';
import OperationDataUtilTest from './phone/util/OperationDataUtil.test';
import LiveViewUtilTest from './phone/util/LiveViewUtil.test';
import SettingLinkageUtilTest from './phone/util/SettingLinkageUtil.test';
import ModeAdapterUtilTest from './phone/util/ModeAdapterUtil.test';
import EmptyUtilsTest from './datamanager/utils/EmptyUtils.test';
import ClockManagerTest from './statemanager/manager/ClockManagerTest.test';
import CommonUtilTest from './datamanager/utils/CommonUtil.test';
import SavedDataUtilTest from './datamanager/utils/SavedDataUtil.test';
import ACNotificationManagerTest from './statemanager/manager/ACNotificationManagerTest.test';
import DeviceNameUtilTest from './phone/util/DeviceNameUtil.test';
import SettingLinkManagerTest from './phone/util/SettingLinkManager.test';
import ModeManualEnableServiceTest from './phone/service/ModeManualEnableService.test';
import El1CallConfigManagerTest from './datamanager/manager/El1CallConfigManager.test';
import SearchUtilTest from './common/util/SearchUtil.test';

export default function testsuite() {
  abilityTest();

  // common
  StringUtilTest();
  CheckEmptyUtilsTest();
  ConfigParseUtilTest();
  DeviceUtilTest();
  PhoneNumberUtilTest();
  ImageUtilTest();
  AbilityUtilTest();
  AccessibilityUtilTest();
  DebounceUtilTest();
  LogUtilTest();
  ResourceUtilTest();
  FontScaleUtilTest();
  JsonUtilTest();
  BackgroundTaskUtilTest();
  SettingsDataUtilTest();
  TimeUtilTest();
  StaticSubscriberUtilTest();
  LanguageUtilTest();
  PreferencesUtilTest();
  PackageUtilTest();
  HiSysEventUtilTest();
  RdbStoreHelperTest();
  SessionUtilTest();
  SystemParamUtilTest();
  DefaultPageConfigTest();
  UiExtensionViewModelTest();
  SavedDataUtilTest();
  EmptyUtilsTest();
  CommonUtilTest();
  ClockManagerTest();
  ACNotificationManagerTest();
  SearchUtilTest();

  // activation
  MapLocationUtilTest();

  // backup
  DndDataMigrationManagerTest();

  // ConfigLinkage
  SettingLinkageManagerTest();
  LiveViewManagerTest();

  // ConfigManager
  AllowDisturbManagerTest();
  SceneBaseDataManagerTest();
  ModeAdapterTest();

  // DataManager
  ConfigDataManagerTest();
  ModeUtilTest();
  ModeDataManagerTest();
  HistoryDataManagerTest();
  LearningPlanManagerTest();
  CursorDataManagerTest();
  ContactDataManagerTest();
  RuleFeedbackManagerTest();
  AllowDisturbDataManagerTest();
  DbBaseManagerTest();
  MigrateUtilTest();
  DateTimeUtilTest();
  PhoneEl2AdapterTest();
  OperationDataManagerTest();
  FormDataManagerTest();
  El1CallConfigManagerTest();

  // DataSync
  ChangeInfoHelperTest();

  // StateManager
  StateManagerTest();
  UpdateConditionUtilTest();
  SceneEndTimeAdapterTest();
  ModeEffectiveAdapterTest();

  // ModeConfig
  ModeConfigAdapterTest();
  PresetModeTest();

  // Phone
  ConditionManagerTest();
  AppCategoryNotificationManagerTest();
  NotDisturbNotificationManagerTest();
  ApplicationManagerTest();
  TimeManagerTest();
  SubTextUtilTest();
  ModeManualEnableUtilTest();
  PrecastModeControllerTest();
  LearningPlanManagerTest();
  LearningTaskGroupControllerTest();
  TemplateModeAdapterTest();
  LearningPlanPageControllerTest();
  IncomingCallControllerTest();
  PhoneCheckEmptyUtilsTest();
  PhoneModeUtilTest();
  PhoneStringUtilTest();
  LearningPageControllerTest();
  OperationDataUtilTest();
  LiveViewUtilTest();
  SettingLinkageUtilTest();
  ModeAdapterUtilTest();
  InteRecommendUtilsTest();
  DeviceNameUtilTest();
  SettingLinkManagerTest();
  ModeManualEnableServiceTest();

  // Intent
  IntentUtilTest();
  IntentSwitchAdaptorTest();
  IntentCreateModeAdaptorTest();
  IntentModifyModeAppAdaptorTest();
  IntentModifyModeCallAdaptorTest();
  IntentConditionUtilTest();
  IntentQueryAdaptorTest();
  ModeIdUtilTest();
  VerifyPeriodUtilTest();

  //Recommendation
  RefreshAdapterTest();
  NotificationManagerTest();
  PermissionManagerTest();
  UserOperationManagerTest();
  DateUtilsTest();
  LocationUtilsTest();

  // Form
  RecentTimeConditionCalUtilsTest();
  FormManagerTest();
}