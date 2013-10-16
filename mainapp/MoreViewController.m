//
//  MoreViewController.m
//  mainapp
//
//  Created by Eric Roland on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"
#import "AboutUsViewController.h"
#import "DataItemDetailWebViewController.h"

@implementation MoreViewController

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    if (buttonIndex == 1) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[[NSArray alloc] initWithObjects:@"appfeedback@yourmapper.com", nil]];
        [controller setSubject:@"Your Mapper iPhone Comment"];
        [controller setMessageBody:@"Comment: " isHTML:NO];
        [self presentModalViewController:controller animated:YES];
    } 
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   	
    [self becomeFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Your Mapper";
    [self.tableView reloadData];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numberOfRows = 2;
    switch (section) {
        case 0:
            numberOfRows = 2;
            break;
        case 1:
            numberOfRows = 2;
            break;
        case 2:
            numberOfRows = 4;
            break;
    }

    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch (section) {
        case 0:
            title = @"App";
            break;
        case 1:
            title = @"Social";
            break;
        case 2:
            title = @"Your Mapper";
            break;
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                UILabel *feedBackLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 20)];
                feedBackLabel.tag = 1;
                feedBackLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                feedBackLabel.text = @"Send us Feedback";
                [cell.contentView addSubview:feedBackLabel];
                break;
            } case 1: {
                UILabel *reviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 20)];
                reviewLabel.tag = 2;
                reviewLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                reviewLabel.text = @"Review on App Store";
                [cell.contentView addSubview:reviewLabel]; 
                break;
            }
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                
                UILabel *twitterLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 20)];
                twitterLabel.tag = 3;
                twitterLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                twitterLabel.text = @"Follow us on Twitter";
                [cell.contentView addSubview:twitterLabel]; 
                break;
            } case 1: {
                UILabel *faceBookLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 20)];
                faceBookLabel.tag = 4;
                faceBookLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                faceBookLabel.text = @"Like us on Facebook";
                [cell.contentView addSubview:faceBookLabel]; 
                break;
            }
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                UILabel *aboutUsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 20)];
                aboutUsLabel.tag = 4;
                aboutUsLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                aboutUsLabel.text = @"About Us";
                [cell.contentView addSubview:aboutUsLabel];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            } case 1: {
                UILabel *adInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 20)];
                adInfoLabel.tag = 6;
                adInfoLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                adInfoLabel.text = @"Advertising Info";
                [cell.contentView addSubview:adInfoLabel]; 
                break;
            } case 2: {
                UILabel *yourMapperWebsiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 20)];
                yourMapperWebsiteLabel.tag = 5;
                yourMapperWebsiteLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                yourMapperWebsiteLabel.text = @"Your Mapper Website";
                [cell.contentView addSubview:yourMapperWebsiteLabel]; 
                break;
            } case 3: {
                UILabel *appVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
                appVersionLabel.tag = 5;
                appVersionLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                appVersionLabel.text = @"App Version";
                [cell.contentView addSubview:appVersionLabel];
                
                UILabel *appVersionNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 10, 40, 20)];
                appVersionNumberLabel.tag = 6;
                appVersionNumberLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
                appVersionNumberLabel.text = @"1.0.1";
                cell.userInteractionEnabled = NO;
                [cell.contentView addSubview:appVersionNumberLabel];
                break;
            }
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
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
    targetUrl = nil;
    NSString *dialogMessage = nil;
    NSString *title = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                dialogMessage = @"Do you want to leave the application and open your email client?";
                title = @"Contact Us";
                selectedIndexPath = indexPath;
                break;
            }    
            case 1:
                targetUrl = @"http://www.yourmapper.com/app/review.php";
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                targetUrl = @"https://twitter.com/yourmapper";
                break;
            }
            case 1: {
                targetUrl = @"http://facebook.com/yourmapper";
                break;
            }
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                AboutUsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsStoryboard"];
                [self.navigationController pushViewController:controller animated:YES];
                break;
            }
            case 1: {
                targetUrl = @"http://www.yourmapper.com/app";
            }
            case 2: {
                targetUrl = @"http://www.yourmapper.com/app/ad";
            }
        }
    }
    if (dialogMessage != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:dialogMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    } else if (targetUrl != nil) {
        DataItemDetailWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataItemDetailWebStoryboard"];
        controller.urlAddress = targetUrl;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
