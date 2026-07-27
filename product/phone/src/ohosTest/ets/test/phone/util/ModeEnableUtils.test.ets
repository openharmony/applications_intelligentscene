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
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit,
  when
} from '@ohos/hypium';
import { ModeEnableService } from '@ohos/scene.statemanage/src/main/ets/service/ModeEnableService';
import { Response } from '@ohos/scene.common/src/main/ets/constant/Response';
import { CallMessage } from '@ohos/scene.common/src/main/ets/stub/BaseServiceStub';
import { ModeResponseBody } from '@ohos/scene.statemanage/src/main/ets/model/RuleResponseBody';
import { ModeHistory } from '@ohos/scene.datamanage/src/main/ets/model/ModeHistory';
import { StateManager } from '@ohos/scene.statemanage/src/main/ets/manager/StateManager';
import { RuleFeedbackManager } from '@ohos/scene.datamanage/src/main/ets/manager/RuleFeedbackManager';
import { FactorType } from '@ohos/scene.common/src/main/ets/model/FactorModel';
import { RuleFeedBack } from '@ohos/scene.datamanage/src/main/ets/model/base/RuleFeedback';
import { NotificationManager } from '@ohos/scene.recommendation/src/main/ets/manager/NotificationManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { RecommendationService } from '@ohos/scene.recommendation/src/main/ets/service/RecommendationService';
import { DateTimeUtil } from '@ohos/scene.datamanage/src/main/ets/utils/DateTimeUtil';

let mocker: MockKit = new MockKit();
let mockFunc: Function = mocker.mockFunc(NotificationManager, NotificationManager.getInstance().publishRecommendOpenNft);
const TAG: string = 'ModeEnableServiceTest: ';

export default function ModeEnableUtilsTest() {
  describe('ModeEnableUtilsTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
      mocker.ignoreMock(NotificationManager, NotificationManager.getInstance().publishRecommendOpenNft);
      RuleFeedbackManager.getInstance().deleteRuleFeedbackByModeId('1');
    });

    it('mode_enable_call_utils_test', 0, async (done: Function) => {
      let modeEnableService: ModeEnableService = new ModeEnableService();
      const json: CallMessage = {
        "method": "modeEnable"
      };
      json.extra = {
        'ruleSatisfyResults': [{
          'operType': 'AUTO_ON',
          'timestamp': 1741762881724,
          'ruleName':'rule-1_3_418880f27ce645be8090a09559805a1d-1741762880944',
          'modeId':'1',
          'priority': 1,
          'configId': '1_3'
        } as ModeHistory],
        'ruleNotSatisfyResults': [],
        'currentEnableMode': {
          'operType': 'AUTO_ON',
          'timestamp': 1741762881724,
          'ruleName': 'rule-1_3_418880f27ce645be8090a09559805a1d-1741762880944',
          'modeId': '1',
          'priority': 1,
          'configId': '1_3'
        } as ModeHistory,
        timeStamp: DateTimeUtil.getCurrentTimeStamp()
      } as ModeResponseBody;
      let response: string = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('mode_disable_call_utils_test', 0, async (done: Function) => {
      let modeEnableService: ModeEnableService = new ModeEnableService();
      const json: CallMessage = {
        "method": "modeEnable"
      };

      json.extra = {
        'ruleSatisfyResults': [],
        'ruleNotSatisfyResults': [{
          'operType': 'AUTO_OFF',
          'timestamp': 1741764420163,
          'ruleName':'rule-1_3_418880f27ce645be8090a09559805a1d-1741764399810',
          'modeId':'1',
          'priority': 1,
          'configId': '1_3'
        }],
        'currentEnableMode': {
          'ruleName': '',
          'modeId': '0',
          'priority': 0,
        } as ModeHistory,
        timeStamp: DateTimeUtil.getCurrentTimeStamp()
      } as ModeResponseBody;
      let response: string = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('mode_disable_call_rule_utils_test', 0, async (done: Function) => {
      let modeEnableService: ModeEnableService = new ModeEnableService();
      const json: CallMessage = {
        "method": "modeEnable"
      };

      json.extra = {
        'ruleSatisfyResults': [{
          'operType': 'AUTO_ON',
          'timestamp': 1741764420164,
          'ruleName':'rule_2_3_418880f27ce645be8090a09559805a1d-1741764399810',
          'modeId':'2',
          'priority': 2,
          'configId': '2_3'
        }],
        'ruleNotSatisfyResults': [{
          'operType': 'AUTO_OFF',
          'timestamp': 1741764420163,
          'ruleName':'rule_1_3_418880f27ce645be8090a09559805a1d-1741764399810',
          'modeId':'1',
          'priority': 1,
          'configId': '1_3'
        }],
        'currentEnableMode': {
          'ruleName': '',
          'modeId': '0',
          'priority': 0,
        } as ModeHistory,
        timeStamp: DateTimeUtil.getCurrentTimeStamp()
      } as ModeResponseBody;
      let response: string = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('mode_disable_call_utils_test_error', 0, async (done: Function) => {
      let modeEnableService: ModeEnableService = new ModeEnableService();
      let response: string = await modeEnableService.onCall('{"id":"000\u0001"}');
      expect(response).assertEqual(Response.UNKNOWN_METHOD);

      const json: CallMessage = {
        "method": "fail"
      };
      response = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.INVALID_METHOD);
      done();
    });

    it('request_timeout_call_utils_test_error', 0, async (done: Function) => {
      let modeEnableService: ModeEnableService = new ModeEnableService();
      const json: CallMessage = {
        "method": "modeEnable"
      };
      json.extra = {
        'ruleSatisfyResults': [],
        'ruleNotSatisfyResults': [],
        'currentEnableMode': {
          'ruleName': '',
          'modeId': '0',
          'priority': 0,
        } as ModeHistory,
        timeStamp: DateTimeUtil.getCurrentTimeStamp()
      } as ModeResponseBody;
      let response: string = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('game_mode_off_call_utils_test', 0, async (done: Function) => {
      let modeEnableService: ModeEnableService = new ModeEnableService();
      const json: CallMessage = {
        "method": "modeEnable"
      };
      json.extra = {
        'ruleSatisfyResults': [],
        'ruleNotSatisfyResults': [{
          'operType': 'AUTO_OFF',
          'timestamp': 1741764420163,
          'ruleName':'rule_1_18_temp_condition-1741764399810',
          'modeId':'1',
          'priority': 1,
          'configId': '1_18'
        }],
        'currentEnableMode': {
          'ruleName': '',
          'modeId': '0',
          'priority': 0,
        } as ModeHistory,
        timeStamp: DateTimeUtil.getCurrentTimeStamp()
      } as ModeResponseBody;
      let response: string = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('recommend_enable_call_utils_test', 0, async (done: Function) => {
      try {
        let modeEnableService: RecommendationService = new RecommendationService();
        const json: CallMessage = {
          "method": "recommendationEnable"
        };
        const extra: string = '{"ruleId": "recommend_1", "facts": {"state_time_1": "true", "state_location_1": "true"}}';
        json.extra = JSON.parse(extra);
        let response: string = await modeEnableService.onCall(JSON.stringify(json));
        expect(response).assertEqual(Response.SUCCESS);
      } catch (e) {
      }
      done();
    });

    it('recommend_disable_call_utils_test', 0, async (done: Function) => {
      let modeEnableService: RecommendationService = new RecommendationService();
      let json: CallMessage = {
        "method": "recommendationDisable"
      };
      const extra: string = '{"ruleId": "recommend_1", "facts": {"state_time_1": "true", "state_location_1": "true"}}';
      json.extra = JSON.parse(extra);
      let response: string = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('recommend_disable_call_utils_test_rule_id_fail', 0, async (done: Function) => {
      let modeEnableService: RecommendationService = new RecommendationService();
      let json: CallMessage = {
        "method": "recommendationEnable"
      };
      const extra: string = '{"facts": {"state_time_1": "true", "state_location_1": "true"}}';
      json.extra = JSON.parse(extra);
      let response: string = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      json.extra = JSON.parse('{"method": "recommendationDisable", "ruleId": "recommend"}');
      response = await modeEnableService.onCall(JSON.stringify(json));
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('recommend_disable_call_test_utils_mock_no_rule_fail', 0, async (done: Function) => {
      let modeEnableService: RecommendationService = new RecommendationService();
      StateManager.getInstance().startScene('1', FactorType.USER);
      await RuleFeedbackManager.getInstance().deleteRuleFeedbackByModeId('3');
      const json: string = '{"method": "recommendationDisable", "extra": {"ruleId": "recommend_4", "facts": {"state_time_4": "true", "state_location_4": "true"}}}';
      let response: string = await modeEnableService.onCall(json);
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('recommend_enable_call_utils_test_mock_rule', 0, async (done: Function) => {
      when(mockFunc)().afterReturnNothing();
      let modeEnableService: RecommendationService = new RecommendationService();
      StateManager.getInstance().startScene('1', FactorType.USER);
      const ruleFeedback: RuleFeedBack = {
        ruleId: 'recommend_1',
        modeId: '1',
        createTime: 1744065666758,
        timeRange: '',
        longitude: '30.494743816170036',
        latitude: '114.53363273469294',
      }
      try {
        await RuleFeedbackManager.getInstance().insertRuleFeedback(ruleFeedback);
        const json: string = '{"method":"recommendationEnable", "extra":{ "ruleId": "recommend_1", "facts": {"state_time_1": "true", "state_location_1": "true"}}}';
        let response: string = await modeEnableService.onCall(json);
        expect(response !== undefined).assertTrue();
      } catch (e) {
        LogUtil.showError(TAG, `recommend_enable_call_test_mock_rule error ${e?.code} ${e?.message}`);
      }
      done();
    });

    it('recommend_disable_call_utils_test_mock_no_rule', 0, async (done: Function) => {
      when(mockFunc)().afterReturnNothing();
      let modeEnableService: RecommendationService = new RecommendationService();
      StateManager.getInstance().startScene('1', FactorType.USER);
      const ruleFeedback: RuleFeedBack = {
        ruleId: 'recommend_1',
        modeId: '5',
        createTime: 1744065666758,
        timeRange: '',
        longitude: '30.494743816170036',
        latitude: '114.53363273469294',
      }
      await RuleFeedbackManager.getInstance().insertRuleFeedback(ruleFeedback);
      const json: string = '{"method": "recommendationDisable", "extra":{"ruleId": "recommend_6", "facts": {"state_time_6": "true", "state_location_6": "true"}}}';
      let response: string = await modeEnableService.onCall(json);
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });

    it('recommend_disable_call_test_utils_mock_not_open', 0, async (done: Function) => {
      let modeEnableService: RecommendationService = new RecommendationService();
      StateManager.getInstance().stopScene('1', FactorType.USER);
      const ruleFeedback: RuleFeedBack = {
        ruleId: 'recommend_1',
        modeId: '1',
        createTime: 1744065666758,
        timeRange: '',
        longitude: '30.494743816170036',
        latitude: '114.53363273469294',
      }
      await RuleFeedbackManager.getInstance().insertRuleFeedback(ruleFeedback);
      const json: string = '{"method": "recommendationDisable", "extra":{"ruleId": "recommend_1", "facts": {"state_time_1": "true", "state_location_1": "true"}}}';
      let response: string = await modeEnableService.onCall(json);
      expect(response).assertEqual(Response.SUCCESS);
      done();
    });
  });
}