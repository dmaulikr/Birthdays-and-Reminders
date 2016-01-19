//
//  YZTransport.m
//  NookStudy
//
//  Created by Mike Ma on 1/12/15.
//  Copyright (c) 2015 Barnes & Noble. All rights reserved.
//

#import "WSTransport.h"
#import "Reachability.h"

const NSInteger kYZErrorRentalExpired = 40006;
const NSInteger kYZErrorDRMDeviceLimitReached = 40007;
const NSInteger kYZErrorPasswordConflictForAccounts = 10020;

@implementation YZTransportResponseObject

- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error
{
    if (self = [super init]) {
        self.data = data;
        self.response = response;
        self.error = error;
    }
    return self;
}

@end


@implementation WSTransport

- (void)send:(NSData *)dataToUpload urlRequest:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, YZTransportResponseObject *responseObject))completionBlock
{

    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        completionBlock(NO, nil);
        NSLog(@"Reachability status is NotReachable");
        return;
    }
    //Create url session with default configuration
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:urlRequest
                                                               fromData:dataToUpload
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                          YZTransportResponseObject *responseObject = [[YZTransportResponseObject alloc] initWithData:data response:httpResponse error:error];
                                                          NSInteger responseStatusCode = httpResponse.statusCode;
                                                          if (error == nil && (responseStatusCode >= 200 && responseStatusCode <= 299)) {
                                                              completionBlock(YES, responseObject);
                                                          } else {
                                                              completionBlock(NO, responseObject);
                                                          }
                                                      }];
//TODO: XCode 7 will not compile Mac Unit Tests if this is present. Investigate again with later builds.
#ifdef NSURLSessionTaskPriorityHigh
    uploadTask.priority = NSURLSessionTaskPriorityHigh;
#endif
    [uploadTask resume];
    [session finishTasksAndInvalidate];
}

- (void)retrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, YZTransportResponseObject *responseObject))completionBlock
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        completionBlock(NO, nil);
        NSLog(@"Reachability status is NotReachable");
        return;
    }
    //Create url session with default configuration
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                    YZTransportResponseObject *responseObject = [[YZTransportResponseObject alloc] initWithData:data response:httpResponse error:error];
                                                    NSInteger responseStatusCode = httpResponse.statusCode;
                                                    if (error == nil && (responseStatusCode >= 200 && responseStatusCode <= 299)) {
                                                        completionBlock(YES, responseObject);
                                                    } else {
                                                        completionBlock(NO, responseObject);
                                                    }
                                                }];
//TODO: XCode 7 will not compile Mac Unit Tests if this is present. Investigate again with later builds.
#ifdef NSURLSessionTaskPriorityHigh
    dataTask.priority = NSURLSessionTaskPriorityHigh;
#endif
    [dataTask resume];
    [session finishTasksAndInvalidate];
}

- (void)synchronousRetrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, YZTransportResponseObject *responseObject))completionBlock
{
    NSAssert(![NSThread isMainThread], @"This will block until request is received so it shouldn't be on the main thread.");

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self retrieve:urlRequest
        completionBlock:^(BOOL success, YZTransportResponseObject *responseObject) {
            completionBlock(success, responseObject);
            dispatch_semaphore_signal(semaphore);
        }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


@end
