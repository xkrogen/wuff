//
//  InputView.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/2/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "InputView.h"

@implementation InputView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textField.delegate = self;
        self.clipsToBounds = YES;
        
        CALayer *rightBorder = [CALayer layer];
        rightBorder.borderColor = [UIColor grayColor].CGColor;
        rightBorder.borderWidth = 1.2f;
        [rightBorder setOpacity:0.15f];
        rightBorder.frame = CGRectMake(-1, 0, CGRectGetWidth(self.frame)+2, CGRectGetHeight(self.frame));
        
        [self.layer addSublayer:rightBorder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = YES;
        
        CALayer *rightBorder = [CALayer layer];
        rightBorder.borderColor = [UIColor grayColor].CGColor;
        rightBorder.borderWidth = 1.2f;
        [rightBorder setOpacity:0.15f];
        rightBorder.frame = CGRectMake(-1, 0, CGRectGetWidth(self.frame)+2, CGRectGetHeight(self.frame));
        
        [self.layer addSublayer:rightBorder];
    }
    return self;

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
