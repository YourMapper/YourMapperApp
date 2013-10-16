//
//  ModelHelper.h
//  Chewable
//
//  Created by Eric Roland on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <MapKit/MapKit.h> 
#import "User.h"
#import "Marker.h"
#import "Location.h"
#import "Dataset.h"

@interface ModelHelper : NSObject {
}

+ (void)deleteObject:(NSManagedObject*)object;
+ (User*)getUserByUserName:(NSString*)userName;
+ (User*)getUserByExternalId:(NSInteger*)externalId;
+ (User*)getCurrentUser;
+ (User*)getUserByUserName:(NSString*)userName;
+ (User*)getCurrentUser;
+ (Marker*)getAndSaveMarkerById:(NSString*)externalId:(NSDictionary*)item:(NSString*)dataSetId;
+ (Marker*)getMarkerById:(NSString*)externalId;
+ (Location*)getLocationByLatLng:(double)latitude:(double)longitude;
+ (Location*)getAndSaveLocationByLatLng:(double)latitude:(double)longitude;
+ (Location*)getAndSaveUserLocationByPlaceMarker:(NSDictionary*)addressDictionary:(NSString*)type:(double)latitude:(double)longitude;
+ (NSMutableArray*)getDatasets:(NSString*)sortOrder:(NSMutableArray*)externalIds;
+ (NSMutableArray*)getDatasetsByCoverage:(NSMutableArray*)externalIds;
+ (Dataset*)getAndSaveDatasetByExternalId:(NSString*)externalId;
+ (Dataset*)getAndSaveDatasetByExternalIdItem:(NSString*)externalId:(NSDictionary*)item;
+ (Dataset*)getAndSaveUserDatasetByExternalIdItem:(NSString*)externalId:(NSDictionary*)item;
+ (UserDataset*)getUserDatasetByExternalId:(NSString*)externalId;
+ (UserDataset*)getAndSaveUserDatasetByExternalIdParams:(NSString*)externalId:(NSMutableDictionary*)params;

@end
