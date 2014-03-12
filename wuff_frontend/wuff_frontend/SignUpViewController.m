//
//  SignUpViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "SignUpViewController.h"

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
    [_myRequester createRequestWithType:POST forExtension:@"/user/add_user" withDictionary:d];
    NSLog(@"sent request!");
}

-(void) handleSignUpResponse:(NSDictionary *)data {
    NSLog(@"Handle signup response data here!");
    for(NSString *key in [data allKeys]) {
        NSLog(@"Key:%@, Value:%@", key, [data objectForKey:key]);
    }
}

-(IBAction)backButton {
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:login animated:YES completion:NULL];
}

@end
