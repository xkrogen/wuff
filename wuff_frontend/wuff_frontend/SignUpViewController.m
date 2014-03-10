//
//  SignUpViewController.m
//  wuff_frontend
//
//  Created by Matthew Griffin on 3/9/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "SignUpViewController.h"
#import "LoginViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)signUp {
    
    //Send http Post Request
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleSignUpResponse:" andDelegate:self];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:_emailInputView.textField.text, @"email", _passwordInputView.textField.text, @"password", _nameInputView.textField.text, @"name", nil];
    [_myRequester createRequestWithType:POST ForURL:@"http://localhost:3000/user/add_user" WithDictionary:d];
    NSLog(@"sent request!");
}

-(void) handleSignUpResponse:(NSDictionary *)data {
    NSLog(@"Handle signup response data here!");
}

-(IBAction)backButton {
    
    [self performSegueWithIdentifier:@"gotoLogin" sender:self];
    
}

@end
