//
//  Clock.m
//  testClock
//
//  Created by 莫景涛 on 14-4-5.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "AlarmClock.h"

@implementation AlarmClock

- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)color andDate:(NSDate*)date
{
    self = [super initWithFrame:frame];
    if (self) {
        _borderColor = [color copy];
        self.calendar = [NSCalendar currentCalendar];
        self.time = date;
        [self setBorderColor];
    }
    return self;
}
- (void)setBorderColor
{
    self.layer.borderColor = _borderColor.CGColor ;
    self.layer.borderWidth = 3 ;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.alpha = 0.8 ;
    
}
- (CGPoint)midPoint {
    CGRect theBounds = self.bounds;
    return CGPointMake(CGRectGetMidX(theBounds), CGRectGetMidY(theBounds));
}

- (CGPoint)pointWithRadius:(CGFloat)inRadius angle:(CGFloat)inAngle {
    CGPoint theCenter = [self midPoint];
    return CGPointMake(theCenter.x + inRadius * sin(inAngle), theCenter.y - inRadius * cos(inAngle));
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.calendar = [NSCalendar currentCalendar];
        self.time = _time;
        
    }
    return self;
}
- (void)drawClockHands {
    
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    CGPoint theCenter = [self midPoint];
    CGFloat theRadius = CGRectGetWidth(self.bounds) / 2.0;
    NSDateComponents *theComponents = [self.calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.time];
    CGFloat theMinute = theComponents.minute * M_PI / 30.0;
    CGFloat theHour = (theComponents.hour + theComponents.minute / 60) * M_PI / 6.0;
    
    CGPoint thePoint = [self pointWithRadius:theRadius * 0.7 angle:theHour];
    //CGPoint moveThePoint = [self pointWithRadius:theRadius * 0.3 angle:theHour];
    const CGFloat *colorFloat = CGColorGetComponents([_borderColor CGColor]);
    CGContextSetFillColor(theContext, colorFloat);
    CGContextSetLineWidth(theContext, 3.0);
    CGContextSetLineCap(theContext, kCGLineCapSquare);
    CGContextMoveToPoint(theContext, theCenter.x, theCenter.y);
    CGContextAddLineToPoint(theContext, thePoint.x, thePoint.y);
    CGContextStrokePath(theContext);
    
    thePoint = [self pointWithRadius:theRadius * 0.8 angle:theMinute];
    //moveThePoint = [self pointWithRadius:theRadius * 0.3 angle:theMinute];
    CGContextSetLineWidth(theContext, 2.0);
    CGContextMoveToPoint(theContext, theCenter.x, theCenter.y);
    CGContextAddLineToPoint(theContext, thePoint.x, thePoint.y);
    CGContextStrokePath(theContext);
    
}
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    CGRect theBounds = self.bounds;
    CGContextSaveGState(theContext);
    const CGFloat *components = CGColorGetComponents(_borderColor.CGColor);
    if (components != NULL) {
        CGContextSetRGBFillColor(theContext, components[0], components[1], components[2], 1.0);
    }
    CGContextAddEllipseInRect(theContext, theBounds);
    CGContextFillPath(theContext);
    self.userInteractionEnabled = YES ;
    
    //画圆心
    CGRect center =CGRectMake((self.bounds.size.width-6)/2 , (self.bounds.size.height-6)/2 , 6 , 6);
    CGContextSaveGState(theContext);
     CGContextSetRGBStrokeColor(theContext, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(theContext, 1.0, 1.0, 1.0, 1.0);
    CGContextAddEllipseInRect(theContext, center);
    CGContextFillPath(theContext);

    CGContextSetLineWidth(theContext, 5.0);
    CGContextSetLineCap(theContext, kCGLineCapRound);
    CGContextAddEllipseInRect(theContext, theBounds);
    CGContextClip(theContext);
    
    [self drawClockHands];
    
    CGContextRestoreGState(theContext);
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    _borderColor = [self.backgroundColor copy] ;
    self.calendar = [NSCalendar currentCalendar];
    if (self.time==nil) {
        _time = [NSDate new];
    }
    self.time = _time;
    [self setBorderColor];
  
  }
@end
