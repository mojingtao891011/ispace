//
//  NSString+PublicMethod.h
//  iSpace
//
//  Created by bear on 14-6-5.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (PublicMethod)

- (NSString*)encodeBase64:(NSString*)sourceStr ;
- (NSString*)decodeBase64:(NSString*)encodeBase64Str ;
- (NSString*)fromDateToWeek:(NSString*)selectDate ;
- (NSDate *) dateFromFomate:(NSString *)datestring formate:(NSString*)formate ;
- (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate ;
- (NSString *)md5:(NSString *)str ;
- (NSString *)getCurrentWifiName ;
- (id)fetchWIFISSIDInfo ;
- (BOOL)isEmail:(NSString*)email ;
//- (BOOL)isMobileNumber:(NSString *)mobileNum ;
- (BOOL)checkTel:(NSString *)str ;

@end
