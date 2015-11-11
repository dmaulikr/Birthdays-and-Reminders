//
//  Birthday+CoreDataProperties.h
//  Birthdays
//
//  Created by Irfan Lone on 11/10/15.
//  Copyright © 2015 Yuzu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Birthday.h"

NS_ASSUME_NONNULL_BEGIN

@interface Birthday (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *timeStamp;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *birthday;
@property (nullable, nonatomic, retain) NSString *facebook;

@end

NS_ASSUME_NONNULL_END
