//
//  MainViewTableViewCell.h
//  wuff_frontend
//
//  Created by Darren Tsung on 4/15/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"
#import "RectUIVew.h"

@interface MainViewTableViewCell : MCSwipeTableViewCell

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) RectUIVew *statusBar;

@end
