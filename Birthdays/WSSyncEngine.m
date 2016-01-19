//
//  WSSyncEngine.m
//  WebServiceCoredataMapping
//
//  Created by Irfan Lone on 9/19/15.
//  Copyright © 2015 Irfan Lone. All rights reserved.
//

#import "WSSyncEngine.h"
#import <CoreData/CoreData.h>
#import "SDCoreDataController.h"
#import "WSParseAPIClient.h"
#import "YZTransport.h"


NSString * const kSDSyncEngineInitialCompleteKey = @"SDSyncEngineInitialSyncCompleted";
NSString * const kSDSyncEngineSyncCompletedNotificationName = @"SDSyncEngineSyncCompleted";

@interface WSSyncEngine ()
@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation WSSyncEngine

@synthesize registeredClassesToSync = _registeredClassesToSync;
@synthesize syncInProgress = _syncInProgress;
@synthesize dateFormatter = _dateFormatter;


+ (WSSyncEngine *)sharedEngine {
    static WSSyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[WSSyncEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)startSync {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadDataForRegisteredObjects:YES];
        });
    }
//    NSArray * arr =  [self managedObjectsForClass:@"Birthday" withSyncStatus:SDObjectSynced];
//    NSLog(@"%@",arr);
}

- (BOOL)initialSyncComplete {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kSDSyncEngineInitialCompleteKey] boolValue];
}

- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kSDSyncEngineInitialCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kSDSyncEngineSyncCompletedNotificationName
         object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}


- (void)registerNSManagedObjectClassToSync:(Class)aClass {
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
    }
    
    if ([aClass isSubclassOfClass:[NSManagedObject class]]) {
        if (![self.registeredClassesToSync containsObject:NSStringFromClass(aClass)]) {
            [self.registeredClassesToSync addObject:NSStringFromClass(aClass)];
        } else {
            NSLog(@"Unable to register %@ as it is already registered", NSStringFromClass(aClass));
        }
    } else {
        NSLog(@"Unable to register %@ as it is not a subclass of NSManagedObject", NSStringFromClass(aClass));
    }
    
}

- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName {
    __block NSDate *date = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Birthday"];
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    //
    // You are only interested in 1 result so limit the request to 1
    //
    [request setFetchLimit:1];
    [[[SDCoreDataController sharedInstance] backgroundManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [[[SDCoreDataController sharedInstance] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
        if ([results lastObject])   {
            //
            // Set date to the fetched result
            //
            date = [[results lastObject] valueForKey:@"updatedAt"];
        }
    }];
    
    return date;
}

- (void)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Birthday" inManagedObjectContext:[[SDCoreDataController sharedInstance] backgroundManagedObjectContext]];
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:newManagedObject];
    }];
    [record setValue:[NSNumber numberWithInt:SDObjectSynced] forKey:@"syncStatus"];
}

- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
    if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"]) {
//        NSDate *date = [self dateUsingStringFromAPI:value];
//        [managedObject setValue:date forKey:key];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
//        if ([value objectForKey:@"__type"]) {
//            NSString *dataType = [value objectForKey:@"__type"];
//            if ([dataType isEqualToString:@"Date"]) {
//                NSString *dateString = [value objectForKey:@"iso"];
//                NSDate *date = [self dateUsingStringFromAPI:dateString];
//                [managedObject setValue:date forKey:key];
//            } else if ([dataType isEqualToString:@"File"]) {
//                NSString *urlString = [value objectForKey:@"url"];
//                NSURL *url = [NSURL URLWithString:urlString];
//                NSURLRequest *request = [NSURLRequest requestWithURL:url];
//                NSURLResponse *response = nil;
//                NSError *error = nil;
//                NSData *dataResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//                [managedObject setValue:dataResponse forKey:key];
//            } else {
//                NSLog(@"Unknown Data Type Received");
//                [managedObject setValue:nil forKey:key];
//            }
//        }
    } else if ([key isEqualToString:@"updatedAt"] || [key isEqualToString:@"createdAt"] || [key isEqualToString:@"image"] || [key isEqualToString:@"date"]) {


    } else if ([key isEqualToString:@"giftIdeas"]) {
        [managedObject setValue:value forKey:@"birthday"];
        
    } else {
        [managedObject setValue:value forKey:key];
    }
}

- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(SDObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Birthday"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncStatus = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    return results;
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds withSyncStatus:(SDObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Birthday"];
    NSPredicate *predicate01;
    NSPredicate *predicate02;
    if (inIds) {
        predicate01 = [NSPredicate predicateWithFormat:@"objectId IN %@", idArray];
    } else {
        predicate01 = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
    }
    predicate02 = [NSPredicate predicateWithFormat:@"syncStatus = %d", syncStatus];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[predicate01, predicate02]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    return results;
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Birthday"];
    NSPredicate *predicate;
    if (inIds) {
        predicate = [NSPredicate predicateWithFormat:@"objectId IN %@", idArray];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
    }
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    return results;
}


- (NSArray *)allManagedObjectsForClass:(NSString *)className {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Birthday"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    return results;
}

- (void)processJSONDataRecordsIntoCoreDataWithCompletionBlock:(void(^)())completion {
    NSManagedObjectContext *managedObjectContext = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    //
    // Iterate over all registered classes to sync
    //
    for (NSString *className in self.registeredClassesToSync) {
        if (![self initialSyncComplete]) { // import all downloaded data to Core Data for initial sync
            //
            // If this is the initial sync then the logic is pretty simple, you will fetch the JSON data from disk
            // for the class of the current iteration and create new NSManagedObjects for each record
            //
            NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:@"Birthday"];
            NSArray *records = [JSONDictionary objectForKey:@"results"];
            for (NSDictionary *record in records) {
                [self newManagedObjectWithClassName:@"Birthday" forRecord:record];
            }
        } else {
            //
            // Otherwise you need to do some more logic to determine if the record is new or has been updated.
            // First get the downloaded records from the JSON response, verify there is at least one object in
            // the data, and then fetch all records stored in Core Data whose objectId matches those from the JSON response.
            //
            NSArray *downloadedRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
            
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"objectId"
                                                                         ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            NSArray *sortedArray = [downloadedRecords sortedArrayUsingDescriptors:sortDescriptors];
            NSLog(@"%@",sortedArray);

            if ([downloadedRecords lastObject]) {

                NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"objectId" usingArrayOfIds:[downloadedRecords valueForKey:@"objectId"] inArrayOfIds:YES];
                int currentIndex = 0;
                
                for (NSDictionary *record in downloadedRecords) {
                    NSManagedObject *storedManagedObject = nil;
                    
                    // Make sure we don't access an index that is out of bounds as we are iterating over both collections together
                    if ([storedRecords count] > currentIndex) {
                        storedManagedObject = [storedRecords objectAtIndex:currentIndex];
                    }
                    
                    if ([[storedManagedObject valueForKey:@"objectId"] isEqualToString:[record valueForKey:@"objectId"]]) {
                        [self updateManagedObject:[storedRecords objectAtIndex:currentIndex] withRecord:record];
                        currentIndex++;
                    } else {
                        [self newManagedObjectWithClassName:className forRecord:record];
                    }
                }
            }
        }
        
        NSArray *downloadedRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
        NSArray<NSManagedObject*> * objectsMarkedForDeletion = [NSArray array];
        objectsMarkedForDeletion = [self managedObjectsForClass:@"Birthday" sortedByKey:@"objectId" usingArrayOfIds:[downloadedRecords valueForKey:@"objectId"] inArrayOfIds:NO withSyncStatus:SDObjectSynced];
        
        for (NSManagedObject * itemToBeDeleted in objectsMarkedForDeletion) {
            [managedObjectContext performBlockAndWait:^{
                NSManagedObject * object =[managedObjectContext existingObjectWithID:itemToBeDeleted.objectID error:nil];
                if (object) {
                    [managedObjectContext deleteObject:object];
                } else {
                    NSLog(@"Failed to retrieve object from core data that needs to be deleted, This would result in bad data");
                }
            }];
        }
        
        [managedObjectContext performBlockAndWait:^{
            BOOL success = [managedObjectContext save:nil];
            if (!success) {
                NSLog(@"Unable to save context for class %@", className);
            }
        }];
        [[SDCoreDataController sharedInstance] saveMasterContext];

        //
        // You are now done with the downloaded JSON responses so you can delete them to clean up after yourself,
        // then call your -executeSyncCompletedOperations to save off your master context and set the
        // syncInProgress flag to NO
        //
        [self deleteJSONDataRecordsForClassWithName:@"Birthday"];
        completion();
    }
}

- (void)downloadDataForRegisteredObjects:(BOOL)useUpdatedAtDate {
    
    for (NSString *className in self.registeredClassesToSync) {
        // 1. get all changes from server
        NSDate *mostRecentUpdatedDate = nil;
        if (useUpdatedAtDate) {
            //mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
        }
    
        NSDictionary *headerDict = [WSParseAPIClient generateESHeader];
        NSMutableURLRequest *urlRequest = [[WSParseAPIClient sharedClient] GETRequestForAllRecordsOfClass:@"Birthday" updatedAfterDate:mostRecentUpdatedDate];
        urlRequest.allHTTPHeaderFields = headerDict;
        YZTransport *transport = [[YZTransport alloc] init];
        [transport retrieve:urlRequest completionBlock:^(BOOL success, YZTransportResponseObject *responseObject) {
            if (success) {
                NSString *dataString = [[NSString alloc] initWithData:responseObject.data encoding:NSUTF8StringEncoding];
                NSData *jsonData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                NSLog(@"%@",responseDictionary);
                [self writeJSONResponse:responseDictionary toDiskForClassWithName:className andCompletion:^(BOOL success) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self processJSONDataRecordsIntoCoreDataWithCompletionBlock:^{
                                
                                // 2. post local changes to server
                                //      a. post all locally created objects
                                [self postLocalChangesToServerForClass:className withCompletionBlock:^{
                                  
                                    //      b. delete locally deleted objects on server
                                    [self deleteObjectsOnServerForClass:className withCompletionBlock:^{
                                        [self executeSyncCompletedOperations];
                                    }];
                                    
                                }];
                                
                            }];
                            NSLog(@"");
                        });

                    } else {
                        // throw an error to the user
                        NSAssert(NO, @"");
                    }
                }];
            } else {
                
            }
        }];
    }
}

- (void)postLocalChangesToServerForClass:(NSString*)className withCompletionBlock:(void(^)())completion
{
    NSArray * newlyCreatedObjects = [self managedObjectsForClass:className withSyncStatus:SDObjectCreated];
    NSManagedObjectContext * moc = [[SDCoreDataController sharedInstance] masterManagedObjectContext];
    
    if ([newlyCreatedObjects count] < 1) {
        completion();
    }
    for (NSManagedObject * object in newlyCreatedObjects) {
        NSMutableDictionary * jsonObject = [self jsonForManagedObject:object];
        NSMutableURLRequest * urlRequest = [[WSParseAPIClient sharedClient] POSTRequestForClass:@"Birthday" parameters:jsonObject];
        urlRequest.allHTTPHeaderFields = [WSParseAPIClient generateESHeader];

        YZTransport * transport = [[YZTransport alloc] init];
        [transport retrieve:urlRequest completionBlock:^(BOOL success, YZTransportResponseObject *responseObject) {
            
            if (success) {
                NSString *dataString = [[NSString alloc] initWithData:responseObject.data encoding:NSUTF8StringEncoding];
                NSData *jsonData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];

                // set the SDSyncStatus and objectID
                [moc performBlockAndWait:^{
                    [object setValue:[NSNumber numberWithInt:SDObjectSynced] forKey:@"syncStatus"];
                    [object setValue:responseDictionary[@"objectId"] forKey:@"objectId"];
                }];
                
                if (object == [newlyCreatedObjects lastObject]) {
                    [[SDCoreDataController sharedInstance] saveBackgroundContext];
                    BOOL success = [moc save:nil];
                    if (!success) {
                        NSLog(@"Unable to save context for class ");
                    }
                }
            } else {
                NSLog(@"Failed to create object on server, Error : %@",responseObject.error);
            }
            completion();
        }];
    }
}

- (void)deleteObjectsOnServerForClass:(NSString*)className withCompletionBlock:(void(^)())completion
{
    NSArray * objectsToDelete = [self managedObjectsForClass:className withSyncStatus:SDObjectDeleted];
    NSManagedObjectContext * moc = [[SDCoreDataController sharedInstance] backgroundManagedObjectContext];
    if ([objectsToDelete count] < 1) {
        completion();
    }
    for (NSManagedObject * object in objectsToDelete) {
        
        NSString * objectId = [[object valueForKey:@"objectId"] description];
        NSMutableURLRequest * urlRequest = [[WSParseAPIClient sharedClient] DELETERequestForClass:@"Birthday" objectID:objectId];
        urlRequest.allHTTPHeaderFields = [WSParseAPIClient generateESHeader];
        
        YZTransport * transport = [[YZTransport alloc] init];
        [transport retrieve:urlRequest completionBlock:^(BOOL success, YZTransportResponseObject *responseObject) {
            
            if (success) {
                // set the SDSyncStatus and objectID
                [moc deleteObject:object];
                
                if (object == [objectsToDelete lastObject]) {
                    [[SDCoreDataController sharedInstance] saveBackgroundContext];
                }
            } else {
                NSLog(@"Failed to create object on server, Error : %@",responseObject.error);
            }
            completion();
        }];
    }
}

-(NSMutableDictionary*)jsonForManagedObject:(NSManagedObject*)object {
    NSMutableDictionary * jsonDict = [[NSMutableDictionary alloc] init];
    jsonDict[@"name"]       = [[object valueForKey:@"name"] description];
    jsonDict[@"facebook"]   = [[object valueForKey:@"facebook"] description];
    jsonDict[@"giftIdeas"]  = [[object valueForKey:@"birthday"] description];
    return jsonDict;
}

- (void)initializeDateFormatter {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
}

- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    [self initializeDateFormatter];
    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-5)];
    
    return [self.dateFormatter dateFromString:dateString];
}

- (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    [self initializeDateFormatter];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    // remove Z
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
    // add milliseconds and put Z back on
    dateString = [dateString stringByAppendingFormat:@".000Z"];
    
    return dateString;
}

#pragma mark - File Management

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSLog(@"file is at: %@",url);
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return url;
}

- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className andCompletion:(void (^)(BOOL success))completion {
    NSURL *fileURL = [NSURL URLWithString:@"Birthday" relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)response writeToFile:[fileURL path] atomically:YES]) {
        NSLog(@"Error saving response to disk, will attempt to remove NSNull values and try again.");
        // remove NSNulls and try again...
        NSArray *records = [response objectForKey:@"results"];
        NSMutableArray *nullFreeRecords = [NSMutableArray array];
        for (NSDictionary *record in records) {
            NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:record];
            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [nullFreeRecord setValue:nil forKey:key];
                }
            }];
            [nullFreeRecords addObject:nullFreeRecord];
        }
        
        NSDictionary *nullFreeDictionary = [NSDictionary dictionaryWithObject:nullFreeRecords forKey:@"results"];
        
        if (![nullFreeDictionary writeToFile:[fileURL path] atomically:YES]) {
            NSLog(@"Failed all attempts to save response to disk: %@", response);
            completion(NO);
        } else {
            completion(YES);
        }
    }  else {
        completion(YES);
    }
}

- (NSDictionary *)JSONDictionaryForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:@"Birthday" relativeToURL:[self JSONDataRecordsDirectory]];
    return [NSDictionary dictionaryWithContentsOfURL:fileURL];
}

- (NSArray *)JSONDataRecordsForClass:(NSString *)className sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:@"Birthday"];
    NSArray *records = [JSONDictionary objectForKey:@"results"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}

- (void)deleteJSONDataRecordsForClassWithName:(NSString *)className {
    NSURL *url = [NSURL URLWithString:@"Birthday" relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        NSLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

@end
