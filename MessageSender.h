//
//  MessageCenter.h
//  iSpace
//
//  Created by CC on 14-5-19.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendInfoModel.h"


@class SendMessageRequest;


typedef void (^SucceededFunction)(SendMessageRequest *request);
typedef void (^FailedFunction)();


@interface MessageSender : NSObject
{
    SendMessageRequest *_currentRequest;
}

+ (MessageSender *)defaultInstance;

- (void)sendMessage:(NSString *)fileName
           fileType:(NSString *)fileType
           fileData:(NSData *)soundData
       fileDuration:(NSString *)fileDuration
           toDevice:(NSString *)deviceSerial
        aboutFriend:(FriendInfoModel *)frined
            ifTimer:(BOOL)isTimer
             andUTS:(NSString *)uts
withSucceededNotify:(SucceededFunction)succeeded
   withFailedNotify:(FailedFunction)failed;

@end



// 发送语音请求
@interface SendMessageRequest : NSObject

@property (copy, nonatomic) NSString *deviceSerial;
@property (copy, nonatomic) NSString *fileId;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *fileType;
@property (copy, nonatomic) NSString *fileDuration;
@property (copy, nonatomic) NSString *fileUrl;
@property (copy, nonatomic) NSData *data;
@property (copy, nonatomic) NSNumber *timestamp;
@property (strong, nonatomic) FriendInfoModel *toUser;
@property (assign, nonatomic) BOOL isTimer;     // 是否定时
@property (copy, nonatomic) NSString *uts;

@property (copy, nonatomic) SucceededFunction succeededBlock;
@property (copy, nonatomic) FailedFunction failedBlock;

@end