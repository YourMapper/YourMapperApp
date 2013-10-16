//
//  Location.h
//  mainapp
//
//  Created by Eric Roland on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserDataset, UserLocation;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * countryCode;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSSet *locationUserDatasets;
@property (nonatomic, retain) NSSet *locationUsers;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addLocationUserDatasetsObject:(UserDataset *)value;
- (void)removeLocationUserDatasetsObject:(UserDataset *)value;
- (void)addLocationUserDatasets:(NSSet *)values;
- (void)removeLocationUserDatasets:(NSSet *)values;

- (void)addLocationUsersObject:(UserLocation *)value;
- (void)removeLocationUsersObject:(UserLocation *)value;
- (void)addLocationUsers:(NSSet *)values;
- (void)removeLocationUsers:(NSSet *)values;

@end
