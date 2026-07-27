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
import { SettingsDataUtils } from '@ohos/scene.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsDataKeyConstant } from '@ohos/scene.common/src/main/ets/constant/SettingsDataKeyConstant';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { CompCtrlParam, ComponentControl } from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import { DynamicDataSource } from '@ohos/scene.common/src/main/ets/framework/model/DynamicDataSource';
import {
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingStateModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { EnableState } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeDetailAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeDetailAdapter';
import {
  NOT_DISTURB_VALUE_ENABLE,
  NOT_DISTURB_VALUE_DISABLE,
} from '@ohos/scene.notdisturb/src/main/ets/utils/NotDisturbUtils';
import { NotDisturbAdapter } from '@ohos/scene.notdisturb/src/main/ets/adapter/NotiDisturbAdapter';

/* instrument ignore file */
// 重复来电响铃控件对应ConfigType
const CURRENT_CONFIG_TYPE = ConfigType.REPEATED_CALL_RING_SWITCH;

/**
 * 重复来电响铃控制器
 */
export class RepeatRingController implements ComponentControl {
  public tag: string = 'RepeatRingController:';
  public compId?: string;
  public dataSource?: DynamicDataSource;
  /**
   * 小艺修改事件
   */
  private onAgentChange = (modifyModeId: string): void => {
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    LogUtil.showInfo(this.tag, `onAgentChange. modifyModeId:${modifyModeId} modeId:${modeId}`);
    if (modifyModeId === modeId) {
      const configId: string = ModeUtil.generateConfigId(modeId, CURRENT_CONFIG_TYPE);
      // 小艺修改已经更新数据库了 这里直接更新缓存即可
      ModeDetailAdapter.getInstance().updateParsedConfigById(configId);
    }
  };
  /**
   * 重复来电响铃的刷新事件
   */
  private onRefreshRepeatRingCallback = (configType: ConfigType): void => {
    if (configType === CURRENT_CONFIG_TYPE) {
      const isOn: boolean = this.getIsOn();
      LogUtil.showInfo(this.tag, `onRefreshRepeatRingCallback. isOn:${isOn}`);
      this.refreshUI(isOn);
    }
  };
  /**
   * 整个模式详情刷新事件
   */
  private onRefreshAllModeDetailCallback = (): void => {
    const isOn: boolean = this.getIsOn();
    LogUtil.showInfo(this.tag, `onRefreshAllModeDetailCallback. isOn:${isOn}`);
    this.refreshUI(isOn);
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, `init.`);
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    let initIsOn: boolean = this.getIsOn();
    LogUtil.showInfo(this.tag, `init. initIsOn:${initIsOn}`);
    this.dataSource?.push(this.getRepeatRingItem(initIsOn));
    EventBus.getInstance().on(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onRefreshAllModeDetailCallback);
    EventBus.getInstance().on(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onRefreshRepeatRingCallback);
    EventBus.getInstance().on(EventBusNameConstant.AGENT_MODIFY_REPEAT_RINGING_EVENT, this.onAgentChange);
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, `destroy.`);
    EventBus.getInstance().detach(EventBusNameConstant.ALL_MODE_DETAIL_REFRESH, this.onRefreshAllModeDetailCallback);
    EventBus.getInstance().detach(EventBusNameConstant.MODE_DETAIL_REFRESH, this.onRefreshRepeatRingCallback);
    EventBus.getInstance().detach(EventBusNameConstant.AGENT_MODIFY_REPEAT_RINGING_EVENT, this.onAgentChange);
  }

  /**
   * 根据ConfigType获取当前值
   */
  private getIsOn(): boolean {
    const parsedConfigArr = ModeDetailAdapter.getInstance().getParsedConfigDataByType([CURRENT_CONFIG_TYPE]);
    const parsedValue = parsedConfigArr[0]?.parsedValue as EnableState;
    return parsedValue?.enable ?? true;
  }

  /**
   * 添加重复来电响铃item
   */
  private getRepeatRingItem(initIsOn: boolean): SettingItemModel {
    const itemModel: SettingItemModel = {
      id: 'repeat_ringing_item',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.repeat_call_ringing'),
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: initIsOn,
          onChanged: (isOn: boolean) => {
            this.onToggleChange(isOn);
          },
        },
      },
    };
    return itemModel;
  }

  /**
   * 开关状态回调
   */
  private onToggleChange(isOn: boolean): void {
    const oldIsOn: boolean = this.getIsOn();
    LogUtil.showInfo(this.tag, `onToggleChange. oldIsOn:${oldIsOn} isOn:${isOn}`);
    if (oldIsOn === isOn) {
      return;
    }
    const modeId: string = ModeDetailAdapter.getInstance().getCurrentModeId();
    NotDisturbAdapter.getInstance().updateRepeatRingState(modeId, isOn);
    const enabledModeId: string = ModeUtil.getModeOpenState().modeId;
    if (enabledModeId === modeId) {
      const value: string = isOn ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE;
      LogUtil.showInfo(this.tag, `setSystemValue. value:${value}`);
      SettingsDataUtils.setSystemValue(SettingsDataKeyConstant.REPEAT_CALLERS_ENABLE, value);
    }
  }

  /**
   * 被动刷新视图
   */
  public refreshUI(isOn: boolean): void {
    notifyCompStateChange(`${this.compId}.repeat_ringing_item`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: isOn } } as SettingResultState,
      ]])
    );
  }
}