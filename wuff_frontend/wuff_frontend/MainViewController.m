//
//  MainViewController.m
//  wuff_frontend
//
//  Created by Yang Xiang on 3/13/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    //Code to send POST Request
     _myRequester = [[HandleRequest alloc] initWithSelector:@"handleMainResponse:" andDelegate:self];
    
     NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: @"all events", @"email", nil];
     [_myRequester createRequestWithType:GET forExtension:@"/user/get_events" withDictionary:d];
     NSLog(@"sent request!");
    
    self.eventList = [[NSMutableArray alloc] init];
    
    // USE THIS CODE TO CREATE THE NAVIGATION CONTROLLER PROGRAMMATICALLY
    UINavigationBar *navigationBar;
    UINavigationItem *navigationBarItem;
    
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 64)];
    
    [[self view] addSubview:navigationBar];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    navigationBarItem = [[UINavigationItem alloc] initWithTitle:@"Wuff"];
    
    UIBarButtonItem *settingsTabButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettingsPanel)];
    [settingsTabButton setTintColor:[UIColor whiteColor]];
    [navigationBarItem setLeftBarButtonItem:settingsTabButton];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createEvent)];
    [addButton setTintColor:[UIColor whiteColor]];
    [navigationBarItem setRightBarButtonItem:addButton];
    
    [navigationBar setBarTintColor:[UIColor colorWithRed:49.0f/255.0f green:103.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    [navigationBar pushNavigationItem:navigationBarItem animated:NO];
    [navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [[self view] addSubview:navigationBar];
    // END CODE
    
}


-(void) handleMainResponse:(NSDictionary *)data {
    NSLog(@"Handle response here!");
    //self.eventList = [[NSMutableArray alloc] init];
    
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];;
    switch (err_code)
    {
        case SUCCESS:
        {
            int eventCount = (int)[[data objectForKey:@"event_count"] integerValue];
            for(int i=1; i<=eventCount; i++) {
                NSDictionary *event = [data objectForKey:[NSString stringWithFormat:@"%d", i]];
                NSLog(@"Event: %@", event);
                [self.eventList addObject:event];
            }
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
    [_mainTable reloadData];
}

-(IBAction)createEvent{
    EventCreateViewController *eventCreate = [[EventCreateViewController alloc]  initWithNibName:nil bundle:nil];
    [self presentViewController:eventCreate animated:YES completion:nil];
    NSLog(@"WTF?");
}

-(IBAction)openSettingsPanel
{
    if ([[self slidingPanelController] sideDisplayed] == MSSPSideDisplayedLeft)
    {
        [[self slidingPanelController] closePanel];
    }
    else
    {
        [[self slidingPanelController] openLeftPanel];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *SimpleIdentifier = @"SimpleIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleIdentifier];
    }
    
    NSDictionary *event = self.eventList[indexPath.row];
    
    UIFont *cellTitleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    UIFont *cellTitleSmallFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    UIFont *cellDetailFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    
    // title
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:cellTitleFont forKey:NSFontAttributeName];
    NSAttributedString *subString = [[NSAttributedString alloc] initWithString:[event objectForKey:@"title"] attributes:attributes];
    [title appendAttributedString:subString];
    
    NSDictionary *attributesSmall = [NSDictionary dictionaryWithObject:cellTitleSmallFont forKey:NSFontAttributeName];
    subString = [[NSAttributedString alloc] initWithString:@" at " attributes:attributesSmall];
    [title appendAttributedString:subString];
    
    subString = [[NSAttributedString alloc] initWithString:[event objectForKey:@"location"] attributes:attributes];
    [title appendAttributedString:subString];
   
    cell.textLabel.attributedText = title;
    
    // detail (user list)
    NSDictionary *users = [self.eventList[indexPath.row] objectForKey:@"users"];
    int user_count = [[users objectForKey:@"user_count"] intValue];
    for (int i=1; i<=user_count; i++) {
        NSDictionary *user = [users objectForKey:[NSString stringWithFormat:@"%d", i]];
        if ([cell.detailTextLabel.text isEqualToString:@""] || cell.detailTextLabel.text == NULL)
            cell.detailTextLabel.text = [user objectForKey:@"name"];
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", cell.detailTextLabel.text, [user objectForKey:@"name"]];
    }
    cell.detailTextLabel.font = cellDetailFont;
    
    /*  ||  PUT IN IMAGE ||
    NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    cell.imageView.image = theImage;
    */
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventViewController *eventView = [[EventViewController alloc]  initWithNibName:nil bundle:nil];
    eventView.myTitle = [self.eventList[indexPath.row] objectForKey:@"title"];
    
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:[[self.eventList[indexPath.row] objectForKey:@"time"] integerValue]];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy | hh:mm a"];
    eventView.time = [format stringFromDate:time];

    
    eventView.location = [self.eventList[indexPath.row] objectForKey:@"location"];
    //eventView.description = [self.eventList[indexPath.row] objectForKey:@"description"];
    eventView.description = @"Nothing here!";
    
    // parse attendees
    eventView.attenders = @"";
    NSDictionary *users = [self.eventList[indexPath.row] objectForKey:@"users"];
    int user_count = [[users objectForKey:@"user_count"] intValue];
    for (int i=1; i<=user_count; i++) {
        NSDictionary *user = [users objectForKey:[NSString stringWithFormat:@"%d", i]];
        if ([eventView.attenders isEqualToString:@""])
            eventView.attenders = [user objectForKey:@"name"];
        else
            eventView.attenders = [NSString stringWithFormat:@"%@, %@", eventView.attenders, [user objectForKey:@"name"]];
    }
    
    [self presentViewController:eventView animated:YES completion:NULL];
}


@end
