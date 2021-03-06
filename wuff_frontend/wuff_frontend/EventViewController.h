//
//  EventViewController.h
//  wuff_frontend
//
//  Created by Yang Xiang on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MainViewController.h"
#import "SettingsTabViewController.h"
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
@property(nonatomic, strong) NSMutableAttributedString *attenders;
@property(nonatomic, strong) NSString *attendersEmailList;
@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSString *eventId;
@property(nonatomic, strong) NSDate *timeDate;

@property(nonatomic) bool owner;

-(IBAction)backButton;


@end