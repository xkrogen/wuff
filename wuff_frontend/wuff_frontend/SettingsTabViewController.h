//
//  SettingsViewController.h
//  wuff_frontend
//
//  Created by Darren Tsung on 3/29/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSlidingPanelController.h"
#import "HandleRequest.h"
#import "LoginViewController.h"
#import "SettingsViewController.h"
#import "GroupAddViewController.h"
#import "AddFriendViewController.h"

@interface SettingsTabViewController : UIViewController <MSSlidingPanelControllerDelegate, UITableViewDataSource, UITabBarDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property(nonatomic, strong) HandleRequest *myRequester;
@property (nonatomic, strong) NSMutableArray *menuList;


@end
