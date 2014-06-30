//
//  RingUploader.m
//  iSpace
//
//  Created by CC on 14-6-14.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "RingUploader.h"
#import "UITools.h"
#import "NSDictionary+Additions.h"


@interface RingUploader ()

@end


@implementation RingUploader


// 上传文件
- (void)uploadFile:(NSString *)fileName
          fileType:(NSString *)fileType
          fileData:(NSData *)fileData
{
    self.fileName = fileName;
    self.fileType = fileType;
    self.fileData = fileData;
    
    [self requestUploadDestAddress:fileName fileType:fileType fileData:fileData];
}


// 请求上传目的地
- (void)requestUploadDestAddress:(NSString *)fileName
                        fileType:(NSString *)fileType
                        fileData:(NSData *)fileData
{
    // 请求体
    NSString *fileNameBase64 = fileName;
    NSString *fileSize = [[NSString alloc] initWithFormat:@"%tu", [fileData length]];
    NSMutableDictionary *params = [NetDataService needCommand:@"2056"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"filename",   @"type",  @"size",  @"md5", @"req_id", @"set"]
                                          andNeedBobyArrValue:@[fileNameBase64, fileType, fileSize, @"-1",  @"456",    @"3"  ]];
    
    void (^failedBlock)() = ^()
    {
        [self fireFailedDelegate];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleUploadDestAddress:result];
                       });
    };
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:nil
                     isShowWaiting:FALSE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理获取设备信息结果
- (void)handleUploadDestAddress:(id)result
{
    NSDictionary *msgBody = [result objectForKey:@"message_body"];
    NSString *host = [msgBody objectForKey:@"host"];
    NSString *port = [msgBody objectForKey:@"port"];
    NSString *params = [msgBody objectForKey:@"param"];
    
    [self uploadFile:self.fileData toHost:host atPort:port withParams:params];
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
                 [self fireFailedDelegate];
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
    NSString *fileUrl = [msgBody getString:@"url"];
    NSString *fileId = [msgBody getString:@"fileid"];
    
    if (errorCode == 0)
    {
        self.fileUrl = fileUrl;      // 暂存, 上传成功后，保存到历史记录
        self.fileId = fileId;
        
        [self requestForwardFile:fileId];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fireFailedDelegate];
        });
    }
}



// 请求服务器转发文件
- (void)requestForwardFile:(NSString *)fileId
{
    //请求体
    NSMutableDictionary *params = [NetDataService needCommand:@"2098"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"fid"]
                                          andNeedBobyArrValue:@[fileId]];
    
    void (^failedBlock)() = ^()
    {
        [self fireFailedDelegate];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleForwardFileResult:result];
                       });
    };
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:nil
                     isShowWaiting:FALSE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理服务器转发文件结果
- (void)handleForwardFileResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        [self fireSucceededDelegate];
    }
    else
    {
        [self fireFailedDelegate];
    }
}


#pragma mark - 触发代理

// 触发成功代理
- (void)fireSucceededDelegate
{
    if ([self.delegate respondsToSelector:@selector(uploadFileSucceeded:)])
    {
        [self.delegate uploadFileSucceeded:self];
    }
}


// 触发失败代理
- (void)fireFailedDelegate
{
    if ([self.delegate respondsToSelector:@selector(uploadFileFailed:)])
    {
        [self.delegate uploadFileFailed:self];
    }
}


@end
