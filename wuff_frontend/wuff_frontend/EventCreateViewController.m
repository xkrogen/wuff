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


-(IBAction)createEvent
{
    _myRequester = [[HandleRequest alloc] initWithSelector:@"handleCreateEvent:" andDelegate:self];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:_nameInputView.textField.text forKey:@"name"];
    [d setObject:_descriptionInputView.textField.text forKey:@"description"];
    [d setObject:_emailListInputView.textField.text forKey:@"user_list"];
    [d setObject:[[NSNumber numberWithDouble:[[_datePicker date]timeIntervalSince1970]] stringValue] forKey:@"time"];
    [d setObject:_locationInputView.textField.text forKey:@"location"];
    
    for(id key in d)
        NSLog(@"key=%@ value=%@", key, [d objectForKey:key]);
    
    [_myRequester createRequestWithType:POST forExtension:@"/event/create_event" withDictionary:d];
    NSLog(@"sent create event request!");
    
}

-(IBAction)cancel
{
    MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:main animated:YES completion:NULL];
}


-(void)handleCreateEvent:(NSDictionary *)response
{
    ErrorCode err_code = (ErrorCode)[[response objectForKey:@"err_code"] integerValue];
    switch (err_code)
    {
        case SUCCESS:
        {
            NSLog(@"Moving to main screen");
            MainViewController *main = [[MainViewController alloc] initWithNibName:nil bundle:nil];
            [self presentViewController:main animated:YES completion:NULL];
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
}

@end
