//
//  MainViewController.h
//  wuff_frontend
//
//  Created by Yang Xiang on 3/13/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventViewController.h"
#import "EventCreateViewController.h"
#import "HandleRequest.h"
@interface MainViewController : UIViewController <UITableViewDataSource, UITabBarDelegate>

@property (copy, nonatomic) NSArray *eventList;
-(IBAction)createEvent;
@end
