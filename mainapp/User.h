//
//  User.h
//  mainapp
//
//  Created by Eric Roland on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserDataset, UserLocation, UserMarker;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * automaticUpdates;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * defaultLatitude;
@property (nonatomic, retain) NSNumber * defaultLongitude;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * notification;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * stayLoggedIn;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *userDatasets;
@property (nonatomic, retain) NSSet *userLocations;
@property (nonatomic, retain) NSSet *userMarkers;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUserDatasetsObject:(UserDataset *)value;
- (void)removeUserDatasetsObject:(UserDataset *)value;
- (void)addUserDatasets:(NSSet *)values;
- (void)removeUserDatasets:(NSSet *)values;

- (void)addUserLocationsObject:(UserLocation *)value;
- (void)removeUserLocationsObject:(UserLocation *)value;
- (void)addUserLocations:(NSSet *)values;
- (void)removeUserLocations:(NSSet *)values;

- (void)addUserMarkersObject:(UserMarker *)value;
- (void)removeUserMarkersObject:(UserMarker *)value;
- (void)addUserMarkers:(NSSet *)values;
- (void)removeUserMarkers:(NSSet *)values;

@end
