//
//  UIViewEx.h
//  WapGess
//
//  Created by mac on 11-1-19.
//  Copyright 2011 YLINK. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (Additions)

- (BOOL)resignFirstResponderEx;

- (void)setShadowWithColor:(UIColor *)color;
- (void)setRounderWithRadius:(CGFloat)radius;
- (void)setBorderWithWidth:(CGFloat)width andColor:(UIColor *)color;

- (void)showSelectedMask:(BOOL)show;
- (void)showOverlayMask:(BOOL)show;

@end
