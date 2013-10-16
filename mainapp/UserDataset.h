//
//  UserDataset.h
//  mainapp
//
//  Created by Eric Roland on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dataset, Location, User;

@interface UserDataset : NSManagedObject

@property (nonatomic, retain) NSString * categories;
@property (nonatomic, retain) NSString * categoriesText;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * searchText;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) Dataset *dataset;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) User *user;

@end
