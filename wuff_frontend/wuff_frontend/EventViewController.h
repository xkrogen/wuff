//
//  EventViewController.h
//  wuff_frontend
//
//  Created by Yang Xiang on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"
#import "SettingsViewController.h"
#import "MSSlidingPanelController.h"

@interface EventViewController : UIViewController {
    
    IBOutlet UILabel *eventTitle;
    IBOutlet UILabel *eventLocation;
    IBOutlet UILabel *eventTime;
    IBOutlet UILabel *eventAttenders;
    IBOutlet UILabel *eventDescription;
    
    
}
// set in main menu and will be passed to Event View
@property(nonatomic, strong) NSString *myTitle;
@property(nonatomic, strong) NSString *location;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, strong) NSString *attenders;
@property(nonatomic, strong) NSString *description;

-(IBAction)backButton;


@end
