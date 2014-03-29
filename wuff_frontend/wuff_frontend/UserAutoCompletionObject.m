//
//  UserAutoCompletionObject.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/27/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "UserAutoCompletionObject.h"

@interface UserAutoCompletionObject()

@property(strong) NSString *name;
@property(strong) NSString *email;

@end


@implementation UserAutoCompletionObject

-(id)initWithUserDictionary:(NSDictionary *)userDict
{
    if (self = [super init])
    {
        self.name = [userDict objectForKey:@"name"];
        self.email = [userDict objectForKey:@"email"];
    }
    return self;
}

-(NSString *)getEmail
{
    return self.email;
}


#pragma mark - MLPAutoCompletionObject Protocl

- (NSString *)autocompleteString
{
    return self.name;
}

@end
