//
//  SOLabel.m
//  wuff_frontend
//
//  Created by Darren Tsung on 4/29/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "SOLabel.h"

@implementation SOLabel

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    // set inital value via IVAR so the setter isn't called
    self.vAlignment = VerticalAlignmentTop;
    
    return self;
}

-(VerticalAlignment) verticalAlignment
{
    return self.vAlignment;
}

-(void) setVerticalAlignment:(VerticalAlignment)value
{
    self.vAlignment = value;
    [self setNeedsDisplay];
}

// align text block according to vertical alignment settings
-(CGRect)textRectForBounds:(CGRect)bounds
    limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rect = [super textRectForBounds:bounds
                    limitedToNumberOfLines:numberOfLines];
    CGRect result;
    switch (self.vAlignment)
    {
        case VerticalAlignmentTop:
            result = CGRectMake(bounds.origin.x, bounds.origin.y,
                                rect.size.width, rect.size.height);
            break;
            
        case VerticalAlignmentMiddle:
            result = CGRectMake(bounds.origin.x,
                                bounds.origin.y + (bounds.size.height - rect.size.height) / 2,
                                rect.size.width, rect.size.height);
            break;
            
        case VerticalAlignmentBottom:
            result = CGRectMake(bounds.origin.x,
                                bounds.origin.y + (bounds.size.height - rect.size.height),
                                rect.size.width, rect.size.height);
            break;
            
        default:
            result = bounds;
            break;
    }
    return result;
}

-(void)drawTextInRect:(CGRect)rect
{
    CGRect r = [self textRectForBounds:rect
                limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:r];
}

@end
