//
//  EventViewController.h
//  wuff_frontend
//
//  Created by Yang Xiang on 3/11/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController {
    
    IBOutlet UILabel *eventTitle;
    IBOutlet UILabel *eventLocation;
    IBOutlet UILabel *eventTime;
    IBOutlet UILabel *eventAttenders;
    IBOutlet UILabel *eventDescription;
    
    
}
//set in main menue and will be passed to Event View
@property(nonatomic) NSString *tit;
@property(nonatomic) NSString *location;
@property(nonatomic) NSString *time;
@property(nonatomic) NSString *attenders;
@property(nonatomic) NSString *description;


@end
