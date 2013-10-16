//
//  SearchesViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchesViewController.h"
#import "ModelHelper.h"
#import "UserDataset.h"
#import "Dataset.h"
#import "AppDelegate.h"
#import "DataSetDetailsViewController.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation SearchesViewController
@synthesize items = _items;
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
    self.title = @"Saved Searches";
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
    self.items = [[[ModelHelper.getCurrentUser mutableSetValueForKey:@"userDatasets"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];

    UITabBarItem *item = [self.parentViewController.tabBarController.tabBar.items objectAtIndex:2];
    item.title = @"Searches";
    [self.tableView reloadData];
    
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(doEdit:)];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doEdit:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
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
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UserDataset *item = [self.items objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 230, 16)];
        name.tag = 3;
        name.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
        [cell.contentView addSubview:name];
        
        UILabel *daysAgo = [[UILabel alloc] initWithFrame:CGRectMake(220, 3, 80, 16)];
        daysAgo.font = [UIFont fontWithName:@"ArialMT" size:12];
        daysAgo.textColor = [UIColor grayColor];
        daysAgo.tag = 4;
        [cell.contentView addSubview:daysAgo];
        
        UILabel *filters = [[UILabel alloc] initWithFrame:CGRectMake(10, 21, 230, 16)];
        filters.font = [UIFont fontWithName:@"Arial-ItalicMT" size:12];
        filters.tag = 5;
        [cell.contentView addSubview:filters];
        
        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(10, 36, 230, 16)];
        address.textColor = [UIColor grayColor];
        address.font = [UIFont fontWithName:@"ArialMT" size:12];
        address.tag = 6;
        [cell.contentView addSubview:address];
    }
    
    UILabel *name = (UILabel*)[cell viewWithTag:3];
    name.text = item.dataset.name;
    NSInteger daysBetween = [AppDelegate daysBetweenDate:item.createdAt andDate:[NSDate date]];
    UILabel *daysAgo = (UILabel*)[cell viewWithTag:4];
    daysAgo.text = [NSString stringWithFormat:@"%i days ago", daysBetween];
    
    NSMutableString *filterText = [[NSMutableString alloc] init];
    if (item.categoriesText != nil && item.categoriesText.length > 0) {
        [filterText appendString:item.categoriesText];
    }
    
    if (item.startDate != nil) {
        if (filterText.length > 0)
            [filterText appendString:@", "];
        [filterText appendString:@"date range"];
    }
    
    if (item.searchText != nil && item.searchText.length > 0) {
        if (filterText.length > 0)
            [filterText appendString:@", "];
        [filterText appendString:item.searchText];
    }
        
    UILabel *filters = (UILabel*)[cell viewWithTag:5];
    filters.text = (filterText.length == 0) ? @"no filters" : filterText;
    
    UILabel *address = (UILabel*)[cell viewWithTag:6];
    address.text = [NSString stringWithFormat:@"%@, %@, %@", (item.location.address == nil) ? @"No Street Address" : item.location.address, item.location.city, item.location.state];
    
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
        UserLocation *userLocation = [self.items objectAtIndex:indexPath.row];
        [ModelHelper deleteObject:(NSManagedObject*)userLocation];
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
        self.items = [[[ModelHelper.getCurrentUser mutableSetValueForKey:@"userDatasets"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
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
    UserDataset *item = [self.items objectAtIndex:indexPath.row];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:item.dataset.externalId forKey:@"dataSetId"];
    [settings setObject:item.dataset.name forKey:@"dataSetName"];
    [settings synchronize];
    
    NSString *dataSetId = item.dataset.externalId;
    if (item.categories != nil && item.categories.length > 0) {
        [settings setValue:item.categories forKey:[NSString stringWithFormat:@"%@SavedCategories", dataSetId]];
    }
    if (item.startDate) {
        [settings setObject:item.startDate forKey:[NSString stringWithFormat:@"%@SavedStartDate", dataSetId]];
    }
    if (item.endDate) {
        [settings setObject:item.endDate forKey:[NSString stringWithFormat:@"%@SavedEndDate", dataSetId]];
    }
    if (item.searchText != nil && item.searchText.length > 0) {
        [settings setValue:item.searchText forKey:[NSString stringWithFormat:@"%@SavedSearchText", dataSetId]];
        [settings setValue:item.searchText forKey:[NSString stringWithFormat:@"%@SearchText", dataSetId]];
    }
    [settings synchronize]; 
    
    DataSetDetailsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetDetailStoryboard"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Datasets" style:UIBarButtonItemStylePlain target:controller action:@selector(showDataSets:)];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
