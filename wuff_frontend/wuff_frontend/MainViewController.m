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
    NSDictionary *attenders1 = @{@"1" : @{ @"name" : @"Darren T" },
                                 @"2" : @{ @"name" : @"Erik K" },
                                 @"3" : @{ @"name" : @"Yang X"} };
    NSDictionary *attenders2 = @{@"1" : @{ @"name" : @"Matt G" },
                                 @"2" : @{ @"name" : @"Sampson G" },
                                 @"3" : @{ @"name" : @"Kevin Y"} };
    NSDictionary *attenders3 = @{@"1" : @{ @"name" : @"Rick L" },
                                 @"2" : @{ @"name" : @"Bob M" },
                                 @"3" : @{ @"name" : @"Jonathan L"} };

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"name_0" forKey:@"title"];
    [dict setObject:@"address_0" forKey:@"location"];
    [dict setObject:@"come Chill" forKey:@"description"];
    [dict setObject:@"2:15" forKey:@"time"];
    [dict setObject:attenders1 forKey:@"users"];
    [self.eventList addObject:dict];
    
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]init];
    [dict1 setObject:@"name_1" forKey:@"title"];
    [dict1 setObject:@"address_1" forKey:@"location"];
    [dict1 setObject:@"come Eat" forKey:@"description"];
    [dict1 setObject:@"2:20" forKey:@"time"];
    [dict1 setObject:attenders2 forKey:@"users"];
    [self.eventList addObject:dict1];
    
    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc]init];
    [dict2 setObject:@"name_2" forKey:@"title"];
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
    
    cell.textLabel.text = [self.eventList[indexPath.row] objectForKey:@"title"];
    
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
        eventView.attenders = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"name"], eventView.attenders];
    }
    
    [self presentViewController:eventView animated:YES completion:NULL];
}


@end
