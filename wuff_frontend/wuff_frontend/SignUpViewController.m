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
    if([data[@"err_code"] isEqualToNumber:@1] ) {
        //If Success
        //IMPORTANT: CODE TO STORE token
        MainViewController *mainVC = [[MainViewController alloc] initWithNibName:nil bundle:nil];
        [self presentViewController:mainVC animated:YES completion:NULL];
    }
    else {
        [self.view makeToast:@"There was An Error"];
    }
    
    
}

-(IBAction)backButton {
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:login animated:YES completion:NULL];
}

@end
