//
//  DataSetDetailsViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataSetDetailsViewController.h"
#import "NSString+HTML.h"
#import "DataItemDetailViewController.h"
#import "ModelHelper.h"
#import "FilterResultsViewController.h"
#import "DataSetViewController.h"
#import "DataSetDetailsMapViewController.h"
#import "DataSetDetailsInfoViewController.h"
#import "AppDelegate.h"
#import "AdWebViewController.h"
#import "HudView.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation DataSetDetailsViewController
@synthesize locationManager, isMovingToDataset;
@synthesize items = _items;
@synthesize tableView = _tableView;
@synthesize iconItems = _iconItems;
@synthesize markerType = _markerType;
@synthesize dataSetId = _dataSetId;
@synthesize adUrl = _adUrl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

-(IBAction)saveDataset:(id)sender {
    [ModelHelper getAndSaveUserDatasetByExternalIdItem:self.dataSetId:nil];
    
    NSString *dialogMessage = @"Your search was saved";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search saved" message:dialogMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    /*
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Filter Results", @"Show Results on Map", 
                                 @"Full Dataset Details", @"Email a Link", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showFromTabBar:self.tabBarController.tabBar];
    */
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    [self becomeFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)getItems {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.items = [settings objectForKey:[NSString stringWithFormat:@"%@DataSetItems", self.dataSetId]];
    if (self.items == nil) {
        [self.items removeAllObjects];
        [self.tableView reloadData];
        [_hudView startActivityIndicator:self.view];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-M-dd"];
        double lastLatitude = [settings doubleForKey:@"lastLatitude"];
        double lastLongitude = [settings doubleForKey:@"lastLongitude"];
        NSMutableString *url = [[[appDelegate defaults] objectForKey:@"DataSetDetailUrl"] mutableCopy];
        NSMutableString *yourMapperAPIKey = [[[appDelegate defaults] objectForKey:@"YourMapperAPIKey"] mutableCopy];
        
        [url replaceOccurrencesOfString:@"KEY" withString:[[NSString alloc] initWithFormat:@"%@", yourMapperAPIKey] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"LATITUDE" withString:[[NSString alloc] initWithFormat:@"%f", lastLatitude] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"LONGITUDE" withString:[[NSString alloc] initWithFormat:@"%f", lastLongitude] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"ID" withString:[[NSString alloc] initWithFormat:@"%@", self.dataSetId] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        NSString *savedCategories = [settings stringForKey:[NSString stringWithFormat:@"%@SavedCategories", self.dataSetId]];
        if (savedCategories != nil && savedCategories.length > 0) {
            [url appendString:[NSString stringWithFormat:@"&c=%@", savedCategories]];
        }
        
        NSDate *startDate = [settings objectForKey:[NSString stringWithFormat:@"%@SavedStartDate", self.dataSetId]];
        if (startDate != nil) {
            NSString *formattedDate = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:startDate]];
            [url appendString:[NSString stringWithFormat:@"&start=%@", formattedDate]];
        }
        
        NSDate *endDate = [settings objectForKey:[NSString stringWithFormat:@"%@SavedEndDate", self.dataSetId]];
        if (endDate != nil) {
            NSString *formattedDate = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:endDate]];
            [url appendString:[NSString stringWithFormat:@"&end=%@", formattedDate]];
        }
        
        NSString *searchText = [settings stringForKey:[NSString stringWithFormat:@"%@SavedSearchText", self.dataSetId]];
        if (searchText != nil && searchText.length > 0) {
            [url appendString:[NSString stringWithFormat:@"&search=%@", searchText]];
        }
        
        NSURL *finalUrl = [NSURL URLWithString:[NSString stringWithString:url]];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:finalUrl];
            if (data == nil) {
                [_hudView stopActivityIndicator];
                [AppDelegate showConnectionError];
            } else {
                [self performSelectorOnMainThread:@selector(fetchedData:) 
                                       withObject:data waitUntilDone:YES];
            }
        });
    } else {
        [self.tableView reloadData];
    }
}

- (void)filterButtonPressed:(id)sender {
    FilterResultsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterResultsStoryboard"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)mapButtonPressed:(id)sender {
    DataSetDetailsMapViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetDetailsMapStoryboard"];
    controller.items = self.items;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)infoButtonPressed:(id)sender {
    DataSetDetailsInfoViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetDetailsInfoStoryboard"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)emailButtonPressed:(id)sender {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:self.dataSetId];
    NSMutableString *url = [[[appDelegate defaults] objectForKey:@"DataSetLinkUrl"] mutableCopy];
    
    NSString *categories = [settings stringForKey:[NSString stringWithFormat:@"%@Categories", self.dataSetId]];
    NSString *searchText = [settings stringForKey:[NSString stringWithFormat:@"%@SearchText", self.dataSetId]];
    NSString *startDate = [settings stringForKey:[NSString stringWithFormat:@"%@SavedStartDate", self.dataSetId]];
    NSString *endDate = [settings stringForKey:[NSString stringWithFormat:@"%@SavedEndDate", self.dataSetId]];
    double latitude = [settings doubleForKey:@"lastLatitude"];
    double longitude = [settings doubleForKey:@"lastLongitude"];
    NSString *dataSetName = [dataSet.name lowercaseString];
    dataSetName = [[dataSetName componentsSeparatedByString: @" "] componentsJoinedByString: @"-"];
    
    [url replaceOccurrencesOfString:@"DATASETID" withString:[NSString stringWithFormat:@"%@", dataSet.datasetId] options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"DATASETNAME" withString:dataSetName options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"DATASETPERMALINK" withString:dataSet.linkPath options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"CATEGORIES" withString:(categories == nil) ? @"" : categories options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"SEARCHTEXT" withString:(searchText == nil) ? @"" : searchText options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"STARTDATE" withString:(startDate == nil) ? @"" : startDate options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"ENDDATE" withString:(endDate == nil) ? @"" : endDate options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"LATITUDE" withString:[NSString stringWithFormat:@"%f",latitude] options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"LONGITUDE" withString:[NSString stringWithFormat:@"%f",longitude] options:NSLiteralSearch range:(NSRange){0,[url length]}];
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:[NSString stringWithFormat:@"Your Mapper: %@", dataSet.name]];
    [controller setMessageBody:url isHTML:NO];
    [self presentModalViewController:controller animated:YES];
}
- (void)locationButtonPressed:(id)sender {
    [_hudView startActivityIndicator:self.view];
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
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
        [locationManager stopUpdatingLocation];
        if (!self.isMovingToDataset && placemarks.count > 0) {
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            [ModelHelper getAndSaveUserLocationByPlaceMarker:placeMark.addressDictionary:@"geocodedLocation":coordinate.latitude:coordinate.longitude];
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            [settings setObject:nil forKey:[NSString stringWithFormat:@"%@DataSetItems", self.dataSetId]];
            [settings synchronize];
            self.isMovingToDataset = YES;
            [self loadData];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error{
    [_hudView stopActivityIndicator];
    [AppDelegate showConnectionError];
    [locationManager stopUpdatingLocation];
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];

    [self loadData];
    
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveDataset:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    if (!self.tableView &&
        [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)self.view;
    }
    
    self.view = [[UIView alloc] initWithFrame:
                  [UIScreen mainScreen].applicationFrame];
    self.tableView.frame = self.view.bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0);
    [self.view addSubview:self.tableView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar sizeToFit];
    CGFloat toolbarHeight = [toolbar frame].size.height;
    CGRect viewBounds = self.navigationController.navigationBar.frame;
    CGFloat rootViewWidth = CGRectGetWidth(viewBounds);
    CGRect rectArea = CGRectMake(0, 0, rootViewWidth, toolbarHeight);
    [toolbar setFrame:rectArea];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL hasFilter = [settings boolForKey:[NSString stringWithFormat:@"%@HasFilter", self.dataSetId]];
    
    
    UIImage *filterImage = [UIImage imageNamed:(hasFilter) ? @"Toolbar-Filter-On" : @"Toolbar-Filter.png"];
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.bounds = CGRectMake( 0, 0, filterImage.size.width, filterImage.size.height );    
    [filterButton setImage:filterImage forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];    
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];

    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Toolbar-Map.png"] style:UIBarButtonItemStylePlain target:self action:@selector(mapButtonPressed:)];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Toolbar-Info.png"] style:UIBarButtonItemStylePlain target:self action:@selector(infoButtonPressed:)];
    UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailButtonPressed:)];
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Toolbar-Location.png"] style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonPressed:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, mapButton, flexibleSpace, filterButtonItem, flexibleSpace, locationButton, flexibleSpace, infoButton, flexibleSpace, emailButton, flexibleSpace, nil]];
    
    [self.view addSubview:toolbar];
}

- (void)loadData {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.dataSetId = [settings stringForKey:@"dataSetId"];
    Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:self.dataSetId];
    
    double latitude = [settings doubleForKey:@"lastLatitude"];
    double longitude = [settings doubleForKey:@"lastLongitude"];
    
    self.markerType = [dataSet.markerType intValue];
    self.title = [settings stringForKey:@"dataSetName"];
    
    NSMutableString *url = [[[appDelegate defaults] objectForKey:@"AdUrl"] mutableCopy];
    [url replaceOccurrencesOfString:@"DATASETID" withString:[NSString stringWithFormat:@"%@", dataSet.datasetId] options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"LATITUDE" withString:[NSString stringWithFormat:@"%f",latitude] options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"LONGITUDE" withString:[NSString stringWithFormat:@"%f",longitude] options:NSLiteralSearch range:(NSRange){0,[url length]}];
    NSURL *finalUrl = [NSURL URLWithString:[NSString stringWithString:url]];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:finalUrl];
        if (data != nil) {
            [self performSelectorOnMainThread:@selector(fetchedAd:) 
                                   withObject:data waitUntilDone:YES];
        }
    });
    
    [self getItems];  
}

- (void)showAd:(id)sender {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:self.adUrl forKey:@"AdUrl"];
    [settings synchronize];
    AdWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AdWebStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)fetchedAd:(NSData *)responseData {
    NSError* error;
    id json = [NSJSONSerialization 
                          JSONObjectWithData:responseData
                          options:kNilOptions 
                          error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:json];
    if (isValid) {
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 50.0, 0.0);
        NSMutableString *adUrl = [[json objectForKey:@"ImagePath"] mutableCopy];
        if ([AppDelegate isRetina]) {
            [adUrl replaceOccurrencesOfString:@".png" withString:@"@2x.png" options:NSLiteralSearch range:(NSRange){0,[adUrl length]}];
        }
        self.adUrl = [json objectForKey:@"LinkPath"];
        NSURL *url = [NSURL URLWithString:adUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 318, 320, 50)];
        [button addTarget:self action:@selector(showAd:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
}

- (void)fetchedData:(NSData *)responseData {
    [_hudView stopActivityIndicator];
    NSError* error;
    id json = [NSJSONSerialization 
                          JSONObjectWithData:responseData
                          options:kNilOptions 
                          error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:json];
    if (isValid) {
        self.items = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"items"]];
        [self.items removeObjectAtIndex:0];
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:self.items forKey:[NSString stringWithFormat:@"%@DataSetItems", self.dataSetId]];
        [settings synchronize];
        for (NSDictionary *item in self.items) {
            [ModelHelper getAndSaveMarkerById:[item objectForKey:@"id"]:item:self.dataSetId];
        }
        [self.tableView reloadData];
    } else {
        [AppDelegate showConnectionError];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hudView = [[HudView alloc] init];
    _hudView.hasSecondHeaderBar = YES;
    [_hudView loadActivityIndicator];
    //[_hudView_hasSecondHeaderBar = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = (NSDictionary*)[self.items objectAtIndex:indexPath.row];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    Marker *marker = [ModelHelper getMarkerById:[item objectForKey:@"id"]];
    float distance = [marker.distance floatValue];
    NSString *roundedDistance = [formatter stringFromNumber:[NSNumber numberWithFloat:distance]];

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        UIImageView *categoryImage = nil;
        if (self.markerType == 1) {
            categoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(13,7,13,20)];
        } else {
            categoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(13,7,13,13)];
        }
        categoryImage.tag = 5;
        [cell.contentView addSubview:categoryImage];
        
        UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 50, 35)];
        distanceLabel.tag = 1;
        distanceLabel.lineBreakMode = UILineBreakModeWordWrap; 
        distanceLabel.numberOfLines = 0;
        distanceLabel.textColor = [UIColor grayColor];
        distanceLabel.font = [UIFont fontWithName:@"ArialMT" size:10];
        
        [cell.contentView addSubview:distanceLabel];   
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 1, 230, 20)];
        titleLabel.tag = 2;
        titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 18, 230, 20)];
        addressLabel.tag = 3;
        addressLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        [cell.contentView addSubview:addressLabel];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 36, 230, 20)];
        categoryLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:12];
        categoryLabel.textColor = [UIColor grayColor];
        categoryLabel.tag = 4;
        [cell.contentView addSubview:categoryLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UIImageView *categoryImage = (UIImageView*)[cell viewWithTag:5];
    NSString *imageName =  [marker.categoryImage stringByAppendingString:@".png"];
    categoryImage.image = [UIImage imageNamed:imageName];
    
    UILabel *distanceLabel = (UILabel*)[cell viewWithTag:1];
    distanceLabel.text = [NSString stringWithFormat:@"%@\nmiles", roundedDistance];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
    titleLabel.text = [NSString stringWithFormat:@"%@", [marker.name stringByConvertingHTMLToPlainText]];
    
    UILabel *addressLabel = (UILabel*)[cell viewWithTag:3];
    addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", marker.address, marker.city, marker.state];
    
    UILabel *categoryLabel = (UILabel*)[cell viewWithTag:4];
    categoryLabel.text = [NSString stringWithFormat:@"%@", marker.category];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_hudView startActivityIndicator:self.view];
    NSDictionary *item = (NSDictionary*)[self.items objectAtIndex:indexPath.row];
    NSString *externalId = [item objectForKey:@"id"];
    Marker *marker = [ModelHelper getMarkerById:externalId];
    DataItemDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataItemDetailStoryboard"];
    controller.marker = marker;
    [self.navigationController pushViewController:controller animated:YES];
    [_hudView stopActivityIndicator];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
