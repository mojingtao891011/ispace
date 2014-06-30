//
//  NSDictionary+Additions.h
//  iSpace
//
//  Created by CC on 14-6-6.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)

- (NSString *)getString:(NSString *)key;
- (NSNumber *)getNumber:(NSString *)key;
- (NSInteger)getInteger:(NSString *)key;
- (NSDictionary *)getDictionary:(NSString *)key;
- (NSArray *)getArray:(NSString *)key;

@end
