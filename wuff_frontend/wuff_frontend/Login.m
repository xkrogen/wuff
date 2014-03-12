//
//  Login.m
//  wuff_frontend
//
//  Created by Yang Xiang on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "Login.h"
#import "SignUp.h"
@interface Login ()

@end

@implementation Login

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
    
    SignUp *signUp = [[SignUp alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:signUp animated:YES completion:NULL];
    
}


@end
