//
//  ConditionalViewController.m
//  wuff_frontend
//
//  Created by Matthew Griffin on 4/17/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "ConditionalViewController.h"

@interface ConditionalViewController ()

@end

@implementation ConditionalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.autocompleteTextField.autoCompleteDataSource = self;
    self.autocompleteTextField.autoCompleteDelegate = self;
    
    [self.autocompleteTextField setAutoCompleteTableBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    // no spell checking / auto correction since persons names
    [self.autocompleteTextField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.autocompleteTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    // auto capitalize words (names)
    [self.autocompleteTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    
    
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleUserList:" andDelegate:self];
    [_myRequester createRequestWithType:POST forExtension:@"/user/get_all_users" withDictionary:d];
    
    UINavigationBar *navigationBar;
    UINavigationItem *navigationBarItem;
    
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 64)];
    
    [[self view] addSubview:navigationBar];
    
    [self.navigationItem setHidesBackButton:NO];
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    navigationBarItem = [[UINavigationItem alloc] initWithTitle:@"Wuff"];
    
    UIBarButtonItem *settingsTabButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [settingsTabButton setTintColor:[UIColor whiteColor]];
    [settingsTabButton setAccessibilityLabel:@"Settings Tab Button"];
    [navigationBarItem setLeftBarButtonItem:settingsTabButton];

    [navigationBar setBarTintColor:[UIColor colorWithRed:49.0f/255.0f green:103.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    [navigationBar pushNavigationItem:navigationBarItem animated:NO];
    [navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [[self view] addSubview:navigationBar];
    
    self.userList = [[NSMutableArray alloc] init];
    self.emailList = [[NSMutableSet alloc] init];
    
    self.explanation.text = @"How many Wuffers should be attending before you automatically accept?";
    
}


-(void)handleUserList:(NSDictionary *)response
{
    NSInteger userCount = [[response objectForKey:@"count"] integerValue];
    for (int i=1; i<=userCount; i++)
    {
        NSDictionary *user = [response objectForKey:[NSString stringWithFormat:@"%d", i]];
        [self.userList addObject:[[UserAutoCompletionObject alloc] initWithUserDictionary:user]];
    }
}

-(IBAction)typeValueChanged {
    
    if(self.condType.selectedSegmentIndex==0) {
        [self.paramsField resignFirstResponder];
        [self.autocompleteTextField resignFirstResponder];
        
        self.paramsField.text = @"";
        
        self.paramsField.placeholder = @"Enter a Number";
        self.paramsField.keyboardType = UIKeyboardTypeNumberPad;
        self.autocompleteTextField.hidden = YES;
        
        self.explanation.text = @"How many Wuffers should be attending before you automatically accept?";
    }
    else {
        
        if(self.condType.selectedSegmentIndex==1) {
            self.explanation.text = @"If any of these Wuffers accept, you'll automatically accept as well.";
        }
        else {
            self.explanation.text = @"You'll only automatically accept if all of these Wuffers accept first.";
        }
        
        
        self.paramsField.text = @"";
        
        [self.paramsField resignFirstResponder];
        [self.autocompleteTextField resignFirstResponder];
        
        self.paramsField.placeholder = @"Enter a list of Emails";
        self.paramsField.keyboardType = UIKeyboardTypeEmailAddress;
        self.autocompleteTextField.hidden = NO;
    }
}

-(IBAction)accept
{
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleAdd:" andDelegate:self];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:self.event forKey:@"event"];
    [d setObject:[NSNumber numberWithInt:self.condType.selectedSegmentIndex+1] forKey:@"condition_type"];
    
    if(self.condType.selectedSegmentIndex==0) {
        [d setObject:[NSNumber numberWithInteger:[self.paramsField.text integerValue]] forKey:@"condition"];
    }
    else {
        [d setObject:self.paramsField.text forKey:@"condition"];
    }
    
    for(id key in d)
        NSLog(@"key=%@ value=%@", key, [d objectForKey:key]);
    
    [_myRequester createRequestWithType:POST forExtension:@"/event/add_conditional_acceptance" withDictionary:d];
    //NSLog(@"sent create event request!");
    
    // close the keyboard
    [self.view endEditing:YES];
}

-(IBAction)cancel
{
    /*
     MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
     SettingsTabViewController *settings = [[SettingsTabViewController alloc] initWithNibName:nil bundle:Nil];
     
     MSSlidingPanelController *newView = [[MSSlidingPanelController alloc] initWithCenterViewController:main andLeftPanelController:settings];
     
     [self presentViewController:newView animated:YES completion:nil];
     */
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)handleAdd:(NSDictionary *)response
{
    ErrorCode err_code = (ErrorCode)[[response objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            [self.view makeToast:@"Condition Added! Add another or press 'Cancel' to go back to your events"];
            break;
        }
            
        case ERR_INVALID_NAME:
            [self.view makeToast:@"Invalid Name"];
            break;
            
        case ERR_INVALID_EMAIL:
            [self.view makeToast:@"Invalid Email"];
            break;
            
        case ERR_INVALID_PASSWORD:
            [self.view makeToast:@"Password must be longer"];
            break;
            
        case ERR_EMAIL_TAKEN:
            [self.view makeToast:@"Email Already Taken"];
            break;
            
        case ERR_INVALID_CREDENTIALS:
            [self.view makeToast:@"Incorrect Email/Password"];
            break;
            
        case ERR_INVALID_FIELD:
            [self.view makeToast:@"Invalid Field."];
            break;
            
        case ERR_UNSUCCESSFUL:
            [self.view makeToast:@"Attempt unsuccessful. Please try again"];
            break;
            
        case ERR_INVALID_TIME:
            [self.view makeToast:@"Invalid Time"];
            break;
            
        case ERR_INVALID_SESSION:
            [self.view makeToast:@"Invalid Session. Try logging out and back in"];
            break;
    }
}


#pragma mark - MLPAutoCompleteTextField DataSource

// asynchronous fetch
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        // simulate latency
        if(true){
            CGFloat seconds = (arc4random_uniform(4)+arc4random_uniform(4)) / 5; //normal distribution
                                                                                 //NSLog(@"sleeping fetch of completions for %f", seconds);
            sleep(seconds);
        }
        
        /*
         NSArray *completions;
         //completions = @[@"Darren Tsung", @"Erik Krogan", @"Matthew Griffin", @"Yang Xiang", @"Sampson Gu"];
         // a UserAutoCompletionObject is a dictionary that has an object for @"name" and @"email"
         UserAutoCompletionObject *darrenObject = [[UserAutoCompletionObject alloc] initWithUserDictionary:@{@"name": @"Darren Tsung", @"email": @"darren.tsung@gmail.com"}];
         UserAutoCompletionObject *testObject = [[UserAutoCompletionObject alloc] initWithUserDictionary:@{@"name": @"Tester McTest", @"email": @"test@gmail.com"}];
         UserAutoCompletionObject *erikObject = [[UserAutoCompletionObject alloc] initWithUserDictionary:@{@"name": @"Erik Krogen", @"email": @"erikkrogen@gmail.com"}];
         UserAutoCompletionObject *yangObject = [[UserAutoCompletionObject alloc] initWithUserDictionary:@{@"name": @"Yang Xiang", @"email": @"xiangyang57@gmail.com"}];
         UserAutoCompletionObject *mattObject = [[UserAutoCompletionObject alloc] initWithUserDictionary:@{@"name": @"Matthew Griffin", @"email": @"mattgriffin94@yahoo.com"}];
         UserAutoCompletionObject *sampsonObject = [[UserAutoCompletionObject alloc] initWithUserDictionary:@{@"name": @"Sampson Gu", @"email": @"sampsongu@berkeley.edu"}];
         completions = @[darrenObject, testObject, erikObject, yangObject, mattObject, sampsonObject];
         handler(completions);
         */
        
        handler(self.userList);
    });
}

#pragma mark - MLPAutoCompleteTextField Delegate

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedObject){
        NSLog(@"selected object from autocomplete menu %@ with string %@", selectedObject, [selectedObject autocompleteString]);
        
        // get the UserObject that we just selected's email
        NSString *email = [(UserAutoCompletionObject *)selectedObject getEmail];
        
        if ([self.emailList containsObject:email])
        {
            [self.view makeToast:@"User already added!"];
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] isEqualToString:email])
        {
            [self.view makeToast:@"No need to add yourself to the event!"];
        }
        else
        {
            // append the email to emailList text
            NSString *previousText = self.paramsField.text;
            NSString *addendum = @"";
            if ([previousText isEqualToString:@""])
                addendum = [NSString stringWithFormat:@"%@", email];
            else
                addendum = [NSString stringWithFormat:@"%@, %@", previousText, email];
            // set the new text
            [self.paramsField setText:addendum];
            [self.emailList addObject:email];
        }
        
        // remove the text in the autocompleteTextField
        [self.autocompleteTextField setText:@""];
        
        // close the keyboard
        [self.view endEditing:YES];
    } else {
        NSLog(@"selected string '%@' from autocomplete menu", selectedString);
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
