//
//  WSParseAPIClient.h
//  WebServiceCoredataMapping
//
//  Created by Irfan Lone on 9/19/15.
//  Copyright © 2015 Irfan Lone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSParseAPIClient : NSObject

+ (WSParseAPIClient *)sharedClient;

+ (NSMutableDictionary<NSString *, NSString *> *)generateESHeader;

- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate;

- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;

- (NSMutableURLRequest *)DELETERequestForClass:(NSString *)className objectID:(NSString *)objectIdToDelete;

@end
