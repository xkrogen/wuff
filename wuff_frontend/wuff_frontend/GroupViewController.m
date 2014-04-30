//
//  GroupViewController.m
//  wuff_frontend
//
//  Created by Darren Tsung on 4/29/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "GroupViewController.h"

@interface GroupViewController ()

@end

@implementation GroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGroup:(NSDictionary *)groupInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.groupInfo = groupInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myTitle = [self.groupInfo objectForKey:@"name"];
    NSDictionary *users = [self.groupInfo objectForKey:@"users"];
    NSInteger userCount = [[users objectForKey:@"user_count"] integerValue];
    self.membersLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.membersLabel.numberOfLines = 0;
    for (int i=1; i<=userCount; i++)
    {
        NSDictionary *user = [users objectForKey:[NSString stringWithFormat:@"%d", i]];
        NSString *displayName = [NSString stringWithFormat:@"%@\n%@\n\n", [user objectForKey:@"name"], [user objectForKey:@"email"]];
        self.membersLabel.text = [NSString stringWithFormat:@"%@%@", self.membersLabel.text, displayName];
    }
    [self.membersLabel sizeToFit];
    
    self.description.text = [self.groupInfo objectForKey:@"description"];

    // Do any additional setup after loading the view from its nib.
    // USE THIS CODE TO CREATE THE NAVIGATION CONTROLLER PROGRAMMATICALLY
    UINavigationBar *navigationBar;
    UINavigationItem *navigationBarItem;
    
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 64)];
    
    [[self view] addSubview:navigationBar];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize: 18.0f]}];
    navigationBarItem = [[UINavigationItem alloc] initWithTitle:self.myTitle];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [backButton setTintColor:[UIColor whiteColor]];
    [backButton setAccessibilityLabel:@"GroupView Back Button"];
    [navigationBarItem setLeftBarButtonItem:backButton];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    [editButton setTintColor:[UIColor whiteColor]];
    [editButton setAccessibilityLabel:@"GroupView Edit Button"];
    [navigationBarItem setRightBarButtonItem:editButton];
    
    [navigationBar setBarTintColor:[UIColor colorWithRed:49.0f/255.0f green:103.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
    [navigationBar pushNavigationItem:navigationBarItem animated:NO];
    [navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [[self view] addSubview:navigationBar];
    // END CODE
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)edit {
    
    GroupEditViewController *editView = [[GroupEditViewController alloc] initWithNibName:nil bundle:nil];
    editView.groupID = self.groupInfo[@"group"];
    NSLog(@"GROUP ID: %@", self.groupInfo[@"group"] );
    [self presentViewController:editView animated:YES completion:nil];
    
    
    
}


-(IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
