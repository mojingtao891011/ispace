//
//  MessageCenter.m
//  iSpace
//
//  Created by CC on 14-5-19.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "MessageSender.h"
#import "UITools.h"
#import "NSDictionary+Additions.h"


static MessageSender *_defaultInstance = nil;

@implementation MessageSender


+ (MessageSender *)defaultInstance
{
	@synchronized(self)
	{
		if (_defaultInstance == nil)
		{
			_defaultInstance = [[MessageSender alloc] init];
		}
	}
	return _defaultInstance;
}


// 发送语音聊天数据
- (void)sendMessage:(NSString *)fileName
           fileType:(NSString *)fileType
           fileData:(NSData *)soundData
       fileDuration:(NSString *)fileDuration
           toDevice:(NSString *)deviceSerial
        aboutFriend:(FriendInfoModel *)frined
            ifTimer:(BOOL)isTimer
             andUTS:(NSString *)uts
withSucceededNotify:(SucceededFunction)succeeded
   withFailedNotify:(FailedFunction)failed
{
    _currentRequest = [[SendMessageRequest alloc] init];
    _currentRequest.deviceSerial = deviceSerial;
    _currentRequest.fileName = fileName;
    _currentRequest.fileType = fileType;
    _currentRequest.data = soundData;
    _currentRequest.fileDuration = fileDuration;
    _currentRequest.toUser = frined;
    _currentRequest.isTimer = isTimer;
    _currentRequest.uts = uts;
    _currentRequest.succeededBlock = succeeded;
    _currentRequest.failedBlock = failed;
    
    [self sendUploadFileRequest:_currentRequest];
}


// 发送上传文件请求
- (void)sendUploadFileRequest:(SendMessageRequest *)requestInfo
{
    // 请求体
    NSString *fileNameBase64 = [UITools encodeBase64:requestInfo.fileName];
    NSString *fileSize = [[NSString alloc] initWithFormat:@"%tu", [requestInfo.data length]];
    NSMutableDictionary *params = [NetDataService needCommand:@"2056"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"filename",   @"type",              @"size",  @"md5", @"req_id", @"set"]
                                          andNeedBobyArrValue:@[fileNameBase64, requestInfo.fileType, fileSize, @"-1",  @"456",    @"3"  ]];
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:nil
                     isShowWaiting:FALSE
                       failedBlock:^()
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (_currentRequest.failedBlock)
             {
                 _currentRequest.failedBlock();
             }
         });
     }
                     completeBlock:^(id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self handleUploadFileRequestResult:result];
         });
     }];
}


// 处理获取设备信息结果
- (void)handleUploadFileRequestResult:(id)result
{
    NSDictionary *msgBody = [result objectForKey:@"message_body"];
    NSString *host = [msgBody objectForKey:@"host"];
    NSString *port = [msgBody objectForKey:@"port"];
    NSString *params = [msgBody objectForKey:@"param"];
    
    [self uploadFile:_currentRequest.data toHost:host atPort:port withParams:params];
}



// 发送上传文件请求
-(void)uploadFile:(NSData *)data toHost:(NSString *)host atPort:(NSString *)port withParams:(NSString *)params
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url = [[NSString alloc] initWithFormat:@"http://%@:%@/iSpaceSvr/?%@", host, port, params];
    NSString *contentLength = [[NSString alloc] initWithFormat:@"%tu", [data length]];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"binary/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setTimeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (connectionError)
            {
                if (_currentRequest.failedBlock)
                {
                    _currentRequest.failedBlock();
                }
            }
            else
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
                [self handleUploadFileResult:dict];
            }
        });
    }];
}



// 处理上传文件结果
- (void)handleUploadFileResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
//    NSString *requestId = [msgBody getString:@"req_id"];
    NSString *fileUrl = [msgBody getString:@"url"];
//    NSString *fileSize = [msgBody getString:@"file_size"];
    NSString *fileId = [msgBody getString:@"fileid"];
    
    if (errorCode == 0)
    {
        _currentRequest.fileUrl = fileUrl;      // 暂存, 上传成功后，保存到历史记录
        _currentRequest.fileId = fileId;
        
        [self requestSendSound:fileId
                      toDevice:_currentRequest.deviceSerial
                    forAccount:@""
                  withDuration:_currentRequest.fileDuration
                    andIsTimer:_currentRequest.isTimer ? @"1" : @"0"
                        andUTS:_currentRequest.uts];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_currentRequest.failedBlock)
            {
                _currentRequest.failedBlock();
            }
        });
    }
}



// 请求服务器转发语音
- (void)requestSendSound:(NSString *)soundFileId
                toDevice:(NSString *)deviceSerial
              forAccount:(NSString *)account
            withDuration:(NSString *)duration
              andIsTimer:(NSString *)isTimer    // 0：不定时；1：定时
                  andUTS:(NSString *)uts        // 如果定时，则必须携带本段。UTC时间戳。误差最大不超过45秒。
{
    //请求体
    NSMutableDictionary *params = [NetDataService needCommand:@"2087"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"fid", @"dev_sn", @"account", @"duration", @"timer", @"uts"]
                                          andNeedBobyArrValue:@[soundFileId, deviceSerial, account, duration, isTimer, uts]];
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:nil
                     isShowWaiting:FALSE
                       failedBlock:^()
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (_currentRequest.failedBlock)
             {
                 _currentRequest.failedBlock();
             }
         });
     }
                     completeBlock:^(id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self handleSendSoundResult:result];
         });
     }];
}


// 处理服务器端转发语音结果
- (void)handleSendSoundResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    
    NSNumber *timestamp = [msgBody getNumber:@"timestamp"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        _currentRequest.timestamp = timestamp;
        _currentRequest.succeededBlock(_currentRequest);
    }
    else
    {
        _currentRequest.failedBlock(nil);
    }
}



@end



@implementation SendMessageRequest



@end
