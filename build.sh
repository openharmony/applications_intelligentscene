#!/bin/bash
#
# Copyright (c) 2026 Huawei Device Co., Ltd. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -ex

echo "old NODE_HOME is ${NODE_HOME}"

if [ "$1" == "clean" ];then
   echo "do nothing"
   exit 0
else
   DT_TASK_FLAG=$2
   echo "DT_TASK_FLAG is ${DT_TASK_FLAG}"
fi

# NODE_HOME的环境变量多配置了一个bin目录, 在这里去除掉
[[ "${NODE_HOME}" =~ .*\bin$ ]] && NODE_HOME=${NODE_HOME%\bin*}
echo "new NODE_HOME is ${NODE_HOME}"
echo "HM_SDK_HOME is ${HM_SDK_HOME}"
echo "HOS_SDK_HOME is ${HOS_SDK_HOME}"
echo "OHOS_SDK_HOME is ${OHOS_SDK_HOME}"
node -v
npm -v

# 任务名赋值
compile_task=$1
echo "compile_task=>$1"

# 初始化相关路径
PROJECT_PATH="$(pwd -P)"
TOOLS_INSTALL_DIR=${PROJECT_PATH}

# 获得签名jar文件
cd ${PROJECT_PATH}/hw_sign
chmod +x build.sh
./build.sh


# Setup npm
#npm config set registry
npm config set registry
npm config set @ohos:registry
npm config set strict-ssl false

# 进入package目录安装依赖
function ohpm_install() {
    cd $1
    ohpm -v
    ohpm install
}

function replace_sdk_files() {
  echo "replace sdk files start ====================="
  cd ${PROJECT_PATH}/
  cp -r ${PROJECT_PATH}/sdk/hms/* ${HOS_SDK_HOME}/default/hms
  cp -r ${PROJECT_PATH}/sdk/openharmony/* ${HOS_SDK_HOME}/default/openharmony
  echo "replace sdk files end ====================="
}

# 构建任务
function build() {
    # 根据业务情况适配local.properties
    cd ${PROJECT_PATH}
    echo "sdk.dir=${HM_SDK_HOME}"  > ./local.properties
    echo "nodejs.dir=${NODE_HOME}" >> ./local.properties

    # cd ${PROJECT_PATH}/sdk_ext
    # chmod +x copy_files.sh
    # ./copy_files.sh

    # 根据业务情况安装ohpm三方库依赖
    ohpm_install "$PROJECT_PATH"
    ohpm_install "$PROJECT_PATH/common"
    ohpm_install "$PROJECT_PATH/feature/activationmanage"
    ohpm_install "$PROJECT_PATH/feature/backup"
    ohpm_install "$PROJECT_PATH/feature/configlinkage"
    ohpm_install "$PROJECT_PATH/feature/configmanage"
    ohpm_install "$PROJECT_PATH/feature/datamanage"
    ohpm_install "$PROJECT_PATH/feature/datasync"
    ohpm_install "$PROJECT_PATH/feature/notdisturb"
    ohpm_install "$PROJECT_PATH/feature/statemanage"
    ohpm_install "$PROJECT_PATH/feature/form"
    ohpm_install "$PROJECT_PATH/product/phone"
    cat ${HOME}/.npmrc | grep 'lockfile=false' || echo 'lockfile=false' >> ${HOME}/.npmrc

    # 根据业务情况，采用对应的构建命令，可以参考IDE构建日志中的命令
    cd ${PROJECT_PATH}
    hvigorw clean --no-daemon

    if [ "${DT_TASK_FLAG}" == "dt_task" ];then
        replace_sdk_files

        mkdir -p build/outputs/IntelligentScene/source/product/phone
        cp -r ${PROJECT_PATH}/product/phone/src build/outputs/IntelligentScene/source/product/phone

        hvigorw --mode module -p module=phone -p debuggable=false -p ohos-test-coverage=true -p build_mode=release assembleHap --parallel --incremental --no-daemon
        hvigorw --mode module -p module=phone@ohosTest -p isOhosTest=true -p build_mode=release -p ohos-test-coverage=true assembleHap packageTesting --analyze=normal --parallel --incremental --no-daemon

        echo "-----------------handle DTPipeline.zip--------------------"
        	has_package_dt_pipeline=0
        	if [ -e "build/DTPipeline.zip" ];then
        	  file_size=$(stat -c%s "build/DTPipeline.zip")
        	  if [ $file_size -gt 0 ]; then
        	    echo "DTPipeline.zip is normal"
        	  else
        	    has_package_dt_pipeline=1
        	    rm -rf build/DTPipeline.zip
        	    echo "DTPipeline.zip size is 0"
        	  fi
        	else
        	  has_package_dt_pipeline=1
        	  echo "build/DTPipeline.zip is not exist"
        	fi
        	if [ $has_package_dt_pipeline -eq 1 ];then
        	  pushd build/outputs
        	  if [ $? -ne 0 ];then
        	         echo "build/outputs is not exist"
        	         exit 1
        	  fi
        	  zip -r ../DTPipeline.zip ./*
        	  popd
        	fi
        echo "After assembleHap packageTesting!"
    fi
    replace_sdk_files
    hvigorw --mode module -p debuggable=false -p build_mode=release assembleHap --no-daemon
    cd ${PROJECT_PATH}
    # 新的流水线2.0不能直接生成归档文件名称（应用名.hap）,使用重命名命令修改名称
    cp product/phone/build/default/outputs/default/phone-default-signed.hap product/phone/build/default/outputs/default/IntelligentScene.hap
    cp product/phone/build/default/outputs/lite/phone-lite-signed.hap product/phone/build/default/outputs/lite/IntelligentScene.hap
}

function main() {
  local start_time=$(date '+%s')
  build
  local end_time=$(date '+%s')
  local elapsed_time=$(expr $end_time - $start_time)
  echo "build success in ${elapsed_time}s..."
}

main