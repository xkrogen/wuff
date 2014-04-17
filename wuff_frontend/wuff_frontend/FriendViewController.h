//
//  FriendViewController.h
//  wuff_frontend
//
//  Created by Yang Xiang on 4/2/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "HandleRequest.h"
#import "UIView+Toast.h"
#import "SettingsTabViewController.h"
#import "MSSlidingPanelController.h"
#import "MSViewControllerSlidingPanel.h"
#import "AddFriendViewController.h"

@interface FriendViewController : UIViewController <MSSlidingPanelControllerDelegate, UITableViewDataSource, UITabBarDelegate>

@property(nonatomic, strong) HandleRequest *myRequester;
@property (nonatomic) NSMutableArray *friendList;
@property (nonatomic, strong) IBOutlet UITableView *mainTable;

-(void) handleFriendResponse:(NSDictionary *)data;

@end
