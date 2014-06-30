//
//  AlarmInfoModel.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-21.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//


#import "AlarmInfoModel.h"

@implementation AlarmInfoModel
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           
                           @"index" :            @"index" ,
                           @"state" :             @"state" ,
                           @"frequency" :    @"frequency" ,
                           @"sleep_times" : @"sleep_times" ,
                           @"sleep_gap" :    @"sleep_gap" ,
                           @"hour" :              @"hour" ,
                           @"minute" :          @"minute" ,
                           @"vol_level" :      @"vol_level" ,
                           @"vol_type" :      @"vol_type" ,
                           @"fm_chnl" :       @"fm_chnl" ,
                           @"file_path" :      @"file_path" ,
                           @"file_id" : @"file_id",
                           @"name" : @"name",
                           @"flag"  :@"flag"
                           
                           };
    return dict ;
}
- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
}

@end
