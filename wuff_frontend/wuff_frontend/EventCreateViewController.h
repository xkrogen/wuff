//
//  EventCreateViewController.h
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

@interface EventCreateViewController : UIViewController <UIScrollViewDelegate>

@property(nonatomic, strong) IBOutlet InputView *nameInputView;
@property(nonatomic, strong) IBOutlet InputView *descriptionInputView;
@property(nonatomic, strong) IBOutlet InputView *emailListInputView;
@property(nonatomic, strong) IBOutlet InputView *locationInputView;
@property(nonatomic, strong) IBOutlet InputView *timeInputView;
@property(nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property(nonatomic, strong) IBOutlet MLPAutoCompleteTextField *autocompleteTextField;

@property (nonatomic,retain)IBOutlet UIButton *myButton;

@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) IBOutlet UIView *contentView;

@property(nonatomic, strong) NSMutableArray *userList;

@property(nonatomic, strong) HandleRequest *myRequester;

@property(nonatomic) bool editMode;
@property(nonatomic, strong) NSString *myTitle;
@property(nonatomic, strong) NSString *location;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, strong) NSString *attenders;
@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSString *eventId;


@end
