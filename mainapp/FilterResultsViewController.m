//
//  FilterResultsViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterResultsViewController.h"
#import "AppDelegate.h"
#import "StartEndFilterViewController.h"
#import "DataSetDetailsViewController.h"
#import "ModelHelper.h"
#import "Dataset.h"
#import "HudView.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]


@implementation FilterResultsViewController
@synthesize filterItems = _filterItems;
@synthesize savedCategoryItems = _savedCategoryItems;
@synthesize savedCurrentCategoryIds = _savedCurrentCategoryIds;
@synthesize searchText = _searchText;
@synthesize hasDateFilter = _hasDateFilter;
@synthesize dataSet = _dataSet;

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

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    [_hudView stopActivityIndicator];
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:json];
    if (isValid) {
        self.filterItems = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"items"]];
        if (self.savedCurrentCategoryIds == nil) {
            self.savedCategoryItems = [[NSMutableArray alloc] init];
            NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
            for (NSDictionary *item in self.filterItems) {
                NSNumber *itemId = (NSNumber*)[numberFormatter numberFromString:[item objectForKey:@"id"]];
                [self.savedCategoryItems addObject:itemId];
            }
        }
        [self.tableView reloadData];
    } else {
        [AppDelegate showConnectionError];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _hudView = [[HudView alloc] init];
    [_hudView loadActivityIndicator];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Datasets" style:UIBarButtonItemStylePlain target:self action:@selector(showDataSets:)];
    self.navigationItem.backBarButtonItem = backButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]; 
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    
    UIView *containerView =
    [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, 300, 35)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 300, 33)];
    headerLabel.text = @"Available search filters for current dataset";
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
    [containerView addSubview:headerLabel];
    self.tableView.tableHeaderView = containerView;
    
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *userSavedCategories = [NSString stringWithFormat:@"%@Categories", self.dataSet.externalId];
    NSMutableString *categoriesText = [[NSMutableString alloc] initWithString:@""];
    if (userSavedCategories != nil)
    {
        [categoriesText appendString:[NSString stringWithFormat:@"%d of ", self.filterItems.count - [userSavedCategories componentsSeparatedByString: @","].count]];
        [categoriesText appendString:[NSString stringWithFormat:@"%d categories", self.filterItems.count]];
    }
    NSString *categories = [settings stringForKey:[NSString stringWithFormat:@"%@Categories", self.dataSet.externalId]];
    [settings setValue:categories forKey:[NSString stringWithFormat:@"%@SavedCategories", self.dataSet.externalId]];
    [settings setValue:categoriesText forKey:[NSString stringWithFormat:@"%@SavedCategoriesText", self.dataSet.externalId]];
    NSDate *startDate = [settings objectForKey:[NSString stringWithFormat:@"%@StartDate", self.dataSet.externalId]];
    [settings setObject:startDate forKey:[NSString stringWithFormat:@"%@SavedStartDate", self.dataSet.externalId]];
    NSDate *endDate = [settings objectForKey:[NSString stringWithFormat:@"%@EndDate", self.dataSet.externalId]];
    [settings setObject:endDate forKey:[NSString stringWithFormat:@"%@SavedEndDate", self.dataSet.externalId]];
    [settings setValue:self.searchText.text forKey:[NSString stringWithFormat:@"%@SavedSearchText", self.dataSet.externalId]];
    [settings setValue:self.searchText.text forKey:[NSString stringWithFormat:@"%@SearchText", self.dataSet.externalId]];
    [settings setObject:nil forKey:[NSString stringWithFormat:@"%@DataSetItems", self.dataSet.externalId]];
    [settings setBool:YES forKey:[NSString stringWithFormat:@"%@HasFilter", self.dataSet.externalId]];
    [settings synchronize]; 
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:6];
    if (self.savedCurrentCategoryIds != nil && self.savedCurrentCategoryIds.length > 0) {
        NSArray *categoryIds = [self.savedCurrentCategoryIds componentsSeparatedByString:@","];
        NSString *categoryText = [NSString stringWithFormat:@"%i of %i categories", categoryIds.count, self.filterItems.count];
        [params setObject:categories forKey:@"categories"];
        [params setObject:categoryText forKey:@"categoriesText"];
    }
    if (endDate != nil) {
        [params setObject:endDate forKey:@"endDate"];
    }
    if (startDate != nil) {
        [params setObject:startDate forKey:@"startDate"];
    }
    if (self.searchText.text != nil) {
        [params setObject:self.searchText.text forKey:@"searchText"];
    }
    [ModelHelper getAndSaveUserDatasetByExternalIdParams:self.dataSet.externalId:params];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@SearchText", self.dataSet.externalId];
    [settings setValue:self.searchText.text forKey:key];
    [settings synchronize];
    [self.searchText resignFirstResponder];
    return YES;
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *dataSetId = [settings stringForKey:@"dataSetId"]; 
    Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:dataSetId];
    self.dataSet = dataSet;
    self.hasDateFilter = [dataSet.dateFilter boolValue];
    self.savedCurrentCategoryIds = [[settings stringForKey:[NSString stringWithFormat:@"%@Categories", self.dataSet.externalId]] mutableCopy];
    
    if (self.savedCurrentCategoryIds != nil && self.savedCurrentCategoryIds.length > 0) {
        self.savedCategoryItems = [[NSMutableArray alloc] init];
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        for (NSString *itemId in [self.savedCurrentCategoryIds componentsSeparatedByString:@","]) {
            [self.savedCategoryItems addObject:(NSNumber*)[numberFormatter numberFromString:itemId]];
        }
    }
    [_hudView startActivityIndicator:self.view];
    NSMutableString *url = [[[appDelegate defaults] objectForKey:@"DataSetCategoriesUrl"] mutableCopy];
    NSMutableString *yourMapperAPIKey = [[[appDelegate defaults] objectForKey:@"YourMapperAPIKey"] mutableCopy];
    [url replaceOccurrencesOfString:@"ID" withString:[[NSString alloc] initWithFormat:@"%@", self.dataSet.externalId] 
                            options:NSLiteralSearch range:(NSRange){0,[url length]}];
    [url replaceOccurrencesOfString:@"KEY" withString:[[NSString alloc] initWithFormat:@"%@", yourMapperAPIKey] 
                            options:NSLiteralSearch range:(NSRange){0,[url length]}];
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
    return (self.hasDateFilter) ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger sectionRowCount = 1;
    if (section == 0) {
        sectionRowCount = self.filterItems.count;
    }
    return sectionRowCount;
}

- (void)switchToggled:(id)sender {
    UISwitch *categorySwitch = (UISwitch*)sender;
    int tagId = categorySwitch.tag;
    NSNumber *tagIdArrayId = [NSNumber numberWithInt:tagId];
    if (categorySwitch.on) {
        [self.savedCategoryItems addObject:tagIdArrayId];
    } else {
        [self.savedCategoryItems removeObject:tagIdArrayId];
    }
    self.savedCurrentCategoryIds = [[self.savedCategoryItems componentsJoinedByString:@","] mutableCopy];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setValue:self.savedCurrentCategoryIds forKey:[NSString stringWithFormat:@"%@Categories", self.dataSet.externalId]];
    [settings synchronize];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch (section) {
        case 0:
            title = @"Categories";
            break;
        case 1:
            title = @"Date Range";
            break;
        case 2:
            title = @"Search Text";
            break;
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    UITableViewCell *cell = nil;
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            NSDictionary *item = (NSDictionary*)[self.filterItems objectAtIndex:indexPath.row];
            NSNumber *itemId = [NSNumber numberWithInt:[[item objectForKey:@"id"] intValue]];
            BOOL on = NO;
            if (self.savedCategoryItems) {
                on = [self.savedCategoryItems containsObject:itemId];
            }
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
            titleLabel.text = [item valueForKey:@"name"];
            titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
            [cell.contentView addSubview:titleLabel];
            
            UISwitch *categorySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(199, 8, 0, 0)];
            categorySwitch.on = on;
            categorySwitch.tag =  [itemId intValue];
            [categorySwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:categorySwitch];
        }
    } else if (indexPath.section == 1 && self.hasDateFilter) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"ccc MMM dd, yyyy"];
        static NSString *StartEndIdentifier = @"StartEnd";
        cell = [tableView dequeueReusableCellWithIdentifier:StartEndIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StartEndIdentifier];
            NSDate *startDate = [settings objectForKey:[NSString stringWithFormat:@"%@StartDate", self.dataSet.externalId]];
            NSDate *endDate = [settings objectForKey:[NSString stringWithFormat:@"%@EndDate", self.dataSet.externalId]];
            
            if (self.dataSet.startDate != nil && startDate == nil) {
                startDate = self.dataSet.startDate;
            }
            
            if (self.dataSet.endDate != nil && endDate == nil) {
                endDate = self.dataSet.endDate;
            }
            
            UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 60, 15)];
            startLabel.text = @"Starts";
            startLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
            [cell.contentView addSubview:startLabel];
            
            UILabel *startTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 8, 140, 15)];
            startTextLabel.text = (startDate == nil) ? @"N/A" : [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:startDate]];
            startTextLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
            startTextLabel.textAlignment = UITextAlignmentRight;
            [cell.contentView addSubview:startTextLabel];
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 22, 60, 15)];
            endLabel.text = @"End";
            endLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
            [cell.contentView addSubview:endLabel];
            
            UILabel *endsTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 22, 140, 15)];
            endsTextLabel.text = (endDate == nil) ? @"N/A" : [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:endDate]];
            endsTextLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
            endsTextLabel.textAlignment = UITextAlignmentRight;
            [cell.contentView addSubview:endsTextLabel];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ((indexPath.section == 2 && self.hasDateFilter) || (indexPath.section == 1 && !self.hasDateFilter)) {
        static NSString *TextIdentifier = @"Text";
        cell = [tableView dequeueReusableCellWithIdentifier:TextIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextIdentifier];
            self.searchText = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 290, 25)];
            self.searchText.placeholder = @"Text";
            self.searchText.text = [settings stringForKey:[NSString stringWithFormat:@"%@SearchText", self.dataSet.externalId]];
            self.searchText.returnKeyType = UIReturnKeyDone;
            self.searchText.delegate = self;
            [cell.contentView addSubview:self.searchText];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.backgroundColor = [UIColor whiteColor];
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
    switch (indexPath.section) {
        case 0:
        {
            break;
        }
        case 1:
        {
            StartEndFilterViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"StartEndFilterStoryboard"];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 2: 
        {
            break;
        }
    }
}

@end
