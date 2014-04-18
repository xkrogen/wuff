//
//  RectUIVew.m
//  wuff_frontend
//
//  Created by Darren Tsung on 4/17/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "RectUIVew.h"

@implementation RectUIVew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.color = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect rectangle = CGRectMake(0, 0, 320, 70);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(context, red, green, blue, 1.0);
    CGContextSetRGBFillColor(context, red, green, blue, 1.0);
    CGContextFillRect(context, rectangle);
    CGContextStrokeRect(context, rectangle);    //this will draw the border
}



@end
