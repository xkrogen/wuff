//
//  LoginViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
    
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookieString"];
        
        /*
        // CODE FOR FINDING OUT THE FONT FAMILYS ON IOS
        NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
        NSArray *fontNames;
        NSInteger indFamily, indFont;
        for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
        {
            NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
            fontNames = [[NSArray alloc] initWithArray:
                         [UIFont fontNamesForFamilyName:
                          [familyNames objectAtIndex:indFamily]]];
            for (indFont=0; indFont<[fontNames count]; ++indFont)
            {
                NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
            }
        }
         */

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // USE THIS CODE TO CREATE THE NAVIGATION CONTROLLER PROGRAMMATICALLY
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    [self.navigationItem setTitle:@"Log In"];
    
    [self.navigationItem setHidesBackButton:YES];
    _fbLoginButton.readPermissions = @[@"basic_info",@"email"];
    _fbLoginButton.delegate = self;
    //We only want to read Basic Info
    // END CODE
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)login {
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:_emailInputView.textField.text, @"email", _passwordInputView.textField.text, @"password",[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"],@"device_token", nil];
    
    //Code to send POST Request
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleSignInResponse:" andDelegate:self];
    [_myRequester createRequestWithType:POST forExtension:@"/user/login_user" withDictionary:d];
    
    // close the keyboard
    [self.view endEditing:YES];
    NSLog(@"sent request!");
    
    [self.view makeToastActivity];
}

-(void) handleSignInResponse:(NSDictionary *)data {
    [self.view hideToastActivity];
    
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];

    switch (err_code)
    {
        case SUCCESS:
        {
            NSLog(@"Storing user logged-in to Standard User Defaults!");
            [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"name"] forKey:@"name"];
            [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"email"] forKey:@"email"];
            
            MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
            SettingsTabViewController *settings = [[SettingsTabViewController alloc] initWithNibName:nil bundle:Nil];
            
            MSSlidingPanelController *newView = [[MSSlidingPanelController alloc] initWithCenterViewController:main andLeftPanelController:settings];
            [self.navigationController presentViewController:newView animated:YES completion:nil];
             
            break;
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

-(IBAction)signUp {
    SignUpViewController *signUp = [[SignUpViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:signUp animated:YES];
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    
    NSString *token = [[FBSession activeSession] accessTokenData].accessToken;
    NSString *userID = user.id;
    
    NSLog(@"token: %@\nUserID: %@",token,userID);
    
    
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:userID, @"face_book_id", token, @"facebook_token", nil];
    
    //Code to send POST Request
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleSignInResponse:" andDelegate:self];
    [_myRequester createRequestWithType:POST forExtension:@"/user/auth_facebook" withDictionary:d];
    
    // close the keyboard
    [self.view endEditing:YES];
    NSLog(@"sent request!");
    
    [self.view makeToastActivity];
    
    
    
}


@end
