//
//  FriendViewController.m
//  wuff_frontend
//
//  Created by Yang Xiang on 4/2/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "FriendViewController.h"
#import "MainViewTableViewCell.h"

@interface FriendViewController ()

@end

@implementation FriendViewController

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
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleFriendResponse:" andDelegate:self];
    
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    [_myRequester createRequestWithType:GET forExtension:@"/user/get_friends" withDictionary:d];
    NSLog(@"sent request!");
    
    self.friendList = [[NSMutableArray alloc] init];

    // USE THIS CODE TO CREATE THE NAVIGATION CONTROLLER PROGRAMMATICALLY
    UINavigationBar *navigationBar;
    UINavigationItem *navigationBarItem;
    
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 64)];
    
    [[self view] addSubview:navigationBar];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    navigationBarItem = [[UINavigationItem alloc] initWithTitle:@"Friends"];
    

    UIBarButtonItem *settingsTabButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
    style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    [settingsTabButton setTintColor:[UIColor whiteColor]];
    [navigationBarItem setLeftBarButtonItem:settingsTabButton];
    
    [settingsTabButton setAccessibilityLabel:@"Friend Add Back"];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriend)];
    [addButton setTintColor:[UIColor whiteColor]];
    [addButton setAccessibilityLabel:@"Friend Add Button"];
    [navigationBarItem setRightBarButtonItem:addButton];
    
    [navigationBar setBarTintColor:[UIColor colorWithRed:49.0f/255.0f green:103.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    [navigationBar pushNavigationItem:navigationBarItem animated:NO];
    [navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [[self view] addSubview:navigationBar];
    // END CODE
    
}

-(void) handleFriendResponse:(NSDictionary *)data {
    NSLog(@"Handle response here!");
    //self.eventList = [[NSMutableArray alloc] init];
    
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];;
    switch (err_code)
    {
        case SUCCESS:
        {
            [self.friendList removeAllObjects];
            int friendCount = (int)[[data objectForKey:@"friend_count"] integerValue];
            for(int i=1; i<=friendCount; i++) {
                NSDictionary *friend = [data objectForKey:[NSString stringWithFormat:@"%d", i]];
                //NSLog(@"Friend: %@", friend);
                [self.friendList addObject:friend];
            }
            
            //sort friends alphabetically
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
            self.friendList =[NSMutableArray arrayWithArray:[self.friendList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
            
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
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *SimpleIdentifier = @"SimpleIdentifier";
    
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if (cell == nil) {
        cell = [[MainViewTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleIdentifier];
    }

    [cell.statusBar removeFromSuperview];
    NSDictionary *friend = self.friendList[indexPath.row];
    
    UIFont *cellTitleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    UIFont *cellDetailFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    
    // title
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:cellTitleFont forKey:NSFontAttributeName];
    NSAttributedString *subString = [[NSAttributedString alloc] initWithString:[friend objectForKey:@"name"] attributes:attributes];
    [title appendAttributedString:subString];
    
    cell.textLabel.attributedText = title;
    
    cell.detailTextLabel.font = cellDetailFont;
    
    
    if (!cell.profpic)
    {
        [cell loadImageWithCreatorEmail:[friend objectForKey:@"email"]];
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
        [cell setNeedsLayout];
        [cell setNeedsDisplay];
        
        UIGraphicsEndImageContext();
    }
    else
    {
        cell.imageView.image = cell.profpic;
        [cell setNeedsLayout];
        [cell setNeedsDisplay];
    }
    [cell setEnabled];
    
    /*  ||  PUT IN IMAGE ||
     NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
     UIImage *theImage = [UIImage imageWithContentsOfFile:path];
     cell.imageView.image = theImage;
     */
    [_mainTable setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
/*
 *MyFriend view, which will have detailed options
 */
    [_mainTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _myRequester = [[HandleRequest alloc] initWithSelector:@"deleteFriendResponse:" andDelegate:self];
        NSDictionary *friend = self.friendList[indexPath.row];

        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:[friend objectForKey:@"email"] forKey:@"friend_email"];
        [_myRequester createRequestWithType:POST forExtension:@"/user/delete_friend" withDictionary:d];

        NSLog(@"sent request!");
        //NSLog([d objectForKey:@"friend_email"]);
    }
}

-(void) deleteFriendResponse:(NSDictionary *)data {
    NSLog(@"Delete Friend response here!");
    //self.eventList = [[NSMutableArray alloc] init];
    
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];;
    switch (err_code)
    {
        case SUCCESS:
        {
            _myRequester = [[HandleRequest alloc] initWithSelector:@"handleFriendResponse:" andDelegate:self];
            
            NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
            [_myRequester createRequestWithType:GET forExtension:@"/user/get_friends" withDictionary:d];
            
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

-(IBAction)back
{
    SettingsTabViewController *settings = [[SettingsTabViewController alloc] initWithNibName:nil bundle:Nil];
    MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil andSettingsTab:settings];
    MSSlidingPanelController *newView = [[MSSlidingPanelController alloc] initWithCenterViewController:main andLeftPanelController:settings];
    [self presentViewController:newView animated:YES completion:nil];
}

-(IBAction)addFriend{
    AddFriendViewController *addFd = [[AddFriendViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:addFd animated:YES completion:nil];

}

@end
