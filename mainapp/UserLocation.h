//
//  UserLocation.h
//  mainapp
//
//  Created by Eric Roland on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, User;

@interface UserLocation : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) User *user;

@end
