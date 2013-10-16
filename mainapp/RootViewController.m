//
//  ViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "DataSetViewController.h"
#import "TypeLocationViewController.h"
#import "User.h"
#import "Location.h"
#import "UserLocation.h"
#import "ModelHelper.h"
#import "AppDelegate.h"
#import "PreviousPlacesViewController.h"
#import "HudView.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation RootViewController
@synthesize locationManager, currentLocationButton, typeButton, previousButton, isMovingToDataset;

- (IBAction) getCurrentLocation {
    [_hudView startActivityIndicator:self.view];
    [self removeCahcedDataset];
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];
}
- (IBAction) moveToTypeLocation {
    [self removeCahcedDataset];
    TypeLocationViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TypeLocationStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction) moveToPreviousLocation {
    [self removeCahcedDataset];
    PreviousPlacesViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviousPlacesStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];   
}

- (void)moveToDataSet {
    DataSetViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)removeCahcedDataset {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:nil forKey:@"dataSets"];
    [settings synchronize];
}

- (void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setDouble:newLocation.coordinate.latitude forKey:@"lastLatitude"];
    [settings setDouble:newLocation.coordinate.longitude forKey:@"lastLongitude"];
    [settings synchronize];
    //[ModelHelper getAndSaveUserLocationByLatLng:newLocation.coordinate.latitude :newLocation.coordinate.longitude:@"geocodedLocation"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([settings doubleForKey:@"lastLatitude"], [settings doubleForKey:@"lastLongitude"]);

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error != nil){
            [_hudView stopActivityIndicator];
            return;
        }
        [_hudView stopActivityIndicator];
        if (!self.isMovingToDataset && placemarks.count > 0) {
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            [ModelHelper getAndSaveUserLocationByPlaceMarker:placeMark.addressDictionary:@"geocodedLocation":coordinate.latitude:coordinate.longitude];
            [locationManager stopUpdatingLocation];
            [self moveToDataSet];
            self.isMovingToDataset = YES;
        }
    }];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error{
    [_hudView stopActivityIndicator];
    [AppDelegate showConnectionError];
    [locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *locationImage = [[UIImageView alloc] initWithFrame:CGRectMake(26,10,17,17)];
    locationImage.image = [UIImage imageNamed:@"Icon-Location.png"];
    [currentLocationButton addSubview:locationImage];
    
    UIImageView *typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(44,10,17,17)];
    typeImage.image = [UIImage imageNamed:@"Icon-Type.png"];
    [typeButton addSubview:typeImage];
    
    UIImageView *previousImage = [[UIImageView alloc] initWithFrame:CGRectMake(37,10,17,17)];
    previousImage.image = [UIImage imageNamed:@"Icon-Previous.png"];
    [previousButton addSubview:previousImage];
    
    _hudView = [[HudView alloc] init];
    [_hudView loadActivityIndicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isMovingToDataset = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
