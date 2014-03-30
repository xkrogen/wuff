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
    }
    return self;
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
    
    self.menuList = [[NSMutableArray alloc] initWithArray:@[@"Self", @"Groups", @"+ Add New", @"", @"", @"Settings", @"Logout"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// TABLE VIEW STUFF

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *SimpleIdentifier = @"SimpleIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SimpleIdentifier];
    }
    
    UIColor *textColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:_menuList[indexPath.row] attributes:@{NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]}];
    [cell.detailTextLabel setTextAlignment:NSTextAlignmentRight];
    cell.backgroundColor = [UIColor colorWithRed:47.0f/255.0f green:47.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
    
    if ([_menuList[indexPath.row] isEqualToString:@"Groups"])
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else if ([_menuList[indexPath.row] isEqualToString:@""])
    {
        //
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else if ([_menuList[indexPath.row] isEqualToString:@"Self"])
    {
        cell.detailTextLabel.attributedText = nil;
        cell.textLabel.attributedText = [[NSAttributedString alloc]
            initWithString:@"NEED LOGIN_USER CHANGES"
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
    NSString *identifier = _menuList[indexPath.row];
    
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
        NSLog(@"sent request!");
    }
    
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) handleLogout:(NSDictionary *)response
{
    ErrorCode err_code = (ErrorCode)[[response objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            LoginViewController *login = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
            [self presentViewController:login animated:YES completion:NULL];
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
