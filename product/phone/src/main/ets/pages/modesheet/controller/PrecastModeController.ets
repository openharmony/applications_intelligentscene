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
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { PADDING_16 } from '@ohos/scene.common/src/main/ets/framework/common/StyleConstant';
import { ModalSheetKey } from '@ohos/scene.common/src/main/ets/constant/EntryKeyConsts';
import { DynamicDataSource } from '@ohos/scene.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  SettingIconType,
  ItemType,
  SettingItemModel,
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { OperateType } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { ModeConfigData } from '@ohos/scene.configmanage/src/main/ets/preload/model/model/DefaultModeConfigData';
import { TemplateModeAdapter } from '../adapter/TemplateModeAdapter';
import { EditModeAdapter } from '../adapter/EditModeAdapter';
import { ModeSheetBusinessUtil } from '../utils/ModeSheetBusinessUtil';
import { EDIT_MODE_SHEET } from '../EditModeSheet';

/* instrument ignore file */
@Builder
function symbolIconBuilder(param: object) {
  Column() {
    SymbolGlyph($r(`sys.symbol.${((param as SettingItemModel).extra as ModeConfigData)?.iconId}`))
      .fontSize('16vp')
      .fontColor([$r('sys.color.icon_on_primary')])
      .draggable(false)
  }
  .justifyContent(FlexAlign.Center)
  .size({
    height: 24,
    width: 24,
  })
  .margin({
    end: PADDING_16,
  })
  .borderRadius(12)
  .backgroundColor(((param as SettingItemModel).extra as ModeConfigData)?.iconColor)
}

/**
 * 添加预置模式group
 */
export class PrecastModeController implements ComponentControl {
  public tag: string = 'PrecastModeController:';
  public compId?: string;
  public dataSource?: DynamicDataSource;

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(this.tag, `init.`);
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    void this.refreshTemplateModeItems();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.showInfo(this.tag, `onPageShow.`);
    void this.refreshTemplateModeItems();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.showInfo(this.tag, `onPageHide.`);
  }

  destroy(): void {
    LogUtil.showInfo(this.tag, `destroy.`);
  }

  /**
   * 刷新预置模式菜单
   */
  private async refreshTemplateModeItems(): Promise<void> {
    await TemplateModeAdapter.getInstance().ensureDataLoaded();
    this.clearDataSource();
    this.pushTemplateModeItems();
  }

  private clearDataSource(): void {
    if (!this.dataSource?.length) {
      return;
    }
    const itemIds: string[] = this.dataSource.map((item: SettingItemModel) => item.id);
    itemIds.forEach((id: string) => {
      this.dataSource?.removeDataById(id);
    });
  }

  /**
   * 添加还未使用的预置模式菜单
   */
  private pushTemplateModeItems(): void {
    const allTemplateModeArr = TemplateModeAdapter.getInstance().getTemplateModeArr();
    LogUtil.showInfo(this.tag, `getTemplateModeArr. allTemplateModeArr:${allTemplateModeArr.length}`);
    const allHasModeIdArr = ModeAdapter.getInstance().getAllModeArr().map(i => i.modeId);
    // 将已经使用的预置模式过滤掉
    const filterArr = allTemplateModeArr.filter(it => !allHasModeIdArr.includes(it.modeId));
    LogUtil.showInfo(this.tag, `getFilterTemplateModes. filterArr:${filterArr.length}`);
    filterArr.forEach(item => {
      this.dataSource?.push(this.getTemplateItem(item));
    })
    this.dataSource?.push(this.getCustomModeItem());
  }

  /**
   * 根据 ModeConfigData 生成菜单控件
   */
  private getTemplateItem(item: ModeConfigData): SettingItemModel {
    const code = ModeUtil.getStringResourceCode(item.modeName);
    const itemModel: SettingItemModel = {
      id: `${code}_item`,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r(`app.string.${code}`),
      },
      icon: {
        builder: wrapBuilder(symbolIconBuilder),
        iconType: SettingIconType.ICON_TYPE_TIP,
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        onItemClick: () => {
          LogUtil.showInfo(this.tag, `onItemClick. code:${code}`);
          const filletIcon = ResourceUtil.getPixelMap(item.filletIcon as string);
          const roundIcon = ResourceUtil.getPixelMap(item.roundIcon as string);
          const addData: ModeData = {
            modeId: item.modeId,
            modeName: item.modeName,
            iconId: item.iconId,
            iconColor: item.iconColor,
            filletIcon: filletIcon,
            roundIcon: roundIcon,
            isSupportDelete: item.isSupportDelete,
          }
          ModeSheetBusinessUtil.addData(addData);
        },
      },
      extra: item,
    };
    return itemModel;
  }

  /**
   * 自定义模式菜单
   */
  private getCustomModeItem(): SettingItemModel {
    // 定义一个自定义的图标
    const item: ModeData = {
      modeId: '',
      modeName: '',
      iconId: 'person_fill',
      iconColor: '#C7C7CC',
      isSupportDelete: true,
    }
    const itemModel: SettingItemModel = {
      id: 'custom_mode_item',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.custom_mode'),
      },
      icon: {
        builder: wrapBuilder(symbolIconBuilder),
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MODAL,
        icon: $r('app.media.ic_settings_arrow'),
        destination: EDIT_MODE_SHEET,
        onItemClick: () => {
          LogUtil.showInfo(this.tag, `onItemClick. code:custom_mode`);
          EditModeAdapter.getInstance().initData(OperateType.ADD);
        },
      },
      extra: item,
    };
    return itemModel;
  }
}