//
//  GroupCreateViewController.h
//  wuff_frontend
//
//  Created by Matthew Griffin on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HandleRequest.h"
#import "UIView+Toast.h"
#import "InputView.h"
#import "MainViewController.h"
#import "SettingsTabViewController.h"
#import "MLPAutoCompleteTextField.h"
#import "UserAutoCompletionObject.h"

@interface GroupCreateViewController : UIViewController <UIScrollViewDelegate>

@property(nonatomic, strong) IBOutlet InputView *nameInputView;
@property(nonatomic, strong) IBOutlet InputView *emailListInputView;
@property(nonatomic, strong) IBOutlet InputView *descriptionInputView;
@property(nonatomic, strong) IBOutlet MLPAutoCompleteTextField *autocompleteTextField;

@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) IBOutlet UIView *contentView;

@property(nonatomic, strong) NSMutableArray *userList;

@property(nonatomic, strong) HandleRequest *myRequester;


-(IBAction)createGroup;

-(IBAction)cancel;


@end
