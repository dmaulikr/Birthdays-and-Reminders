//
//  YZTransport.h
//
//
//  Created by Irfan Lone on 1/12/15.
//  Copyright (c) 2015 Irfan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSTransportResponseObject : NSObject
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSError *error;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithData:(NSData *)data response:(NSHTTPURLResponse *)response error:(NSError *)error NS_DESIGNATED_INITIALIZER;
@end

@interface WSTransport : NSObject

- (void)send:(NSData *)dataToUpload urlRequest:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, WSTransportResponseObject *responseObject))completionBlock;

- (void)retrieve:(NSURLRequest *)urlRequest completionBlock:(void (^)(BOOL success, WSTransportResponseObject *responseObject))completionBlock;

@end
