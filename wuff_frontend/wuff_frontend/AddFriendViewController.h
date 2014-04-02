//
//  AddFriendViewController.h
//  wuff_frontend
//
//  Created by Yang Xiang on 4/1/14.
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

@interface AddFriendViewController : UIViewController
    @property(nonatomic, strong) IBOutlet UITextField *emailInputView;
    @property(nonatomic, strong) IBOutlet MLPAutoCompleteTextField *autocompleteTextField;

    @property(nonatomic, strong) NSMutableArray *userList;

    @property(nonatomic, strong) HandleRequest *myRequester;


    -(IBAction)addFriends;

    -(IBAction)back;
@end
