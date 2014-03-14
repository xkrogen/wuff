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
    NSArray *attenders1 = @[@"hello1", @"bob1", @"cheese1"];
    NSArray *attenders2 = @[@"hello2", @"bob2", @"cheese2"];
    NSArray *attenders3 = @[@"hello3", @"bob3", @"cheese3"];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"name_0" forKey:@"name"];
    [dict setObject:@"address_0" forKey:@"location"];
    [dict setObject:@"come Chill" forKey:@"description"];
    [dict setObject:@"2:15" forKey:@"time"];
    [dict setObject:attenders1 forKey:@"users"];
    [self.eventList addObject:dict];
    
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
    [dict1 setObject:@"name_1" forKey:@"name"];
    [dict1 setObject:@"address_1" forKey:@"location"];
    [dict1 setObject:@"come Eat" forKey:@"description"];
    [dict1 setObject:@"2:20" forKey:@"time"];
    [dict1 setObject:attenders2 forKey:@"users"];
    [self.eventList addObject:dict1];
    
    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc]init];
    [dict2 setObject:@"name_2" forKey:@"name"];
    [dict2 setObject:@"address_2" forKey:@"location"];
    [dict2 setObject:@"come sleep and have the greatest time of you life tonight wooooo hooo" forKey:@"description"];
    [dict2 setObject:@"2:30" forKey:@"time"];
    [dict2 setObject:attenders3 forKey:@"users"];
    [self.eventList addObject:dict2];
    
    //self.eventList = @[@"Join MEH", @"SUPA FUN TIME", @"Lonely need friends and this is a super long ass event name so idk how it should go"];
}


-(void) handleMainResponse:(NSDictionary *)data {
    NSLog(@"Handle response here!");
    //self.eventList = [[NSMutableArray alloc] init];
    
    for(NSString *key in [data allKeys]) {
        //[self.eventList addObject:[data objectForKey:key]];
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
    
    cell.textLabel.text = [self.eventList[indexPath.row] objectForKey:@"name"];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventViewController *eventView = [[EventViewController alloc]  initWithNibName:nil bundle:nil];
    eventView.tit = [self.eventList[indexPath.row] objectForKey:@"name"];
    eventView.time = [self.eventList[indexPath.row] objectForKey:@"time"];
    eventView.location = [self.eventList[indexPath.row] objectForKey:@"location"];
    eventView.description = [self.eventList[indexPath.row] objectForKey:@"description"];
    eventView.attenders = @"";
    for (NSString *user in [self.eventList[indexPath.row] objectForKey:@"users"]) {
        eventView.attenders = [NSString stringWithFormat:@"%@ %@", user, eventView.attenders];
    }
    [self presentViewController:eventView animated:YES completion:NULL];
}


@end
