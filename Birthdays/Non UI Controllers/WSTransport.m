//
//  WSTransport.m
//  
//
//  Created by Irfan Lone on 1/12/15.
//  Copyright (c) 2015 Irfan. All rights reserved.
//

#import "WSTransport.h"
#import "Reachability.h"


@implementation WSTransportResponseObject

- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error {
    if (self = [super init]) {
        self.data = data;
        self.response = response;
        self.error = error;
    }
    return self;
}

@end


@implementation WSTransport

- (void)send:(NSData *)dataToUpload urlRequest:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, WSTransportResponseObject *responseObject))completionBlock {

    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        completionBlock(NO, nil);
        NSLog(@"Reachability status is NotReachable");
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:urlRequest fromData:dataToUpload completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        WSTransportResponseObject *responseObject = [[WSTransportResponseObject alloc] initWithData:data response:httpResponse error:error];
        NSInteger responseStatusCode = httpResponse.statusCode;
        if (error == nil && (responseStatusCode >= 200 && responseStatusCode <= 299)) {
            completionBlock(YES, responseObject);
        } else {
            completionBlock(NO, responseObject);
        }
    }];
    [uploadTask resume];
    [session finishTasksAndInvalidate];
}

- (void)retrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, WSTransportResponseObject *responseObject))completionBlock
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        completionBlock(NO, nil);
        NSLog(@"Reachability status is NotReachable");
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        WSTransportResponseObject *responseObject = [[WSTransportResponseObject alloc] initWithData:data response:httpResponse error:error];
        NSInteger responseStatusCode = httpResponse.statusCode;
        if (error == nil && (responseStatusCode >= 200 && responseStatusCode <= 299)) {
            completionBlock(YES, responseObject);
        } else {
            completionBlock(NO, responseObject);
        }
    }];
    [dataTask resume];
    [session finishTasksAndInvalidate];
}


@end
