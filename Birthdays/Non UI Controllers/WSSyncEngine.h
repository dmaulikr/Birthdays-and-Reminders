//
//  WSSyncEngine.h
//  WebServiceCoredataMapping
//
//  Created by Irfan Lone on 9/19/15.
//  Copyright © 2015 Irfan Lone. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kSDSyncEngineSyncCompletedNotificationName;


typedef enum {
    WSObjectSynced = 0,
    WSObjectCreated,
    WSObjectDeleted,
} WSObjectSyncStatus;


@interface WSSyncEngine : NSObject
@property (atomic, readonly) BOOL syncInProgress;


+ (WSSyncEngine *)sharedEngine;

- (void)startSync;

- (void)registerNSManagedObjectClassToSync:(Class)aClass;

@end
