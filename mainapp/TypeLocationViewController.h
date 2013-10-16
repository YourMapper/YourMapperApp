//
//  TypeLocationViewController.h
//  mainapp
//
//  Created by Eric Roland on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HudView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h> 
#import "AppDelegate.h"

@interface TypeLocationViewController : UIViewController <CLLocationManagerDelegate, ABPeoplePickerNavigationControllerDelegate,
    ABPersonViewControllerDelegate> { 
    IBOutlet UITextField *_searchBox;
    IBOutlet UIButton *_searchButton;
    CLLocationManager *_locationManager;
    HudView *_hudView;
}

@property (nonatomic, retain) IBOutlet UITextField *searchBox;
@property (nonatomic, retain) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)moveToDataSet;
- (IBAction)locate:(id)sender;
- (IBAction)searchTextEntered:(id)sender;
- (IBAction)doSearch:(id)sender;
- (IBAction)showPeoplePickerController;

@end
