//
//  PlaceMark.h
//  ShowOfPeace
//
//  Created by Eric Roland on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceMark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *subtitle;
	NSString *title;
	NSString *type;
	NSString *itemId;
	NSString *iconName;
	NSString *icon;
}
//(nonatomic, readonly, copy)
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSString *iconName;
@property (nonatomic, retain) NSString *icon;

-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end
