//
//  GroupEditViewController.h
//  wuff_frontend
//
//  Created by Matthew Griffin on 4/30/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextField.h"
#import "UserAutoCompletionObject.h"

@interface GroupEditViewController : UIViewController 


@property(nonatomic, strong) IBOutlet UITextField *emailInputView;
@property(nonatomic, strong) IBOutlet UITextField *removeEmailInputView;

@property(nonatomic, strong) IBOutlet MLPAutoCompleteTextField *autocompleteTextField;
@property(nonatomic, strong) IBOutlet MLPAutoCompleteTextField *autocompleteTextField2;

@property(nonatomic, strong) NSMutableArray *userList;

@property(nonatomic, strong) HandleRequest *myRequester;

@property (nonatomic, strong) NSNumber *groupID;

@property (nonatomic,retain) NSMutableArray *emailList;
@property (nonatomic,retain) NSMutableArray *removeEmailList;


-(IBAction)addMembers;

-(IBAction)deleteMembers;

-(IBAction)back;


@end
