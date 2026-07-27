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

import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { FormInfo } from '@ohos/scene.datamanage/src/main/ets/model/FormInfo';
import { FormDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/FormDataManager';
import { ModeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/ModeUtil';
import { FormModeData } from '../model/FormControlData';
import { SceneForm } from '../constant/FormConstant';
import { RecentTimeConditionCalUtils } from '../utils/RecentTimeConditionCalUtils';

/**
 * 卡片更新延时，避免单次时间围栏状态变化为已关闭后，卡片查询到的依旧是已开启状态
 */
const FORM_UPDATE_DELAY_TIME: number = 300;

const TAG: string = 'FormManager: ';

export class FormManager {
  private static instance: FormManager;
  private language: string | undefined;

  private constructor() {
  }

  public static getInstance(): FormManager {
    if (!FormManager.instance) {
      FormManager.instance = new FormManager();
    }
    return FormManager.instance;
  }

  /**
   * 睡眠->其他/关闭 其他/关闭->睡眠  更新睡眠模式卡片
   */
  public async updateAllForms(nextScene: string, preScene: string): Promise<void> {
    setTimeout(async () => {
      if (preScene === ModeType.SLEEP_MODE || nextScene === ModeType.SLEEP_MODE) {
        await this.updateSleepModeForAllForm(ModeType.SLEEP_MODE);
      }
    }, FORM_UPDATE_DELAY_TIME);
  }

  /**
   * 系统语言修改时刷新卡片内容
   */
  public async updateAllFormByConfigurationUpdate(configLanguage: string | undefined): Promise<void> {
    setTimeout(async () => {
      LogUtil.showInfo(TAG, `updateAllFormByConfigurationUpdate configLanguage ${configLanguage}`);
      this.language = configLanguage;
      await this.updateSleepModeForAllForm(ModeType.SLEEP_MODE);
      this.language = undefined;
    }, FORM_UPDATE_DELAY_TIME);
  }

  /**
   * 添加卡片预览时，获取睡眠模式卡片内容
   */
  public async getSleepFormDataWithFormId(formId: string): Promise<void> {
    LogUtil.showInfo(TAG, `getSleepFormDataWithFormId formId ${formId}`);
    let curModeData: FormModeData = await this.getSleepModeFormData(ModeType.SLEEP_MODE);
    let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(curModeData);
    await this.updateForm(formId, formMsg);
  }

  /**
   * 时间围栏更新时刷新卡片内容
   */
  public async updateModeByTimeCondition(curModeId: string): Promise<void> {
    if (curModeId !== ModeType.SLEEP_MODE) {
      await this.updateSleepModeForAllForm(ModeType.SLEEP_MODE);
    }
  }

  public async updateSleepModeForAllForm(modeId: string): Promise<void> {
    LogUtil.showInfo(TAG, `updateSleepModeForAllForm modeId ${modeId}`);
    const formList: FormInfo[] = await FormDataManager.getInstance().queryFormByName(SceneForm.SLEEP_FORM);
    if (!formList) {
      return;
    }
    const formModeData: FormModeData = await this.getSleepModeFormData(modeId);
    let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formModeData);
    for (let formInfo of formList) {
      await this.updateForm(formInfo.formId, formMsg);
    }
  }

  /**
   * 获取睡眠卡片需要展示的内容
   */
  public async getSleepModeFormData(modeId: string): Promise<FormModeData> {
    LogUtil.showInfo(TAG, `getSleepModeFormData modeId ${modeId}`);
    const recentTimeCondition: string =
      await RecentTimeConditionCalUtils.getRecentEnableTimeConditionDescription(modeId, this.language);
    LogUtil.showInfo(TAG, `getSleepModeFormData recentTimeCondition ${recentTimeCondition}`);
    const curModeId: string = ModeUtil.getModeOpenState().modeId;
    let curModeData: FormModeData = {
      formId: '',
      recentTimeCondition: recentTimeCondition,
      isStartStatus: curModeId === ModeType.SLEEP_MODE,
    }
    return curModeData;
  }

  public async updateForm(formId: string, formMsg: formBindingData.FormBindingData): Promise<void> {
    LogUtil.showInfo(TAG, 'updateForm');
    await formProvider.updateForm(formId, formMsg).then(() => {
      LogUtil.showInfo(TAG, `updateForm success formId: ${formId}`);
    }).catch((error: BusinessError) => {
      LogUtil.showError(TAG, `updateForm failed. code:${error?.code} message:${error?.message}`);
    });
  }
}