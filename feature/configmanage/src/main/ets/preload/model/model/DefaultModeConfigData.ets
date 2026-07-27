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

export class ModeDetailConfig {
  public configId: string = '';
  public configType: number = 0;
  public configValue: string = '';
}

export class ModeConfigData {
  public modeId: string = '-1';
  public modeName: string = '';
  public iconId: string = '';
  public iconColor: string = '';
  public filletIcon: string = '';
  public roundIcon: string = '';
  public isSupportDelete: boolean = false;
  public modePriority: number = -1;
  public configs: Array<ModeDetailConfig> = [];
}

/**
 * 本地模式模板JSON数据实体类
 */
export class DefaultModeConfigData {
  public modeDataList: Array<ModeConfigData> = [];
}