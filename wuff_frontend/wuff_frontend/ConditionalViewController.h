//
//  ConditionalViewController.h
//  wuff_frontend
//
//  Created by Matthew Griffin on 4/17/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextField.h"
#import "UserAutoCompletionObject.h"
#import "InputView.h"
#import "MainViewController.h"

@interface ConditionalViewController : UIViewController <MLPAutoCompleteTextFieldDataSource,MLPAutoCompleteTextFieldDelegate>



@property(nonatomic, strong) IBOutlet MLPAutoCompleteTextField *autocompleteTextField;
@property(nonatomic, strong) IBOutlet UITextField *paramsField;
@property(nonatomic, strong) HandleRequest *myRequester;
@property (nonatomic,strong) NSMutableArray *userList;
@property (nonatomic,strong) NSMutableSet *emailList;
@property (nonatomic,strong) IBOutlet UISegmentedControl *condType;
@property (nonatomic, strong) IBOutlet UITextView *explanation;
@property id event;
@property (nonatomic,retain) IBOutlet UILabel *typeField;
@property (nonatomic ,retain) IBOutlet UILabel *numberLabel;
@property (nonatomic,retain) IBOutlet UITextView *paramsView;



-(IBAction)typeValueChanged;
-(IBAction)accept;


@end
