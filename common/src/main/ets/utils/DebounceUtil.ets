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

/* instrument ignore file */
const TAG: string = 'DebounceUtil: ';

export class DebounceUtil {

  public static sleep(delayTime: number): Promise<void> {
    return new Promise<void>((resolve) => setTimeout(resolve, delayTime));
  }

  /**
   * 防抖函数
   *
   * @param fn 方法
   * @param delay 延时时长
   * @returns 返回一个防抖函数
   */
  public static debounce<P extends Object[]>(fn: (...args: P) => void, delay: number): (...args: P) => void {
    let timerId: number | undefined;
    return (...args: P) => {
      if (timerId !== undefined) {
        clearTimeout(timerId);
        timerId = undefined;
      }
      timerId = setTimeout(() => {
        fn(...args);
      }, delay);
    };
  }

  /**
   * 函数promise防抖，同一周期内执行最后一次
   *
   * @param fn
   * @param thisArg
   */
  public static debouncePromise<P extends Object[]>(fn: (...args: P) => void): (...args: P) => Promise<void> {
    let promise: Promise<void> | undefined;

    return async (...args: P): Promise<void> => {
      if (promise) {
        return promise;
      }
      promise = Promise.resolve().then(() => fn(...args)).finally(() => {
        promise = undefined;
      });
      return promise;
    };
  }
}