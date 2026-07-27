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

export default interface IService {

  /**
   * 调用SCB情景模式接口
   *
   * @param requestCode 接口请求码
   * @param methodName 方法名称
   * @param extra 扩展信息
   * @param callback 接口回调
   */
  getICallback(requestCode: number, methodName: string, extra: string, callback: ICallback): void;
}

export type ICallback = (errCode: number, returnValue: string[]) => void;
export type SceneBoardDeathRecipientCallback = () => void;
export const REQUEST_CODE: number = 1;