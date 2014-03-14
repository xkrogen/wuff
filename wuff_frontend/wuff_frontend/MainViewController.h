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
#import "UIView+Toast.h"

@interface MainViewController : UIViewController <UITableViewDataSource, UITabBarDelegate>

@property(nonatomic, strong) HandleRequest *myRequester;
@property (nonatomic) NSMutableArray *eventList;
@property (nonatomic, strong) IBOutlet UITableView *mainTable;

-(IBAction)createEvent;

-(void) handleMainResponse:(NSDictionary *)data;

@end
