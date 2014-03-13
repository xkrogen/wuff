//
//  HandleRequest.m
//  wuff_frontend
//
//  Created by Darren Tsung on 3/7/14.
//  Copyright (c) 2014 Wuff Productions. All rights reserved.
//

#import "HandleRequest.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation HandleRequest

+(NSString *)getBaseUrl
{
    return @"http://wuff.herokuapp.com";
}

-(id) initWithSelector:(NSString *)selectorString andDelegate:(id)theDelegate
{
    if (self = [super init])
    {
        _selectorName = selectorString;
        _delegate = theDelegate;
    }
    return self;
}

+(bool)isStringEmpty:(NSString *)string
{
    if([string length] == 0) { //string is empty or nil
        return true;
    }
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return true;
    }
    return false;
}

-(bool)createRequestWithType:(HTTPRequestType)requestType forExtension:(NSString *)extensionURL withDictionary:(NSDictionary *)json_dict
{
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json_dict options:kNilOptions error:&error];
    
    if (error)
    {
        NSLog(@"ERROR: %@, %@", error, [error localizedDescription]);
    }
    else
    {
        // init new data
        _data = [[NSMutableData alloc] init];
        
        NSString *URL_str = [NSString stringWithFormat:@"%@%@", [HandleRequest getBaseUrl], extensionURL];
        
        // make sure string is not empty
        if ([HandleRequest isStringEmpty:URL_str])
            return false;
        
        NSURL *url = [NSURL URLWithString:URL_str];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        switch (requestType)
        {
            case GET:
                [request setHTTPMethod:@"GET"];
                break;
            case POST:
                [request setHTTPMethod:@"POST"];
                break;
            case DELETE:
                [request setHTTPMethod:@"DELETE"];
                break;
            default:
                // set post by default
                [request setHTTPMethod:@"POST"];
                break;
        }
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        
        // if there is no connection going on, start a new connection
        if (!_connection)
        {
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        }
    }
    
    return true;
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    NSLog(@"received response!");
    _data = [[NSMutableData alloc] init];
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSString *cookie = [fields valueForKey:@"Set-Cookie"]; // It is your cookie
    _cookie = cookie;
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // nil out the connection so the user can try again
    _connection = nil;
    // nil out any data just-in-case
    _data = nil;
    
    NSLog(@"ERROR: %@", error);
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSError *error = nil;
    // allow fragments so empty fields do not crash the app
    NSMutableDictionary *jsonResponse = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&error]];
    NSLog(@"JSONRESPONSE: %@", jsonResponse);
    if (error)
    {
        NSLog(@"ERROR: %@, %@", error, [error localizedDescription]);
    }
    else
    {
        [jsonResponse setObject:_cookie forKey:@"cookie"];
        SEL sel = NSSelectorFromString(_selectorName);
        [_delegate performSelector:sel withObject:jsonResponse]; // Deal with the data
    }
}

@end
