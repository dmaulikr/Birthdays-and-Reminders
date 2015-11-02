//
//  YZTransport.h
//  NookStudy
//
//  Created by Mike Ma on 1/12/15.
//  Copyright (c) 2015 Barnes & Noble. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: convert to YZErrorEnumFactoryMacros
extern const NSInteger kYZErrorRentalExpired;
extern const NSInteger kYZErrorDRMDeviceLimitReached;
extern const NSInteger kYZErrorPasswordConflictForAccounts;

@interface YZTransportResponseObject : NSObject
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSError *error;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error NS_DESIGNATED_INITIALIZER;
@end

@interface YZTransport : NSObject

- (void)send:(NSData *)dataToUpload urlRequest:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, YZTransportResponseObject *responseObject))completionBlock;

- (void)retrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, YZTransportResponseObject *responseObject))completionBlock;

- (void)synchronousRetrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, YZTransportResponseObject *responseObject))completionBlock;
@end
