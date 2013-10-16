//
//  DataSetDetailsMapViewController.h
//  mainapp
//
//  Created by Eric Roland on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h> 
#import "Marker.h"

@interface DataSetDetailsMapViewController : UIViewController <MKMapViewDelegate> {
    NSArray *_items;
    MKMapView *_mapView;
    Marker *marker;
}

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) IBOutlet MKMapView* mapView;

- (IBAction)done;

@end
