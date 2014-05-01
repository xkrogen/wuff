//
//  SOLabel.h
//  wuff_frontend
//
//  Created by Darren Tsung on 4/29/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface SOLabel : UILabel

@property (nonatomic, readwrite) VerticalAlignment vAlignment;


@end
