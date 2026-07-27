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

import { LogUtil } from '../../utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'SymbolIconComponent:';

/**
 * 自定义背景色得Symbol图标展示控件
 */
@Component
export struct SymbolIconComponent {
  @Prop iconSize: number = 64;
  @Prop symbolSize: number = 0;
  @Prop symbolCode: string = '';
  @Prop iconBackgroundColor: ResourceColor = '';

  build() {
    Column() {
      SymbolGlyph($r(`sys.symbol.${this.symbolCode}`))
        .fontSize(`${this.symbolSize ? this.symbolSize : this.iconSize * 0.75}vp`)
        .fontColor([$r('sys.color.icon_on_primary')])
        .draggable(false)
    }
    .justifyContent(FlexAlign.Center)
    .size({
      height: this.iconSize,
      width: this.iconSize,
    })
    .borderRadius(this.iconSize / 2)
    .backgroundColor(this.iconBackgroundColor)
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }
}