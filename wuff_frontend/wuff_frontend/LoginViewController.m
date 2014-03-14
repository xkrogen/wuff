//
//  LoginViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
    typedef enum {
        SUCCESS = 1,
        
    } ErrorCode;
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
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:_emailInputView.textField.text, @"email", _passwordInputView.textField.text, @"password", nil];
    
    //Code to send POST Request
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleSignInResponse:" andDelegate:self];
    [_myRequester createRequestWithType:POST forExtension:@"/user/login_user" withDictionary:d];
    NSLog(@"sent request!");
}

-(void) handleSignInResponse:(NSDictionary *)data {
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
            NSLog(@"Moving to main screen");
            MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
            [self presentViewController:main animated:YES completion:NULL];
            break;
    }
}

-(IBAction)signUp {
    SignUpViewController *signUp = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:signUp animated:YES completion:NULL];
}


@end
