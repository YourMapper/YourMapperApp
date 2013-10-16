//
//  PreviousPlacesViewController.m
//  mainapp
//
//  Created by Eric Roland on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreviousPlacesViewController.h"
#import "ModelHelper.h"
#import "UserLocation.h"
#import "CoreDataHelper.h"
#import "Location.h"
#import "DataSetViewController.h"
#import "AppDelegate.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation PreviousPlacesViewController
@synthesize userLocations = _userLocations;
@synthesize doneButton = _doneButton;
@synthesize editButton = _editButton;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:nil forKey:@"dataSets"];
    [settings synchronize];
    self.title = @"Previous Locations";
    UITabBarItem *item = [self.parentViewController.tabBarController.tabBar.items objectAtIndex:1];
    item.title = @"Locations";
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
    self.userLocations = [[[ModelHelper.getCurrentUser mutableSetValueForKey:@"userLocations"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(doEdit:)];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doEdit:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    [self.tableView reloadData];
    /*
    NSMutableArray* locations = [CoreDataHelper searchObjectsInContext:@"Location" :nil :nil :NO :[appDelegate managedObjectContext]];
    for(Location *location in locations) {
        NSLog(@"%@ %f %f", location.address, [location.latitude doubleValue], [location.longitude doubleValue]);
        
    }
    */
}

- (IBAction)doEdit:(id)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:NO];
        self.navigationItem.rightBarButtonItem = self.editButton;
    } else {
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }
    [self.tableView reloadData];
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
    return self.userLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UIImageView *locationImage = nil;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
    UserLocation *userLocation = [self.userLocations objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        locationImage = [[UIImageView alloc] initWithFrame:CGRectMake(15,20,17,17)];
        locationImage.tag = 2;
        [cell.contentView addSubview:locationImage];
        //UIImage *locationImage = [UIImage imageNamed:@"Icon-Location.png"];
        //[AppDelegate scale:locationImage toSize:size]
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 230, 16)];
        addressLabel.tag = 3;
        addressLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
        [cell.contentView addSubview:addressLabel];
        
        UILabel *cityStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 18, 230, 16)];
        cityStateLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        cityStateLabel.tag = 4;
        [cell.contentView addSubview:cityStateLabel];
        
        UILabel *dateSavedLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 36, 230, 16)];
        dateSavedLabel.textColor = [UIColor grayColor];
        dateSavedLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        dateSavedLabel.tag = 5;
        [cell.contentView addSubview:dateSavedLabel];
    }
    
    UILabel *addressLabel = (UILabel*)[cell viewWithTag:3];
    addressLabel.text = [NSString stringWithFormat:@"%@", (userLocation.location.address == nil) ? @"No Street Address" : userLocation.location.address];
    
    locationImage = (UIImageView*)[cell viewWithTag:2];
    NSString *imageName = ([userLocation.type isEqualToString:@"geocodedLocation"]) ? @"Icon-Location.png" : @"Icon-Type.png";
    locationImage.image = [UIImage imageNamed:imageName];
    
    UILabel *cityStateLabel = (UILabel*)[cell viewWithTag:4];
    cityStateLabel.text = [NSString stringWithFormat:@"%@, %@", userLocation.location.city, userLocation.location.state];
    
    UILabel *dateSavedLabel = (UILabel*)[cell viewWithTag:5];
    dateSavedLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:userLocation.createdAt]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UserLocation *userLocation = [self.userLocations objectAtIndex:indexPath.row];
        [ModelHelper deleteObject:(NSManagedObject*)userLocation];
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
        self.userLocations = [[[ModelHelper.getCurrentUser mutableSetValueForKey:@"userLocations"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }    
}

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
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    UserLocation *userLocation = [self.userLocations objectAtIndex:indexPath.row];
    [settings setDouble:[userLocation.location.latitude doubleValue] forKey:@"lastLatitude"];
    [settings setDouble:[userLocation.location.longitude doubleValue] forKey:@"lastLongitude"];
    [settings synchronize];
    DataSetViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
