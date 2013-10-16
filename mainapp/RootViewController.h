//
//  ViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h> 
#import <UIKit/UIKit.h>
#import "HudView.h"

@interface RootViewController : UIViewController <CLLocationManagerDelegate>  {
    UIButton *currentLocationButton;
    UIButton *typeButton;
    UIButton *previousButton;
    //UIButton *typeLocationButton;
    //UIButton *previousLocationButton;
    CLLocationManager *locationManager;
    BOOL _isMovingToDataset;
    HudView *_hudView;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isMovingToDataset;
@property (nonatomic, retain) IBOutlet UIButton *currentLocationButton;
@property (nonatomic, retain) IBOutlet UIButton *typeButton;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;

- (void)moveToDataSet;
- (void)removeCahcedDataset;
- (IBAction) getCurrentLocation;
- (IBAction) moveToTypeLocation;
- (IBAction) moveToPreviousLocation;
@end
