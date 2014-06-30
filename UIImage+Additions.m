//
//  UIImage+Additions.m
//  iSpace
//
//  Created by CC on 14-6-17.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

// 创建纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}



@end
