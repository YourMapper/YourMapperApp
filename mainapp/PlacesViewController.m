//
//  PlacesViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "ModelHelper.h"
#import "UserMarker.h"
#import "Marker.h"
#import "DataItemDetailViewController.h"
#import "RootViewController.h"

@implementation PlacesViewController
@synthesize userMarkers = _userMarkers;
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
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
    self.userMarkers = [[[ModelHelper.getCurrentUser mutableSetValueForKey:@"userMarkers"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(doEdit:)];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doEdit:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    [self.tableView reloadData];
    /*
    for(UserMarker *userMarker in userMarkers) {
        if(userMarker.marker.externalId == self.marker.externalId) {
            foundMarker = YES;   
        }
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
    return self.userMarkers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UserMarker *userMarker = [self.userMarkers objectAtIndex:indexPath.row];
    UIImageView *imageView = nil;
    Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:userMarker.marker.dataSetId];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,30,13,20)];
        imageView.tag = 1;
        [cell.contentView addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 1, 230, 20)];
        titleLabel.tag = 2;
        titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,  18, 230, 20)];
        categoryLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:12];
        categoryLabel.tag = 4;
        [cell.contentView addSubview:categoryLabel];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *dataSetName = [[UILabel alloc] initWithFrame:CGRectMake(50, 36, 230, 20)];
        dataSetName.font = [UIFont fontWithName:@"ArialMT" size:12];
        dataSetName.tag = 5;
        [cell.contentView addSubview:dataSetName];
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 56, 230, 20)];
        addressLabel.tag = 3;
        addressLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        [cell.contentView addSubview:addressLabel];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *imageName = [userMarker.marker.categoryImage stringByAppendingString:@".png"];
    imageView = (UIImageView*)[cell viewWithTag:1];
    if ([dataSet.markerType intValue] == 1) {
        imageView.frame = CGRectMake(15,30,13,20);
    } else {
        imageView.frame = CGRectMake(15,30,13,13);
    }
    imageView.image = [UIImage imageNamed:imageName];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
    titleLabel.text = [NSString stringWithFormat:@"%@", userMarker.marker.name];
    
    UILabel *addressLabel = (UILabel*)[cell viewWithTag:3];
    addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", (userMarker.marker.address == nil) ? @"No Street Address" : userMarker.marker.address, userMarker.marker.city, userMarker.marker.state];
    
    UILabel *categoryLabel = (UILabel*)[cell viewWithTag:4];
    categoryLabel.text = [NSString stringWithFormat:@"%@", userMarker.marker.category];
    
    UILabel *dataSetName = (UILabel*)[cell viewWithTag:5];
    dataSetName.text = [NSString stringWithFormat:@"%@", dataSet.name];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
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
        UserMarker *marker = [self.userMarkers objectAtIndex:indexPath.row];
        [ModelHelper deleteObject:(NSManagedObject*)marker];
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
        self.userMarkers = [[[ModelHelper.getCurrentUser mutableSetValueForKey:@"userMarkers"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
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
    UserMarker *userMarker = [self.userMarkers objectAtIndex:indexPath.row];
    DataItemDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataItemDetailStoryboard"];
    controller.marker = userMarker.marker;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
