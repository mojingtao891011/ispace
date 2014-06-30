//
//  RingUploader.h
//  iSpace
//
//  Created by CC on 14-6-14.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iSpaceRing.h"

@protocol RingUploaderDelegate;


@interface RingUploader : NSObject
{
    
}

@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *fileUrl;
@property (copy, nonatomic) NSString *fileId;
@property (copy, nonatomic) NSString *fileType;
@property (copy, nonatomic) NSData *fileData;
@property (weak, nonatomic) id <RingUploaderDelegate> delegate;

// 上传文件
- (void)uploadFile:(NSString *)fileName
          fileType:(NSString *)fileType
          fileData:(NSData *)fileData;

@end


@protocol RingUploaderDelegate <NSObject>

@optional
- (void)uploadFileSucceeded:(RingUploader *)uploader;
- (void)uploadFileFailed:(RingUploader *)uploader;

@end