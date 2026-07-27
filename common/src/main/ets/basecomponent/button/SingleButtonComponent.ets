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

const TAG: string = 'SingleButtonComponent:';

@Extend(Button)
function buttonCommonStyle(style?: ButtonStyle) {
  .type(ButtonType.ROUNDED_RECTANGLE)
  .constraintSize({
    minHeight: 40,
    maxHeight: 64,
  })
  .labelStyle({
    maxLines: 1,
    overflow: TextOverflow.Ellipsis,
    minFontSize: 8,
    maxFontSize: 16,
    heightAdaptivePolicy: TextHeightAdaptivePolicy.MAX_LINES_FIRST,
  })
}

/**
 * 自定义按钮 attributeModifier
 */
class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  public fontColor?: ResourceColor;
  public buttonColor?: ResourceColor;

  applyNormalAttribute(instance: ButtonAttribute): void {
    // 如果buttonColor没值 就不能给setFontColor
    if (this.buttonColor) {
      instance.fontColor(this.fontColor || $r('sys.color.font_on_primary'));
      instance.backgroundColor(this.buttonColor);
    }
  }
}

/**
 * 底部单按钮基础组件
 */
@Component
export struct SingleButtonComponent {
  @Prop title: ResourceStr = $r('app.string.cancel');
  @Prop isEnabled: boolean = true;
  // 自定义按钮颜色
  @Prop fontColor: ResourceColor;
  @Prop buttonColor: ResourceColor;
  @State modifier: MyButtonModifier = new MyButtonModifier();
  buttonStyle: ButtonStyleMode = ButtonStyleMode.NORMAL;
  buttonRole: ButtonRole = ButtonRole.NORMAL;
  action: Function = () => {
  };

  build() {
    Row({ space: 16 }) {
      Button(this.title)
        .buttonCommonStyle()
        .role(this.buttonRole)
        .buttonStyle(this.buttonStyle)
        .enabled(this.isEnabled)
        .layoutWeight(1)
        // 注意attributeModifier 必须写在buttonStyle和role后 否则自定义颜色会被覆盖
        .attributeModifier(this.modifier)
        .onClick(() => {
          this.action();
        })
    }
    .padding({
      top: 8,
      bottom: 16,
    })
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear.');
    this.modifier.fontColor = this.fontColor;
    this.modifier.buttonColor = this.buttonColor;
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }
}