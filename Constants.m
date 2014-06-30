//
//  Constants.m
//  nlbs
//
//  Created by xiabing on 13-1-31.
//
//

#import "Constants.h"


NSString * const NM_REGISTER_APNS_RESULT = @"Notify_Resister_APNS_Result";          // 注册推送通知结果
NSString * const NM_APNS_MESSAGE = @"Notify_Received_APNS_Message";                 // 接收到推送通知消息

NSString * const NM_USER_LOGIN_SUCCEEDED = @"Notify_User_Login_Succeeded";          // 用户已成功登录
NSString * const NM_USER_LOGOUT = @"Notify_User_Logout";                            // 用户已登出


NSString * const NM_SERVER_PUSH_MSG_2065 = @"Notify_Server_Push_Msg_2065";          // 权限变更通知
NSString * const NM_SERVER_PUSH_MSG_2073 = @"Notify_Server_Push_Msg_2073";          // 好友变更消息
NSString * const NM_SERVER_PUSH_MSG_2083 = @"Notify_Server_Push_Msg_2083";          // 服务器推送消息
NSString * const NM_SERVER_PUSH_MSG_0 = @"Notify_Server_Push_Msg_0";                // 下发语音通知
NSString * const NM_SERVER_PUSH_MSG_1 = @"Notify_Server_Push_Msg_1";                // 请求加交友通知
NSString * const NM_SERVER_PUSH_MSG_2 = @"Notify_Server_Push_Msg_2";                // 闹铃响铃通知
NSString * const NM_SERVER_PUSH_MSG_3 = @"Notify_Server_Push_Msg_3";                // 版本升级通知
NSString * const NM_SERVER_PUSH_MSG_4 = @"Notify_Server_Push_Msg_4";                // 设备掉线
NSString * const NM_SERVER_PUSH_MSG_5 = @"Notify_Server_Push_Msg_5";                // 修改设备名称
NSString * const NM_SERVER_PUSH_MSG_6 = @"Notify_Server_Push_Msg_6";                // 设备端绑定用户
NSString * const NM_SERVER_PUSH_MSG_7 = @"Notify_Server_Push_Msg_7";                // 闹钟被设置
NSString * const NM_SERVER_PUSH_MSG_8 = @"Notify_Server_Push_Msg_8";                // 用户在其他地方登录
NSString * const NM_SERVER_PUSH_MSG_9 = @"Notify_Server_Push_Msg_9";                // 设备网速测试结果通知
NSString * const NM_SERVER_PUSH_MSG_101 = @"Notify_Server_Push_Msg_101";            // 广播通知



NSString * const NM_DEVICE_BANDING_CHANGED = @"Notify_Device_Banding_Changed";      // 设备绑定用户状态变更
NSString * const NM_DEVICE_INFO_CHANGED = @"Notify_Device_Info_Changed";            // 设备名称变更
NSString * const NM_DEVICE_REMOVED = @"Notify_Device_Removed";                      // 设备被解除绑定
NSString * const NM_DEVICE_MESSAGE_CHANGED = @"Notify_Device_Message_Changed";      // 设备消息数量变更

NSString * const NM_START_USE = @"Notify_Start_Use";                       // 开始使用


NSInteger const MAX_SECONDS_OF_RECORD = 20;                 // 最大录音时间(秒)

/////////////////////////////////////////////////////////莫景涛code/////////////////////////////////////////////////////////

NSString *const REMORESTARIMG = @"removeStarImg" ;               // 删除启动画面通知
NSString *const STOP_ALERM_NOTE = @"stopAlermNote"  ;            // 停用闹钟通知（从闹钟设置界面发送到主页界面）
NSString *const FEEKBACK_STOP_ALERM_ISSUCCESS  = @"feekbackStopAlermIsSuccess";              // 主页界面反馈给闹钟设置界面
NSString *const SETTING_ISSUCCESS = @"settingIsSuccess"  ;                                    //设置闹钟是否成功
