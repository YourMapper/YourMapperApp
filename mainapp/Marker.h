//
//  Marker.h
//  mainapp
//
//  Created by Eric Roland on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserMarker;

@interface Marker : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * categoryColor;
@property (nonatomic, retain) NSNumber * categoryId;
@property (nonatomic, retain) NSString * categoryImage;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * detailLink;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * permalink;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * dataSetId;
@property (nonatomic, retain) NSSet *markerUsers;
@end

@interface Marker (CoreDataGeneratedAccessors)

- (void)addMarkerUsersObject:(UserMarker *)value;
- (void)removeMarkerUsersObject:(UserMarker *)value;
- (void)addMarkerUsers:(NSSet *)values;
- (void)removeMarkerUsers:(NSSet *)values;

@end
