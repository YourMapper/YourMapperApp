//
//  DataItemDetailMapViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataItemDetailMapViewController.h"
#import "Marker.h"
#import "PlaceMark.h"

@implementation DataItemDetailMapViewController
@synthesize marker = _marker;
@synthesize mapView;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds]; 
    mapView.showsUserLocation = TRUE;
    mapView.delegate = self;
    [self.view addSubview:mapView]; 
    float latitude = [self.marker.latitude floatValue];
    float longitude = [self.marker.longitude floatValue];
    CLLocationCoordinate2D location = {latitude, longitude};
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = .025;
    span.longitudeDelta = .025;
    region.center = location;
    region.span = span;
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
    [mapView setCenterCoordinate:mapView.region.center animated:NO];
     
	PlaceMark *placeMark = [[PlaceMark alloc] initWithCoordinate:location];
	placeMark.title = self.marker.name;
    NSArray *address = [[NSArray alloc] initWithObjects:self.marker.address, self.marker.address2, self.marker.state, self.marker.zip, nil];
    placeMark.subtitle = [address componentsJoinedByString: @" "];
	[mapView addAnnotation:placeMark];
    
    
    UIBarButtonItem *goToMapButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Map App"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(openMap:)];
    self.navigationItem.rightBarButtonItem = goToMapButton;
}

- (IBAction)openMap:(id)sender {
    NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@,%@", self.marker.latitude, self.marker.longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (MKAnnotationView *) mapView:(MKMapView *)currentMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    if (annotation == currentMapView.userLocation) {
        return nil; //default to blue dot
    }
    MKPinAnnotationView *dropPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location"];
    dropPin.pinColor = MKPinAnnotationColorGreen;
    dropPin.animatesDrop = YES;
    dropPin.canShowCallout = YES;
    return dropPin;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
