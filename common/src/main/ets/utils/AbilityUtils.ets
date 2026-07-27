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

import rpc from '@ohos.rpc';
import lazy { appManager, common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@ohos.base';
import { LogUtil } from './LogUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtilsByTs';
import { FaultScene, FaultSubScene } from '../systemEvent/EventRsultConstsByTs';

/* instrument ignore file */
/**
 * 系统弹框参数
 */
export interface SysDialogWant {
  bundleName: string;
  abilityName: string;
  sysDialogZOrder: number;
}

export class IntelligentSceneConstant {
  public static readonly BUNDLE_NAME: string = 'com.ohos.intelligentscene';
  public static readonly ABILITY_NAME: string = 'EntryAbility';
  public static readonly INTELLIGENT_SCENE_SERVICE_EXT_ABILITY: string = 'IntelligentSceneServiceExtAbility';
  public static readonly UI_EXT_ABILITY_PROCESS_NAME: string = 'com.ohos.intelligentscene:sys/commonUI';
}

export class SettingsConstant {
  public static readonly SETTINGS_BUNDLE_NAME: string = 'com.ohos.settings';
  public static readonly SETTINGS_MAIN_ABILITY_NAME: string = 'com.ohos.settings.MainAbility';
  public static readonly APPLICATION_INFO_ENTRY: string = 'application_info_entry';
  public static readonly WIFI_ENTRY: string = 'wifi_entry';
}

// sceneboard 那边的参数code
const OPEN_CODE: number = 1;

const TAG: string = 'AbilityUtils:';

/**
 * Ability工具�?
 */
export class AbilityUtils {
  /**
   * 启动Ability
   *
   * @param want 启动参数
   */
  static startAbility(context: common.UIAbilityContext | common.UIExtensionContext, want: Want,
    callback?: () => void): void {
    try {
      context.startAbility(want).then((data) => {
        LogUtil.showInfo(TAG, 'succeed to start ability');
        if (callback) {
          callback();
        }
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `startAbility fail. code:${err?.code} message:${err?.message}`);
        if (callback) {
          callback();
        }
      });
    } catch (error) {
      LogUtil.showError(TAG, `startAbility catch error. code:${error?.code} message:${error?.message}`);
    }
  }

  /**
   * 启动ServiceExtensionAbility
   *
   * @param context 上下�?
   * @param want 启动参数
   * @param callback 启动回调
   */
  static startServiceExtensionAbility(context: common.UIAbilityContext | common.UIExtensionContext, want: Want,
    callback?: (err?: BusinessError) => void): void {
    try {
      context.startServiceExtensionAbility(want).then((data) => {
        LogUtil.showInfo(TAG, 'succeed to start ability');
        if (callback) {
          callback();
        }
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `startServiceExtensionAbility fail. code:${err?.code} message:${err?.message}`);
        if (callback) {
          callback(err);
        }
      });
    } catch (error) {
      LogUtil.showError(TAG, `startServiceExtensionAbility catch error. code:${error?.code} message:${error?.message}`);
    }
  }

  static startAbilityIntelligent(): void {
    AbilityUtils.startAbility(AbilityContextManager.getContext() as common.UIExtensionContext, {
      bundleName: SettingsConstant.SETTINGS_BUNDLE_NAME,
      abilityName: SettingsConstant.SETTINGS_MAIN_ABILITY_NAME,
      uri: SettingsConstant.APPLICATION_INFO_ENTRY,
      parameters: {
        pushParams: IntelligentSceneConstant.BUNDLE_NAME
      }
    }, () => {
      LogUtil.showInfo(TAG, 'start about application info page success');
    });
  }

  /**
   * 拉起系统弹框,可能会抛异常，需要调用方捕获
   *
   * @param want 系统弹框参数
   * @param extra 业务参数
   */
  static openSysDialog(context: common.UIAbilityContext | common.UIExtensionContext, want: SysDialogWant,
    extra?: Object): void {
    try {
      context.connectServiceExtensionAbility({
        bundleName: 'com.ohos.sceneboard',
        abilityName: 'com.ohos.sceneboard.systemdialog'
      }, {
        onConnect(elementName, remote): void {
          LogUtil.showInfo(TAG, 'openSysDialog onConnect callback');
          if (!remote) {
            LogUtil.showError(TAG, 'openSysDialog onConnect remote is null');
            return;
          }
          // 调用rpc的接口向服务端发送消息，客户端需自行对入参进行序列化，对返回值进行反序列�?
          const data: rpc.MessageSequence = new rpc.MessageSequence();
          const reply: rpc.MessageSequence = new rpc.MessageSequence();
          const option: rpc.MessageOption = new rpc.MessageOption();
          // 3个键值对
          data.writeInt(3);
          data.writeString('bundleName');
          data.writeString(want.bundleName);
          data.writeString('abilityName');
          data.writeString(want.abilityName);
          data.writeString('parameters');
          const param: Record<string, Object> = {
            'ability.want.params.uiExtensionType': 'sysDialog/common',
            'sysDialogZOrder': want.sysDialogZOrder,
            'extra': extra,
          };
          data.writeString(JSON.stringify(param));
          // 拉起业务方弹�?
          remote.sendMessageRequest(OPEN_CODE, data, reply, option).then((ret) => {
            const msg: number = reply.readInt();
            LogUtil.showInfo(TAG, `sendMessageRequest msg:${msg}`);
          }).catch((error: BusinessError) => {
            LogUtil.showError(TAG, `sendMessageRequest failed. code:${error?.code} message:${error?.message}`);
          }).finally(() => {
            // 释放MessageSequence创建的内�?
            data.reclaim();
            reply.reclaim();
          });
        },
        onDisconnect(elementName): void {
          LogUtil.showInfo(TAG, 'openSysDialog onDisconnect');
        },
        onFailed(code): void {
          LogUtil.showInfo(TAG, `openSysDialog onFailed. code:${code}`);
        }
      });
    } catch (error) {
      LogUtil.showError(TAG, `openSysDialog catch error. code:${error?.code} message:${error?.message}`);
      HiSysEventUtil.reportDefaultBehaviorEvent('CONTROL_START_FAIL', FaultScene.CONTROL_START_FAIL,
        FaultSubScene.DIALOG_ERROR, error?.code, error?.message, 'openSysDialog');
    }
  }

  /**
   * 拉起手动开启模式服�?
   *
   * @param extra 业务参数
   */
  static connectManualEnableService(context: common.UIAbilityContext | common.UIExtensionContext, extra: object): void {
    try {
      context.connectServiceExtensionAbility({
        bundleName: IntelligentSceneConstant.BUNDLE_NAME,
        abilityName: IntelligentSceneConstant.INTELLIGENT_SCENE_SERVICE_EXT_ABILITY,
      }, {
        onConnect(elementName, remote): void {
          LogUtil.showInfo(TAG, 'connectManualEnableService onConnect callback');
          if (!remote) {
            LogUtil.showError(TAG, 'connectManualEnableService onConnect remote is null');
            return;
          }
          const data: rpc.MessageSequence = new rpc.MessageSequence();
          const reply: rpc.MessageSequence = new rpc.MessageSequence();
          const option: rpc.MessageOption = new rpc.MessageOption();
          try {
            data.writeInterfaceToken(remote.getDescriptor());
            data.writeString(JSON.stringify({ method: 'modeManualEnable', extra }));
          } catch (e) {
            LogUtil.showError(TAG, `write message error: ${e?.code}, msg: ${e?.message}`);
          }
          remote.sendMessageRequest(2, data, reply, option).then((ret) => {
            const msg: number = reply.readInt();
            LogUtil.showInfo(TAG, `sendMessageRequest msg:${msg}`);
          }).catch((error: BusinessError) => {
            LogUtil.showError(TAG, `sendMessageRequest failed. code:${error?.code} message:${error?.message}`);
          }).finally(() => {
            // 释放MessageSequence创建的内�?
            data.reclaim();
            reply.reclaim();
          });
        },
        onDisconnect(elementName): void {
          LogUtil.showInfo(TAG, 'connectManualEnableService onDisconnect');
        },
        onFailed(code): void {
          LogUtil.showInfo(TAG, `connectManualEnableService onFailed. code:${code}`);
        }
      });
    } catch (error) {
      LogUtil.showError(TAG, `connectManualEnableService catch error. code:${error?.code} message:${error?.message}`);
    }
  }

  static async isUiExtensionAbilityActive(): Promise<boolean> {
    let processInfo: appManager.ProcessInformation[] = [];
    try {
      processInfo = await appManager.getRunningProcessInfoByBundleName(IntelligentSceneConstant.BUNDLE_NAME);
    } catch (error) {
      LogUtil.showError(TAG, `getRunningProcessInfo failed. code:${error?.code} message:${error?.message}`);
    }

    const result: appManager.ProcessInformation | undefined =
      processInfo.find(process => process.processName === IntelligentSceneConstant.UI_EXT_ABILITY_PROCESS_NAME &&
      process.bundleNames.includes(IntelligentSceneConstant.BUNDLE_NAME));
    LogUtil.showInfo(TAG, `isUiExtensionAbilityActive: ${result !== undefined}`);
    return result !== undefined;
  }
}