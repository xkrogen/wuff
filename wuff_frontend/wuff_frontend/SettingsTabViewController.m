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
    self.view.backgroundColor = bg_color;
    self.table.backgroundColor = bg_color;
    
    self.menuList = @[@"Groups", @"+Add New", @"Settings"];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleIdentifier];
    }
    
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:_menuList[indexPath.row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]}];
    cell.backgroundColor = [UIColor colorWithRed:47.0f/255.0f green:47.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
    
    return cell;
}

@end
