//
//  GroupViewController.h
//  wuff_frontend
//
//  Created by Darren Tsung on 4/29/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOLabel.h"
#import "GroupEditViewController.h"

@interface GroupViewController : UIViewController

@property(nonatomic, strong) NSString *myTitle;
@property(nonatomic, strong) NSDictionary *groupInfo;
@property(nonatomic, strong) IBOutlet SOLabel *membersLabel;
@property(nonatomic, strong) IBOutlet UILabel *description;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGroup:(NSDictionary *)groupInfo;

@end
