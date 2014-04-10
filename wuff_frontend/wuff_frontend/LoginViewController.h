//
//  LoginViewController.h
//  wuff_frontend
//
//  Created by Darren Tsung on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputView.h"
#import "HandleRequest.h"
#import "SignUpViewController.h"
#import "MainViewController.h"
#import "SettingsTabViewController.h"
#import "MSSlidingPanelController.h"

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

@property(nonatomic, strong) IBOutlet InputView *emailInputView;
@property(nonatomic, strong) IBOutlet InputView *passwordInputView;

@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) IBOutlet UIView *contentView;

@property (nonatomic,retain) IBOutlet FBLoginView *fbLoginButton;

@property(nonatomic, strong) HandleRequest *myRequester;

-(void) handleSignInResponse:(NSDictionary *)data;

-(IBAction)login;
-(IBAction)signUp;


@end
