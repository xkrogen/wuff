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
        self.logging_in_fb = false;
        
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
    
    // 505 is the minimum you can use for a content-size that doesn't move around but still streches (used for the login page)
    [self.scrollView setContentSize:CGSizeMake(320, 505)];
    [self.scrollView addSubview:self.contentView];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    
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
    //NSLog(@"sent request!");
    
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
            [[NSUserDefaults standardUserDefaults] setObject:[data objectForKey:@"user_id"] forKey:@"user_id"];
            
            SettingsTabViewController *settings = [[SettingsTabViewController alloc] initWithNibName:nil bundle:Nil];
            MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil andSettingsTab:settings];
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
    
    if (!self.logging_in_fb)
    {
        self.logging_in_fb = true;
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:userID, @"facebook_id", token, @"facebook_token", nil];
        
        //Code to send POST Request
        _myRequester = [[HandleRequest alloc] initWithSelector:@"handleSignInResponse:" andDelegate:self];
        [_myRequester createRequestWithType:POST forExtension:@"/user/auth_facebook" withDictionary:d];
        [self.view makeToastActivity];
    }
    
    /*
    HandleRequest *changeProfilePic = [[HandleRequest alloc] initWithSelector:nil andDelegate:nil];
    NSDictionary *p = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", [user username]], @"pic_url", nil];
    [changeProfilePic createRequestWithType:POST
                               forExtension:@"/user/set_profile_pic" withDictionary:p];
    
    */
    
    
    // close the keyboard
    [self.view endEditing:YES];
    
    
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
