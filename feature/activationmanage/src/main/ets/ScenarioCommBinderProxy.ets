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

import util from '@ohos.util';
import rpc from '@ohos.rpc';
import { LogUtil } from '@ohos/scene.common/src/main/ets/utils/LogUtil';
import { CommCallbackStub } from './CommCallbackStub';
import { CommCallback } from './CommCallback';
import { ScenarioCommBinder } from './ScenarioCommBinder';

const TAG = 'ScenarioCommBinderProxy';
const RPC_CODE = 100;

/**
 * 通用binder客户端实现，集成在客户端
 *
 * @since 2024/12/30
 */
export class ScenarioCommBinderProxy implements ScenarioCommBinder {
  private static readonly RPC_SEND_STRING_MAXSIZE = 1024 * 35;
  private proxy: rpc.IRemoteObject;
  private mTextEncoder: util.TextEncoder;

  constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
    this.mTextEncoder = new util.TextEncoder();
  }

  /**
   * 注意如果想要回调生效，这里的callback类型，一定要集成stub！！
   * @param params 传递的参数
   * @param callback 传递的回调
   */
  onScenarioCmd(params: string, callback?: CommCallback) {
    LogUtil.showInfo(TAG, 'start onScenarioCmd.');
    if (!this.proxy) {
      LogUtil.showError(TAG, 'Proxy is null');
      return;
    }
    let _option = new rpc.MessageOption();
    let _data = rpc.MessageSequence.create();
    let _reply = rpc.MessageSequence.create();
    try {
      _data.writeInterfaceToken(this.proxy.getDescriptor());
      if (params) {
        this.writeStringData(_data, params);
      } else {
        // 为了保证消息统一解析, 此处需要填空字串, 接收端不会使用该字段
        _data.writeString('');
      }
      if (callback && callback instanceof CommCallbackStub) {
        // 异步消息
        _option.setAsync(true);
        _data.writeRemoteObject(callback as CommCallbackStub);
      } else {
        // 同步消息，不会再传回调
        _option.setAsync(false);
      }
      this.proxy.sendMessageRequest(RPC_CODE, _data, _reply, _option)
        .then(() => {
          LogUtil.showInfo(TAG, 'binder write remote success');
        })
        .catch(() => {
          LogUtil.showError(TAG, 'binder write remote exception occured');
        })
        .finally(() => {
          _data.reclaim();
          _reply.reclaim();
        });
    } catch (error) {
      LogUtil.showError(TAG, `onScenarioCmd occurs error: ${error?.code}, ${error?.message}`);
    }
  };

  private writeStringData(sequence: rpc.MessageSequence, data: string): void {
    let needSendRawData = data.length >= ScenarioCommBinderProxy.RPC_SEND_STRING_MAXSIZE;
    sequence.writeBoolean(needSendRawData); // 判断是否为rawdata传输
    if (needSendRawData) {
      let bytes: number[] = this.stringToBytes(data);
      if (bytes !== undefined && bytes !== null) {
        sequence.writeInt(bytes.length); // rawdata的size
        sequence.writeRawData(bytes, bytes.length);
      }
    } else {
      sequence.writeString(data);
    }
  }

  private stringToBytes(str: string): Array<number> {
    let data: Uint8Array = this.mTextEncoder.encodeInto(str);
    return Array.from(data);
  }
}