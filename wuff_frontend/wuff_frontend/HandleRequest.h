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

typedef enum {
    SUCCESS = 1,
    ERR_INVALID_NAME = -1,
    ERR_INVALID_EMAIL = -2,
    ERR_INVALID_PASSWORD = -3,
    ERR_EMAIL_TAKEN = -4,
    ERR_INVALID_CREDENTIALS = -5,
    ERR_INVALID_FIELD = -6,
    ERR_UNSUCCESSFUL = -7,
    ERR_INVALID_TIME = -10,
    ERR_INVALID_SESSION = -11
} ErrorCode;

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
