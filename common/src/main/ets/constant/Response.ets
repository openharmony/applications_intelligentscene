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

export class Response {
  public static readonly SUCCESS: string = 'success';

  public static readonly FAIL: string = 'fail';

  public static readonly INVALID_METHOD: string = 'invalid method';

  public static readonly UNKNOWN_METHOD: string = 'unknown method';

  public static readonly FAULT_MODE_ID: string = 'fault modeid';

  public static readonly FAULT_PARAM: string = 'fault param';
}