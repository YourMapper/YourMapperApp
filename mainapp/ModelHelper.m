//
//  ModelHelper.m
//  Chewable
//
//  Created by Eric Roland on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModelHelper.h"
#import "CoreDataHelper.h"
#import "User.h"
#import "Marker.h"
#import "Location.h"
#import "UserLocation.h"
#import "AppDelegate.h"
#import "Dataset.h"
#import "UserDataset.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation ModelHelper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (void)deleteObject:(NSManagedObject*)object {
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    [context deleteObject:object];
    [appDelegate saveContext];
}

+ (User*)getUserByUserName:(NSString*)userName {
    User *currentUser = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userName == %@", userName];
    NSMutableArray* users = [CoreDataHelper searchObjectsInContext:@"User" :predicate :nil :NO :[appDelegate managedObjectContext]];
    if (users.count == 1) {
        currentUser = [users objectAtIndex:0];
    }
    return currentUser;
}

+ (User*)getUserByExternalId:(NSInteger*)externalId {
    User *currentUser = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"externalId == %@", externalId];
    NSMutableArray* users = [CoreDataHelper searchObjectsInContext:@"User" :predicate :nil :NO :[appDelegate managedObjectContext]];
    if (users.count == 1) {
        currentUser = [users objectAtIndex:0];
    }
    return currentUser;
}

+ (User*)getCurrentUser {
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"];
    return [ModelHelper getUserByUserName:userName];
}

+ (Marker*)getMarkerById:(NSString*)externalId {
    Marker *marker = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"externalId == %@", externalId];
    NSMutableArray *markers = [CoreDataHelper searchObjectsInContext:@"Marker" :predicate :nil :NO :[appDelegate managedObjectContext]];
    if (markers.count == 1) {
        marker = [markers objectAtIndex:0];
    }
    return marker;
}

+ (Marker*)getAndSaveMarkerById:(NSString*)externalId:(NSDictionary*)item:(NSString*)dataSetId {
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *entityName = @"Marker";  
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    Marker *marker = [ModelHelper getMarkerById:externalId];
    if (marker == nil) {
        marker = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"]; //2006-06-13 
    marker.externalId = [item objectForKey:@"id"];
    marker.name = [item objectForKey:@"name"];
    marker.itemDescription = [item objectForKey:@"description"];
    marker.categoryId = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"categoryid"]];;
    marker.category = [item objectForKey:@"catname"];
    marker.categoryImage = [item objectForKey:@"catimage"];
    marker.categoryColor = [item objectForKey:@"catcolor"];
    marker.address = [item objectForKey:@"address"];
    marker.address2 = [item objectForKey:@"address2"];
    marker.city = [item objectForKey:@"city"];
    marker.state = [item objectForKey:@"state"]; 
    marker.date = [dateFormatter dateFromString:[item objectForKey:@"date"]];
    marker.latitude = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"latitude"]];
    marker.longitude = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"longitude"]];
    marker.url = [item objectForKey:@"fullurl"];
    marker.detailLink = [item objectForKey:@"detaillink"];
    marker.permalink = [item objectForKey:@"permalink"];
    marker.imagePath = [item objectForKey:@"imagepath"];
    marker.distance = [numberFormatter numberFromString:[item objectForKey:@"distance"]];
    marker.dataSetId = dataSetId;
    [appDelegate saveContext];
    return marker;
}

+ (Location*)getLocationByLatLng:(double)latitude:(double)longitude {
    Location *location = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"latitude == %lf AND longitude == %lf", latitude, longitude];
    NSMutableArray *locations = [CoreDataHelper searchObjectsInContext:@"Location" :predicate :nil :NO :[appDelegate managedObjectContext]];
    if (locations.count == 1) {
        location = [locations objectAtIndex:0];
    }
    return location;    
}

+ (Location*)getAndSaveLocationByLatLng:(double)latitude:(double)longitude {
    NSString *entityName = @"Location";  
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    Location *location = [ModelHelper getLocationByLatLng:latitude:longitude];
    if (location == nil) {
        location = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    location.latitude = [NSNumber numberWithDouble:latitude];
    location.longitude = [NSNumber numberWithDouble:longitude];
    [appDelegate saveContext];
    return location;
}

+ (Location*)getAndSaveUserLocationByPlaceMarker:(NSDictionary*)addressDictionary:(NSString*)type:(double)latitude:(double)longitude {
    Location *location = [ModelHelper getAndSaveLocationByLatLng:latitude:longitude];
    location.city = [addressDictionary valueForKey:@"City"];
    location.country = [addressDictionary valueForKey:@"Country"];
    location.countryCode = [addressDictionary valueForKey:@"CountryCode"];
    location.state = [addressDictionary valueForKey:@"State"];
    location.address = [addressDictionary valueForKey:@"Street"];
    location.zip = [addressDictionary valueForKey:@"ZIP"];
    BOOL foundLocation = NO;
    NSMutableSet *userLocations = [ModelHelper.getCurrentUser mutableSetValueForKey:@"userLocations"];
    for(UserLocation *userLocation in userLocations) {
        if([userLocation.location.city isEqualToString:location.city] && 
           [userLocation.location.state isEqualToString:location.state] && 
           [userLocation.location.country isEqualToString:location.country] &&
           [userLocation.location.state isEqualToString:location.state] && 
           [userLocation.location.address isEqualToString:location.address] && 
           [userLocation.location.zip isEqualToString:location.zip]) {
            foundLocation = YES;   
            break;
        }
    }
    if (!foundLocation) {
        UserLocation* userLocation = [NSEntityDescription insertNewObjectForEntityForName:@"UserLocation" inManagedObjectContext:[appDelegate managedObjectContext]];
        User *user = ModelHelper.getCurrentUser;
        userLocation.user = user;
        userLocation.location = location;
        userLocation.createdAt = [NSDate date];
        userLocation.type = type;
        [appDelegate saveContext];
    }
    [appDelegate saveContext];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSURL *uRL = [location.objectID URIRepresentation];
    [settings setURL:uRL forKey:@"lastLocation"];
    [settings synchronize];

    return location;
}

+ (NSMutableArray*)getDatasets:(NSString*)sortOrder:(NSMutableArray*)externalIds {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dataset" inManagedObjectContext:[appDelegate managedObjectContext]];
	[request setEntity:entity];	
    NSPredicate *externalIdsPredicate = [NSPredicate predicateWithFormat:@"externalId IN %@", externalIds];
    [request setPredicate:externalIdsPredicate];
    BOOL sortAscending = ([sortOrder isEqualToString:@"name"] || [sortOrder isEqualToString:@"daysUpdate"] || [sortOrder isEqualToString:@"typeName"]) ? YES : NO;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortOrder ascending:sortAscending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];
    
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[[appDelegate managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
	
	return mutableFetchResults;
}

+ (NSMutableArray*)getDatasetsByCoverage:(NSMutableArray*)externalIds {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dataset" inManagedObjectContext:[appDelegate managedObjectContext]];
	[request setEntity:entity];	
    NSPredicate *externalIdsPredicate = [NSPredicate predicateWithFormat:@"externalId IN %@", externalIds];
    [request setPredicate:externalIdsPredicate];
    NSSortDescriptor *nationalDescriptor = [[NSSortDescriptor alloc] initWithKey:@"national" ascending:NO];
    NSSortDescriptor *stateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"state" ascending:YES];
    NSSortDescriptor *cityDescriptor = [[NSSortDescriptor alloc] initWithKey:@"city" ascending:YES];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nationalDescriptor,stateDescriptor,cityDescriptor,nameDescriptor,nil];
    [request setSortDescriptors:sortDescriptors];

	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[[appDelegate managedObjectContext] executeFetchRequest:request error:&error] mutableCopy];
	
	return mutableFetchResults;
}

+ (Dataset*)getAndSaveDatasetByExternalId:(NSString*)externalId {
    Dataset *item = nil;
    NSString *entityName = @"Dataset";
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"externalId == %@", externalId];
    NSMutableArray* items = [CoreDataHelper searchObjectsInContext:entityName :predicate :nil :NO :[appDelegate managedObjectContext]];
    if (items.count == 1) {
        item = [items objectAtIndex:0];
    } else {
        item = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        item.externalId = externalId;
        [appDelegate saveContext];
    }
    return item;
}

+ (Dataset*)getAndSaveDatasetByExternalIdItem:(NSString*)externalId:(NSDictionary*)item {
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    Dataset *dataset = [ModelHelper getAndSaveDatasetByExternalId:externalId];
    if (item != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *coverage = [item objectForKey:@"Coverage"];
        if ([coverage caseInsensitiveCompare:@"National"] == NSOrderedSame) {
            dataset.national = [NSNumber numberWithBool:YES];
        } else if ([coverage rangeOfString:@"," options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            NSArray *chunks = [coverage componentsSeparatedByString: @","];
            dataset.city = [[chunks objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dataset.state = [[chunks objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        } else {
            dataset.state = coverage;
        }
        dataset.linkPath = [item objectForKey:@"Linkpath"];
        dataset.datasetId = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"DatasetID"]];
        dataset.coverage = [item objectForKey:@"Coverage"];
        dataset.daysUpdate = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"DaysUpdate"]];
        dataset.dateFilter = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"DateFilter"]];
        dataset.endDate = [dateFormatter dateFromString:[item objectForKey:@"EndDate"]];
        dataset.itemDescription = [item objectForKey:@"Description"];
        dataset.markerType =  (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"MarkerType"]];
        dataset.name = [item objectForKey:@"Name"];
        dataset.ratingScore = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"RatingScore"]];
        dataset.startDate = [dateFormatter dateFromString:[item objectForKey:@"StartDate"]];
        dataset.typeName = [item objectForKey:@"TypeName"];
        dataset.updateDate = [dateFormatter dateFromString:[item objectForKey:@"UpdatedDate"]];
        dataset.viewCount = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"ViewCount"]];
        dataset.externalLinkName = [item objectForKey:@"ExternalLinkName"]; 
        [appDelegate saveContext];
    }
    return dataset;
}

+ (Dataset*)getAndSaveUserDatasetByExternalIdItem:(NSString*)externalId:(NSDictionary*)item {
    Dataset *dataset = [ModelHelper getAndSaveDatasetByExternalIdItem:externalId:item];
    UserDataset *userDataset = [ModelHelper getUserDatasetByExternalId:externalId];
    if (userDataset == nil) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSURL *locationUrl = [settings URLForKey:@"lastLocation"];
        NSManagedObjectID *locationId = [[appDelegate persistentStoreCoordinator] managedObjectIDForURIRepresentation:locationUrl];
        Location *location = (Location*)[[appDelegate managedObjectContext] objectWithID:locationId];
        NSString *dataSetId = [settings stringForKey:@"dataSetId"];
        NSString *savedCategoriesText = [settings stringForKey:[NSString stringWithFormat:@"%@SavedCategoriesText", dataSetId]];
        NSString *savedCategories = [settings stringForKey:[NSString stringWithFormat:@"%@SavedCategories", dataSetId]];
        NSDate *startDate = [settings objectForKey:[NSString stringWithFormat:@"%@SavedStartDate", dataSetId]];
        NSDate *endDate = [settings objectForKey:[NSString stringWithFormat:@"%@SavedEndDate", dataSetId]];
        NSString *searchText = [settings stringForKey:[NSString stringWithFormat:@"%@SavedSearchText", dataSetId]];
        userDataset = [NSEntityDescription insertNewObjectForEntityForName:@"UserDataset" inManagedObjectContext:[appDelegate managedObjectContext]];
        userDataset.searchText = searchText;
        userDataset.categories = savedCategories;
        userDataset.categoriesText = savedCategoriesText;
        userDataset.startDate = startDate;
        userDataset.endDate = endDate;
        userDataset.user = ModelHelper.getCurrentUser;
        userDataset.dataset = dataset;
        userDataset.createdAt = [NSDate date];
        userDataset.location = location;
        [appDelegate saveContext];
    }
    return dataset;
}

+ (UserDataset*)getUserDatasetByExternalId:(NSString*)externalId {
    UserDataset *userDataset = nil;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *dataSetId = [settings stringForKey:@"dataSetId"];
    NSMutableSet *items = [ModelHelper.getCurrentUser mutableSetValueForKey:@"userDatasets"];
    NSString *savedCategories = [settings stringForKey:[NSString stringWithFormat:@"%@SavedCategories", dataSetId]];
    NSDate *startDate = [settings objectForKey:[NSString stringWithFormat:@"%@SavedStartDate", dataSetId]];
    NSDate *endDate = [settings objectForKey:[NSString stringWithFormat:@"%@SavedEndDate", dataSetId]];
    NSString *searchText = [settings stringForKey:[NSString stringWithFormat:@"%@SavedSearchText", dataSetId]];
    for(UserDataset *item in items) {
        if([item.dataset.externalId isEqualToString:externalId] && ([savedCategories isEqualToString:item.categoriesText] || (savedCategories == nil && item.categoriesText == nil))
            && ([startDate isEqualToDate:item.startDate] || (startDate == nil && item.startDate == nil)) && ([endDate isEqualToDate:item.endDate] || (endDate == nil && item.endDate == nil)) 
            && ([searchText caseInsensitiveCompare:item.searchText] || (searchText == nil && item.searchText == nil))) {
            userDataset =  item;
            break;
        }
    }
    return  userDataset;
}

+ (UserDataset*)getAndSaveUserDatasetByExternalIdParams:(NSString*)externalId:(NSMutableDictionary*)params {
    UserDataset *userDataset = [ModelHelper getUserDatasetByExternalId:externalId];
    userDataset.categories = [params valueForKey:@"categories"];
    userDataset.categoriesText = [params valueForKey:@"categoriesText"];
    userDataset.endDate = [params valueForKey:@"endDate"];
    userDataset.searchText = [params valueForKey:@"searchText"];
    userDataset.startDate = [params valueForKey:@"startDate"];
    [appDelegate saveContext];
    return userDataset;
}

@end
