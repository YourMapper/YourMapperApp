//
//  DataSetDetailsViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h> 
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AppDelegate.h"
#import "HudView.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 

@interface DataSetDetailsViewController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate> {
    NSMutableArray *_items;
    NSMutableArray *_iconItems;
    UITableView *_tableView;
    int _markerType;
    NSString *_dataSetId;
    NSString *_adUrl;
    HudView *_hudView;
    CLLocationManager *locationManager;
    BOOL _isMovingToDataset;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *iconItems;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *dataSetId;
@property (nonatomic, retain) NSString *adUrl;
@property (nonatomic) int markerType;
@property (nonatomic) BOOL isMovingToDataset;

- (IBAction)saveDataset:(id)sender;
- (void)filterButtonPressed:(id)sender;
- (void)mapButtonPressed:(id)sender;
- (void)infoButtonPressed:(id)sender;
- (void)emailButtonPressed:(id)sender;
- (void)locationButtonPressed:(id)sender;
- (void)getItems;
- (void)showAd:(id)sender;
- (void)loadData;

@end
