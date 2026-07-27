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
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { OperateType, COLOR_ARR, SYMBOL_CODE_ARR } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';
import { INVALID_MODE_ID } from '@ohos/scene.common/src/main/ets/constant/DbConfig';

/* instrument ignore file */
// 初始空数据
export const INIT_EDIT_MODE_DATA: ModeData = {
  modeId: INVALID_MODE_ID,
  modeName: '',
  iconId: SYMBOL_CODE_ARR[0],
  iconColor: COLOR_ARR[0],
  isSupportDelete: true,
};

// 初始操作类型
const INIT_TYPE: OperateType = OperateType.ADD;

/**
 * 新增/编辑模式适配器
 */
export class EditModeAdapter {
  private tag: string = 'EditModeAdapter:';
  private static singleInstance: EditModeAdapter;
  // 避免直接引用INIT_EDIT_MODE_DATA对象
  private editModeData: ModeData = {
    modeId: INIT_EDIT_MODE_DATA.modeId,
    modeName: INIT_EDIT_MODE_DATA.modeName,
    iconId: INIT_EDIT_MODE_DATA.iconId,
    iconColor: INIT_EDIT_MODE_DATA.iconColor,
    isSupportDelete: INIT_EDIT_MODE_DATA.isSupportDelete,
  };
  private type: OperateType = INIT_TYPE;

  /**
   * 单例
   */
  public static getInstance(): EditModeAdapter {
    if (!EditModeAdapter.singleInstance) {
      EditModeAdapter.singleInstance = new EditModeAdapter();
    }
    return EditModeAdapter.singleInstance;
  }

  /**
   * 初始化编辑模式组件数据
   */
  public initData(type?: OperateType, data?: ModeData): void {
    this.clearData();
    LogUtil.showInfo(this.tag, `init. type:${type}`);
    this.type = type ?? INIT_TYPE;
    if (data) {
      LogUtil.showInfo(this.tag, `init. modeId:${data.modeId} iconId:${data.iconId} iconColor:${data.iconColor}`);
      // 避免值引用
      this.editModeData = {
        modeId: data.modeId,
        modeName: data.modeName,
        iconId: data.iconId,
        iconColor: data.iconColor,
        filletIcon: data.filletIcon,
        roundIcon: data.roundIcon,
        isSupportDelete: data.isSupportDelete,
      }
    }
  }

  /**
   * 清空数据
   */
  private clearData(): void {
    LogUtil.showInfo(this.tag, `clear`);
    // 避免直接引用INIT_EDIT_MODE_DATA对象
    this.editModeData = {
      modeId: INIT_EDIT_MODE_DATA.modeId,
      modeName: INIT_EDIT_MODE_DATA.modeName,
      iconId: INIT_EDIT_MODE_DATA.iconId,
      iconColor: INIT_EDIT_MODE_DATA.iconColor,
      isSupportDelete: INIT_EDIT_MODE_DATA.isSupportDelete,
    }
    this.type = INIT_TYPE;
  }

  /**
   * 更新iconId
   */
  public setIconId(code: string): void {
    this.editModeData.iconId = code;
  }

  /**
   * 更新iconColor
   */
  public setIconColor(color: string): void {
    this.editModeData.iconColor = color;
  }

  /**
   * 更新filletIcon
   */
  public setFilletIcon(filletIcon?: PixelMap): void {
    this.editModeData.filletIcon = filletIcon;
  }

  /**
   * 更新roundIcon
   */
  public setRoundIcon(roundIcon?: PixelMap): void {
    this.editModeData.roundIcon = roundIcon;
  }

  /**
   * 更新modeName
   */
  public setModeName(name: string): void {
    this.editModeData.modeName = name;
  }

  /**
   * 获取数据
   */
  public getEditModeData(): ModeData {
    return this.editModeData;
  }

  /**
   * 获取当前操作类型
   */
  public getOperateType(): OperateType {
    return this.type;
  }
}