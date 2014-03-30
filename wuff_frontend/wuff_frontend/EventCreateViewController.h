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
#import "SettingsViewController.h"
#import "MLPAutoCompleteTextField.h"
#import "UserAutoCompletionObject.h"

@interface EventCreateViewController : UIViewController

@property(nonatomic, strong) IBOutlet InputView *nameInputView;
@property(nonatomic, strong) IBOutlet InputView *descriptionInputView;
@property(nonatomic, strong) IBOutlet InputView *emailListInputView;
@property(nonatomic, strong) IBOutlet InputView *locationInputView;
@property(nonatomic, strong) IBOutlet InputView *timeInputView;
@property(nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property(nonatomic, strong) IBOutlet MLPAutoCompleteTextField *autocompleteTextField;

@property(nonatomic, strong) NSMutableArray *userList;

@property(nonatomic, strong) HandleRequest *myRequester;


-(IBAction)createEvent;

-(IBAction)cancel;


@end
