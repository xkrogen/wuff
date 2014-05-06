//
//  GroupAutoCompletionObject.m
//  wuff_frontend
//
//  Created by Matthew Griffin on 5/5/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "GroupAutoCompletionObject.h"

@implementation GroupAutoCompletionObject

-(id)initWithGroupDictionary:(NSDictionary *)groupDict
{
    if (self = [super init])
    {
        self.name = [groupDict objectForKey:@"name"];
        self.groupID = [groupDict objectForKey:@"group"];
    }
    return self;
}

-(NSNumber *)getGroupID
{
    return self.groupID;
}


#pragma mark - MLPAutoCompletionObject Protocl

- (NSString *)autocompleteString
{
    return self.name;
}

-(UIColor *)getTextColor
{
    return [UIColor colorWithRed:81.0/255.0f green:127/255.0f blue:172.0/255.0f alpha:1.0f];
}

@end
