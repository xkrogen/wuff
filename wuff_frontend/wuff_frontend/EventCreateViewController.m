//
//  EventCreateViewController.m
//  wuff_frontend
//
//  Created by Matthew Griffin on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "EventCreateViewController.h"
#import "GroupAutoCompletionObject.h"

@interface EventCreateViewController ()

@property (nonatomic, strong) NSMutableSet *emailList;
@property (nonatomic, strong) NSMutableSet *groupIDList;

@end

@implementation EventCreateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 505 is the minimum you can use for a content-size that doesn't move around but still streches (used for the login page)
    [self.scrollView setContentSize:CGSizeMake(320, 505)];
    [self.scrollView addSubview:self.contentView];
    [self.scrollView setDelegate:self];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    [self.datePicker setMinuteInterval:15];
    // set display date to 15 minutes from now
    [self.datePicker setDate:[NSDate dateWithTimeIntervalSinceNow:15*60]];
    
    [self.autocompleteTextField setBorderStyle:UITextBorderStyleRoundedRect];
    self.autocompleteTextField.delegate = (id)self;
    self.autocompleteTextField.autoCompleteDataSource = (id)self;
    self.autocompleteTextField.autoCompleteDelegate = (id)self;

    [self.autocompleteTextField setAutoCompleteTableBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    // no spell checking / auto correction since persons names
    [self.autocompleteTextField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.autocompleteTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    // auto capitalize words (names)
    [self.autocompleteTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    
    
    
    [[_nameInputView textField] setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [[_locationInputView textField] setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    
    self.datePicker.minimumDate = [NSDate date];

    self.userList = [[NSMutableArray alloc] init];
    self.groupList = [[NSMutableArray alloc] init];
    self.emailList = [[NSMutableSet alloc] init];
    self.groupIDList = [[NSMutableSet alloc] init];
    
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleUserList:" andDelegate:self];
    [_myRequester createRequestWithType:POST forExtension:@"/user/get_all_users" withDictionary:d];
    
    HandleRequest * groupRequester = [[HandleRequest alloc] initWithSelector:@"handleGroupList:" andDelegate:self];
    [groupRequester createRequestWithType:GET forExtension:@"/user/get_groups" withDictionary:d];
    
    // USE THIS CODE TO CREATE THE NAVIGATION CONTROLLER PROGRAMMATICALLY
    UINavigationBar *navigationBar;
    UINavigationItem *navigationBarItem;
    
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 64)];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    [self.navigationItem setTitle:@"Create Event"];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [cancelButton setAccessibilityLabel:@"Cancel Button"];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    // END CODE
    
    if (self.editMode) {
        _locationInputView.textField.text = self.location;
        
        _nameInputView.textField.text = self.myTitle;
        
        //TODO set date as well
        //[_datePicker date]timeIntervalSince1970] stringValue] = self.time;
        
        _emailListInputView.textField.text = self.attenders;
        
        _descriptionInputView.textField.text = self.description;
        
        [_myButton setTitle:@"Edit" forState:UIControlStateNormal];
        
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(delete)];
        [deleteButton setTintColor:[UIColor whiteColor]];
        [deleteButton setAccessibilityLabel:@"Delete Button"];
        [self.navigationItem setRightBarButtonItem:deleteButton];
        
        [self.navigationItem setTitle:@"Edit Event"];
    }
}

-(void)handleUserList:(NSDictionary *)response
{
    
    NSLog(@"HANDLING USER LIST");
    NSInteger userCount = [[response objectForKey:@"count"] integerValue];
    for (int i=1; i<=userCount; i++)
    {
        NSDictionary *user = [response objectForKey:[NSString stringWithFormat:@"%d", i]];
        [_userList addObject:[[UserAutoCompletionObject alloc] initWithUserDictionary:user]];
    }
}

-(void)handleGroupList:(NSDictionary*)response
{
    
    NSLog(@"HANDLING GROUP LIST");
    NSInteger groupCount = [[response objectForKey:@"group_count"] integerValue];
    for (int i=1; i<=groupCount; i++)
    {
        NSDictionary *group = [response objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        NSLog(@"group: %@", group);
        
        [_groupList addObject:[[GroupAutoCompletionObject alloc] initWithGroupDictionary:group]];
    }
    
}

-(IBAction)createModifyEvent
{
    if (!self.eventBeingCreated)
    {
        self.eventBeingCreated = true;
        _myRequester = [[HandleRequest alloc] initWithSelector:@"handleCreateEvent:" andDelegate:self];
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        
        [d setObject:_nameInputView.textField.text forKey:@"title"];
        [d setObject:_descriptionInputView.textField.text forKey:@"description"];
        
        // add the current user logged in to the user_list
        NSString *userlist;
        if (self.editMode)
        {
            userlist = _emailListInputView.textField.text;
        }
        else
        {
            userlist = [NSString stringWithFormat:@"%@, %@", _emailListInputView.textField.text, [[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
        }
        
        [d setObject:userlist forKey:@"user_list"];
        
        [d setObject:[[NSNumber numberWithDouble:[[_datePicker date]timeIntervalSince1970]] stringValue] forKey:@"time"];
        [d setObject:_locationInputView.textField.text forKey:@"location"];
        NSMutableString *groupString = [NSMutableString stringWithString:@""];
        for (NSNumber *groupID in self.groupIDList) {
            [groupString appendFormat:@"%@,",groupID];
        }
        [d setObject:groupString forKey:@"group_list"];
        
        for(id key in d)
            NSLog(@"key=%@ value=%@", key, [d objectForKey:key]);
        
        if (self.editMode) {
            [d setObject: self.eventId forKey:@"event"];
            [_myRequester createRequestWithType:POST forExtension:@"/event/edit_event" withDictionary:d];
            //NSLog([NSString stringWithFormat: @"The EventID is: %@", self.eventId]);
        } else {
            NSLog(@"sending %@",d);
            [_myRequester createRequestWithType:POST forExtension:@"/event/create_event" withDictionary:d];
        }
        //NSLog(@"sent create event request!");
    }
    
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

-(IBAction)delete
{
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleCreateEvent:" andDelegate:self];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:self.eventId forKey:@"event"];
    
    [_myRequester createRequestWithType:POST forExtension:@"/event/cancel_event" withDictionary:d];
    NSLog([NSString stringWithFormat: @"The EventID is: %@", self.eventId]);
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)handleCreateEvent:(NSDictionary *)response
{
    ErrorCode err_code = (ErrorCode)[[response objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            NSLog(@"Moving to main screen");
            SettingsTabViewController *settings = [[SettingsTabViewController alloc] initWithNibName:nil bundle:Nil];
            MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil andSettingsTab:settings];
            
            MSSlidingPanelController *newView = [[MSSlidingPanelController alloc] initWithCenterViewController:main andLeftPanelController:settings];
            
            [self presentViewController:newView animated:YES completion:nil];
            break;
        }
            
        case ERR_INVALID_NAME:
            [self.view makeToast:@"Invalid Title: "];
            self.eventBeingCreated = false;
            break;
            
        case ERR_INVALID_EMAIL:
            [self.view makeToast:@"Invalid Email"];
            self.eventBeingCreated = false;
            break;
            
        case ERR_INVALID_PASSWORD:
            [self.view makeToast:@"Password must be longer"];
            self.eventBeingCreated = false;
            break;
            
        case ERR_EMAIL_TAKEN:
            [self.view makeToast:@"Email Already Taken"];
            self.eventBeingCreated = false;
            break;
            
        case ERR_INVALID_CREDENTIALS:
            [self.view makeToast:@"Incorrect Email/Password"];
            self.eventBeingCreated = false;
            break;
            
        case ERR_INVALID_FIELD:
            [self.view makeToast:@"Invalid Field."];
            self.eventBeingCreated = false;
            break;
            
        case ERR_UNSUCCESSFUL:
            [self.view makeToast:@"Attempt unsuccessful. Please try again"];
            self.eventBeingCreated = false;
            break;
            
        case ERR_INVALID_TIME:
            [self.view makeToast:@"Invalid Time"];
            self.eventBeingCreated = false;
            break;
            
        case ERR_INVALID_SESSION:
            [self.view makeToast:@"Invalid Session. Try logging out and back in"];
            self.eventBeingCreated = false;
            break;
            
        default:
            self.eventBeingCreated = false;
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
        
        handler([self.groupList arrayByAddingObjectsFromArray:self.userList]);
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
        
        
        if([selectedObject respondsToSelector:@selector(getEmail)]) {
        
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
                NSString *previousText = self.emailListInputView.textField.text;
                NSString *addendum = @"";
                if ([previousText isEqualToString:@""])
                    addendum = [NSString stringWithFormat:@"%@", email];
                else
                    addendum = [NSString stringWithFormat:@"%@, %@", previousText, email];
                
                // set the new text
                [self.emailListInputView.textField setText:addendum];
                [self.emailList addObject:email];
            }
        }
        
        else {
            
            
            
            // get the UserObject that we just selected's email
            NSNumber *groupID = [(GroupAutoCompletionObject *)selectedObject getGroupID];
            NSLog(@"selected group %@",groupID);
            
            if ([self.groupIDList containsObject:groupID])
            {
                NSLog(@"already made");
                [self.view makeToast:@"Group already added!"];
            }
            else
            {
                NSLog(@"mmot already made");
                [self.groupIDList addObject:groupID];
            }
            
        }
        
        // remove the text in the autocompleteTextField
        [self.autocompleteTextField setText:@""];
        
        // close the keyboard
        [self.view endEditing:YES];
    } else {
        NSLog(@"selected string '%@' from autocomplete menu", selectedString);
    }
}



@end
