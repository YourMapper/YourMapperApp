//
//  Dataset.h
//  mainapp
//
//  Created by Eric Roland on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserDataset;

@interface Dataset : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * coverage;
@property (nonatomic, retain) NSNumber * datasetId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * dateFilter;
@property (nonatomic, retain) NSNumber * daysUpdate;
@property (nonatomic, retain) NSString * detailLink;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSString * linkPath;
@property (nonatomic, retain) NSNumber * mapperId;
@property (nonatomic, retain) NSString * mapperName;
@property (nonatomic, retain) NSNumber * markerType;
@property (nonatomic, retain) NSNumber * maxLat;
@property (nonatomic, retain) NSNumber * maxLon;
@property (nonatomic, retain) NSNumber * minLat;
@property (nonatomic, retain) NSNumber * minLon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * national;
@property (nonatomic, retain) NSNumber * ratingScore;
@property (nonatomic, retain) NSString * startCity;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * startState;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * stateName;
@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * updateFrequency;
@property (nonatomic, retain) NSNumber * viewCount;
@property (nonatomic, retain) NSString * externalLinkName;
@property (nonatomic, retain) NSSet *dataSetUsers;
@end

@interface Dataset (CoreDataGeneratedAccessors)

- (void)addDataSetUsersObject:(UserDataset *)value;
- (void)removeDataSetUsersObject:(UserDataset *)value;
- (void)addDataSetUsers:(NSSet *)values;
- (void)removeDataSetUsers:(NSSet *)values;

@end
