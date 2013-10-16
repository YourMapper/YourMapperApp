//
//  DataSetDetailsMapViewController.m
//  mainapp
//
//  Created by Eric Roland on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataSetDetailsMapViewController.h"
#import "PlaceMark.h"
#import "DataItemDetailViewController.h"
#import "MKAnnotationView+Extensions.h"
#import "Marker.h"
#import "ModelHelper.h"
#define MAP_PADDING 1.1
#define MINIMUM_VISIBLE_LATITUDE 0.01

@implementation DataSetDetailsMapViewController
@synthesize items = _items;
@synthesize mapView = _mapView;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds]; 
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView]; 
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (NSDictionary *item in self.items) {
        marker = [ModelHelper getMarkerById:[item objectForKey:@"id"]];
        float latitude = [marker.latitude floatValue];
        float longitude = [marker.longitude floatValue];
        minLatitude = fmin(latitude, minLatitude);
        maxLatitude = fmax(latitude, maxLatitude);
        minLongitude = fmin(longitude, minLongitude);
        maxLongitude = fmax(longitude, maxLongitude);

        CLLocationCoordinate2D location = {latitude, longitude};
        
        PlaceMark *placeMark = [[PlaceMark alloc] initWithCoordinate:location];
        placeMark.title = marker.name;
        NSArray *address = [[NSArray alloc] initWithObjects:marker.address, marker.address2, marker.state, marker.zip, nil];
        placeMark.subtitle = [address componentsJoinedByString: @" "];
        placeMark.itemId = marker.externalId;
        [self.mapView addAnnotation:placeMark];
    }
    
    MKCoordinateRegion region;

    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    
    region.span.latitudeDelta = (maxLatitude - minLatitude) * MAP_PADDING;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
        ? MINIMUM_VISIBLE_LATITUDE 
        : region.span.latitudeDelta;
    
    region.span.longitudeDelta = (maxLongitude - minLongitude) * MAP_PADDING;
    
    MKCoordinateRegion scaledRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:scaledRegion animated:YES];
}

- (IBAction)done
{
    [self dismissModalViewControllerAnimated:YES];
}

- (MKAnnotationView *) mapView:(MKMapView *)currentMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    if (annotation == currentMapView.userLocation) {
        return nil; //default to blue dot
    }
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    MKPinAnnotationView *dropPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location"];
    dropPin.itemId = ((PlaceMark*)annotation).itemId;
    dropPin.rightCalloutAccessoryView = infoButton;
    dropPin.pinColor = MKPinAnnotationColorGreen;
    dropPin.animatesDrop = YES;
    dropPin.canShowCallout = YES;
    return dropPin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    DataItemDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataItemDetailStoryboard"];
    controller.marker = marker;
    [self.navigationController pushViewController:controller animated:YES];    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Done"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(done)];
    self.navigationItem.leftBarButtonItem = doneButton;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
