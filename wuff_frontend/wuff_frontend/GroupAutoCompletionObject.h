//
//  GroupAutoCompletionObject.h
//  wuff_frontend
//
//  Created by Matthew Griffin on 5/5/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompletionObject.h"

@interface GroupAutoCompletionObject : NSObject <MLPAutoCompletionObject>

// must have email and name
-(id)initWithGroupDictionary:(NSDictionary *)groupDict;

-(NSNumber *)getGroupID;

@property (nonatomic,retain) NSString *name;

@property (nonatomic, retain) NSNumber *groupID;


@end
