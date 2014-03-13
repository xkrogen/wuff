//
//  LoginViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)login {
    
    //Code to send POST Request
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleSignInResponse:" andDelegate:self];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:_emailInputView.textField.text, @"email", _passwordInputView.textField.text, @"password", nil];
    [_myRequester createRequestWithType:POST forExtension:@"/user/login_user" withDictionary:d];
    NSLog(@"sent request!");
}

-(void) handleSignInResponse:(NSDictionary *)data {
    NSLog(@"Handle response here!");
    for(NSString *key in [data allKeys]) {
        NSLog(@"Key:%@, Value:%@", key, [data objectForKey:key]);
    }
}

-(IBAction)signUp {
    SignUpViewController *signUp = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:signUp animated:YES completion:NULL];
}


@end
