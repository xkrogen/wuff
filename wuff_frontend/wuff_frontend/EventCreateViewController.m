//
//  EventCreateViewController.m
//  wuff_frontend
//
//  Created by Matthew Griffin on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "EventCreateViewController.h"

@interface EventCreateViewController ()

@end

@implementation EventCreateViewController


-(IBAction)createEvent {
    
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleCreate:" andDelegate:self];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:_nameInputView.textField.text forKey:@"name"];
    [d setObject:_descriptionInputView.textField.text forKey:@"description"];
    [d setObject:[_emailListInputView.textField.text componentsSeparatedByString:@","] forKey:@"user_list"];
    [d setObject:[NSNumber numberWithDouble:[[_datePicker date]timeIntervalSince1970]] forKey:@"time"];
    [d setObject:_locationInputView.textField.text forKey:@"location"];
    
    [_myRequester createRequestWithType:POST forExtension:@"/event/create_event" withDictionary:d];
    NSLog(@"sent create event request!");
    
}

-(IBAction)cancel {
    
    MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:main animated:YES completion:NULL];
}


-(void)handleCreate {
    

    
}


@end
