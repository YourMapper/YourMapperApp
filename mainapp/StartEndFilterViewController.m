//
//  StartEndFilterViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StartEndFilterViewController.h"
#import "FilterResultsViewController.h"

@implementation StartEndFilterViewController
@synthesize datePicker = _datePicker;
@synthesize dateTableView = _dateTableView;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize selectedRow = _selectedRow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    self.selectedRow = 0;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(save)];
    saveButton.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *dataSetId = [settings stringForKey:@"dataSetId"];
    self.startDate = [settings objectForKey:[NSString stringWithFormat:@"%@StartDate", dataSetId]];
    self.endDate = [settings objectForKey:[NSString stringWithFormat:@"%@EndDate", dataSetId]];
    if (self.startDate == nil) {
        self.startDate = [NSDate date];
        self.endDate = [NSDate date];
    } else {
        [self.datePicker setDate:self.startDate];
    }
}

- (IBAction)dateChanged
{
    NSDate *oldEndDate = self.endDate;
    if (self.selectedRow == 0) {
        self.startDate = [self.datePicker date];
    } else {
        
        self.endDate = [self.datePicker date];
    }
    if ([self.startDate earlierDate:self.endDate] == self.endDate) {
        self.endDate = oldEndDate;
        NSString *dialogMessage = @"Your end date must be greater than your start date";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"End Date" message:dialogMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [self.dateTableView reloadData];
}

- (IBAction)cancel
{
    FilterResultsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterResultsStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)save
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *dataSetId = [settings stringForKey:@"dataSetId"];
    [settings setObject:self.startDate forKey:[NSString stringWithFormat:@"%@StartDate", dataSetId]];
    [settings setObject:self.endDate forKey:[NSString stringWithFormat:@"%@EndDate", dataSetId]];
    [settings synchronize];   
    FilterResultsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterResultsStoryboard"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 170, 20)];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"ccc MMM dd, yyyy"];
    
    if (indexPath.row == self.selectedRow) {
        cell.backgroundColor = [UIColor blueColor];
        label.backgroundColor = [UIColor blueColor];
        label.textColor = [UIColor whiteColor];
        dateLabel.backgroundColor = [UIColor blueColor];
        dateLabel.textColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 0) {
        label.text = @"Starts";
        dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:self.startDate]];
    } else {
        label.text = @"Ends";
        dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:self.endDate]];
    }
    
    label.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
    [cell.contentView addSubview:label];
    
    dateLabel.textAlignment = UITextAlignmentRight;
    dateLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
    [cell.contentView addSubview:dateLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    [self.dateTableView reloadData];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
