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

import lazy { common } from '@kit.AbilityKit';
import lazy { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { AbilityContextManager } from '@ohos/scene.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { DATASHARE_CALENDAR_WHOLE_ADDRESS } from '../constant/DatabaseConfigConstant';
import { Course, CourseInstance, CourseTime } from '../model/ClassSchedule';

export interface Schedule {
  uid: string;
  name: string;
  courseCount: number;
}

const TAG: string = 'CalendarDBManager: ';
const URI: string = DATASHARE_CALENDAR_WHOLE_ADDRESS;

/* instrument ignore file */
export class CalendarDBManager {
  protected static instance: CalendarDBManager;

  private constructor() {
  }

  public static getInstance(): CalendarDBManager {
    if (!CalendarDBManager.instance) {
      CalendarDBManager.instance = new CalendarDBManager();
    }
    return CalendarDBManager.instance;
  }

  async queryAllSchedules(uid?: string): Promise<Schedule[]> {
    let scheduleList: Schedule[] = [];
    let context = AbilityContextManager.getContext() as Context;
    let resultSetSchedule: DataShareResultSet | undefined = undefined;
    let scheduleURI: string = URI + 'Schedule';
    let dataShareHelper: dataShare.DataShareHelper | undefined = undefined;
    try {
      dataShareHelper = await dataShare.createDataShareHelper(context, URI, { isProxy: false });
      const scheduleCond: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      if (uid !== undefined) {
        scheduleCond.equalTo('uuid', uid);
      }
      const columnsSchedule: string[] = ['_id', 'uuid', 'name'];
      resultSetSchedule = await dataShareHelper.query(scheduleURI, scheduleCond, columnsSchedule);
      for (let index = 0; index < resultSetSchedule.rowCount; index++) {
        resultSetSchedule.goToRow(index);
        scheduleList.push({
          uid: resultSetSchedule.getString(resultSetSchedule.getColumnIndex('uuid')),
          name: resultSetSchedule.getString(resultSetSchedule.getColumnIndex('name')),
          courseCount: 0
        });
      }
    } catch (error) {
      LogUtil.showError(TAG, `queryAllSchedules error:${error?.code}, msg: ${error?.message}`);
    } finally {
      resultSetSchedule?.close();
      dataShareHelper?.close();
    }
    return scheduleList;
  }

  async queryCourse(scheduleUUID?: string, courseUUID?: string | string[]): Promise<Course[]> {
    let courseList: Course[] = [];
    let context = AbilityContextManager.getContext() as common.UIExtensionContext;
    let courseURI: string = URI + 'Course';
    let resultSetCourse: DataShareResultSet | undefined = undefined;
    let dataShareHelper: dataShare.DataShareHelper | undefined;
    try {
      dataShareHelper = await dataShare.createDataShareHelper(context, courseURI, { isProxy: false });
      let courseCond: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      if (scheduleUUID !== undefined) {
        courseCond.equalTo('schedule_uuid', scheduleUUID);
      }
      if (courseUUID !== undefined) {
        if (Array.isArray(courseUUID)) {
          courseCond.in('uuid', courseUUID);
        } else {
          courseCond.equalTo('uuid', courseUUID);
        }
      }
      const columnsCourse: string[] = ['uuid', 'schedule_uuid', 'name', 'color', 'description'];
      resultSetCourse = await dataShareHelper.query(courseURI, courseCond, columnsCourse);
      while(resultSetCourse.goToNextRow()){
        courseList.push({
          uid: resultSetCourse.getString(resultSetCourse.getColumnIndex('uuid')),
          name: resultSetCourse.getString(resultSetCourse.getColumnIndex('name')),
          color: resultSetCourse.getString(resultSetCourse.getColumnIndex('color')),
          desc: resultSetCourse.getString(resultSetCourse.getColumnIndex('description')),
          scheduleUid: resultSetCourse.getString(resultSetCourse.getColumnIndex('schedule_uuid')),
        });
      }
    } catch (error) {
      LogUtil.showError(TAG, `queryCourse error:${error?.code}, msg: ${error?.message}`);
    } finally {
      dataShareHelper?.close();
      resultSetCourse?.close();
    }
    return courseList;
  }

  async queryCourseInstance(courseUUIDs?: string[]): Promise<CourseInstance[]> {
    let instanceList: CourseInstance[] = [];
    let context = AbilityContextManager.getContext() as Context;
    let courseInstanceURI: string = `${URI}CourseInstance`;
    let resultSetCI: DataShareResultSet | undefined = undefined;
    let dataShareHelper: dataShare.DataShareHelper | undefined;
    try {
      dataShareHelper = await dataShare.createDataShareHelper(context, courseInstanceURI, { isProxy: false });
      const curTime: number = Math.floor(Date.now());
      const condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      if (courseUUIDs) {
        condition.in('course_uuid', courseUUIDs);
      }
      condition.greaterThan('end_time', curTime).orderByAsc('start_time').limit(5, 0);
      const columns: string[] = ['uuid', 'course_uuid', 'start_time', 'end_time'];
      resultSetCI = await dataShareHelper.query(courseInstanceURI, condition, columns);
      for (let index = 0; index < resultSetCI.rowCount; index++) {
        resultSetCI.goToRow(index);
        instanceList.push({
          uid: resultSetCI.getString(resultSetCI.getColumnIndex('uuid')),
          courseUid: resultSetCI.getString(resultSetCI.getColumnIndex('course_uuid')),
          startTime: resultSetCI.getLong(resultSetCI.getColumnIndex('start_time')).toString(),
          endTime: resultSetCI.getLong(resultSetCI.getColumnIndex('end_time')).toString(),
        });
      }
    } catch (error) {
      LogUtil.showError(TAG, `queryCourseInstance error:${error?.code}, msg: ${error?.message}`);
    } finally {
      dataShareHelper?.close();
      resultSetCI?.close();
    }
    LogUtil.showInfo(TAG, `instanceList length: ${instanceList.length}`);
    return instanceList;
  }

  async queryCourseTime(courseUUID?: string | string[]): Promise<CourseTime[]> {
    let courseTimeList: CourseTime[] = [];
    let context = AbilityContextManager.getContext() as common.UIExtensionContext;
    let courseInstanceURI: string = `${URI}CourseTime`;
    let resultSetCT: DataShareResultSet | undefined = undefined;
    let dataShareHelper: dataShare.DataShareHelper | undefined = undefined;
    try {
      dataShareHelper = await dataShare.createDataShareHelper(context, courseInstanceURI, { isProxy: false });
      const condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      if (courseUUID !== undefined) {
        if (Array.isArray(courseUUID)) {
          condition.in('course_uuid', courseUUID);
        } else {
          condition.equalTo('course_uuid', courseUUID);
        }
      }
      const columns: string[] = ['uuid', 'course_uuid', 'teacher', 'location'];
      resultSetCT = await dataShareHelper.query(courseInstanceURI, condition, columns);
      for (let index = 0; index < resultSetCT.rowCount; index++) {
        resultSetCT.goToRow(index);
        courseTimeList.push({
          uid: resultSetCT.getString(resultSetCT.getColumnIndex('uuid')),
          courseUid: resultSetCT.getString(resultSetCT.getColumnIndex('course_uuid')),
          teacher: resultSetCT.getString(resultSetCT.getColumnIndex('teacher')),
          location: resultSetCT.getString(resultSetCT.getColumnIndex('location')),
        });
      }
    } catch (error) {
      LogUtil.showError(TAG, `queryCourseTime error:${error?.code}, msg: ${error?.message}`);
    } finally {
      dataShareHelper?.close();
      resultSetCT?.close();
    }
    return courseTimeList;
  }

  async queryAllScheduleWithCourseCount(): Promise<Schedule[]> {
    let scheduleList: Schedule[] = await this.queryAllSchedules();
    let courseList: Course[] = await this.queryCourse();
    for (let index = 0; index < scheduleList.length; index++) {
      const scheduleUUId = scheduleList[index].uid;
      const scheduleCourses = courseList.filter(course => course.scheduleUid === scheduleUUId)
      scheduleList[index].courseCount = scheduleCourses.length;
    }
    return scheduleList;
  }
}