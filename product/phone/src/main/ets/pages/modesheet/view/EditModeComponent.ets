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

import buffer from '@ohos.buffer';
import { image } from '@kit.ImageKit';
import { componentSnapshot } from '@kit.ArkUI';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/scene.common/src/main/ets/utils/ResourceUtil';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { EventBusNameConstant } from '@ohos/scene.common/src/main/ets/constant/EventBusNameConstant';
import { SymbolIconComponent } from '@ohos/scene.common/src/main/ets/basecomponent/icon/SymbolIconComponent';
import { ModeData } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { OperateType, SYMBOL_CODE_ARR } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';
import { ModeAdapter } from '@ohos/scene.configmanage/src/main/ets/adapter/ModeAdapter';
import { TemplateModeAdapter } from '../adapter/TemplateModeAdapter';
import { EditModeAdapter } from '../adapter/EditModeAdapter';
import { TitleComponent } from './TitleComponent';
import { ColorLibraryComponent } from './ColorLibraryComponent';
import { SymbolLibraryComponent } from './SymbolLibraryComponent';
import { ModeSheetBusinessUtil } from '../utils/ModeSheetBusinessUtil';

/* instrument ignore file */
// 默认最大长度
const DEFAULT_MAX_LENGTH: number = 64;
const SNAPSHOT_DELAY: number = 100;

const TAG: string = 'EditModeComponent:';

/**
 * 模式图标新增/编辑组件
 */
@Component
export struct EditModeComponent {
  @State symbolCode: string = '';
  @State iconBackgroundColor: string = '';
  @State title: string = '';
  @State isEditing: boolean = false;
  @State isSupportEditTitle: boolean = false;
  @State symbolCodeArr: string[] = [];
  private templateModeNameArr: string[] = [];
  private otherCustomModeNameArr: string[] = [];
  @State filletPixmap?: image.PixelMap = undefined;
  @State roundPixmap?: image.PixelMap = undefined;

  private onSaveModeData = async (type: OperateType) => {
    LogUtil.showInfo(TAG, 'onSaveModeData.');
    await this.createNtfIcon();
    const data: ModeData = EditModeAdapter.getInstance().getEditModeData();
    const newData: ModeData = {
      modeId: data.modeId,
      modeName: data.modeName,
      iconId: data.iconId,
      iconColor: data.iconColor,
      filletIcon: data.filletIcon,
      roundIcon: data.roundIcon,
      isSupportDelete: data.isSupportDelete,
    };
    if (type === OperateType.ADD) {
      ModeSheetBusinessUtil.addData(newData);
    } else {
      ModeSheetBusinessUtil.updateData(newData);
    }
  }

  @Builder
  FilletIconBuilder() {
    Column() {
      this.RoundIconBuilder()
    }
    .justifyContent(FlexAlign.Center)
    .size({
      height: 64,
      width: 64,
    })
    .borderRadius($r('sys.float.corner_radius_level6'))
    .backgroundColor(this.iconBackgroundColor)
  }

  @Builder
  RoundIconBuilder() {
    SymbolIconComponent({
      iconSize: 64,
      symbolCode: this.symbolCode,
      iconBackgroundColor: this.iconBackgroundColor,
    })
  }

  build() {
    Column() {
      Column() {
        this.FilletIconBuilder()
      }
      .justifyContent(FlexAlign.Center)
      .size({
        height: 82,
        width: 82,
      })
      .borderRadius(41)
      .backgroundColor(this.iconBackgroundColor)
      .margin({
        bottom: 16
      })
      .clip(true)

      // 模式名称
      TitleComponent({
        value: this.title,
        isEditing: this.isEditing,
        isSupportEdit: this.isSupportEditTitle,
        onInputChange: (title) => {
          this.onTitleChange(title);
        },
        getErrorHint: (title) => {
          return this.getErrorHint(title);
        }
      })
      // 颜色选择器
      ColorLibraryComponent({
        color: this.iconBackgroundColor,
        onSelectChange: (color) => {
          this.onColorChange(color);
        }
      }).margin({
        bottom: 10,
      })
      // 图标选择器
      SymbolLibraryComponent({
        symbolCodeArr: this.symbolCodeArr,
        symbolCode: this.symbolCode,
        onSelectChange: (code) => {
          this.onSymbolChange(code);
        }
      })
    }
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        LogUtil.showInfo(TAG, 'onTouch. TouchType.Down');
        const data: ModeData = EditModeAdapter.getInstance().getEditModeData();
        focusControl.requestFocus(data.iconColor);
      }
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
    const data: ModeData = EditModeAdapter.getInstance().getEditModeData();
    const type: OperateType = EditModeAdapter.getInstance().getOperateType();
    // 获取所有已使用的图标
    const usedSymbolCodeArr = ModeAdapter.getInstance().getAllModeArr()
      .filter(it => it.modeId !== data.modeId).map(it => it.iconId);
    LogUtil.showInfo(TAG, `aboutToAppear. usedSymbolCodeArr:${usedSymbolCodeArr}`);
    // 过滤出没有使用过的图标
    const filterSymbolCodeArr = SYMBOL_CODE_ARR.filter(it => !usedSymbolCodeArr.includes(it));
    // 预置模式 标题是字串 不可编辑
    if (ModeUtil.isPrecastMode(data.modeId)) {
      const initSymbolCode = TemplateModeAdapter.getInstance().getTemplateModeIconId(data.modeId);
      // 新增预置模式：25个固定图标过滤已使用的 + 预置模式初始图标加到图标库第一个
      // 编辑预置模式：25个固定图标过滤已使用的 + 预置模式初始图标加到图标库第一个 + 本身使用的
      this.symbolCodeArr = initSymbolCode ? [initSymbolCode, ...filterSymbolCodeArr] : filterSymbolCodeArr;
      const code = ModeUtil.getStringResourceCode(data.modeName);
      this.title = ResourceUtil.getStringByName(code);
      this.isSupportEditTitle = false;
    } else {
      this.title = data.modeName;
      this.isSupportEditTitle = true;
      // 新增自定义：25个固定图标过滤已使用的（默认选中第一个）
      // 编辑自定义：25个固定图标过滤已使用的 + 本身使用的
      this.symbolCodeArr = filterSymbolCodeArr;
      if (type === OperateType.ADD) {
        // 新增自定义模式 直接激活输入控件
        this.isEditing = true;
        // 新增自定义模式 图标取过滤后的第一个
        EditModeAdapter.getInstance().setIconId(this.symbolCodeArr[0]);
      }
    }
    this.symbolCode = data.iconId;
    this.iconBackgroundColor = data.iconColor;
    this.getHasModeNameArr();
    EventBus.getInstance().on(EventBusNameConstant.MODE_DATA_SAVE_EVENT, this.onSaveModeData);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
    EventBus.getInstance().detach(EventBusNameConstant.MODE_DATA_SAVE_EVENT, this.onSaveModeData);
  }

  /**
   * 获取已有/预置模式名称数据
   */
  private getHasModeNameArr(): void {
    const data: ModeData = EditModeAdapter.getInstance().getEditModeData();
    // 获取预置模式名称
    this.templateModeNameArr = TemplateModeAdapter.getInstance().getTemplateModeNameArr();
    // 获取已有自定义模式名称(过滤自己)
    this.otherCustomModeNameArr = ModeAdapter.getInstance().getAllModeArr()
      .filter(it => it.modeId !== data.modeId && ModeUtil.isCustomMode(it.modeId))
      .map(it => it.modeName);
  }

  /**
   * 图标修改事件
   */
  private async onSymbolChange(code: string): Promise<void> {
    LogUtil.showInfo(TAG, `onSymbolChange. code:${code}`);
    this.symbolCode = code;
    EditModeAdapter.getInstance().setIconId(code);
  }

  /**
   * 颜色修改事件
   */
  private async onColorChange(color: string): Promise<void> {
    LogUtil.showInfo(TAG, `onColorChange. color:${color}`);
    this.iconBackgroundColor = color;
    EditModeAdapter.getInstance().setIconColor(color);
  }

  /**
   * 创建圆角图标
   */
  private async createNtfIcon(): Promise<void> {
    LogUtil.showInfo(TAG, 'createNtfIcon');
    try {
      const options: componentSnapshot.SnapshotOptions = { scale: 0.5, waitUntilRenderFinished: true };
      this.filletPixmap = await this.getUIContext().getComponentSnapshot().createFromBuilder(() => {
        this.FilletIconBuilder()
      }, SNAPSHOT_DELAY, true, options);
      this.roundPixmap = await this.getUIContext().getComponentSnapshot().createFromBuilder(() => {
        this.RoundIconBuilder()
      }, SNAPSHOT_DELAY, true, options);
      LogUtil.showInfo(TAG, 'filletPixmap, roundPixmap');
      let filletPixmapSize: image.Size = (await this.filletPixmap?.getImageInfo())?.size;
      let roundPixmapSize: image.Size = (await this.roundPixmap?.getImageInfo())?.size;
      LogUtil.showInfo(TAG, `componentSnapshot, ${filletPixmapSize?.width}, ${roundPixmapSize?.width}`);
      EditModeAdapter.getInstance().setFilletIcon(this.filletPixmap);
      EditModeAdapter.getInstance().setRoundIcon(this.roundPixmap);
    } catch (error) {
      LogUtil.showError(TAG, `createFilletIcon fail code:${error?.code} message:${error?.message}`);
    }
  }

  /**
   * 标题修改事件
   */
  private onTitleChange(title: string): void {
    this.title = title;
    EditModeAdapter.getInstance().setModeName(title);
  }

  /**
   * 实时校验并联动按钮
   */
  private getErrorHint(title: string): ResourceStr | undefined {
    let byteLength: number = 0;
    try {
      byteLength = buffer.from(title || '', 'utf8')?.length;
      LogUtil.showInfo(TAG, `buffer.from. byteLength:${byteLength}`);
    } catch (error) {
      LogUtil.showError(TAG, `buffer.from catch error. code:${error?.code} message:${error?.message}`);
    }
    let hint: ResourceStr | undefined = undefined;
    if (byteLength > DEFAULT_MAX_LENGTH) {
      hint = $r('app.string.input_max_length_message');
    } else if (this.templateModeNameArr.includes(title)) {
      hint = $r('app.string.has_duplicate_mode_name');
    } else if (this.otherCustomModeNameArr.includes(title)) {
      hint = $r('app.string.has_duplicate_mode_name');
    }
    // 是否全空字符
    const isAllEmpty = !title?.trim();
    LogUtil.showInfo(TAG, `getErrorHint. isAllEmpty:${isAllEmpty}`);
    // 空字串和有错误提示的时候按钮置灰
    EventBus.getInstance()
      .emit(EventBusNameConstant.EDIT_MODE_BUTTON_ENABLED, !(byteLength === 0 || hint || isAllEmpty));
    return hint;
  }
}