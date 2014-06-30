//
//  UploadModel.m
//  iSpace
//
//  Created by bear on 14-6-23.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "UploadModel.h"

@implementation UploadModel
+(UploadModel*)shareManager
{
    static UploadModel *shareManager = nil ;
    static dispatch_once_t once ;
    dispatch_once(&once , ^{
        shareManager = [[self alloc]init];
    });
    return shareManager ;
}
- (void)creatUploadModel:(id)result
{
    NSString *error = result[@"message_body"][@"error"];
    if ([error isEqualToString:@"0"]) {
        NSArray *uploadArr = result[@"message_body"][@"list"];
        [_myUploadArr removeAllObjects];
        for (NSDictionary *dict in uploadArr) {
            UploadModel *model = [[UploadModel alloc]initWithDataDic:dict];
            if (_myUploadArr == nil) {
                _myUploadArr = [[NSMutableArray alloc]initWithCapacity:20];
            }
            [_myUploadArr addObject:model];
        }
        [MKNetWork shareMannger].fininshBlock(_myUploadArr);
    }else{
        [MKNetWork shareMannger].failBlock(error);
    }
}
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           @"ext": @"ext",
                           @"fid": @"fid",
                           @"name": @"name",
                           @"url": @"url"
                           };
    return dict ;
}
@end
