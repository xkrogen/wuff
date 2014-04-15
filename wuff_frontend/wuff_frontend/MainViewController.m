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

+ (NSString *)stringForDisplayFromDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitYear
                                                         |kCFCalendarUnitMonth
                                                         |kCFCalendarUnitWeek
                                                         |kCFCalendarUnitDay
                                                         |kCFCalendarUnitHour
                                                         |kCFCalendarUnitMinute)
                                               fromDate:currentDate
                                                 toDate:date
                                                options:0];
    if (components.year == 0) {
        // same year
        if (components.month == 0) {
            // same month
            if (components.week == 0) {
                // same week
                if (components.day == 0) {
                    // same day
                    if (components.hour == 0) {
                        // same hour
                        if (components.minute < 10) {
                            // in 10 mins
                            return @"now";
                        } else {
                            // 10 mins age
                            return [NSString stringWithFormat:@"%dm", (int)(components.minute/10)*10];
                        }
                    } else {
                        // different hour
                        return [NSString stringWithFormat:@"%dh", components.hour];
                    }
                } else {
                    // different day
                    return [NSString stringWithFormat:@"%dd", components.day];
                }
            } else {
                // different week
                return [NSString stringWithFormat:@"%dW", components.week];
            }
        } else {
            // different month
            return [NSString stringWithFormat:@"%dM", components.month];
        }
    } else {
        // different year
        return [NSString stringWithFormat:@"%dY", components.year];
    }
    
    return @"-∞";
}

-(void)refresh
{
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleMainResponse:" andDelegate:self];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    [_myRequester createRequestWithType:GET forExtension:@"/user/get_events" withDictionary:d];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Code to send POST Request
     _myRequester = [[HandleRequest alloc] initWithSelector:@"handleMainResponse:" andDelegate:self];
    
     NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
     [_myRequester createRequestWithType:GET forExtension:@"/user/get_events" withDictionary:d];
     //NSLog(@"sent request!");
    
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
    [settingsTabButton setAccessibilityLabel:@"Settings Tab Button"];
    [navigationBarItem setLeftBarButtonItem:settingsTabButton];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createEvent)];
    [addButton setTintColor:[UIColor whiteColor]];
    [addButton setAccessibilityLabel:@"Add Button"];
    [navigationBarItem setRightBarButtonItem:addButton];
    
    [navigationBar setBarTintColor:[UIColor colorWithRed:49.0f/255.0f green:103.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    [navigationBar pushNavigationItem:navigationBarItem animated:NO];
    [navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [[self view] addSubview:navigationBar];
    // END CODE
    
    // ADD OBSERVER TO SEEK OUT NOTIFICATIONS
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveRemoteNotification:)
     name:UIApplicationDidReceiveRemoteNotification
     object:nil];
}

-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (self.isViewLoaded && self.view.window) {
        // handle the notification
        [self refresh];
    }
}

-(void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidReceiveRemoteNotification
     object:nil];
}

-(void) handleMainResponse:(NSDictionary *)data {
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];;
    switch (err_code)
    {
        case SUCCESS:
        {
            // make sure no duplicates
            [self.eventList removeAllObjects];
            
            // remove notifications
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            int eventCount = (int)[[data objectForKey:@"event_count"] integerValue];
            for(int i=1; i<=eventCount; i++) {
                NSDictionary *event = [data objectForKey:[NSString stringWithFormat:@"%d", i]];
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
    UIViewController *eventCreate = [[EventCreateViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:eventCreate];
    [self presentViewController:navController animated:YES completion:nil];
}

-(IBAction)openSettingsPanel
{
    [[self slidingPanelController] setLeftPanelMaximumWidth:260.0f];
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
    
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if (cell == nil) {
        cell = [[MainViewTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleIdentifier];
    }
    
    NSDictionary *event = self.eventList[indexPath.row];
    
    // test
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:[[event objectForKey:@"time"] integerValue]];
    NSString *timeString = [MainViewController stringForDisplayFromDate:time];
    
    cell.descriptionLabel.text = timeString;
    
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
    
    if ([title length] > 35)
    {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[title attributedSubstringFromRange:NSMakeRange(0, 35)]];
        subString = [[NSAttributedString alloc] initWithString:@".." attributes:attributes];
        [title appendAttributedString:subString];
    }
   
    cell.textLabel.attributedText = title;
    
    // detail (user list)
    cell.detailTextLabel.text = @"";
    NSDictionary *users = [self.eventList[indexPath.row] objectForKey:@"users"];
    int user_count = [[users objectForKey:@"user_count"] intValue];
    for (int i=1; i<=user_count; i++) {
        NSDictionary *user = [users objectForKey:[NSString stringWithFormat:@"%d", i]];
        if ([cell.detailTextLabel.text isEqualToString:@""] || cell.detailTextLabel.text == NULL)
            cell.detailTextLabel.text = [user objectForKey:@"name"];
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", cell.detailTextLabel.text, [user objectForKey:@"name"]];
        
        // +X functionality
        if ([cell.detailTextLabel.text length] > 20)
        {
            if (i != user_count) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@.. +%d", cell.detailTextLabel.text, user_count-i];
                break;
            }
        }
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
    eventView.description = [self.eventList[indexPath.row] objectForKey:@"description"];
    
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
