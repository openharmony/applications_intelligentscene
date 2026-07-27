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
import { DespTextType } from '../../framework/model/SettingItemModel';

export interface FillResourceListItem {
  /**
   * text资源
   */
  text: Resource;
  /**
   * 点击事件
   */
  clickFn: () => void;
}

interface FullStringListItem {
  text: string;
  type: DespTextType;
  clickFn?: () => void;
}

const TAG = 'LinkTextComponent';

/**
 * Text文本中存在部分可点击文案组件
 */
@Component
export struct LinkTextComponent {
  fontSize: Length = 12;
  fontColor: ResourceStr = $r('sys.color.font_secondary');
  linkColor: ResourceStr = $r('sys.color.font_emphasize');
  // 存在占位符的文本,如:你好,%1$s,%2$s
  @Prop fullResource?: Resource;
  // fullResource中占位符填充内容及相关点击事件
  @Prop fillResourceList: FillResourceListItem[] = [];

  private getTextList(): FullStringListItem[] {
    const resultList: FullStringListItem[] = [];
    if (!this.fullResource || this.fillResourceList.length === 0) {
      LogUtil.showInfo(TAG, `getTextList return, fullResource: ${this.fullResource}`);
      return resultList;
    }
    const fillStrList = this.fillResourceList.map((item) => ResourceUtil.getStringSync(item.text));
    const fullString = ResourceUtil.getStringWithParamSync(this.fullResource, ...fillStrList);
    let endIndex = 0;
    fillStrList.forEach((str: string, index) => {
      const startIndex = fullString.indexOf(str, endIndex);
      if (startIndex !== -1) {
        resultList.push({ text: fullString.substring(endIndex, startIndex), type: DespTextType.ONLY_SHOW });
        resultList.push({ text: str, type: DespTextType.LINK_TEXT, clickFn: this.fillResourceList[index].clickFn });
        endIndex = startIndex + str.length;
      }
    });
    resultList.push({ text: fullString.substring(endIndex), type: DespTextType.ONLY_SHOW });
    return resultList;
  }

  build() {
    Text() {
      ForEach(this.getTextList(), (item: FullStringListItem) => {
        if (item.type === DespTextType.LINK_TEXT) {
          Span(item.text)
            .fontColor(this.linkColor)
            .onClick(() => {
              LogUtil.showInfo(TAG, `onClink by ${item.text}`);
              item.clickFn?.();
            })
        } else {
          Span(item.text)
        }
      })
    }
    .width('100%')
    .fontSize(this.fontSize)
    .fontColor(this.fontColor)
    .textAlign(TextAlign.Start)
    .wordBreak(WordBreak.BREAK_WORD)
  }
}