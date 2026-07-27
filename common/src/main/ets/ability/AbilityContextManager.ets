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

import type common from '@ohos.app.ability.common';
import type { Context } from '@ohos.abilityAccessCtrl';
import { contextConstant } from '@kit.AbilityKit';

const TAG = 'AbilityContextManager : ';

/**
 * Ability Context管理类
 *
 * @since 2024-12-06
 */
export class AbilityContextManager {
  private contexts: Context[] = [];
  private dataShareExtAbility?: Context = undefined;
  private extServiceContext?: Context = undefined;
  private stageContext?: Context = undefined;
  private backgroundIntentContext?: Context = undefined;
  private static instance?: AbilityContextManager;

  static getInstance(): AbilityContextManager {
    if (!AbilityContextManager.instance) {
      AbilityContextManager.instance = new AbilityContextManager();
    }
    return AbilityContextManager.instance;
  }

  private addAbilityContext(context: Context): void {
    this.contexts.push(context);
  }

  private removeAbilityContext(context: Context): void {
    for (let index = 0; index < this.contexts.length; index++) {
      let current = this.contexts[index];
      if (current === context) {
        this.contexts.splice(index, 1);
        break;
      }
    }
  }

  private getAbilityContext(): Context | undefined {
    if (this.contexts.length <= 0) {
      return undefined;
    }
    return this.contexts[0];
  }

  /**
   * 获取指定分区的Context，由于调用createAreaModeContext接口拷贝的context有hap信息丢失，转成ExtensionContext后返回
   *
   * @param context 上下文
   * @param areaMode context对应的EL分区
   * @returns Context的ExtensionContext副本
   */
  static getAreaContext(context: Context, areaMode: contextConstant.AreaMode): common.ExtensionContext {
    const extensionContext = (context as common.ExtensionContext);
    let areaContext: common.ExtensionContext = context.createAreaModeContext(areaMode) as common.ExtensionContext;
    areaContext.currentHapModuleInfo = extensionContext.currentHapModuleInfo;
    return areaContext;
  }

  /**
   * 添加Ability的Context
   *
   * @param context Ability的Context
   */
  static addContext(context: Context): void {
    AbilityContextManager.getInstance().addAbilityContext(context);
  }

  /**
   * 删除Ability的Context
   *
   * @param context Ability的Context
   */
  static removeContext(context: Context): void {
    AbilityContextManager.getInstance().removeAbilityContext(context);
  }

  /**
   * 获取Ability的Context
   */
  static getContext(): Context | undefined {
    let context: Context | undefined = AbilityContextManager.getInstance().getAbilityContext();
    if (AbilityContextManager.isEmpty(context)) {
      context = AbilityContextManager.getExtContext();
    }
    // DataShareExtContext建议放在最后，后续添加context建议放在DataShareExtContext上面
    if (AbilityContextManager.isEmpty(context)) {
      context = AbilityContextManager.getDataShareExtContext();
    }
    return context;
  }

  static setStageContext(context: Context | undefined): void {
    AbilityContextManager.getInstance().stageContext = context;
  }

  static getStageContext(): Context | undefined {
    return AbilityContextManager.getInstance().stageContext;
  }

  /**
   * 添加ServiceExtensionAbility的context
   * @param context
   */
  static setExtContext(context: Context | undefined): void {
    AbilityContextManager.getInstance().extServiceContext = context;
  }

  /**
   * 获取ServiceExtensionAbility的context
   * @returns
   */
  static getExtContext(): Context | undefined {
    return AbilityContextManager.getInstance().extServiceContext;
  }

  /**
   * 添加DataShareExtensionAbility的context
   * @param context
   */
  static setDataShareExtContext(context: Context): void {
    AbilityContextManager.getInstance().dataShareExtAbility = context;
  }

  /**
   * 获取DataShareExtensionAbility的context
   * @returns
   */
  static getDataShareExtContext(): Context | undefined {
    return AbilityContextManager.getInstance().dataShareExtAbility;
  }

  static tryKillBackgroundAbility(): void {
    let context: Context | undefined = AbilityContextManager.getInstance().backgroundIntentContext;
    if (context) {
      (context as common.UIAbilityContext)?.terminateSelf();
    }
  }

  static isEmpty(context: Context | undefined): boolean {
    return (typeof context === 'undefined' || context == null);
  }
}
