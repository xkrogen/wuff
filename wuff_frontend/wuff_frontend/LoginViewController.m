//
//  LoginViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/2/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)signIn {
    
    //Code to send POST Request
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleSignInResponse:" andDelegate:self];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:_emailInputView.textField.text, @"email", _passwordInputView.textField.text, @"password", nil];
    [_myRequester createRequestWithType:POST ForURL:@"http://localhost:3000/user/login_user" WithDictionary:d];
    NSLog(@"sent request!");
}

-(void) handleSignInResponse:(NSDictionary *)data {
    NSLog(@"Handle response here!");
}

-(IBAction)signUp {
    
    [self performSegueWithIdentifier:@"gotoSignUp" sender:self];
    
    
}


@end
