//
//  UserMarker.h
//  mainapp
//
//  Created by Eric Roland on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Marker, User;

@interface UserMarker : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) Marker *marker;
@property (nonatomic, retain) User *user;

@end
