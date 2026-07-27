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

import accessibility from '@ohos.accessibility';
import { LogUtil } from './LogUtil';
import { ResourceUtil } from './ResourceUtil';

/* instrument ignore file */
export const SCENE_BOARD_PACKAGE_NAME: string = 'com.ohos.sceneboard';

const TAG: string = 'AccessibilityUtils:';
const DELAY_TIME: number = 50;
const DEFAULT_PACKAGE_NAME: string = 'com.ohos.intelligentscene';

/**
 * Accessibility工具�?
 */
export class AccessibilityUtils {
  /**
   * 判断是否屏幕朗读模式�?
   */
  public static isScreenReaderMode(): boolean {
    const isScreenReader: boolean = accessibility.isScreenReaderOpenSync();
    LogUtil.showInfo(TAG, `isScreenReaderMode. isScreenReader:${isScreenReader}`);
    return isScreenReader;
  }

  /**
   * 在无障碍模式主动聚焦
   *
   * @param customId 组件id
   * @param packageName 应用包名
   */
  public static requestFocusAccessibility(customId: string, packageName?: string): void {
    if (!AccessibilityUtils.isScreenReaderMode()) {
      LogUtil.showWarn(TAG, 'requestFocusAccessibility, current is not in AccessibilityMode');
      return;
    }
    let eventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibility',
      bundleName: packageName ?? DEFAULT_PACKAGE_NAME,
      triggerAction: 'common',
      customId: customId,
    });
    AccessibilityUtils.sendAccessibilityEvent(eventInfo);
  }

  /**
   * 在无障碍模式主动聚焦
   *
   * @param customId 组件id
   * @param packageName 应用包名
   */
  public static requestFocusAccessibilityDelay(customId: string, packageName?: string): void {
    if (!AccessibilityUtils.isScreenReaderMode()) {
      LogUtil.showWarn(TAG, 'requestFocusAccessibilityDelay, current is not in AccessibilityMode');
      return;
    }
    let eventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibility',
      bundleName: packageName ?? DEFAULT_PACKAGE_NAME,
      triggerAction: 'common',
      customId: customId,
    });
    setTimeout(() => {
      AccessibilityUtils.sendAccessibilityEvent(eventInfo);
    }, DELAY_TIME);
  }

  /**
   * 无障碍模式下主动播报内容，如Radio选中后播�?已选中"
   *
   * @param text 播报内容资源字符�?
   */
  public static announceText(text: ResourceStr): void {
    if (!AccessibilityUtils.isScreenReaderMode()) {
      return;
    }
    let eventInfo: accessibility.EventInfo = ({
      type: 'announceForAccessibility',
      bundleName: 'com.ohos.intelligentscene',
      triggerAction: 'common',
      textAnnouncedForAccessibility: ResourceUtil.getStringSync(text),
    });
    AccessibilityUtils.sendAccessibilityEvent(eventInfo);
  }

  private static sendAccessibilityEvent(eventInfo: accessibility.EventInfo): void {
    try {
      accessibility.sendAccessibilityEvent(eventInfo, (err) => {
        if (err) {
          LogUtil.showError(TAG, `sendAccessibilityEvent is failed, code:${err?.code} message:${err?.message}`);
          return;
        }
        LogUtil.showInfo(TAG, `sendAccessibilityEvent is Succeeded, customId:${eventInfo?.customId}`);
      });
    } catch (error) {
      LogUtil.showError(TAG, `sendAccessibilityEvent catch error, code:${error?.code} message:${error?.message}`);
    }
  }
}