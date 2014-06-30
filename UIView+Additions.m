//
//  UIViewEx.m
//  WapGess
//
//  Created by mac on 11-1-19.
//  Copyright 2011 YLINK. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Additions.h"

#define kSelectedMaskTag        101
#define kOverlayMaskTag         102


@implementation UIView (Additions)

- (BOOL)resignFirstResponderEx
{
    if (self.isFirstResponder) 
    {
        [self resignFirstResponder];
		return YES;     
    }
    
	for (UIView *subView in self.subviews) 
	{
        if ([subView resignFirstResponderEx])
		{
			return YES;
		}
	}
  
	return NO;
}


- (void)setShadowWithColor:(UIColor *)color
{
    [self.layer setShadowOffset:CGSizeMake(1, 1)];  
    [self.layer setShadowOpacity:0.6];
    [self.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.layer setShadowColor:color.CGColor];
}


- (void)setRounderWithRadius:(CGFloat)radius
{
    [self.layer setCornerRadius:radius];
}


- (void)setBorderWithWidth:(CGFloat)width andColor:(UIColor *)color
{
    [self.layer setBorderWidth:width];
    [self.layer setBorderColor:[color CGColor]];
}


- (void)showSelectedMask:(BOOL)show
{
    [self showMask:show forTag:kSelectedMaskTag withColor:[UIColor blueColor] andAlpha:0.1f];
}


- (void)showOverlayMask:(BOOL)show
{
    [self showMask:show forTag:kOverlayMaskTag withColor:[UIColor whiteColor] andAlpha:1.0f];
}


- (void)showMask:(BOOL)show forTag:(NSInteger)tag withColor:(UIColor *)color andAlpha:(CGFloat)alpha
{
    if (show)
    {
        UIView *view = [self viewWithTag:tag];
        if (!view)
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
            view.backgroundColor = color;
            view.alpha = alpha;
            view.tag = tag;
            [self addSubview:view];
        }
    }
    else
    {
        UIView *view = [self viewWithTag:tag];
        if (view)
        {
            [view removeFromSuperview];
        }
    }
}

@end
