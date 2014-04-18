//
//  MainViewController.m
//  wuff_frontend
//
//  Created by Yang Xiang on 3/13/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "MainViewController.h"

typedef enum {
    ATTENDING,
    NO_ANSWER,
    DECLINED
} AttendState;

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        [self.mainTable addSubview:self.refreshControl];
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
                        return [NSString stringWithFormat:@"%ldh", (long)components.hour];
                    }
                } else {
                    // different day
                    return [NSString stringWithFormat:@"%dd", components.day];
                }
            } else {
                // different week
                return [NSString stringWithFormat:@"%ldW", (long)components.week];
            }
        } else {
            // different month
            return [NSString stringWithFormat:@"%ldM", (long)components.month];
        }
    } else {
        // different year
        return [NSString stringWithFormat:@"%ldY", (long)components.year];
    }
    
    return @"-∞";
}

-(void)refresh
{
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleMainResponse:" andDelegate:self];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    [_myRequester createRequestWithType:GET forExtension:@"/user/get_events" withDictionary:d];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleMainResponse:" andDelegate:self];
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    [_myRequester createRequestWithType:GET forExtension:@"/user/get_events" withDictionary:d];
    [self.refreshControl endRefreshing];
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

-(void) handleGoingToEvent:(NSDictionary *)data {
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            break;
        }
        default:
            [self.view makeToast:@"Error in accepting event"];
            break;
    }
}

-(void) handleNotGoingToEvent:(NSDictionary *)data {
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            break;
        }
        default:
            [self.view makeToast:@"Error in declining event"];
            break;
    }
}

-(void) handleMainResponse:(NSDictionary *)data {
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];
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
            
            //Sort Newest Events to be at top of page
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time"  ascending:NO];
            self.eventList= [[self.eventList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] copy];
            
            
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

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *event = self.eventList[indexPath.row];
    
    NSString *SimpleIdentifier = [NSString stringWithFormat:@"%d", indexPath.row];
    
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    AttendState userAttendState;
    UIColor *appColor = [UIColor colorWithRed:81.0f/255.0f green:127.0f/255.0f blue:172.0f/255.0f alpha:1.0f];
    if (cell == nil) {
        cell = [[MainViewTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.firstTrigger = 0.2;
        cell.secondTrigger = 0.7;
        
        // Setting the background color of the cell.
        NSDictionary *users = [event objectForKey:@"users"];
        int user_count = [[users objectForKey:@"user_count"] intValue];
        for (int i=1; i<=user_count; i++) {
            NSDictionary *user = [users objectForKey:[NSString stringWithFormat:@"%d", i]];
            if ([[user objectForKey:@"name"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]])
            {
                // if this user is attending
                if ([[user objectForKey:@"status"] integerValue] == 1)
                {
                    userAttendState = ATTENDING;
                    cell.statusBar.color = appColor;
                    [cell setEnabled];
                }
                else if([[user objectForKey:@"status"] integerValue] == -1)
                {
                    userAttendState = DECLINED;
                    cell.statusBar.color = [UIColor lightGrayColor];
                    [cell setTransparentDisabled];
                }
                else
                {
                    userAttendState = NO_ANSWER;
                    cell.statusBar.color = [UIColor lightGrayColor];
                }
            }
        }
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    if (!cell.profpic)
    {
        [cell loadImageWithCreator:[event objectForKey:@"creator"]];
        cell.imageView.image = [UIImage imageNamed:@"profilepic.png"];
        UIImage *image = cell.imageView.image;
        CGSize targetSize = CGSizeMake(42,42);
        UIGraphicsBeginImageContext(targetSize);
        
        CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
        thumbnailRect.origin = CGPointMake(0.0,0.0);
        thumbnailRect.size.width  = targetSize.width;
        thumbnailRect.size.height = targetSize.height;
        
        [image drawInRect:thumbnailRect];
        
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    else
    {
        cell.imageView.image = cell.profpic;
    }
    
    // Configuring the views and colors.
    UIView *checkView = [self viewWithImageName:@"check"];
    
    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    UIView *clockView = [self viewWithImageName:@"clock"];
    UIColor *yellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];
    
    UIView *listView = [self viewWithImageName:@"list"];
    UIColor *brownColor = [UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0];
    
    // Setting the default inactive state color to the tableView background color.
    [cell setDefaultColor:[UIColor lightGrayColor]];
    
    // Adding gestures per state basis.
    [cell setSwipeGestureWithView:checkView color:appColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Checkmark\" cell");
        ((MainViewTableViewCell *)cell).statusBar.color = appColor;
        [(MainViewTableViewCell *)cell setEnabled];
        [((MainViewTableViewCell *)cell).statusBar setNeedsDisplay];
        _myRequester = [[HandleRequest alloc] initWithSelector:@"handleGoingToEvent:" andDelegate:self];
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[event objectForKey:@"event"], @"event", @1, @"status",nil];
        [_myRequester createRequestWithType:POST forExtension:@"/event/update_user_status" withDictionary:d];
    }];
    
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Cross\" cell");
        ((MainViewTableViewCell *)cell).statusBar.color = [UIColor lightGrayColor];
        [(MainViewTableViewCell *)cell setTransparentDisabled];
        [((MainViewTableViewCell *)cell).statusBar setNeedsDisplay];
        _myRequester = [[HandleRequest alloc] initWithSelector:@"handleNotGoingToEvent:" andDelegate:self];
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[event objectForKey:@"event"], @"event", @-1, @"status",nil];
        [_myRequester createRequestWithType:POST forExtension:@"/event/update_user_status" withDictionary:d];
    }];
    
    [cell setSwipeGestureWithView:clockView color:yellowColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Clock\" cell");
    }];
    
    [cell setSwipeGestureWithView:listView color:brownColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"List\" cell");
    }];
    
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
    
    if ([title length] > 27)
    {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[title attributedSubstringFromRange:NSMakeRange(0, 27)]];
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
        NSString *name = [user objectForKey:@"name"];
        
        // +X functionality
        // fix for ", " existing only
        if ([cell.detailTextLabel.text length] > 34)
        {
            if (i != user_count) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@.. +%d", cell.detailTextLabel.text, user_count-i];
                break;
            }
        }
        
        if ([cell.detailTextLabel.text isEqualToString:@""] || cell.detailTextLabel.text == NULL)
            cell.detailTextLabel.text = name;
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", cell.detailTextLabel.text, name];
        
        // +X functionality
        if ([cell.detailTextLabel.text length] > 30)
        {
            cell.detailTextLabel.text = [[NSString alloc] initWithString:[cell.detailTextLabel.text substringWithRange:NSMakeRange(0, 30)]];
            if (i != user_count) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@.. +%d", cell.detailTextLabel.text, user_count-i];
                break;
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@..", cell.detailTextLabel.text];
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
