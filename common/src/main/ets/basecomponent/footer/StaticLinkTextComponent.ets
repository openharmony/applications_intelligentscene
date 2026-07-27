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
import { ResourceUtil } from '../../utils/ResourceUtil';
import { LanguageUtils } from '../../utils/LanguageUtils';

/* instrument ignore file */
const TAG: string = 'StaticLinkTextComponent:';

@Component
export struct StaticLinkTextComponent {
  textResource: ResourceStr = '';
  linkText: ResourceStr = '';
  linkAction: Function = () => {
  };

  build() {
    Column() {
      Text() {
        Span(this.textResource)
          .fontSize($r('sys.float.Body_S'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
        Span(this.linkText)
          .fontSize($r('sys.float.Body_S'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            this.linkAction();
          })
      }
      .lineHeight(LanguageUtils.getLineHeight(16))
      .textAlign(TextAlign.Start)
      .width('100%')
      .wordBreak(WordBreak.BREAK_WORD)
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.processStartResource();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
  }

  private processStartResource(): void {
    if (typeof this.textResource === 'string') {
      this.textResource = this.textResource.replace(/%\d+\$s/g, '');
      return ;
    }
    const result: string = ResourceUtil.getStringSync(this.textResource);
    this.textResource = result.replace(/%\d+\$s/g, '');
  }
}