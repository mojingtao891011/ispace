//
//  GCDAsyncFileRequest.m
//  iSpace
//
//  Created by CC on 14-5-27.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "AsyncFileDownloader.h"

@interface AsyncFileDownloader ()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *fileData;

@end



@implementation AsyncFileDownloader


// 下载文件
- (void)downloadFileWithUrl:(NSString *)url
{
    self.fileData = [[NSMutableData alloc] initWithCapacity:0];
    self.fileUrl = url;
    
    // 取消先前的下载
    [self cancel];
 
    // 开始下载
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.fileUrl]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:60];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}


// 取消下载
- (void)cancel
{
    [self.connection cancel];
}


#pragma mark - <NSURLConnectionDelegate> Functions

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.fileData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.succeededBlock)
    {
        self.succeededBlock(self.fileData, self.fileUrl);
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.failedBlock)
    {
        self.failedBlock(self.fileUrl);
    }
}


@end
