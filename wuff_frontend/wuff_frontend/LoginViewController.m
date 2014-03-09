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
    [self.view makeToast:@"Need Get/Post implemenation :("];
    
}

-(IBAction)signUp {
    
    [self performSegueWithIdentifier:@"gotoSignUp" sender:self];
    
    
}


@end
