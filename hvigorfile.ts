// // 系统插件
// import { appTasks } from '@ohos/hvigor-ohos-plugin';
// // 1. 导入在线签名插件
// import { onlineSignPlugin } from '@ohos/hvigor-ohos-online-sign-plugin';
// import type { OnlineSignOptions } from '@ohos/hvigor-ohos-online-sign-plugin';
// import { hvigor, getHvigorNode} from '@ohos/hvigor';
// import { uploadTestCases } from '@ohos/hypium-plugin';
//
// // 2. 配置签名参数 keyAlias证书名称
// const signOptions: OnlineSignOptions = {
//     profile: 'hw_sign/IntelligentSceneRelease.p7b',
//     keyAlias: 'IntelligentScene',
//     hapSignToolFile: `${process.env.HAP_SIGN_TOOL ?? 'hw_sign/hap-sign-tool.jar'}`,
//     username: `${process.env.ONLINE_USERNAME}`,
//     password: `${process.env.ONLINE_PASSWD}`,
//     enableOnlineSign: true
// }
//
// // hvigorfile 导出范式
// export default {
//     system: appTasks,
//     plugins:[
//     // 3. 应用插件
//         onlineSignPlugin(signOptions)
//     ]
// }
//
// const config = {
//     hvigor: hvigor,
//     hvigorNode: getHvigorNode(__filename),
//     templateEngName: 'IntelligentSceneTask',
//     modulesConfig: [
//       {
//         moduleName: 'phone',
//         appName: 'IntelligentScene'
//       }
//     ]
// };
// uploadTestCases(config);

module.exports = require('@ohos/hvigor-ohos-plugin').appTasks;