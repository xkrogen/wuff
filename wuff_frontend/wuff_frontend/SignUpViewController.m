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
    
    // close the keyboard
    [self.view endEditing:YES];
}

-(void) handleSignUpResponse:(NSDictionary *)data {
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];
    
    switch (err_code) {

        case SUCCESS:
        {
            MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
            SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:nil bundle:Nil];
            
            MSSlidingPanelController *newView = [[MSSlidingPanelController alloc] initWithCenterViewController:main andLeftPanelController:settings];
            
            [self presentViewController:newView animated:YES completion:NULL];
        }
            
        case ERR_INVALID_NAME:
            [self.view makeToast:@"Invalid Name"];
            break;
            
        case ERR_INVALID_EMAIL:
            [self.view makeToast:@"Invalid Email"];
            break;
            
        case ERR_INVALID_PASSWORD:
            [self.view makeToast:@"Password must be longer"];
            break;
            
        case ERR_EMAIL_TAKEN:
            [self.view makeToast:@"Email Already Taken"];
            break;
            
        case ERR_INVALID_CREDENTIALS:
            [self.view makeToast:@"Incorrect Email/Password"];
            break;
            
        case ERR_INVALID_FIELD:
            [self.view makeToast:@"Invalid Field."];
            break;
            
        case ERR_UNSUCCESSFUL:
            [self.view makeToast:@"Attempt unsuccessful. Please try again"];
            break;
            
        case ERR_INVALID_TIME:
            [self.view makeToast:@"Invalid Time"];
            break;
            
        case ERR_INVALID_SESSION:
            [self.view makeToast:@"Invalid Session. Try logging out and back in"];
            break;
        
    }
    
}

-(IBAction)backButton {
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:login animated:YES completion:NULL];
}

@end
