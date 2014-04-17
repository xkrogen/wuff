//
//  EventViewController.m
//  wuff_frontend
//
//  Created by Yang Xiang on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "EventViewController.h"

@interface EventViewController ()

@end

@implementation EventViewController

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
    eventLocation.text = self.location;
    eventLocation.lineBreakMode = NSLineBreakByWordWrapping;
    eventLocation.numberOfLines = 1;
    
    eventTitle.text = self.myTitle;
    eventTitle.lineBreakMode = NSLineBreakByWordWrapping;
    eventTitle.numberOfLines = 1;
    
    eventTime.text = self.time;
    eventTime.lineBreakMode = NSLineBreakByWordWrapping;
    eventTime.numberOfLines = 1;
    
    eventAttenders.text = self.attenders;
    eventAttenders.lineBreakMode = NSLineBreakByWordWrapping;
    eventAttenders.numberOfLines = 1;
    [eventAttenders sizeToFit];
    
    eventDescription.text = self.description;
    eventDescription.lineBreakMode = NSLineBreakByWordWrapping;
    eventDescription.numberOfLines = 1;
    [eventDescription sizeToFit];
    
    // USE THIS CODE TO CREATE THE NAVIGATION CONTROLLER PROGRAMMATICALLY
    UINavigationBar *navigationBar;
    UINavigationItem *navigationBarItem;
    
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 64)];
    
    [[self view] addSubview:navigationBar];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    navigationBarItem = [[UINavigationItem alloc] initWithTitle:@"Event"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButton)];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setAccessibilityLabel:@"Back Button"];
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

-(IBAction)backButton {
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
    MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    SettingsTabViewController *settings = [[SettingsTabViewController alloc] initWithNibName:nil bundle:Nil];
    
    MSSlidingPanelController *newView = [[MSSlidingPanelController alloc] initWithCenterViewController:main andLeftPanelController:settings];
    
    [self presentViewController:newView animated:YES completion:NULL];
     */
}

@end
