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

export const SETTINGS_UI_APPEARANCE_DARK_MODE: string = 'settings.uiappearance.darkmode_mode';
export const DEFAULT_DARK_MODE: string = 'scene.default.darkmode';
export const DEFAULT_DARK_MODE_STATE: string = '0';
export const DARK_MODE_OPEN_ALL_DAY: string = '1';
export const DARK_MODE_TIMED_ON: string = '2';
export const SETTING_DATA_DARK_MODE: string = '2';
export const SETTING_DATA_LIGHT_MODE: string = '1';
export const SETTING_DATA_LIGHT_MODE_NOT_LINKED: string = '3';

export const DEFAULT_EYE_PROTECT_MODE: string = 'scene.default.eye_project';
export const SETTINGS_EYESHIELD_ENABLE = 'settings.eyeshield.enable';
export const SETTINGS_DISPLAY_EYE_COMFORT_MODE = 'settings.display.eye_comfort_mode';
export const EYE_PROTECT_MODE_ENABLED: string = '1';
export const EYE_PROTECT_MODE_DISABLED: string = '0';
export const EYE_PROTECT_MODE_NOT_LINKED: string = '4';

export const SCENE_DISABLE: string = '0';
export const SCENE_ENABLE: string = '1';

export const SCENE_START_TIME: string = 'sceneStartTime';
export const SCENE_TOKEN_KEY: string = 'intelligent.scene.token';
export const GREET_FLAG: string = 'intelligent.scene.greet';
export const SHOW_GREET_DURATION: string = 'intelligent.scene.show.greet.duration';

export const TWENTY_MINUTES: number = 20 * 60 * 1000;
export const SET_MODE_DELAY: number = 10;
export const MAX_ACCURACY: number = 100;

export const LOCATION_WEATHER_URL: string = 'datashareproxy://com.openharmony.ohosapp.totemweather/locationWeather';
export const LOCATION_WEATHER_ID: string = '1001';

export const enum DayHours {
  TWO = 2,
  FIVE = 5,
  SIX = 6,
  TWELVE = 12,
  FOURTEEN = 14,
  EIGHTEEN = 18,
  TWENTY_THREE = 23,
};

export const INVALID_CONNECTION_ID: number = -1;
export const REQUEST_CODE: number = 1;
export const LEARNING_START_TIME: string = '00:00';

/**
 * 请求方法
 *
 * @since 2025-01-11
 */
export const enum RequestMethod {
  /**
   * 发送通知
   */
  SEND_NOTIFICATION = 'sendNotification',
  /**
   * 移除通知
   */
  CANCEL_NOTIFICATION = 'cancelNotification',
  /**
   * 更新通知
   */
  UPDATE_NOTIFICATION = 'updateNotification',
}

export const enum ACTION {
  NO_ACTION = 0,
  CACHE_AND_ON,
  ON_TO_DEFAULT,
  OFF_TO_ON,
  ON_TO_OFF,
  CACHE_AND_OFF,
  OFF_TO_DEFAULT
};

export const SCB_IS_WANT: Want = {
  bundleName: 'com.ohos.sceneboard',
  abilityName: 'IntelligentSceneService'
};

export interface NotificationData {
  type: string;
  title: string;
  text: string;
  modeId: string;
  startTime: number;
  preStartTime: number;
  duration: number;
  capsuleTitle: string;
  capsuleContent: string;
  extra?: Record<string, string>;
}