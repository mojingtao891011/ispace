//
//  iSpaceRing.h
//  iSpace
//
//  Created by CC on 14-6-9.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iSpaceRing : NSObject

@property (assign, nonatomic) NSInteger ringId;
@property (copy,   nonatomic) NSString *name;
@property (copy,   nonatomic) NSString *type;
@property (copy,   nonatomic) NSData *data;
@property (assign, nonatomic) NSInteger size;       // 长度,字节单位

@end
