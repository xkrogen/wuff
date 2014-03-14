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
    
     NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys: nil];
     [_myRequester createRequestWithType:GET forExtension:@"/user/get_events" withDictionary:d];
     NSLog(@"sent request!");
    
    
    //self.eventList = @[@"Join MEH", @"SUPA FUN TIME", @"Lonely need friends and this is a super long ass event name so idk how it should go"];
}


-(void) handleMainResponse:(NSDictionary *)data {
    NSLog(@"Handle response here!");
    self.eventList = [[NSMutableArray alloc] init];
    
    for(NSString *key in [data allKeys]) {
        [self.eventList addObject:[data objectForKey:key]];
        NSLog(@"Key:%@, Value:%@", key, [data objectForKey:key]);
    }
}

- (IBAction)createEvent{
    EventCreateViewController *eventCreate = [[EventCreateViewController alloc]  initWithNibName:nil bundle:nil];
    [self presentViewController:eventCreate animated:YES completion:NULL];
    
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleIdentifier];
    }
    
    cell.textLabel.text = self.eventList[indexPath.row];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventViewController *eventView = [[EventViewController alloc]  initWithNibName:nil bundle:nil];
    eventView.tit = self.eventList[indexPath.row];
    [self presentViewController:eventView animated:YES completion:NULL];
}


@end
