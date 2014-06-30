//
//  GCDAsyncFileRequest.h
//  iSpace
//
//  Created by CC on 14-5-27.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^DownloadFileIsSucceeded)(NSData *, NSString *);
typedef void (^DownloadFileIsFailed)(NSString *);


@interface AsyncFileDownloader : NSObject <NSURLConnectionDelegate>
{
    
}

@property (nonatomic, copy) DownloadFileIsSucceeded succeededBlock;
@property (nonatomic, copy) DownloadFileIsFailed failedBlock;
@property (nonatomic, copy) NSString *fileUrl;


- (void)downloadFileWithUrl:(NSString *)url;    // 异步下载文件
- (void)cancel;                                 // 取消

@end
