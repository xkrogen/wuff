//
//  SettingsViewController.h
//  wuff_frontend
//
//  Created by Darren Tsung on 3/29/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSlidingPanelController.h"

@interface SettingsTabViewController : UIViewController <MSSlidingPanelControllerDelegate, UITableViewDataSource, UITabBarDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) NSArray *menuList;


@end
