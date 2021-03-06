//
//  SettingsViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/30/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    // Do any additional setup after loading the view from its nib.
    // USE THIS CODE TO CREATE THE NAVIGATION CONTROLLER PROGRAMMATICALLY
    UINavigationBar *navigationBar;
    UINavigationItem *navigationBarItem;
    
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 64)];
    
    [[self view] addSubview:navigationBar];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    navigationBarItem = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setAccessibilityLabel:@"Settings Back Button"];
    [navigationBarItem setLeftBarButtonItem:backButton];
    
    [navigationBar setBarTintColor:[UIColor colorWithRed:49.0f/255.0f green:103.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    [navigationBar pushNavigationItem:navigationBarItem animated:NO];
    [navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [[self view] addSubview:navigationBar];
    // END CODE
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
