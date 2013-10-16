//
//  DataSetViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataSetViewController.h"
#import "DataSetDetailsViewController.h"
#import "NSString+HTML.h"
#import "ModelHelper.h"
#import "Dataset.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "HudView.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation DataSetViewController
@synthesize coordiante;
@synthesize items = _items;
@synthesize content = _content;
@synthesize indices = _indices;
@synthesize externalIds = _externalIds;

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
    _hudView = [[HudView alloc] init];
    [_hudView loadActivityIndicator];
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
    self.title = @"Area Datasets";
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *userSortOption = [settings objectForKey:@"userSortOption"];
    if (userSortOption == nil) {
        [settings setObject:@"views" forKey:@"userSortOption"];
        [settings synchronize];
    }
    self.externalIds = [[NSMutableArray alloc] init];
    UIBarButtonItem* sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(showActionSheet:)];
    self.navigationItem.rightBarButtonItem = sortButton;
    [self getItems];
}

- (void)getItems {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    double lastLatitude = [settings doubleForKey:@"lastLatitude"];
    double lastLongitude = [settings doubleForKey:@"lastLongitude"];
    NSDictionary* dataSets = [settings objectForKey:@"dataSets"];
    if (dataSets == nil && lastLatitude != 0 && lastLongitude != 0) {
        [_hudView  startActivityIndicator:self.view];
        self.coordiante = CLLocationCoordinate2DMake(lastLatitude, lastLongitude);
        NSMutableString *url = [[[appDelegate defaults] objectForKey:@"DataSetUrl"] mutableCopy];
        NSMutableString *yourMapperAPIKey = [[[appDelegate defaults] objectForKey:@"YourMapperAPIKey"] mutableCopy];
        float margin = 0.0025;
        [url replaceOccurrencesOfString:@"KEY" withString:[[NSString alloc] initWithFormat:@"%@", yourMapperAPIKey] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"MAXLON" withString:[[NSString alloc] initWithFormat:@"%f", lastLongitude + margin] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"MAXLAT" withString:[[NSString alloc] initWithFormat:@"%f", lastLatitude + margin] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"MINLON" withString:[[NSString alloc] initWithFormat:@"%f", lastLongitude - margin] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"MINLAT" withString:[[NSString alloc] initWithFormat:@"%f", lastLatitude - margin] 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        
        [url replaceOccurrencesOfString:@"SORT" withString:@"views" 
                                options:NSLiteralSearch range:(NSRange){0,[url length]}];
        NSURL *finalUrl = [NSURL URLWithString:[NSString stringWithString:url]];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:finalUrl];
            if (data == nil) {
                [_hudView stopActivityIndicator];
                [AppDelegate showConnectionError];
            } else {
                [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
            }
        }); 
    } else {
        [self loadItems];  
    }
}

-(IBAction)showActionSheet:(id)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Location", @"Dataset Name", @"Last Updated", @"User Rating", @"Popularity", @"Type", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *userSortOption = nil;
    switch (buttonIndex) {
        case 0:
            userSortOption = @"location";
            break;
        case 1:
            userSortOption = @"name";
            break;
        case 2:
            userSortOption = @"daysUpdate";
            break;
        case 3:
            userSortOption = @"ratingScore";
            break;
        case 4:
            userSortOption = @"viewCount";
            break;
        case 5:
            userSortOption = @"typeName";
            break;
    }
    if (userSortOption != nil) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:userSortOption forKey:@"userSortOption"];
        [settings synchronize];
        [self getItems];
    }
}


- (void)fetchedData:(NSData *)responseData {
    [_hudView stopActivityIndicator];
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:json];
    if (isValid) {
        NSDictionary* dataSets = json;
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:dataSets forKey:@"dataSets"];
        [settings synchronize];
        for (NSDictionary *item in [dataSets objectForKey:@"items"]) {
            Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalIdItem:[item objectForKey:@"ID"]:item];
            [self.externalIds addObject:dataSet.externalId];
        }
        [self loadItems];
    } else {
        [AppDelegate showConnectionError];
    }
}

- (void)loadItems {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *sortOrder = [settings stringForKey:@"userSortOption"];
    if (self.externalIds.count == 0) {
        NSDictionary* dataSets = [settings objectForKey:@"dataSets"];
        for (NSDictionary *item in [dataSets objectForKey:@"items"]) {
            [self.externalIds addObject:[item objectForKey:@"ID"]];
        }
    }
    if ([sortOrder caseInsensitiveCompare:@"location"] == NSOrderedSame) {
        self.items = [ModelHelper getDatasetsByCoverage:self.externalIds];
    } else {
        self.items = [ModelHelper getDatasets:sortOrder:self.externalIds]; 
    }
    self.content = self.groupedContent;
    [self.tableView reloadData];
}

- (NSMutableArray *)addRow:(NSMutableArray *)content:(NSMutableDictionary *)row:(NSMutableArray *)groupedItems:(NSString *)headerTitle {
    [row setValue:headerTitle forKey:@"headerTitle"];
    [row setValue:groupedItems forKey:@"rowValues"];        
    [content addObject:row];
    return content;
}

- (NSMutableArray *)viewCountContent {
    NSMutableArray *content = [NSMutableArray new];
    NSArray *thresholdLabels = [[NSArray alloc] initWithObjects:@"Millions",@"Hundreds of Thousands",@"Tens of Thousands",@"Thousands",@"Hundreds",@"Dozens",@"A Few",nil];
    double thresholds[7] = {1000000,100000,10000,1000,100,11,0};
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    NSMutableArray *groupedItems = [[NSMutableArray alloc] init];
    int priorThresholdIndex = 0;
    int currentIndex = 0;
    for (Dataset *item in self.items) {
        for(int i = 0; i < thresholdLabels.count; i++) { //find the right threshold
            if ([item.viewCount intValue] >= thresholds[i]) {
                if (priorThresholdIndex != i) {
                    if (groupedItems.count > 0) {
                        [self addRow:content :row :groupedItems :[NSString stringWithFormat:@"Views: %@", [thresholdLabels objectAtIndex:priorThresholdIndex]]];
                    }
                    row = [[NSMutableDictionary alloc] init];
                    groupedItems = [[NSMutableArray alloc] init]; 
                    priorThresholdIndex = i;
                }
                [groupedItems addObject:item];
                break;
            }
        }
        currentIndex++;
        if (currentIndex == self.items.count && groupedItems.count > 0) {
            [self addRow:content :row :groupedItems :[NSString stringWithFormat:@"Views: %@", [thresholdLabels objectAtIndex:priorThresholdIndex]]];
        }
    }
    return content;
}

- (NSMutableArray *)daysUpdatedContent {
    NSMutableArray *content = [NSMutableArray new];
    NSArray *thresholdLabels = [[NSArray alloc] initWithObjects:@"Recently",@"1+ Weeks Ago",@"2+ Weeks Ago",@"1+ Months Ago",@"2+ Months Ago",@"3+ Months Ago",@"6+ Months Ago",@"1+ Years Ago",nil];
    int thresholds[9] = {0,7,14,30,61,91,160,365,999999999};
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    NSMutableArray *groupedItems = [[NSMutableArray alloc] init];
    int priorThresholdIndex = 0;
    int currentIndex = 0;
    for (Dataset *item in self.items) {
        for(int i = 0; i < thresholdLabels.count; i++) { //find the right threshold
            if (([item.daysUpdate intValue] >= thresholds[i]) && (i == thresholdLabels.count || [item.daysUpdate intValue] <= thresholds[i + 1])) {
                if (priorThresholdIndex != i) {
                    if (groupedItems.count > 0) {
                        [self addRow:content :row :groupedItems :[NSString stringWithFormat:@"Updated: %@", [thresholdLabels objectAtIndex:priorThresholdIndex]]];
                    }
                    row = [[NSMutableDictionary alloc] init];
                    groupedItems = [[NSMutableArray alloc] init]; 
                    priorThresholdIndex = i;
                }
                [groupedItems addObject:item];
                break;
            }
        }
        currentIndex++;
        if (currentIndex == self.items.count && groupedItems.count > 0) {
            [self addRow:content :row :groupedItems :[NSString stringWithFormat:@"Updated: %@", [thresholdLabels objectAtIndex:priorThresholdIndex]]];
        }
    }
    return content;
}

- (NSMutableArray *)ratingsContent {
    NSMutableArray *content = [NSMutableArray new];
    NSArray *thresholdLabels = [[NSArray alloc] initWithObjects:@"5 Stars",@"4 Stars",@"3 Stars",@"2 Stars",@"1 Star",@"No Stars",nil];
    double thresholds[6] = {4.5,3.5,2.5,1.5,0.5,0.0};
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    NSMutableArray *groupedItems = [[NSMutableArray alloc] init];
    int priorThresholdIndex = 0;
    int currentIndex = 0;
    for (Dataset *item in self.items) {
        for(int i = 0; i < thresholdLabels.count; i++) { //find the right threshold
            if ([item.ratingScore doubleValue] >= thresholds[i]) {
                if (priorThresholdIndex != i) {
                    if (groupedItems.count > 0) {
                        [self addRow:content :row :groupedItems :[NSString stringWithFormat:@"Rating: %@", [thresholdLabels objectAtIndex:priorThresholdIndex]]];
                    }
                    row = [[NSMutableDictionary alloc] init];
                    groupedItems = [[NSMutableArray alloc] init]; 
                    priorThresholdIndex = i;
                }
                [groupedItems addObject:item];
                break;
            }
        }
        currentIndex++;
        if (currentIndex == self.items.count && groupedItems.count > 0) {
            [self addRow:content :row :groupedItems :[NSString stringWithFormat:@"Rating: %@", [thresholdLabels objectAtIndex:priorThresholdIndex]]];
        }
    }
    return content;
}

- (NSMutableArray *)nameContent {
    NSMutableArray *content = [NSMutableArray new];
    int currentIndex = 0;
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    NSMutableArray *groupedItems = [[NSMutableArray alloc] init];
    unichar priorFirstLetter = 'A';
    for (Dataset *item in self.items) {
        unichar currentFirstLetter = [item.name characterAtIndex:0];
        if (priorFirstLetter == currentFirstLetter) {
            [groupedItems addObject:item];
        } else {
            if (groupedItems.count > 0) {
                [self addRow:content :row :groupedItems :[NSString stringWithFormat: @"%c", priorFirstLetter]];            
            }
            row = [[NSMutableDictionary alloc] init];
            groupedItems = [[NSMutableArray alloc] init];
            [groupedItems addObject:item];
            priorFirstLetter = currentFirstLetter;
            if (currentIndex == self.items.count - 1) {
                [self addRow:content :row :groupedItems :[NSString stringWithFormat: @"%c", priorFirstLetter]];
            }
        }
        currentIndex++;
        if (currentIndex == self.items.count && groupedItems.count > 0) {
            [self addRow:content :row :groupedItems :[NSString stringWithFormat: @"%c", priorFirstLetter]];
        }
    }    
    return content;
}

- (NSMutableArray *)typeContent {
    NSMutableArray *content = [NSMutableArray new];
    int currentIndex = 0;
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    NSMutableArray *groupedItems = [[NSMutableArray alloc] init];
    NSString *priorType = @"";
    for (Dataset *item in self.items) {
        NSString *currentType = item.typeName;
        if ([priorType isEqualToString:currentType]) {
            [groupedItems addObject:item];
        } else {
            if (groupedItems.count > 0) {
                [self addRow:content :row :groupedItems :[NSString stringWithFormat: @"%@", priorType]];            
            }
            row = [[NSMutableDictionary alloc] init];
            groupedItems = [[NSMutableArray alloc] init];
            [groupedItems addObject:item];
            priorType = currentType;
            if (currentIndex == self.items.count - 1) {
                [self addRow:content :row :groupedItems :[NSString stringWithFormat: @"%@", priorType]];
            }
        }
        currentIndex++;
        if (currentIndex == self.items.count && groupedItems.count > 0) {
            [self addRow:content :row :groupedItems :[NSString stringWithFormat: @"%@", priorType]];
        }
    }    
    return content;
}

- (NSMutableArray *)coverageContent {
    NSMutableArray *content = [NSMutableArray new];
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    NSMutableArray *groupedItems = [[NSMutableArray alloc] init];
    for (Dataset *item in self.items) {
        if (item.national == [NSNumber numberWithInt:1]) {
            [groupedItems addObject:item];
        } else {
            break;
        }
    }
    if (groupedItems.count > 0) {
        [self addRow:content :row :groupedItems :@"National"];
    }
    
    row = [[NSMutableDictionary alloc] init];
    groupedItems = [[NSMutableArray alloc] init];
    NSString *lastState = nil;
    NSString *lastCity = nil;
    NSString *lastCoverage = nil;
    for (Dataset *item in self.items) {
        if (item.national == [NSNumber numberWithInt:0]) {
            if (item.city == nil) {
                if (lastCity != nil) {
                    [self addRow:content :row :groupedItems :lastCity];    
                    row = [[NSMutableDictionary alloc] init];
                    groupedItems = [[NSMutableArray alloc] init];
                }
                lastState = item.state;
                lastCity = nil;
                [groupedItems addObject:item];
            } else {
                if (groupedItems.count > 0 && lastCity == nil) {
                    [self addRow:content :row :groupedItems :lastState];    
                    row = [[NSMutableDictionary alloc] init];
                    groupedItems = [[NSMutableArray alloc] init];
                }
                if (lastCity == nil || [lastCity caseInsensitiveCompare:item.city] != NSOrderedSame) {
                    if (groupedItems.count > 0) {
                        [self addRow:content :row :groupedItems :item.coverage];  
                    }
                    lastCity = item.city;
                    row = [[NSMutableDictionary alloc] init];
                    groupedItems = [[NSMutableArray alloc] init];
                }
                lastState = nil;
                [groupedItems addObject:item];
            }
        }
        lastCoverage = item.coverage;
    }
    if (groupedItems.count > 0) {
        [self addRow:content :row :groupedItems :(lastState == nil) ? lastCoverage : lastState];
    }
    return content;
}

- (NSArray*)groupedContent {
    NSMutableArray *content = nil;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *sortOrder = [settings stringForKey:@"userSortOption"];
    if ([sortOrder isEqualToString:@"viewCount"]) {
        content = [self viewCountContent];
    } else if ([sortOrder isEqualToString:@"name"]) {
        content = [self nameContent];
    } else if ([sortOrder isEqualToString:@"daysUpdate"]) {
        content = [self daysUpdatedContent];
    } else if ([sortOrder isEqualToString:@"ratingScore"]) {
        content = [self ratingsContent]; 
    } else if ([sortOrder isEqualToString:@"location"]) {
        content = [self coverageContent];
    } else if ([sortOrder isEqualToString:@"typeName"]) {
        content = [self typeContent];
    }
    return content;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Dataset *item = [[[self.content objectAtIndex:indexPath.section] objectForKey:@"rowValues"] 
                     objectAtIndex:indexPath.row];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:item.externalId forKey:@"dataSetId"];
    [settings setObject:item.name forKey:@"dataSetName"];
    [settings setObject:nil forKey:[NSString stringWithFormat:@"%@DataSetItems", item.externalId]];
    [settings synchronize];
    DataSetDetailsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataSetDetailStoryboard"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Datasets" style:UIBarButtonItemStylePlain target:controller action:@selector(showDataSets:)];
    self.navigationItem.backBarButtonItem = backButton;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.content count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.content objectAtIndex:section] objectForKey:@"rowValues"] count] ;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	return [[self.content objectAtIndex:section] objectForKey:@"headerTitle"];
    
}

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.content valueForKey:@"headerTitle"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.indices indexOfObject:title];
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dataset *item = [[[self.content objectAtIndex:indexPath.section] objectForKey:@"rowValues"] 
                     objectAtIndex:indexPath.row];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSize:3];
    [formatter setGroupingSeparator:@","];
    [formatter setUsesGroupingSeparator:YES];
    
    //static NSString *CellIdentifier = @"Cell";
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 220, 25)];
        titleLabel.tag = 1;
        titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 220, 15)];
        descriptionLabel.tag = 2;
        descriptionLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        [cell.contentView addSubview:descriptionLabel];
        
        UILabel *coverageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 42, 220, 15)];
        coverageLabel.tag = 3;
        coverageLabel.textColor = [UIColor grayColor];
        coverageLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        [cell.contentView addSubview:coverageLabel];
        
        UILabel *ratingScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(242, 5, 75, 15)];
        ratingScoreLabel.tag = 4;
        ratingScoreLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        ratingScoreLabel.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:ratingScoreLabel];
        
        UILabel *viewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(242, 22, 75, 15)];
        viewCountLabel.tag = 5;
        viewCountLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:10];
        viewCountLabel.textColor = [UIColor grayColor];
        viewCountLabel.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:viewCountLabel];
        
        UILabel *daysLabel = [[UILabel alloc] initWithFrame:CGRectMake(242, 40, 75, 15)];
        daysLabel.tag = 6;
        daysLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
        daysLabel.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:daysLabel];
        
    }
    
    UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:1];
    titleLabel.text = item.name;
    
    UILabel *descriptionLabel = (UILabel*)[cell viewWithTag:2];
    descriptionLabel.text = [NSString stringWithFormat:@"%@", [item.itemDescription stringByConvertingHTMLToPlainText]];
    
    UILabel *coverageLabel = (UILabel*)[cell viewWithTag:3];
    coverageLabel.text = [NSString stringWithFormat:@"%@", item.coverage];
    
    UILabel *ratingScoreLabel = (UILabel*)[cell viewWithTag:4];
    ratingScoreLabel.text = [NSString stringWithFormat:@"%@ rating", item.ratingScore];
    
    UILabel *viewCountLabel = (UILabel*)[cell viewWithTag:5];
    viewCountLabel.text = [NSString stringWithFormat:@"%@ views", [formatter stringFromNumber:item.viewCount]];
    
    UILabel *daysLabel = (UILabel*)[cell viewWithTag:6];
    daysLabel.text = [NSString stringWithFormat:@"%@ days ago", item.daysUpdate];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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

@end
