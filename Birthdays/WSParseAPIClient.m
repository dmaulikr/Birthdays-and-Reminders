//
//  WSParseAPIClient.m
//  WebServiceCoredataMapping
//
//  Created by Irfan Lone on 9/19/15.
//  Copyright © 2015 Irfan Lone. All rights reserved.
//

#import "WSParseAPIClient.h"

static NSString * const kSDFParseAPIBaseURLString = @"https://api.parse.com/1/";

static NSString * const kSDFParseAPIApplicationId = @"ZXZJQAqUyVrq1HJel5DoOHquqxw1jqbfMumRQdib";
static NSString * const kSDFParseAPIKey = @"RplMa0mTwS9oIldaaG3kvJbnqqMUIU4PZmv9UlEb";


@implementation WSParseAPIClient

+ (WSParseAPIClient *)sharedClient {
    static WSParseAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[[self class] alloc] init];
    });
    
    return sharedClient;
}

+ (NSMutableDictionary<NSString *, NSString *> *)generateESHeader
{
    NSMutableDictionary<NSString *, NSString *> *headers = [NSMutableDictionary dictionary];
    [headers setValue:kSDFParseAPIKey forKey:@"X-Parse-REST-API-Key"];
    [headers setValue:kSDFParseAPIApplicationId forKey:@"X-Parse-Application-Id"];
    return headers;
}

- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    request.HTTPMethod = @"GET";
    NSString * urlstr = [[NSString stringWithString:kSDFParseAPIBaseURLString] stringByAppendingString:[NSString stringWithFormat:@"classes/%@", className]];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:[AFPropertyListStringFromParameters(parameters) dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {

    NSString * urlstr = @"https://api.parse.com/1/classes/Birthday";
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSError * error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    [request setHTTPBody:jsonData];
    return request;
}


static NSString * AFPropertyListStringFromParameters(NSDictionary *parameters) {
    NSString *propertyListString = nil;
    NSError *error = nil;
    
    NSData *propertyListData = [NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if (!error) {
        propertyListString = [[NSString alloc] initWithData:propertyListData encoding:NSUTF8StringEncoding];
    }
    
    return propertyListString;
}

- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate {
    NSMutableURLRequest *request = nil;
    NSDictionary *parameters = nil;
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSString *jsonString = [NSString
                                stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}",
                                [dateFormatter stringFromDate:updatedDate]];
        
        parameters = [NSDictionary dictionaryWithObject:jsonString forKey:@"where"];
    }
    
    request = [self GETRequestForClass:className parameters:parameters];
    return request;
}

@end
