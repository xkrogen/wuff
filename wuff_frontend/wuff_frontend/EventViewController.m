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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButton {
    MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:nil bundle:Nil];
    
    MSSlidingPanelController *newView = [[MSSlidingPanelController alloc] initWithCenterViewController:main andLeftPanelController:settings];
    
    [self presentViewController:newView animated:YES completion:NULL];
}

@end
