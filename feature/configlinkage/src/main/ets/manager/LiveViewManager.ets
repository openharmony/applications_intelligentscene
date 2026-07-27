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

import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { JsonUtil } from '@ohos/scene.common/src/main/ets/utils/JsonUtil';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneErrorEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { FaultScene, FaultSubScene } from '@ohos/scene.common/src/main/ets/systemEvent/EventRsultConstsByTs';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { TimeUtil } from '@ohos/scene.common/src/main/ets/utils/TimeUtil';
import { El1ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/El1ModeDataManager';
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import lazy { TimeConstant } from '@ohos/scene.common/src/main/ets/constant/TimeConstant';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { LEARNING_START_TIME, NotificationData, RequestMethod } from '../constant/LinkageConstants';

const TAG: string = 'LiveViewManager: ';

export class LiveViewManager {

  public sendLiveView(modeId: string): void {
    LogUtil.showInfo(TAG, `sendLiveView, modeId: ${modeId}`);
    let data: ModeData | undefined = El1ModeDataManager.getInstance().queryModeDataByIdSync(modeId);
    if (!data) {
      LogUtil.showWarn(TAG, 'sendLiveView fail, mode data is undefined');
      return;
    }
    const modeName: string = ModeUtil.getModeNameStr(data);
    let title: string = modeName;
    let text: string = ResourceUtil.getStringSync($r('app.string.mode_starting_tips'));
    let capsuleTitle: string = modeName;
    let capsuleContent: string = ResourceUtil.getFormatStringSync($r('app.string.mode_started'), '');
    let extra: Record<string, string> = {};
    let bootTime: number = TimeUtil.getDeviceBootTime();
    let ntfData: NotificationData = {
      title: title,
      text: text,
      capsuleTitle: capsuleTitle,
      capsuleContent: capsuleContent,
      modeId: modeId,
      startTime: bootTime,
      preStartTime: 0,
      duration: 0,
      extra: extra,
    } as NotificationData;
    this.processNtfData(modeId, ntfData);
    this.saveNtfData(RequestMethod.SEND_NOTIFICATION, ntfData);
  }

  public cancelLiveView(modeId: string): void {
    LogUtil.showInfo(TAG, `cancelLiveView, modeId: ${modeId}`);
    let data: ModeData | undefined = El1ModeDataManager.getInstance().queryModeDataByIdSync(modeId);
    if (!data) {
      LogUtil.showWarn(TAG, 'cancelLiveView fail, mode data is undefined');
      return;
    }
    let title: string = ModeUtil.getModeNameStr(data);
    let text: string = ResourceUtil.getFormatStringSync($r('app.string.mode_ended'), '');
    const bootTime: number = TimeUtil.getDeviceBootTime();
    this.saveNtfData(RequestMethod.CANCEL_NOTIFICATION, {
      title: title,
      text: text,
      capsuleTitle: title,
      capsuleContent: text,
      modeId: modeId,
      startTime: bootTime,
      preStartTime: 0,
      duration: 0,
    } as NotificationData);
  }

  public notifyLiveViewRefresh(): void {
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_STATE, '1');
  }

  public updateLiveView(ntfData: NotificationData): void {
    LogUtil.showInfo(TAG, `updateLiveView, modeId: ${ntfData.modeId}`);
    this.saveNtfData(RequestMethod.UPDATE_NOTIFICATION, ntfData);
    SettingsDataUtils.setSecureValue(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_STATE, '1');
  }

  public fillLearningNtfData(ntfData: NotificationData): void {
    const prefix: string = ResourceUtil.getStringSync($r('app.string.learning'));
    let title: string = prefix;
    let content: string = ResourceUtil.getStringSync($r('app.string.mode_starting_tips'));
    ntfData.title = title;
    ntfData.extra = {
      'immersiveTitle': prefix,
      'immersiveContent': content,
    };
  }

  /**
   * 是否需要处理学习模式学习时长
   */
  private processLearningModeNtfIfNeed(ntfData: NotificationData): void {
    const value: string = SettingsDataUtils.getSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, '');
    if (!value) {
      LogUtil.showWarn(TAG, 'isNeedProcessLearningDuration, ntf data is empty');
      return;
    }
    const currentModeId: string = SettingsDataUtils.getSecureValue(SettingsDataKeyConstant.FOCUS_MODE_PROFILE, '');

    // 锁屏未解锁场景下开启学习模式只修改了settingsdata值，解锁后，学习模式重新开启场景适配
    if (currentModeId !== ModeType.LEARNING_MODE) {
      LogUtil.showWarn(TAG, 'no need process learning mode duration');
      return;
    }
    const ntfObj: NotificationData = JsonUtil.fromJson(value) as NotificationData;
    if (ntfObj && ntfObj.modeId !== ModeType.LEARNING_MODE) {
      LogUtil.showWarn(TAG, 'ntf data invalid,no need process');
      return;
    }
    const nowBootTime: number = TimeUtil.getDeviceBootTime();
    let duration: number = nowBootTime - ntfObj.startTime;
    duration = Math.floor(duration / TimeConstant.ONE_MINUTE_MS_UNIT);
    LogUtil.showInfo(TAG,
      `process learning duration, nowBootTime: ${nowBootTime}, startTime: ${ntfObj.startTime} duration: ${duration}`);
    ntfData.duration = duration >= 0 ? duration : 0;
    ntfData.preStartTime = ntfData.duration * TimeConstant.ONE_MINUTE_MS_UNIT;
    ntfData.text = TimeUtil.buildLearningTime(ntfData.duration);
  }

  private saveNtfData(method: string, data: NotificationData): void {
    try {
      LogUtil.showInfo(TAG, `saveNtfData, method: ${method}, modeId: ${data.modeId}`);
      SettingsDataUtils.setSettingsData(SettingsDataKeyConstant.INTELLIGENT_SCENE_NTF_DATA, JSON.stringify(data));
    } catch (e) {
      HiSysEventUtil.reportDefaultBehaviorEvent(HiSysIntelligentSceneErrorEvent.SENCE_EXTERNAL_ERROR,
        FaultScene.SEND_MESSAGE_FAIL, FaultSubScene.SEND_MESSAGE_FAIL, e?.code, e?.message);
      LogUtil.showError(TAG, `request fail: ${e?.message}`);
    }
  }
}

export default new LiveViewManager();