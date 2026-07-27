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

import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
} from '@ohos/hypium';
import { LogUtil } from '@ohos/scene.common';
import { DefaultPageConfig } from '@ohos/scene.common/src/main/ets/framework/common/DefaultPageConfig';
import {
  SettingContentTextStyle,
  SettingGroupLayout
} from '@ohos/scene.common/src/main/ets/framework/model/SettingGroupModel';
import {
  DefaultSettingItemModel,
  SettingSheetTitleStyle
} from '@ohos/scene.common/src/main/ets/framework/model/SettingItemModel';

const TAG: string = 'DefaultPageConfigTest: ';

export default function DefaultPageConfigTest() {
  describe('DefaultPageConfigTest', () => {
    beforeEach(() => {

    });

    afterEach(() => {

    });

    it('getInstance_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        expect(instance !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getInstance_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultSheetTitleLayout_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style: SettingSheetTitleStyle = instance.getDefaultSheetTitleLayout();
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultSheetTitleLayout_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultPageHeaderStyle_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style: SettingContentTextStyle = instance.getDefaultPageHeaderStyle();
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultPageHeaderStyle_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultGroupLayout_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const layout: SettingGroupLayout = instance.getDefaultGroupLayout();
        expect(layout !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultGroupLayout_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultGroupHeaderStyle_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style = instance.getDefaultGroupHeaderStyle();
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultGroupHeaderStyle_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultGroupFooterStyle_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style = instance.getDefaultGroupFooterStyle();
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultGroupFooterStyle_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultItemLayout_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style = instance.getDefaultItemLayout(DefaultSettingItemModel.get());
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultItemLayout_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultDialogButtonStyle_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style = instance.getDefaultDialogButtonStyle();
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultDialogButtonStyle_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultRadioStyle_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style = instance.getDefaultRadioStyle();
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultRadioStyle_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });

    it('getDefaultMenuStyle_DefaultPageConfigTest', 0, (done: Function) => {
      try {
        const instance: DefaultPageConfig = DefaultPageConfig.getInstance();
        const style = instance.getDefaultMenuStyle();
        expect(style !== undefined).assertTrue();
      } catch (err) {
        LogUtil.showError(TAG,
          `getDefaultMenuStyle_DefaultPageConfigTest error. Code: ${err?.code}, message: ${err?.message}`);
      }
      done();
    });
  });
}