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
    [self.view makeToast:@"Need Get/Post implemenation :("];
    
}

-(IBAction)backButton {
    
    [self performSegueWithIdentifier:@"gotoLogin" sender:self];
    
}

@end
