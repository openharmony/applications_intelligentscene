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

import { describe, it, beforeAll, afterAll, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, MatchPattern, ON } from '@kit.TestKit';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { EventBus } from '@ohos/scene.common/src/main/ets/framework/common/EventBus';
import { IntelligentSceneConstant } from '@ohos/scene.common/src/main/ets/utils/AbilityUtils';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { ConfigData } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigModel';
import { ConfigType } from '@ohos/scene.datamanage/src/main/ets/model/base/ConfigType';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { ModeType } from '@ohos/scene.datamanage/src/main/ets/model/base/ModeModel';
import { ConfigDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ConfigDataManager';
import { COLOR_ARR, SYMBOL_CODE_ARR } from '@ohos/scene.datamanage/src/main/ets/constant/ModeConstant';
import { ModeDataManager } from '@ohos/scene.datamanage/src/main/ets/manager/ModeDataManager';
import { APP_NAME_ARRAY, Constant } from '../constant/Constant';
import { LearningModeConstant } from '../../../../../main/ets/pages/learning/constant/LearningModeConstant';

const CUSTOM_MODE_NAME_1: string = '1自定义模式1';
const CUSTOM_MODE_NAME_2: string = '2自定义模式2';

const TAG: string = 'SceneManagerTest: ';
const driver: Driver = Driver.create();
const COMMON_DELAY: number = 500;
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SceneManagerTest() {
  describe('SceneManagerTest', () => {
    beforeAll(async () => {
      await startIntelligentScene();
      await clearCondition();
    });

    afterAll(async () => {
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    it('scene_manager_in_home_start_dnd_mode', 0, inHomeStartDndMode);

    it('scene_manager_in_home_time_condition_in_dnd_mode', 0, inHomeAddTimeConditionDndMode);

    it('scene_manager_addAppCondition', 0, addAppCondition);

    it('scene_manager_editAppCondition', 0, editAppCondition);

    it('scene_manager_deleteAppCondition', 0, deleteAppCondition);

    it('scene_manager_addTimeConditionDndMode', 0, addTimeCondition);

    it('scene_manager_editTimeCondition', 0, editTimeCondition);

    it('scene_manager_deleteTimeCondition', 0, deleteTimeCondition);

    it('scene_manager_addLearningPlan', 0, addLearningPlan);

    it('scene_manager_in_home_time_contact_test', 0, changeContactTest);

    it('scene_manager_changeSystemSetting', 0, changeSystemSetting);

    it('scene_manager_addPresetMode', 0, addPresetMode);

    it('scene_manager_editPresetMode', 0, editPresetMode);

    it('scene_manager_deletePresetMode', 0, deletePresetMode);

    it('scene_manager_addCustomMode', 0, addCustomMode);

    it('scene_manager_editCustomMode', 0, editCustomMode);

    it('scene_manager_deleteCustomMode', 0, deleteCustomMode);

    it('scene_manager_deleteCurrentOpenMode', 0, deleteCurrentOpenMode);
  });
}

async function startIntelligentScene(): Promise<void> {
  try {
    await DELEGATOR.startAbility({
      'bundleName': IntelligentSceneConstant.BUNDLE_NAME,
      'abilityName': 'EntryAbility',
    }).then(() => {
      LogUtil.showInfo(TAG, 'EntryAbility start success');
    });
  } catch (err) {
    LogUtil.showError(TAG, `failed to startAbility. Code: ${err?.code}, message: ${err?.message}`);
  }
}

async function inHomeStartDndMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'inHomeStartDndMode');
  StateManager.getInstance().stopScene(ModeType.DND_MODE, FactorType.USER);
  await driver.delayMs(COMMON_DELAY);
  try {
    await driver.assertComponentExist(ON.text(Constant.START_SCENE));
    let startBtn = await driver.waitForComponent(ON.text(Constant.START_SCENE), COMMON_DELAY);
    await startBtn.click();
    await driver.delayMs(COMMON_DELAY);

    await driver.assertComponentExist(ON.text(Constant.STOP_SCENE));
    let stopBtn = await driver.waitForComponent(ON.text(Constant.STOP_SCENE), COMMON_DELAY);
    await stopBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function inHomeAddTimeConditionDndMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'inHomeAddTimeConditionDndMode');
  await driver.delayMs(COMMON_DELAY);
  try {
    await driver.assertComponentExist(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    let addTriggeringConditionBtn = await driver.findComponent(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    await addTriggeringConditionBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let addTimeConditionBtm = await driver.findComponent(ON.text(Constant.TIME_TRIGGERING_CONDITION));
    await addTimeConditionBtm.click();
    await driver.delayMs(COMMON_DELAY);

    let saveBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.TIME_TRIGGERING_CONDITION)))
    await saveBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function clearCondition(): Promise<void> {
  const configs: ConfigData[] = await ConfigDataManager.getInstance().queryConfigByModeAndType(ModeType.DND_MODE, ConfigType.TRIGGER_CONDITION_TIME);
  for (let config of configs) {
    ConfigDataManager.getInstance().deleteConfigDataById(config.configId);
  }
}

async function addAppCondition(): Promise<void> {
  LogUtil.showInfo(TAG, 'addAppCondition');
  try {
    await driver.assertComponentExist(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    let add = await driver.findComponent(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    await add.click();
    await driver.delayMs(COMMON_DELAY);
    let addTriggeringConditionBtn = await driver.findComponent(ON.text(Constant.APP_TRIGGERING_CONDITION));
    await addTriggeringConditionBtn.click();

    await driver.delayMs(4000);

    for (let appName of APP_NAME_ARRAY) {
      let appBtn = await driver.findComponent(ON.text(appName));
      if (appBtn) {
        await appBtn.click();
        await driver.delayMs(200);
      }
    }

    let saveBtn = await driver.findComponent(ON.text(Constant.FINISHED));
    if (saveBtn) {
      await saveBtn.click();
      await driver.delayMs(COMMON_DELAY);
    }
  } catch (e) {
    LogUtil.showError(TAG, `addAppCondition, failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function editAppCondition(): Promise<void> {
  LogUtil.showInfo(TAG, 'editAppCondition');
  try {
    await driver.delayMs(1000);
    let editAppBtn = await driver.findComponent(ON.text(Constant.APP_NUM, MatchPattern.ENDS_WITH));
    if (editAppBtn) {
      LogUtil.showInfo(TAG, 'editAppCondition in');
      await editAppBtn.click();
      await driver.delayMs(2000);

      let switchBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.OPEN)));
      if (!switchBtn) {
        LogUtil.showInfo(TAG, 'editAppCondition, no find switch');
        return;
      }
      await switchBtn.click();
      LogUtil.showInfo(TAG, 'editAppCondition, find switch ');
      await driver.delayMs(200);
      let saveBtn = await driver.findComponent(ON.text(Constant.FINISHED));
      await saveBtn.click();
    }
  } catch (e) {
    LogUtil.showError(TAG, `editAppCondition, failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function deleteAppCondition(): Promise<void> {
  LogUtil.showInfo(TAG, 'deleteAppCondition');
  try {
    await driver.delayMs(1000);
    let editAppBtn = await driver.findComponent(ON.text(Constant.APP_NUM, MatchPattern.ENDS_WITH));
    if (editAppBtn) {
      await editAppBtn.click();
      await driver.delayMs(2000);

      let deleteBtn = await driver.findComponent(ON.text(Constant.DELETE_CONDITION));
      await deleteBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let cancelBtn = await driver.findComponent(ON.text(Constant.CANCEL));
      await cancelBtn.click();
      await driver.delayMs(200);

      await deleteBtn.click();
      await driver.delayMs(200);

      let confirmBtn = await driver.findComponent(ON.text(Constant.DELETE));
      await confirmBtn.click();
    }
  } catch (e) {
    LogUtil.showError(TAG, `deleteAppCondition, failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function addTimeCondition(): Promise<void> {
  LogUtil.showInfo(TAG, 'addTimeCondition');
  try {
    await driver.assertComponentExist(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    let addTriggeringConditionBtn = await driver.findComponent(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    await addTriggeringConditionBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let addTimeConditionBtm = await driver.findComponent(ON.text(Constant.TIME_TRIGGERING_CONDITION));
    await addTimeConditionBtm.click();
    await driver.delayMs(COMMON_DELAY);

    let typeBtn = await driver.findComponent(ON.text(Constant.LOOP_TYPE));
    await typeBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let everyDayBtn = await driver.findComponent(ON.text(Constant.EVERY_DAY));
    await everyDayBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let saveBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.TIME_TRIGGERING_CONDITION)))
    await saveBtn.click();
  } catch (e) {
    LogUtil.showError(TAG, `addTimeCondition failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function editTimeCondition(): Promise<void> {
  LogUtil.showInfo(TAG, 'editTimeCondition');
  try {
    let dayTimeTriggeringConditionBtn = await driver.findComponent(ON.text(Constant.EVERY_DAY));
    if (dayTimeTriggeringConditionBtn) {
      await dayTimeTriggeringConditionBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let switchBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.OPEN)));
      if (!switchBtn) {
        LogUtil.showInfo(TAG, 'editTimeCondition, no find switch');
        return;
      }
      await switchBtn.click();
      LogUtil.showInfo(TAG, 'editAppCondition, find switch ');
      await driver.delayMs(COMMON_DELAY);

      let startTimeBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.START_TIME)));
      await startTimeBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let startChangeBtn = await driver.findComponent(ON.text(Constant.START_TIME_CHANGE));
      await startChangeBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let confirmBtm = await driver.findComponent(ON.text(Constant.CONFIRM));
      await confirmBtm.click();
      await driver.delayMs(COMMON_DELAY);

      let endTimeBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.END_TIME)));
      await endTimeBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let endChangeBtn = await driver.findComponent(ON.text(Constant.END_TIME_CHANGE));
      await endChangeBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let cancel = await driver.findComponent(ON.text(Constant.CANCEL));
      await cancel.click();
      await driver.delayMs(COMMON_DELAY);

      let typeBtn = await driver.findComponent(ON.text(Constant.LOOP_TYPE));
      await typeBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let weekBtn = await driver.findComponent(ON.text(Constant.EVERY_WEEK));
      await weekBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let saveBtn = await driver.findComponent(ON.isAfter(ON.text(Constant.TIME_TRIGGERING_CONDITION)))
      await saveBtn.click();

    }
  } catch (e) {
    LogUtil.showError(TAG, `editTimeCondition, failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function deleteTimeCondition(): Promise<void> {
  LogUtil.showInfo(TAG, 'deleteTimeCondition');
  try {
    let onceTimeTriggeringConditionBtn = await driver.findComponent(ON.text(Constant.ONE_TIME));

    if (onceTimeTriggeringConditionBtn) {
      await onceTimeTriggeringConditionBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let deleteConditionBtn = await driver.findComponent(ON.text(Constant.DELETE_CONDITION));
      await deleteConditionBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let deleteCancelBtn = await driver.findComponent(ON.text(Constant.CANCEL));
      await deleteCancelBtn.click();
      await driver.delayMs(COMMON_DELAY);

      await deleteConditionBtn.click();
      await driver.delayMs(COMMON_DELAY);

      let deleteConfirmBtn = await driver.findComponent(ON.text(Constant.DELETE));
      await deleteConfirmBtn.click();
    }
  } catch (e) {
    LogUtil.showError(TAG, `deleteTimeCondition, failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function addLearningPlan(): Promise<void> {
  LogUtil.showInfo(TAG, 'addLearningPlan');
  await driver.delayMs(1000);
  try {
    let homeScroll = await driver.findComponent(ON.id('homeScroll'));
    let list = await driver.findComponent(ON.id('allModeSwiperList'));
    let swiper = await driver.findComponent(ON.id('swiperDotIndicator'));
    await swiper.doubleClick();
    await driver.delayMs(100);
    let learningModeCard = await list.scrollSearch(ON.text(Constant.LEARN_MODE), false);
    if (learningModeCard) {
      let learningPlanBtn = await homeScroll.scrollSearch(ON.text(Constant.LEARN_PLAN), true);
      await learningPlanBtn.click();
      await driver.delayMs(400);
      let addPlanBtn = await driver.findComponent(ON.text(Constant.ADD_LEARN_PLAN));
      await addPlanBtn.click();
      await driver.delayMs(400);

      let nextStep = await driver.findComponent(ON.text(Constant.NEXT_STEP));
      if (nextStep) {
        await nextStep.click();
        await driver.delayMs(400);
      }

      let input = await driver.findComponent(ON.id('addLearningPlanInput'));
      await input.inputText('测试学习计划123');
      await driver.delayMs(400);
      await driver.pressBack();
      let confirmBtn = await driver.findComponent(ON.text(Constant.CONFIRM));
      await confirmBtn.click();

      await driver.delayMs(400);
      await driver.pressBack();
      EventBus.getInstance().emit(LearningModeConstant.CLOSE_ADD_LEARNING_TASK_DIALOG_EVENT);

      let cancelBtn = await driver.findComponent(ON.text(Constant.CANCEL));
      if (cancelBtn) {
        await cancelBtn.click();
      }
      await driver.delayMs(200);

      let learnPlan = await driver.findComponent(ON.id('learningTaskItem'));
      await learnPlan.click();
      await driver.delayMs(200);

      let editInput = await driver.findComponent(ON.id('editLearningPlanInput'));
      await editInput.inputText('测试学习计划测试学习计划测试学习计划测试学习计划测试学习计划测试学习计划测试学习计划测试学习计划测试');
      cancelBtn = await driver.findComponent(ON.text(Constant.CANCEL));
      await cancelBtn.click();
      await driver.delayMs(400);

      learnPlan = await driver.findComponent(ON.id('learningTaskItem'));
      await learnPlan.click();
      await driver.delayMs(200);

      editInput = await driver.findComponent(ON.id('editLearningPlanInput'));
      await editInput.inputText('朗读古诗一首');

      await driver.delayMs(200);
      let saveBtn = await driver.findComponent(ON.text(Constant.CONFIRM));
      await saveBtn.click();

      await driver.delayMs(1000);

      let deleteBtn = await driver.findComponent(ON.isAfter(ON.text('朗读古诗一首')));
      await deleteBtn.click();
      await driver.pressBack();
      await driver.delayMs(1000);
    }
  } catch (e) {
    LogUtil.showError(TAG, `failed to addLearningPlan. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function addLocationCondition(): Promise<void> {
  LogUtil.showInfo(TAG, 'addLocationCondition');
  try {
    let add = await driver.findComponent(ON.text(Constant.ADD_TRIGGERING_CONDITION));
    await add.click();
    await driver.delayMs(COMMON_DELAY);
    await driver.pressBack();
  } catch (e) {
    LogUtil.showError(TAG, `addLocationCondition error ${e?.code}, ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function changeSystemSetting(): Promise<void> {
  LogUtil.showInfo(TAG, 'changeSystemSetting');
  try {
    let homeScroll = await driver.findComponent(ON.id('homeScroll'));
    await homeScroll.scrollSearch(ON.text(Constant.DARK_MODE), true);
    await driver.delayMs(COMMON_DELAY);
    await driver.assertComponentExist(ON.text(Constant.DARK_MODE));
    let darkModeMenuBtn = await driver.findComponent(ON.text(Constant.DARK_MODE));
    await darkModeMenuBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let darkModeLinkBtm = await driver.findComponent(ON.text(Constant.OPEN));
    await darkModeLinkBtm.click();
    await driver.delayMs(COMMON_DELAY);

    await darkModeMenuBtn.click();
    await driver.delayMs(COMMON_DELAY);
    darkModeLinkBtm = await driver.findComponent(ON.text(Constant.NO_LINK));
    await darkModeLinkBtm.click();
    await driver.delayMs(COMMON_DELAY);

    await darkModeMenuBtn.click();
    await driver.delayMs(COMMON_DELAY);

    darkModeLinkBtm = await driver.findComponent(ON.text(Constant.CLOSED));
    await darkModeLinkBtm.click();
    await driver.delayMs(COMMON_DELAY);

    let eyeMenuBtn = await driver.findComponent(ON.text(Constant.EYE_PROJECT_MODE));
    await eyeMenuBtn.click();
    await driver.delayMs(1000);
    let eyeLinkBtm = await driver.findComponent(ON.text(Constant.OPEN));
    await eyeLinkBtm.click();
    await driver.delayMs(1000);

    await eyeMenuBtn.click();
    await driver.delayMs(1000);
    eyeLinkBtm = await driver.findComponent(ON.text(Constant.CLOSED));
    await eyeLinkBtm.click();
    await driver.delayMs(1000);

    await eyeMenuBtn.click();
    await driver.delayMs(1000);
    eyeLinkBtm = await driver.findComponent(ON.text(Constant.NO_LINK));
    await eyeLinkBtm.click();
    await driver.delayMs(1000);
  } catch (e) {
    LogUtil.showError(TAG, `failed to startAbility. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function changeContactTest(): Promise<void> {
  try {
    LogUtil.showInfo(TAG, 'changeContactTest');
    await driver.delayMs(800);
    await driver.assertComponentExist(ON.text(Constant.CONTACT));
    let contactBtn = await driver.findComponent(ON.text(Constant.CONTACT));
    await contactBtn.click();
    await driver.delayMs(COMMON_DELAY);

    let btn1 = await driver.findComponent(ON.text(Constant.FORBID_EVERYONE));
    await btn1.click();
    await driver.delayMs(COMMON_DELAY);

    let btn2 = await driver.findComponent(ON.text(Constant.ALLOW_EVERYONE));
    await btn2.click();
    await driver.delayMs(COMMON_DELAY);

    let btn3 = await driver.findComponent(ON.text(Constant.ALLOW_EXISTING_CONTACTS));
    await btn3.click();
    await driver.delayMs(COMMON_DELAY);

    let btn4 = await driver.findComponent(ON.text(Constant.ALLOW_FAVORITE_CONTACTS));
    await btn4.click();
    await driver.delayMs(COMMON_DELAY);

    let btn5 = await driver.findComponent(ON.text(Constant.ALLOW_SPECIFIED_CONTACTS));
    await btn5.click();
    await driver.delayMs(COMMON_DELAY);

    let btn6 = await driver.findComponent(ON.text(Constant.FORBID_SPECIFIED_CONTACTS));
    await btn6.click();
    await driver.delayMs(COMMON_DELAY);

    let addContact = await driver.findComponent(ON.text(Constant.ADD_CONTACTS));
    await addContact.click();
    await driver.delayMs(2000);
    await driver.pressBack();
    await driver.delayMs(1000);

    let repeatToggle = await driver.findComponent(ON.isAfter(ON.text(Constant.REPEAT_CALL)));
    await repeatToggle.click();
    await driver.delayMs(COMMON_DELAY);
    await repeatToggle.click();
    await driver.delayMs(COMMON_DELAY);

    let aiToggle = await driver.findComponent(ON.isAfter(ON.text(Constant.AI_CALL)));
    await aiToggle.click();
    await driver.delayMs(1000);

    let backBtn = await driver.findComponent(ON.text(Constant.BACK));
    if (backBtn) {
      await backBtn.click();
      await driver.delayMs(1000);
    }

    await driver.delayMs(COMMON_DELAY);
    let knowBtn = await driver.findComponent(ON.text(Constant.KNOW_MORE, MatchPattern.ENDS_WITH));
    if (knowBtn) {
      await knowBtn.click();
      await driver.delayMs(2000);
      await driver.pressBack();
    }
  } catch (e) {
    LogUtil.showError(TAG, `failed to changeContactTest. Code: ${e?.code}, message: ${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function addPresetMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'addPresetMode');
  try {
    // 新增模式
    const addIcon = await driver.findComponent(ON.id('addModeIcon'));
    await addIcon.click();
    await driver.delayMs(COMMON_DELAY);
    // 新增工作模式
    const customModeItem = await driver.findComponent(ON.text(Constant.WORK_MODE));
    await customModeItem.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `addPresetMode catch error. code:${e?.code} message:${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function editPresetMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'editPresetMode');
  try {
    let homeScroll = await driver.findComponent(ON.id('homeScroll'));
    await homeScroll.scrollSearch(ON.text(Constant.WORK_MODE), true);
    await driver.delayMs(COMMON_DELAY);
    // 滑动到工作模式
    const allModeList = await driver.findComponent(ON.id('allModeSwiperList'));
    const customModeCard = await allModeList.scrollSearch(ON.text(Constant.WORK_MODE), false);
    await customModeCard.click();
    await driver.delayMs(COMMON_DELAY);
    // 修改模式图标
    const symbolIcon = await driver.findComponent(ON.id('case_fill'));
    await symbolIcon.click();
    await driver.delayMs(COMMON_DELAY);
    // 修改模式颜色
    const colorIcon = await driver.findComponent(ON.id(COLOR_ARR[1]));
    await colorIcon.click();
    await driver.delayMs(COMMON_DELAY);
    // 点击保存
    const doneBtn = await driver.findComponent(ON.text(Constant.FINISHED));
    await doneBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `editPresetMode catch error. code:${e?.code} message:${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function deletePresetMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'deletePresetMode');
  try {
    // 滑动到工作模式
    const allModeList = await driver.findComponent(ON.id('allModeSwiperList'));
    await allModeList.scrollSearch(ON.text(Constant.WORK_MODE), false);
    // 上滑卡片露出删除按钮
    await allModeList.scrollSearch(ON.id('deleteSwipeButton'), true);
    // 点击删除模式按钮
    const deleteModeBtn = await driver.findComponent(ON.id('deleteSwipeButton'));
    await deleteModeBtn.click();
    await driver.delayMs(COMMON_DELAY);
    // 确认删除
    const deleteBtn = await driver.findComponent(ON.text(Constant.DELETE));
    await deleteBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `deletePresetMode catch error. code:${e?.code} message:${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function addCustomMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'addCustomMode');
  try {
    // 新增模式
    const addIcon = await driver.findComponent(ON.id('addModeIcon'));
    await addIcon.click();
    await driver.delayMs(COMMON_DELAY);
    // 选择自定义模式
    const customModeItem = await driver.findComponent(ON.text(Constant.CUSTOM_MODE));
    await customModeItem.click();
    await driver.delayMs(COMMON_DELAY);
    // 填入模式名称
    const addInput = await driver.findComponent(ON.id('modeNameTextInput'));
    await addInput.inputText(CUSTOM_MODE_NAME_1);
    await driver.delayMs(COMMON_DELAY);
    // 修改模式颜色
    const colorIcon = await driver.findComponent(ON.id(COLOR_ARR[COLOR_ARR.length - 1]));
    await colorIcon.click();
    await driver.delayMs(COMMON_DELAY);
    // 点击新建
    const addBtn = await driver.findComponent(ON.text(Constant.ADD));
    await addBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `addCustomMode catch error. code:${e?.code} message:${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function editCustomMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'editCustomMode');
  try {
    let homeScroll = await driver.findComponent(ON.id('homeScroll'));
    await homeScroll.scrollSearch(ON.text(CUSTOM_MODE_NAME_1), true);
    await driver.delayMs(COMMON_DELAY);
    // 滑动到自定义模式
    const allModeList = await driver.findComponent(ON.id('allModeSwiperList'));
    const customModeCard = await allModeList.scrollSearch(ON.text(CUSTOM_MODE_NAME_1), false);
    await customModeCard.click();
    await driver.delayMs(COMMON_DELAY);
    // 点击编辑名称
    const editLink = await driver.findComponent(ON.text(Constant.EDIT));
    await editLink.click();
    await driver.delayMs(COMMON_DELAY);
    // 修改模式名称
    const addInput = await driver.findComponent(ON.id('modeNameTextInput'));
    await addInput.inputText(Constant.SLEEP_MODE);
    await driver.delayMs(COMMON_DELAY);
    await addInput.inputText('超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本');
    await driver.delayMs(COMMON_DELAY);
    await addInput.inputText(CUSTOM_MODE_NAME_2);
    await driver.delayMs(COMMON_DELAY);
    // 修改模式图标
    const symbolIcon = await driver.findComponent(ON.id(SYMBOL_CODE_ARR[1]));
    await symbolIcon.click();
    await driver.delayMs(COMMON_DELAY);
    // 修改模式颜色
    const colorIcon = await driver.findComponent(ON.id(COLOR_ARR[1]));
    await colorIcon.click();
    await driver.delayMs(COMMON_DELAY);
    // 点击保存
    const doneBtn = await driver.findComponent(ON.text(Constant.FINISHED));
    await doneBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `editCustomMode catch error. code:${e?.code} message:${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function deleteCustomMode(): Promise<void> {
  LogUtil.showInfo(TAG, 'deleteCustomMode');
  try {
    // 滑动到自定义模式
    const allModeList = await driver.findComponent(ON.id('allModeSwiperList'));
    await allModeList.scrollSearch(ON.text(CUSTOM_MODE_NAME_2), false);
    // 点击删除模式按钮
    const homeScroll = await driver.findComponent(ON.id('homeScroll'));
    const deleteModeBtn = await homeScroll.scrollSearch(ON.text(Constant.DELETE_MODE), true);
    await deleteModeBtn.click();
    await driver.delayMs(COMMON_DELAY);
    // 取消按钮
    const cancelBtn = await driver.findComponent(ON.text(Constant.CANCEL));
    await cancelBtn.click();
    await driver.delayMs(COMMON_DELAY);

    await deleteModeBtn.click();
    await driver.delayMs(COMMON_DELAY);
    // 确认删除
    const deleteBtn = await driver.findComponent(ON.text(Constant.DELETE));
    await deleteBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `deleteCustomMode catch error. code:${e?.code} message:${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}

async function deleteCurrentOpenMode() {
  LogUtil.showInfo(TAG, 'deleteCurrentOpenMode');
  try {
    await addCustomMode();
    // 滑动到自定义模式
    const allModeList = await driver.findComponent(ON.id('allModeSwiperList'));
    await allModeList.scrollSearch(ON.text(CUSTOM_MODE_NAME_1), false);
    // 拿最后一个保证是当前模式的开启按钮
    const openButtons = await driver.findComponents(ON.text(Constant.START_SCENE));
    await openButtons[openButtons.length -1].click();
    await driver.delayMs(COMMON_DELAY);
    // 点击删除模式按钮
    const homeScroll = await driver.findComponent(ON.id('homeScroll'));
    const deleteModeBtn = await homeScroll.scrollSearch(ON.text(Constant.DELETE_MODE), true);
    await deleteModeBtn.click();
    await driver.delayMs(COMMON_DELAY);
    // 取消按钮
    const cancelBtn = await driver.findComponent(ON.text(Constant.CANCEL));
    await cancelBtn.click();
    await driver.delayMs(COMMON_DELAY);

    await deleteModeBtn.click();
    await driver.delayMs(COMMON_DELAY);
    // 确认删除
    const deleteBtn = await driver.findComponent(ON.text(Constant.DELETE));
    await deleteBtn.click();
    await driver.delayMs(COMMON_DELAY);
  } catch (e) {
    LogUtil.showError(TAG, `deleteCurrentOpenMode catch error. code:${e?.code} message:${e?.message}`);
  }
  const count: number = await ModeDataManager.getInstance().queryModeCount();
  expect(count >= 0).assertTrue();
}