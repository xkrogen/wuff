//
//  LoginViewController.h
//  wuff_frontend
//
//  Created by Darren Tsung on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "InputView.h"
#include "HandleRequest.h"

@interface LoginViewController : UIViewController

@property(nonatomic, strong) IBOutlet InputView *emailInputView;
@property(nonatomic, strong) IBOutlet InputView *passwordInputView;

@property(nonatomic, strong) HandleRequest *myRequester;


-(IBAction)login;
-(IBAction)signUp;


@end
