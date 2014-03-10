//
//  SignUpViewController.h
//  wuff_frontend
//
//  Created by Matthew Griffin on 3/9/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputView.h"
#import "UIView+Toast.h"
#import "HandleRequest.h"

@interface SignUpViewController : UIViewController


@property(nonatomic, strong) IBOutlet InputView *emailInputView;
@property(nonatomic, strong) IBOutlet InputView *passwordInputView;
@property(nonatomic, strong) IBOutlet InputView *nameInputView;

@property(nonatomic, strong) HandleRequest *myRequester;

-(IBAction)signUp;

-(IBAction)backButton;


@end
