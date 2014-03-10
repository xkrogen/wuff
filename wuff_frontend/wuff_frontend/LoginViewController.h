//
//  LoginViewController.h
//  wuff_frontend
//
//  Created by Darren Tsung on 3/2/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputView.h"
#import "UIView+Toast.h"

@interface LoginViewController : UIViewController

@property(nonatomic, strong) IBOutlet InputView *emailInputView;

@property(nonatomic, strong) IBOutlet InputView *passwordInputView;




-(IBAction)signIn;

-(IBAction)signUp;


@end
