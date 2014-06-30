//
//  MusicModel.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-24.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "RecordModel.h"

@implementation RecordModel

+(RecordModel*)sharedManager
{
    static  RecordModel  *shareManager = nil;
    static dispatch_once_t once ;
    dispatch_once (&once , ^{
        shareManager = [[self alloc]init ];
    });
    return shareManager ;
}
- (void)creatModel:(id)result
{
    
    if (_listArr == nil) {
        _listArr = [[NSMutableArray alloc]initWithCapacity:20];
    }
     [_listArr removeAllObjects];
    int errorInt = [result[@"message_body"][@"error"] intValue];
    int totalInt = [result[@"message_body"][@"total"] intValue];
    if (errorInt == 0 && totalInt != 0) {
        NSArray *musicInfoArr = result[@"message_body"][@"info"] ;
        
        for (NSDictionary *musicDict in musicInfoArr) {
            RecordModel *recordModel = [[RecordModel alloc]initWithDataDic:musicDict];
            
            [_listArr addObject:recordModel];
        }
        [MKNetWork shareMannger].fininshBlock(_listArr);
       
    }else
    {
        [MKNetWork shareMannger].fininshBlock(result[@"message_body"][@"error"]);
       
    }
}
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           
                           @"recordName" :            @"name" ,
                           @"recordUrl" :             @"url" ,
                           @"recordId" :    @"id" ,
                           @"recordSize" : @"size" ,
                                                      
                           };
    return dict ;
}
- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
}

@end
