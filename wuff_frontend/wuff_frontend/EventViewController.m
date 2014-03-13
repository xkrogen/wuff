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
    eventLocation.numberOfLines = 0;
    
    eventTitle.text = self.tit;
    eventTitle.lineBreakMode = NSLineBreakByWordWrapping;
    eventTitle.numberOfLines = 0;
    
    eventTime.text = self.time;
    eventTime.lineBreakMode = NSLineBreakByWordWrapping;
    eventTime.numberOfLines = 0;
    
    eventAttenders.text = self.attenders;
    eventAttenders.lineBreakMode = NSLineBreakByWordWrapping;
    eventAttenders.numberOfLines = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
