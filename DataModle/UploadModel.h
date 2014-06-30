//
//  UploadModel.h
//  iSpace
//
//  Created by bear on 14-6-23.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "WXBaseModel.h"

@interface UploadModel : WXBaseModel
@property(nonatomic , copy)NSString *ext ;
@property(nonatomic , copy)NSString *fid ;
@property(nonatomic , copy)NSString *name ;
@property(nonatomic , copy)NSString *url ;
@property(nonatomic , retain)NSMutableArray *myUploadArr ;

+(UploadModel*)shareManager ;
- (void)creatUploadModel:(id)result ;
@end
