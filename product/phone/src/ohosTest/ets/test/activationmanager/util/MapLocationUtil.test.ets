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

import { site } from '@kit.MapKit';
import {
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit, when, ArgumentMatchers
} from '@ohos/hypium';
import { geoLocationManager as location } from '@kit.LocationKit';
import { MapLocationUtil } from '@ohos/scene.activationmanage/src/main/ets/util/MapLocationUtil';

let mocker: MockKit = new MockKit();
let mockFunc: Function = mocker.mockFunc(MapLocationUtil, MapLocationUtil.wgs84ToGcj02);

export default function MapLocationUtilTest() {
  describe('MapLocationUtilTest', () => {
    beforeEach(() => {
    });

    afterEach(() => {
    });

    it('map_query', 0, async (done: Function) => {
      let param: site.QueryAutoCompleteParams = {
        query: '武汉',
        location: {
          longitude: 114.5333672239858,
          latitude: 30.494691726146126
        }
      };
      let result = await MapLocationUtil.query(param);
      expect(result).not().assertNull();

      param = {query: ''};
      result = await MapLocationUtil.query(param);
      expect(result).assertUndefined();
      done();
    });

    it('map_new_address', 0, async (done: Function) => {
      const DEFAULT_LATITUDE = 30.494743816170036;
      const DEFAULT_LONGITUDE = 114.53363273469294;
      let param: site.ReverseGeocodeParams = {
        location: {
          latitude: DEFAULT_LATITUDE,
          longitude: DEFAULT_LONGITUDE
        },
        language: 'zh_CN',
        radius: 200
      };
      await MapLocationUtil.getCurrentLocation();
      let result = await MapLocationUtil.nearAddress(param);
      expect(result).not().assertNull();
      done();
    });

    it('get_current_location_test', 0, async (done: Function) => {
      const DEFAULT_LATITUDE = 30.494743816170036;
      const DEFAULT_LONGITUDE = 114.53363273469294;
      when(mockFunc)(ArgumentMatchers.any).afterThrow(undefined);
      let location: location.Location | undefined = await MapLocationUtil.getCurrentLocation();
      expect(location).assertUndefined();

      when(mockFunc)(ArgumentMatchers.any).afterReturn({
        latitude: DEFAULT_LATITUDE, longitude: DEFAULT_LONGITUDE} as location.Location);
      location = await MapLocationUtil.getCurrentLocation();
      expect(location).not().assertNull();
      mocker.ignoreMock(MapLocationUtil, MapLocationUtil.wgs84ToGcj02);
      done();
    });

    it('map_wgs84ToGcj02', 0, async (done: Function) => {
      expect(MapLocationUtil.gcj02ToWgs84(114.5333672239858, 30.494691726146126).length).assertLarger(1);
      expect(MapLocationUtil.gcj02ToWgs84(114.5333672239858, 138.00001).length).assertLarger(1);
      expect(MapLocationUtil.gcj02ToWgs84(30.494691726146126, 73.004).length).assertLarger(1);
      expect(MapLocationUtil.gcj02ToWgs84(0.7293, 73.004).length).assertLarger(1);
      expect(MapLocationUtil.gcj02ToWgs84(56.8271, 73.004).length).assertLarger(1);
      done();
    });
  });
}