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

import lazy { map, mapCommon, site } from '@kit.MapKit';
import lazy { geoLocationManager as location } from '@kit.LocationKit';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';

const TAG = 'MapLocationUtil';

const MAX_ACCURACY = 100;

const PI = Math.PI;

const SEMI_MAJOR_AXIS = 6378245.0;

const OBLATENESS = 0.00669342162296594323;

/**
 * 地图工具类
 */
export class MapLocationUtil {
  static async query(param: site.QueryAutoCompleteParams): Promise<site.QueryAutoCompleteResult | undefined> {
    let res: site.QueryAutoCompleteResult | undefined = undefined;
    try {
      LogUtil.showInfo(TAG, 'start to queryAutoComplete.');
      res = await site.queryAutoComplete(param);
      LogUtil.showInfo(TAG, 'success to queryAutoComplete.');
    } catch (error) {
      LogUtil.showError(TAG, `fail to queryAutoComplete. error: ${error?.code} ${error?.message}`);
      res = undefined;
    }
    return res;
  }

  static async nearAddress(param: site.ReverseGeocodeParams): Promise<site.ReverseGeocodeResult | undefined> {
    let res: site.ReverseGeocodeResult | undefined = undefined;
    try {
      LogUtil.showInfo(TAG, 'start to reverseGeocode.');
      res = await site.reverseGeocode(param);
      LogUtil.showInfo(TAG, 'success to reverseGeocode');
    } catch (error) {
      LogUtil.showError(TAG, `fail to reverseGeocode. error: ${error?.code} ${error?.message}`);
    }
    return res;
  }

  static async getCurrentLocation(): Promise<location.Location | undefined> {
    let requestInfo: location.CurrentLocationRequest = {
      'priority': location.LocationRequestPriority.FIRST_FIX,
      'scenario': location.LocationRequestScenario.DAILY_LIFE_SERVICE,
      'maxAccuracy': MAX_ACCURACY
    };
    try {
      LogUtil.showInfo(TAG, 'start to getCurrentLocation.');
      let locationInfo: location.Location = await location.getCurrentLocation(requestInfo);
      let gcj02LocationInfo: number[] = MapLocationUtil.wgs84ToGcj02(locationInfo.latitude, locationInfo.longitude);
      if (gcj02LocationInfo.length > 1) {
        locationInfo.longitude = gcj02LocationInfo[0];
        locationInfo.latitude = gcj02LocationInfo[1];
      }
      LogUtil.showInfo(TAG, 'success to getCurrentLocation.');
      return locationInfo;
    } catch (err) {
      LogUtil.showError(TAG, `fail to getLocation. error: ${err?.code} ${err?.message}`);
    }
    return undefined;
  }

  static wgs84ToGcj02(latitude: number, longitude: number): number[] {
    let wgs84Position: mapCommon.LatLng = {
      latitude: latitude,
      longitude: longitude
    };
    let gcj02Position: mapCommon.LatLng =
      map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
    return [gcj02Position.longitude, gcj02Position.latitude];
  }

  static gcj02ToWgs84(lat: number, lng: number): number[] {
    if (MapLocationUtil.isOutOfChina(lng, lat)) {
      return [lng, lat];
    }
    let dlat = MapLocationUtil.transformLat(lng - 105.0, lat - 35.0);
    let dlng = MapLocationUtil.transformLng(lng - 105.0, lat - 35.0);
    let radlat = lat / 180.0 * PI;
    let magic = Math.sin(radlat);
    magic = 1 - OBLATENESS * magic * magic;
    let sqrtmagic = Math.sqrt(magic);
    dlat = (dlat * 180.0) / ((SEMI_MAJOR_AXIS * (1 - OBLATENESS)) / (magic * sqrtmagic) * PI);
    dlng = (dlng * 180.0) / (SEMI_MAJOR_AXIS / sqrtmagic * Math.cos(radlat) * PI);
    let mglat = lat + dlat;
    let mglng = lng + dlng;
    return [lng * 2 - mglng, lat * 2 - mglat];
  }

  private static isOutOfChina(lng: number, lat: number): boolean {
    if (lng < 72.004 || lng > 137.8347) {
      return true;
    }
    if (lat < 0.8293 || lat > 55.8271) {
      return true;
    }
    return false;
  }

  private static transformLat(lng: number, lat: number): number {
    let ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * Math.sqrt(Math.abs(lng));
    ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(lat * PI) + 40.0 * Math.sin(lat / 3.0 * PI)) * 2.0 / 3.0;
    ret += (160.0 * Math.sin(lat / 12.0 * PI) + 320 * Math.sin(lat * PI / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  private static transformLng(lng: number, lat: number): number {
    let ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * Math.sqrt(Math.abs(lng));
    ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(lng * PI) + 40.0 * Math.sin(lng / 3.0 * PI)) * 2.0 / 3.0;
    ret += (150.0 * Math.sin(lng / 12.0 * PI) + 300.0 * Math.sin(lng / 30.0 * PI)) * 2.0 / 3.0;
    return ret;
  }
}