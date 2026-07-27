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

import { AccessibilityUtils } from '@ohos/scene.common/src/main/ets/utils/AccessibilityUtils';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import TriggerConditionManager from '@ohos/scene.configmanage/src/main/ets/manager/TriggerConditionManager';
import { AppCondition } from '@ohos/scene.datamanage/src/main/ets/model/TriggerCondition';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { CONDITION_LIST } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';

/* instrument ignore file */
const REQUEST_DELAY: number = 20;

/**
 * 无障碍页面焦点处理工具
 */
export class AccessibilityFocusUtil {
  private static isNeedFocusAddConditionBtn: boolean = false;
  /**
   * 重新聚焦到 添加条件按钮
   */
  public static async requestFocusAddConditionButton(): Promise<void> {
    if (!AccessibilityUtils.isScreenReaderMode()) {
      return;
    }
    if (!AccessibilityFocusUtil.isNeedFocusAddConditionBtn) {
      return;
    }
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    const hasCondition: boolean = ModeDetailAdapter.getInstance().getParsedConfigDataByType(CONDITION_LIST).length > 0;
    const appCondition: AppCondition[] = await TriggerConditionManager.getConditionsByModeIdAndConfigType(modeId,
      ConfigType.TRIGGER_CONDITION_APP) as AppCondition[];
    const hasAppCondition: boolean = appCondition.length > 0;
    const baseCompId: string = 'home_standard_page.enable_way_group.add_triggering_condition';
    const focusId: string = `${baseCompId}_${modeId}_${hasAppCondition}_${hasCondition}`;
    setTimeout(() => {
      AccessibilityUtils.requestFocusAccessibility(focusId);
      AccessibilityFocusUtil.isNeedFocusAddConditionBtn = false;
    }, REQUEST_DELAY);
  }

  /**
   * 判断是否已经有围栏条件
   *
   * @returns true 已有， false 没有
   */
  public static async hasCondition(): Promise<boolean> {
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    return (await ConfigDataManager.getInstance()
      .queryConfigByModeAndTypes(modeId, CONDITION_LIST)).length > 0;
  }

  /**
   * 设置是否需要将焦点聚焦到添加条件按钮
   *
   * @param true 需要 false 不需要
   */
  public static setIsNeedFocusAddConditionBtn(isNeedFocusAddConditionBtn: boolean): void {
    AccessibilityFocusUtil.isNeedFocusAddConditionBtn = isNeedFocusAddConditionBtn;
  }
}