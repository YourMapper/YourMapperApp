//
//  TypeLocationViewController.m
//  mainapp
//
//  Created by Eric Roland on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TypeLocationViewController.h"
#import "ModelHelper.h"
#import "DataSetViewController.h"
#import "RootViewController.h"
#import "DataSetViewController.h"
#import "HudView.h"

@implementation TypeLocationViewController
@synthesize searchBox = _searchBox;
@synthesize searchButton = _searchButton;
@synthesize locationManager = _locationManager;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Loc" style:UIBarButtonItemStylePlain target:self action:@selector(locate:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.title = @"Type Location";
    if (self.searchBox.text.length == 0) {
        self.searchButton.enabled = NO;
    }
}

- (IBAction)showPeoplePickerController
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	NSArray *displayedItems = [NSArray arrayWithObjects: [NSNumber numberWithInt:kABPersonEmailProperty],
                               [NSNumber numberWithInt:kABPersonAddressProperty], nil];
	
	
	picker.displayedProperties = displayedItems;
	// Show the picker 
	[self presentModalViewController:picker animated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonAddressProperty) {
        /*
         * Set up an ABMultiValue to hold the address values; copy from address
         * book record.
         */
        ABMultiValueRef multi = ABRecordCopyValue(person, property);
        
        // Set up an NSArray and copy the values in.
        NSArray *theArray = (__bridge_transfer NSArray*)ABMultiValueCopyArrayOfAllValues(multi);
        
        // Figure out which values we want and store the index.
        const NSUInteger theIndex = ABMultiValueGetIndexForIdentifier(multi, identifier);
        
        // Set up an NSDictionary to hold the contents of the array.
        NSDictionary *theDict = [theArray objectAtIndex:theIndex];
        
        // Set the address label's text.
        NSString *address;
        address = [NSString stringWithFormat:@"%@, %@, %@, %@ %@",
                   [theDict objectForKey:(NSString *)kABPersonAddressStreetKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressCityKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressStateKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressZIPKey],
                   [theDict objectForKey:(NSString *)kABPersonAddressCountryKey]];
        
        _searchBox.text = address;
        self.searchButton.enabled = YES;
        
        // Return to the main view controller.
        [ self dismissModalViewControllerAnimated:YES ];
    }
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setDouble:newLocation.coordinate.latitude forKey:@"lastLatitude"];
    [settings setDouble:newLocation.coordinate.longitude forKey:@"lastLongitude"];
    [settings synchronize];
    [self.locationManager stopUpdatingLocation];
    [self moveToDataSet];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error{
    [_hudView stopActivityIndicator];
    [AppDelegate showConnectionError];
    [self.locationManager stopUpdatingLocation];
}

- (void)moveToDataSet {
    DataSetViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)locate:(id)sender {
    [_hudView startActivityIndicator:self.view];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (IBAction)searchTextEntered:(id)sender {
    if (self.searchBox.text.length > 0) {
        self.searchButton.enabled = YES;
    }
}

- (IBAction)doSearch:(id)sender {
    NSString *address = self.searchBox.text;
    if (address.length > 0) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
         { 
             if (error != nil && placemarks.count > 0) {
                 [_hudView stopActivityIndicator];
                 if (error.code == -1009) {
                     [AppDelegate showConnectionError];
                 } else {
                     NSString *dialogMessage = @"Unable to locate your address address";
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Address not found" message:dialogMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];  
                 }
             } else {
                 [_hudView stopActivityIndicator];
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
                 [settings setFloat:placemark.location.coordinate.latitude forKey:@"lastLatitude"];
                 [settings setFloat:placemark.location.coordinate.longitude forKey:@"lastLongitude"];
                 [settings synchronize];
                 [ModelHelper getAndSaveUserLocationByPlaceMarker:placemark.addressDictionary:@"typedLocation":placemark.location.coordinate.latitude:placemark.location.coordinate.longitude];
                 //[ModelHelper getAndSaveUserLocationByLatLng:placemark.coordinate.latitude :placemark.coordinate.longitude :@"typedLocation"];
                 DataSetViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetStoryboard"];    
                 [self.navigationController pushViewController:controller animated:YES];  
             }
             
         }];
    } else {
        NSString *dialogMessage = @"Your must enter a valid address";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Address not valid" message:dialogMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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
