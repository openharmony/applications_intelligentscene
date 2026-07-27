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

import { AppData } from './AppData';

/**
 * 允许打扰应用和元服务数据类
 */
export interface AllowAppData {
  selectedAppList: AppData[];
}

/**
 * 声音和振动白名单数据类
 */
export interface SoundWhiteListData {
  bundle: string;
  appIndex: number;
  uid: number;
}

export enum NotifyPolicy {
  ALLOW_NOTIFY = 1,
  FORBID_NOTIFY = 2
}