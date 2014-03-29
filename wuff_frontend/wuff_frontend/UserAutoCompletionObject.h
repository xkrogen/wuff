//
//  UserAutoCompletionObject.h
//  wuff_frontend
//
//  Created by Darren Tsung on 3/27/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompletionObject.h"

@interface UserAutoCompletionObject : NSObject <MLPAutoCompletionObject>

// must have email and name
-(id)initWithUserDictionary:(NSDictionary *)userDict;

-(NSString *)getEmail;

@end
