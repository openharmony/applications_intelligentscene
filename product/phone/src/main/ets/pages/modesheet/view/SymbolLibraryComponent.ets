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
import { SymbolIconComponent } from '@ohos/scene.common/src/main/ets/basecomponent/icon/SymbolIconComponent';
import { SYMBOL_CODE_MAP } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';

/* instrument ignore file */
// 边距
const TOP_PADDING: number = 12;
const LEFT_PADDING: number = 24;
// 元素之间最小间隙
const ROW_SPACE: number = 8;
const COL_SPACE: number = 8;
// 图标大小
const ICON_SIZE: number = 48;

const TAG: string = 'SymbolLibraryComponent:';

/**
 * Symbol图标选择器(受控)
 */
@Component
export struct SymbolLibraryComponent {
  @Prop symbolCodeArr: string[] = [];
  @Prop symbolCode: string = '';
  onSelectChange: (code: string) => void = () => {
  };
  // 占位图标数组
  @State placeholderIconArr: string[] = [];

  @Builder
  symbolIconBuilder(code: string): void {
    Column() {
      Column() {
        SymbolIconComponent({
          symbolCode: code,
          iconSize: 40,
          symbolSize: 24,
          iconBackgroundColor: $r('sys.color.mask_fourth'),
        })
      }
      .key(code)
      .accessibilityText(SYMBOL_CODE_MAP.get(code) ?? $r('app.string.icon_select'))
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .justifyContent(FlexAlign.Center)
      .size({
        height: ICON_SIZE,
        width: ICON_SIZE,
      })
      .borderRadius(ICON_SIZE / 2)
      .border({
        width: 2,
        color: this.symbolCode === code ? $r('sys.color.icon_emphasize') : Color.Transparent,
      })
      .onClick(() => {
        LogUtil.showInfo(TAG, `onClick. code:${code}`);
        this.onSelectChange(code);
      })
    }
    .justifyContent(FlexAlign.Center)
    .height(ICON_SIZE + COL_SPACE)
    .width(ICON_SIZE + ROW_SPACE)
  }

  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      justifyContent: FlexAlign.SpaceBetween,
    }) {
      ForEach(this.symbolCodeArr, (code: string) => {
        this.symbolIconBuilder(code)
      }, (code: string) => code)

      // 占位图标保证视觉上左对齐 (只给宽度不给高度，就算误差导致新加了一行，也不影响视觉)
      ForEach(this.placeholderIconArr, () => {
        Column() {
        }
        .size({
          width: ICON_SIZE + ROW_SPACE,
        })
      }, (i: string) => i)
    }
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      if (typeof newValue.width === 'number') {
        // 根据容器宽度 计算当前一行有多少个图标
        const containerWidth = newValue.width - 2 * LEFT_PADDING + ROW_SPACE;
        const colorIconWidth = ICON_SIZE + ROW_SPACE;
        const col = containerWidth / colorIconWidth;
        const realCol = Math.floor(col);
        LogUtil.showInfo(TAG, `onSizeChange. width:${newValue.width} col:${containerWidth}/${colorIconWidth}=${col}`);
        // 最后一行图标如果没放满的话 这里计算还剩多少个补齐
        const remainder = this.symbolCodeArr.length % realCol;
        const placeholderIconNum = remainder ? realCol - remainder : 0;
        LogUtil.showInfo(TAG,
          `onSizeChange. length:${this.symbolCodeArr.length} remainder:${remainder} placeholderIconNum:${placeholderIconNum}`);
        const arr: string[] = [];
        for (let i = 0; i < placeholderIconNum; i++) {
          arr.push(`${i}`);
        }
        this.placeholderIconArr = arr;
      }
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .padding({
      top: TOP_PADDING - COL_SPACE / 2,
      bottom: TOP_PADDING - COL_SPACE / 2,
      left: LEFT_PADDING - ROW_SPACE / 2,
      right: LEFT_PADDING - ROW_SPACE / 2,
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }
}