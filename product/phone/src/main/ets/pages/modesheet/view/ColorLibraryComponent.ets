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
import { COLOR_ARR, COLOR_MAP } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';

/* instrument ignore file */
// 边距
const TOP_PADDING: number = 12;
const LEFT_PADDING: number = 28;
// 元素之间最小间隙
const ROW_SPACE: number = 20;
const COL_SPACE: number = 12;
// 图标大小
const ICON_SIZE: number = 32;

const TAG: string = 'ColorLibraryComponent:';

/**
 * 颜色选择器(受控)
 */
@Component
export struct ColorLibraryComponent {
  colorStrArr: string[] = COLOR_ARR;
  @Prop color: string = '';
  onSelectChange: (code: string) => void = () => {
  };
  // 占位图标数组
  @State placeholderIconArr: string[] = [];

  @Builder
  colorIconBuilder(colorStr: string): void {
    Column() {
      Column() {
        if (this.color === colorStr) {
          Column()
            .size({
              height: ICON_SIZE / 2,
              width: ICON_SIZE / 2,
            })
            .borderRadius(ICON_SIZE / 4)
            .backgroundColor(Color.White)
        }
      }
      .key(colorStr)
      .justifyContent(FlexAlign.Center)
      .size({
        height: ICON_SIZE,
        width: ICON_SIZE,
      })
      .borderRadius(ICON_SIZE / 2)
      .backgroundColor(colorStr)
      .accessibilityRole(AccessibilityRoleType.BUTTON)
      .accessibilityText(COLOR_MAP.get(colorStr) ?? $r('app.string.color_select'))
    }
    .onClick(() => {
      LogUtil.showInfo(TAG, `onClick. colorStr:${colorStr}`);
      this.onSelectChange(colorStr);
    })
    .justifyContent(FlexAlign.Center)
    .height(ICON_SIZE + COL_SPACE)
    .width(ICON_SIZE + ROW_SPACE)
  }

  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      justifyContent: FlexAlign.SpaceBetween,
    }) {
      ForEach(this.colorStrArr, (colorStr: string) => {
        this.colorIconBuilder(colorStr)
      }, (value: string) => value)

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
        const remainder = this.colorStrArr.length % realCol;
        const placeholderIconNum = remainder ? realCol - remainder : 0;
        LogUtil.showInfo(TAG,
          `onSizeChange. length:${this.colorStrArr.length} remainder:${remainder} placeholderIconNum:${placeholderIconNum}`);
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