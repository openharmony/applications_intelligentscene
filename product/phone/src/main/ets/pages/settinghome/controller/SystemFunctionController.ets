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
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { DynamicDataSource } from '@ohos/scene.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingSelectMenuState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import {
  ItemResultType,
  ItemDetailType,
  ItemType,
  SettingItemModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysEventUtil } from '@ohos/scene.common/src/main/ets/systemEvent/HiSysEventUtilsByTs';
import { HiSysIntelligentSceneEvent } from '@ohos/scene.common/src/main/ets/systemEvent/BehaviorEventConstsByTs';
import { HomeGroupItemId } from '@ohos/scene.modeconfig/src/main/ets/constant/HomeCompIdConstant';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { SettingsLinkageState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeDetailAdapter, ParsedConfigData } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import SystemSettingManager from '@ohos/scene.configmanage/src/main/ets/manager/SystemSettingManager';
import {
  SELECT_VALUE_ARR,
  SELECT_RESOURCE_MAP,
  SYSTEM_FUNCTION_CONFIG_TYPE_ARR,
  SYSTEM_FUNCTION_RESOURCE_MAP,
} from '../constant/HomeConstant';

/* instrument ignore file */
// 关联系统功能控件id映射（护眼模式入口暂隐藏）
const SYSTEM_FUNCTION_ID_MAP: Map<ConfigType, string> = new Map<ConfigType, string>([
  [ConfigType.SYSTEM_SETTINGS_DARK_MODE, HomeGroupItemId.DARK_COLOR_MODE],
  // [ConfigType.SYSTEM_SETTINGS_EYE_PROTECT_MODE, HomeGroupItemId.EYE_PROTECTION_MODE],
]);

/**
 * 关联系统功能
 */
export class SystemFunctionController implements ComponentControl {
  public tag: string = 'SystemFunctionController:';
  public compId?: string;
  public dataSource?: DynamicDataSource;
  /**
   * 关联系统功能某个控件的刷新事件
   */
  private onRefreshSystemFunctionCallback = (configType: ConfigType): void => {
    if (SYSTEM_FUNCTION_CONFIG_TYPE_ARR.includes(configType)) {
      const value: SettingsLinkageState = this.getValueByType(configType);
      LogUtil.showInfo(this.tag, `onRefreshSystemFunctionCallback. configType:${configType} value:${value}`);
      this.refreshUI(configType, value);
    }
  };
  /**
   * 整个模式详情刷新事件
   */
  private onRefreshAllModeDetailCallback = (): void => {
    const currentModeId = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(this.tag, `onRefreshAllModeDetailCallback. currentModeId:${currentModeId}`);
    SYSTEM_FUNCTION_CONFIG_TYPE_ARR.forEach(configType => {
      const value: SettingsLinkageState = this.getValueByType(configType);
      LogUtil.showInfo(this.tag, `onRefreshAllModeDetailCallback. configType:${configType} value:${value}`);
      this.refreshUI(configType, value);
    })
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, `init.`);
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    SYSTEM_FUNCTION_CONFIG_TYPE_ARR.forEach(configType => {
      const initValue = this.getValueByType(configType);
      LogUtil.showInfo(this.tag, `getSystemFunctionItem. configType:${configType} initValue:${initValue}`);
      this.dataSource?.push(this.getSystemFunctionItem(configType, initValue));
    })
    EventBus.getInstance().on(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onRefreshAllModeDetailCallback);
    EventBus.getInstance().on(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onRefreshSystemFunctionCallback);
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, `destroy.`);
    EventBus.getInstance().detach(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onRefreshAllModeDetailCallback);
    EventBus.getInstance().detach(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onRefreshSystemFunctionCallback);
  }

  /**
   * 根据ConfigType获取当前值
   */
  private getValueByType(configType: ConfigType): SettingsLinkageState {
    const parsedConfigArr: ParsedConfigData[] =
      ModeDetailAdapter.getInstance().getParsedConfigDataByType([configType]);
    return parsedConfigArr[0]?.parsedValue as SettingsLinkageState ?? SettingsLinkageState.NOT_LINK;
  }

  /**
   * 刷新视图
   */
  private refreshUI(configType: ConfigType, value: SettingsLinkageState) {
    notifyCompStateChange(`${this.compId}.${SYSTEM_FUNCTION_ID_MAP.get(configType)}`,
      new Map<SettingStateType, SettingBaseState>([[
        SettingStateType.STATE_TYPE_ITEM_MENU,
        { selectIndex: SELECT_VALUE_ARR.indexOf(value) } as SettingSelectMenuState],
      ]));
  }

  /**
   * 开关状态回调
   */
  private onSelectChange(configType: ConfigType, value: SettingsLinkageState): void {
    const oldValue = this.getValueByType(configType);
    LogUtil.showInfo(this.tag, `onSelectChange. configType:${configType} oldValue:${oldValue} value:${value}`);
    if (oldValue === value) {
      return;
    }
    const modeId = ModeDetailAdapter.getInstance().getCurrentModeId();
    const parsedConfigArr = ModeDetailAdapter.getInstance().getParsedConfigDataByType([configType]);
    let invokeFunction = parsedConfigArr.length === 0 ? SystemSettingManager.insertSystemSettingByType :
    SystemSettingManager.updateSystemSettingByType;
    invokeFunction(modeId, configType, value).then((configId) => {
      LogUtil.showInfo(this.tag, `invokeFunction. configId:${configId}`);
      if (configId) {
        // 更新ModeDetailAdapter数据
        ModeDetailAdapter.getInstance().updateParsedConfigById(configId);
      }
    });
    let param: Record<string, Object> = {
      'MODE': ModeUtil.isCustomMode(modeId) ? '-1' : modeId,
      'CONTACTS': value,
      'CONFIG_TYPE': configType
    };
    HiSysEventUtil.reportBehaviorEventByUE(HiSysIntelligentSceneEvent.MODE_CONTACTS, param);
  }

  /**
   * 根据configType生成控件
   */
  private getSystemFunctionItem(configType: ConfigType, initValue: SettingsLinkageState): SettingItemModel {
    const itemId = SYSTEM_FUNCTION_ID_MAP.get(configType) || '';
    const itemModel: SettingItemModel = {
      id: itemId,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: SYSTEM_FUNCTION_RESOURCE_MAP.get(configType) || '',
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: SELECT_RESOURCE_MAP.get(initValue) || '',
        },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('app.media.ic_arrow_pull'),
        style: {
          width: 12,
          height: 18,
          fillColor: $r('sys.color.icon_fourth'),
        },
        menu: {
          items: [
            { content: $r('app.string.associated_system_noRelated') },
            { content: $r('app.string.associated_system_open') },
            { content: $r('app.string.associated_system_close') },
          ],
          onSelected: (index) => {
            const value = SELECT_VALUE_ARR[index];
            this.onSelectChange(configType, value);
          },
          selectIndex: SELECT_VALUE_ARR.indexOf(initValue),
        },
      },
    };
    return itemModel;
  }
}