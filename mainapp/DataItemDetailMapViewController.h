//
//  DataItemDetailMapViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h> 
#import "Marker.h"

@interface DataItemDetailMapViewController : UIViewController <MKMapViewDelegate> {
    Marker *_marker;
    MKMapView *mapView;
}

@property (nonatomic, retain) Marker *marker;
@property (nonatomic, retain) IBOutlet MKMapView* mapView;

- (IBAction)openMap:(id)sender;

@end
