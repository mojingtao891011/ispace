//
//  MessageManager.m
//  iSpace
//
//  Created by CC on 14-6-3.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "MessageManager.h"
#import "Constants.h"
#import "Tools.h"
#import "CoreDataManager.h"
#import "MessageReceiver.h"
#import "NSDictionary+Additions.h"
#import "EventEntity.h"


static MessageManager *_defaultInstance = nil;


@interface MessageManager ()

@property (nonatomic, retain) NSArray *notifyNames;

@end


@implementation MessageManager

+ (MessageManager *)defaultInstance
{
	@synchronized(self)
	{
		if (_defaultInstance == nil)
		{
			_defaultInstance = [[MessageManager alloc] init];
            [_defaultInstance initMessageManager];
		}
	}
	return _defaultInstance;
}


// 初始化
- (void)initMessageManager
{
    _messageReaderState = kMessageReaderStateClosed;          // 消息阅读器状态,默认关闭
    _deviceUnreadMessageCounter = [[NSMutableDictionary alloc] init];   // 设备未读消息
}


// 启动
- (void)start
{
    self.notifyNames = [NSArray arrayWithObjects:NM_SERVER_PUSH_MSG_0,
                        NM_SERVER_PUSH_MSG_1,
                        NM_SERVER_PUSH_MSG_2,
                        NM_SERVER_PUSH_MSG_3,
                        NM_SERVER_PUSH_MSG_4,
                        NM_SERVER_PUSH_MSG_5,
                        NM_SERVER_PUSH_MSG_6,
                        NM_SERVER_PUSH_MSG_7,
                        NM_SERVER_PUSH_MSG_8,
                        NM_SERVER_PUSH_MSG_9,
                        nil];

    // 监听推送消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleServerPushNotify:)
                                                 name:NM_SERVER_PUSH_MSG_2083
                                               object:nil];
    
    // 启动接收器
    [[MessageReceiver defaultInstance] start];
    
    NSLog(@"Message Manager Start");
}


// 停止
- (void)stop
{
    // 取消监听消息
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 停止接收器
    [[MessageReceiver defaultInstance] stop];
    
    NSLog(@"Message Manager Stop");
}


// 设置消息阅读器状态
- (void)setMessageReaderState:(NSInteger )state
{
    _messageReaderState = state;
}


// 返回消息阅读器状态
- (NSInteger)messageReaderState
{
    return _messageReaderState;
}


// 返回某个设备的未读消息数量
- (NSInteger)unreadMessageForDevice:(NSString *)deviceSerial
{
    NSInteger count = [_deviceUnreadMessageCounter getInteger:deviceSerial];
    return count;
}


// 递增未读消息数量
- (void)incrementUnreadMessageForDevice:(NSString *)deviceSerial
{
    NSInteger count = [self unreadMessageForDevice:deviceSerial];
    count ++;
    [_deviceUnreadMessageCounter setObject:[NSString stringWithFormat:@"%zd", count] forKey:deviceSerial];
}



// 复位某个设备的未读消息数量为0
- (void)resetUnreadMessageForDevice:(NSString *)deviceSerial
{
    [_deviceUnreadMessageCounter setObject:@"0" forKey:deviceSerial];
}


// APP是否有未读消息
- (BOOL)hasUnreadMessageForApp
{
    for (NSString *value in [_deviceUnreadMessageCounter allValues])
    {
        if ([value integerValue] > 0)
        {
            return TRUE;
        }
    }
    
    return FALSE;
}



// 处理服务器下发的消息
//    {
//        "message_head":
//        {
//            "command": "-2147481565",
//            "timestamp": "1401154816",
//            "sequence": "0",
//            "flag": "1",
//            "protocol": "1",
//            "user_id": "21"
//        },
//        "message_body":
//        {
//            "type": "0",
//            "date": "1401154816",
//            "arg1": "1890",
//            "arg2": "321321321321327",
//            "arg3": "0",
//            "arg4": "http:\/\/115.29.199.95:23000\/?cmd=3001&uid=-1&fid=1890&uts=1401154815&tpn=3",
//            "argx": ""
//        }
//    }
- (void)handleServerPushNotify:(NSNotification *)notification
{
    NSDictionary *msgDict = [notification userInfo];
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSInteger type = [msgBody getInteger:@"type"];
    switch (type)
    {
        case 0:             // 推送语音
        {
            [self handleChatMessage:msgDict];
            [self fireMessageChangedNotify];
        }
            break;
        case 2:             // 闹钟响铃通知
        {
            [self handleAlarmEvent:msgDict];
        }
            break;
        case 1:             // 推送交友通知
        case 3:             // 版本升级通知
        case 4:             // 设备掉线
        case 5:             // 修改设备名字
        case 6:             // 设备端绑定用户
        case 7:             // 闹钟被设置
        case 8:             // 用户被踢掉
        case 9:             // 测速通知
        {
            NSNotification *notification = [NSNotification notificationWithName:[self.notifyNames objectAtIndex:type]
                                                                         object:nil
                                                                       userInfo:msgDict];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
            break;
        case 100:           // 离线消息, 包括语音和交友信息
        {
            [self handleOfflineMessage:msgDict];
        }
            break;
        case 101:           // 广播消息
        {
            [self handleBroadcastMessage:msgDict];
        }
            break;
            
        default:
            break;
    }
    
}


// 处理服务器下发的语音
- (void)handleChatMessage:(NSDictionary *)msgDict
{
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSString *timestamp = [msgBody getString:@"date"];
    NSString *fileId = [msgBody getString:@"arg1"];
    NSString *deviceSerial = [msgBody getString:@"arg2"];
    NSString *duration = [msgBody getString:@"arg3"];
    NSString *url = [msgBody getString:@"arg4"];
    
    NSManagedObjectContext *context = [[CoreDataManager defaultInstance] managedObjectContext];
    NSString *entityName = kiSpaceCoreDataEntityName;
    
    EventEntity *eventInfo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    eventInfo.event_device = deviceSerial;
    eventInfo.event_user_id = USER_ID;
    eventInfo.event_type = [NSNumber numberWithInteger:kEventFromDevice];        // 来自设备的消息
    eventInfo.event_timestamp = [NSNumber numberWithInteger:[timestamp integerValue]];
    eventInfo.audio_file_id = fileId;
    eventInfo.audio_url = url;
    eventInfo.audio_duration = [NSString stringWithFormat:@"%zd", MAX([duration integerValue] / 1000, 1)];
    
    // Save the context.
    [[CoreDataManager defaultInstance] saveContext];
    
    // 记录未读消息数
    if ([self messageReaderState] == kMessageReaderStateClosed)
    {
        [self incrementUnreadMessageForDevice:deviceSerial];
        NSLog(@"离线消息条数:%zd", [self unreadMessageForDevice:deviceSerial]);
    }
}


// 处理服务器下发的闹铃响铃通知
//{
//    "message_body" =     {
//        arg1 = 1;
//        arg2 = 321321321321327;
//        arg3 = 0;
//        arg4 = "16:4";
//        argx = "";
//        date = 0;
//        type = 2;
//    };
//    "message_head" =     {
//        command = "-2147481565";
//        flag = 1;
//        protocol = 1;
//        sequence = 0;
//        timestamp = 1401869050;
//        "user_id" = 21;
//    };
//}
- (void)handleAlarmEvent:(NSDictionary *)msgDict
{
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSNumber *state = [msgBody getNumber:@"date"];                      // 闹钟状态
    NSNumber *index = [msgBody getNumber:@"arg1"];                      // 闹钟索引号
    NSString *deviceSerial = [msgBody getString:@"arg2"];               // 设备序列号
    NSString *result = [msgBody getString:@"arg3"];                     // 响铃结果
    NSString *alarmTime = [msgBody getString:@"arg4"];                  // 响钟时间
    
    NSDictionary *msgHead = [msgDict getDictionary:@"message_head"];
    NSNumber *timestamp = [msgHead getNumber:@"timestamp"];             // 消息时间戳
    
    // 只显示成功的闹铃事件
    if ([result integerValue] == 0 &&
        [alarmTime length] > 0)
    {
        NSManagedObjectContext *context = [[CoreDataManager defaultInstance] managedObjectContext];
        NSString *entityName = kiSpaceCoreDataEntityName;
        
        EventEntity *eventInfo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        eventInfo.event_device = deviceSerial;
        eventInfo.event_user_id = USER_ID;
        eventInfo.event_type = [NSNumber numberWithInteger:kEventFromSystem];        // 来自系统的消息
        eventInfo.event_timestamp = [NSNumber numberWithInteger:[timestamp integerValue]];
        eventInfo.alarm_index = index;
        eventInfo.alarm_state = state;
        eventInfo.alarm_timestamp = alarmTime;
        eventInfo.alarm_description = [NSString stringWithFormat:@"你好, 你设置的今天 %@ 闹钟已完成", alarmTime];
        
        // Save the context.
        [[CoreDataManager defaultInstance] saveContext];
    }
}


// 处理广播消息
- (void)handleBroadcastMessage:(NSDictionary *)msgDict
{
    NSNotification *notification = [NSNotification notificationWithName:NM_SERVER_PUSH_MSG_101
                                                                 object:nil
                                                               userInfo:msgDict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

}


// 处理离线消息
- (void)handleOfflineMessage:(NSDictionary *)msgDict
{
    BOOL isAudioMessageFound = FALSE;
    
    NSArray *array = [msgDict getArray:@"argx"];
    for (NSDictionary *dict in array)
    {
        NSDictionary *msgHead = [dict getDictionary:@"message_head"];
        NSInteger command = [msgHead getInteger:@"command"] & ~0x80000000;
        if (command == 2083)    // 推送消息
        {
            NSDictionary *msgBody = [dict getDictionary:@"message_body"];
            NSInteger type = [msgBody getInteger:@"type"];
            if (type == 0)      // 离线语音
            {
                [self handleChatMessage:dict];
                isAudioMessageFound = TRUE;
            }
            else if (type == 101)   // 离线广播
            {
                [self handleBroadcastMessage:dict];
            }
        }
        else if (command == 2073)   // 好友变更消息
        {
            NSNotification *notification = [NSNotification notificationWithName:NM_SERVER_PUSH_MSG_2073
                                                                         object:nil
                                                                       userInfo:dict];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    
    // 如果离线消息中有语音消息, 则发出通知
    if (isAudioMessageFound)
    {
        [self fireMessageChangedNotify];
    }
}


// 增加消息记数
- (void)fireMessageChangedNotify
{
    if ([self messageReaderState] == kMessageReaderStateClosed)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NM_DEVICE_MESSAGE_CHANGED object:nil];
    }
}

@end
