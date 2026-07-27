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
import { LanguageUtils } from '@ohos/scene.common/src/main/ets/utils/LanguageUtils';

/* instrument ignore file */
const TAG: string = 'TitleComponent:';

/**
 * 模式名称编辑控件
 */
@Component
export struct TitleComponent {
  @Prop isSupportEdit: boolean = true;
  onInputChange: (value: string) => void = () => {
  };
  @Prop value: string = '';
  @Prop isEditing: boolean = false;
  // 实时校验
  @State errorHint: ResourceStr | undefined = undefined;
  getErrorHint?: (value: string) => ResourceStr | undefined = () => {
    return undefined;
  };
  private inputController: TextInputController = new TextInputController();
  private inputFocusKey: string = 'modeNameTextInput';

  build() {
    Column() {
      // 输入控件
      TextInput({
        text: this.value,
        controller: this.inputController,
        placeholder: $r('app.string.mode_name'),
      })
        .showError(this.errorHint)
        .key(this.inputFocusKey)
        .placeholderColor($r('sys.color.font_tertiary'))
        .placeholderFont({
          size: $r('sys.float.Title_M'),
          weight: FontWeight.Bold,
          family: 'HarmonyHeiTi',
        })
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.Title_M'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(32)
        .borderRadius(0)
        .padding({
          top: 0,
          bottom: 8,
          left: 0,
          right: 0,
        })
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
        .showUnderline(true)
        .onTouch((event: TouchEvent) => {
          event.stopPropagation();
        })
        .onChange((input) => {
          this.onInputChange(input);
          this.errorHint = this.getErrorHint?.(input);
        })
        .visibility(this.isEditing ? Visibility.Visible : Visibility.None);
      // 标题显示
      Text(this.value)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_M'))
        .lineHeight(LanguageUtils.getLineHeight(32))
        .margin({
          bottom: 8,
        })
        .maxLines(2)
        .maxFontScale(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.BREAK_ALL)
        .visibility(this.isEditing ? Visibility.None : Visibility.Visible);
      // 编辑按钮
      if (this.isSupportEdit) {
        Button($r('app.string.edit'))
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .constraintSize({
            minHeight: 20,
            maxHeight: 64,
          })
          .labelStyle({
            maxLines: 1,
            overflow: TextOverflow.Ellipsis,
            minFontSize: 7,
            maxFontSize: 14,
            heightAdaptivePolicy: TextHeightAdaptivePolicy.MAX_LINES_FIRST,
          })
          .margin({
            bottom: 8,
          })
          .onClick(() => {
            this.onEnableTextInput();
          })
          .visibility(this.isEditing ? Visibility.None : Visibility.Visible);
      }
    }
    .padding({
      left: 36,
      right: 36,
    })
    .constraintSize({
      minHeight: 80,
    })
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear.`);
    if (this.isEditing === true) {
      setTimeout(() => {
        focusControl.requestFocus(this.inputFocusKey);
      })
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear.');
  }

  /**
   * 开启输入控件
   */
  private onEnableTextInput(): void {
    LogUtil.showInfo(TAG, `onEnableTextInput`)
    this.isEditing = true;
    focusControl.requestFocus(this.inputFocusKey);
  }
}