//
//  HandleRequest.h
//  wuff_frontend
//
//  Created by Darren Tsung on 3/7/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GET,
    POST,
    DELETE
} HTTPRequestType;

@interface HandleRequest : NSObject

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSString *cookie;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString *selectorName;

+(NSString *)getBaseUrl;
-(id) initWithSelector:(NSString *)selectorString andDelegate:(id)theDelegate;
+(bool) isStringEmpty:(NSString *)string;
-(bool) createRequestWithType:(HTTPRequestType)requestType forExtension:(NSString *)extensionURL withDictionary:(NSDictionary *)json_dict;

@end
