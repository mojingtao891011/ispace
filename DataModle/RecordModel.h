//
//  MusicModel.h
//  iSpace
//
//  Created by 莫景涛 on 14-4-24.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "WXBaseModel.h"

@interface RecordModel : WXBaseModel

@property(nonatomic , copy)NSString *recordName ;
@property(nonatomic , copy)NSString *recordUrl ;
@property(nonatomic , copy)NSString *recordId ;
@property(nonatomic , copy)NSString *recordSize ;

@property(nonatomic , retain)NSMutableArray *listArr ;

+(RecordModel*)sharedManager ;
- (void)creatModel:(id)result ;

@end
