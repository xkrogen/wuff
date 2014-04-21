//
//  SettingsViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/29/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "SettingsTabViewController.h"

@interface SettingsTabViewController ()

@end

@implementation SettingsTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.menuList = [[NSMutableArray alloc] initWithArray:@[@"Self", @"Friends", @"Groups", @"+ Add Group", @"", @"", @"Settings", @"Logout"]];
    }
    return self;
}

-(void)loadGroups
{
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleGroupResponse:" andDelegate:self];
    
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
    [_myRequester createRequestWithType:GET forExtension:@"/user/get_groups" withDictionary:d];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIColor *bg_color = [UIColor colorWithRed:47.0f/255.0f green:47.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
    UIColor *sep_color = [UIColor colorWithRed:80.0f/255.0f green:80.0f/255.0f blue:80.0f/255.0f alpha:1.0f];
    self.view.backgroundColor = bg_color;
    self.table.backgroundColor = bg_color;
    [self.table setSeparatorColor:sep_color];
    
    
}

-(void) handleGroupResponse:(NSDictionary *)data
{
    ErrorCode err_code = (ErrorCode)[[data objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            int group_count = [[data objectForKey:@"group_count"] integerValue];
            
            for(int i=1; i<=group_count; i++)
            {
                NSDictionary *group = [data objectForKey:[NSString stringWithFormat:@"%d", i]];
                // insert it after the @"Group"
                [self.menuList insertObject:group atIndex:3];
            }
            break;
        }
        case ERR_INVALID_SESSION:
            [self.view makeToast:@"Invalid Session. Try logging out and back in"];
            break;
    }
}
                             

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// TABLE VIEW STUFF
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0)
        return 55;
    else
        return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *SimpleIdentifier = @"SimpleIdentifier";
    
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if (cell == nil) {
        cell = [[MainViewTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SimpleIdentifier];
        [cell.statusBar removeFromSuperview];
    }
    
    UIColor *textColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    
    NSString *label;
    NSLog(@"Class %@",[self.menuList[indexPath.row] class] );
    if ([self.menuList[indexPath.row] isKindOfClass:[NSString class]])
    {
        label = self.menuList[indexPath.row];
    }
    else if ([self.menuList[indexPath.row] isKindOfClass:[NSDictionary class]])
    {
        label = [self.menuList[indexPath.row] objectForKey:@"name"];
    }
    else
    {
        label = @"???";
    }
    cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:label attributes:@{NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]}];
    [cell.detailTextLabel setTextAlignment:NSTextAlignmentRight];
    cell.backgroundColor = [UIColor colorWithRed:47.0f/255.0f green:47.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
    
    if ([label isEqualToString:@"Groups"])
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.imageView.image = [UIImage imageNamed:@"groups_icon.png"];
    }
    else if ([label isEqualToString:@""])
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else if ([label isEqualToString:@"Self"])
    {
        if (!cell.profpic)
        {
            [cell loadImageWithCreator:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
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
        cell.detailTextLabel.attributedText = nil;
        cell.textLabel.attributedText = [[NSAttributedString alloc]
            initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]
            attributes:@{NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]}];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else
    {
        
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    if ([self.menuList[indexPath.row] isKindOfClass:[NSString class]])
    {
        identifier = _menuList[indexPath.row];
    }
    else if([self.menuList[indexPath.row] isKindOfClass:[NSDictionary class]])
    {
        identifier = [_menuList[indexPath.row] objectForKey:@"name"];
    }
    else
    {
        identifier = @"???";
    }
    
    if ([identifier isEqualToString:@"Settings"])
    {
        SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
        [self presentViewController:settings animated:YES completion:nil];
    }
    else if ([identifier isEqualToString:@"Logout"])
    {
        _myRequester = [[HandleRequest alloc] initWithSelector:@"handleLogout:" andDelegate:self];
        
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
        [_myRequester createRequestWithType:DELETE forExtension:@"/user/logout_user" withDictionary:d];
        //NSLog(@"sent request!");
    }
    else if ([identifier isEqualToString:@"+ Add Group"])
    {
        GroupCreateViewController *settings = [[GroupCreateViewController alloc] initWithNibName:nil bundle:nil];
        [self presentViewController:settings animated:YES completion:nil];
    }
    else if ([identifier isEqualToString:@"Friends"])
    {
        FriendViewController *settings = [[FriendViewController alloc] initWithNibName:nil bundle:nil];
        [self presentViewController:settings animated:YES completion:nil];
    }

    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) logoutFrontend
{
    // clear defaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookieString"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
    
    // logout of facebook if it's open
    if (FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

-(void) handleLogout:(NSDictionary *)response
{
    ErrorCode err_code = (ErrorCode)[[response objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            [self logoutFrontend];
            
            LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:login];
            [self presentViewController:navController animated:YES completion:nil];
            
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
        default:
            NSLog(@"Wtf. Error code invalid.");
            break;
    }
}

@end
