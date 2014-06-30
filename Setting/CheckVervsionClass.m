//
//  CheckVervsionClass.m
//  iSpace
//
//  Created by bear on 14-6-24.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "CheckVervsionClass.h"

@implementation CheckVervsionClass
+(CheckVervsionClass*)shareManager
{
    static CheckVervsionClass *shareManager = nil ;
    static dispatch_once_t once ;
    dispatch_once(&once , ^{
        shareManager = [[self alloc]init];
    });
    return shareManager ;
}
- (void)starCheckVersion:(id)result
{
    int errorInt = [result[@"message_body"][@"error"] intValue];
    if (errorInt == 0) {
        CheckVervsionClass *checkVersion = [[CheckVervsionClass alloc]initWithDataDic:result[@"message_body"]];
        [MKNetWork shareMannger].fininshBlock(checkVersion);
    }else{
        [MKNetWork shareMannger].failBlock(result[@"message_body"][@"error"]);
    }
}
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           
                           @"descript" :@"descript" ,
                           @"suggest" :@"suggest" ,
                           @"url" :@"url" ,
                           @"ver_num" :@"ver_num" ,
                           @"ver_str" :@"ver_str"
                           
                           };
    return dict ;
}
@end
