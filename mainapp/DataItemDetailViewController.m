//
//  DataItemDetailView.m
//  mainapp
//
//  Created by Eric Roland on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "DataItemDetailViewController.h"
#import "Marker.h"
#import "User.h"
#import "UserMarker.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+HTML.h"
#import "DataItemDetailWebViewController.h"
#import "DataItemDetailMapViewController.h"
#import "ModelHelper.h"
#import "CoreDataHelper.h"
#import "AdWebViewController.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation DataItemDetailViewController
@synthesize marker = _marker;
@synthesize adUrl = _adUrl;
@synthesize scrollView;

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
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:self.marker.dataSetId];
    double latitude = [settings doubleForKey:@"lastLatitude"];
    double longitude = [settings doubleForKey:@"lastLongitude"];
    
    float center = (self.view.frame.size.width / 2);
    if ([dataSet.markerType intValue] == 1) {
        categoryImage.frame = CGRectMake(center - 72,35 + 3,13,20);
    } else {
        categoryImage.frame = CGRectMake(center - 65,35 + 3,13,13);
    }
    
    if (markerImageView != nil && markerImageView.image == nil) {
        NSURL *url = [NSURL URLWithString:self.marker.imagePath];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:url];
            if (data != nil) {
                [self performSelectorOnMainThread:@selector(fetchedImage:) 
                                       withObject:data waitUntilDone:YES];
            }
        });
    }
    
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
}

- (void)fetchedImage:(NSData *)responseData {
    UIImage *image = [UIImage imageWithData:responseData];
    markerImageView.image = image;    
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
    id json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:json];
    if (isValid) {
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

- (IBAction)save:(id)sender {
    BOOL foundMarker = NO;
    NSMutableSet *userMarkers = [ModelHelper.getCurrentUser mutableSetValueForKey:@"userMarkers"];
    for(UserMarker *userMarker in userMarkers) {
        if([userMarker.marker.externalId isEqualToString:self.marker.externalId]) {
            foundMarker = YES;   
        }
    }
    if (!foundMarker) {
        UserMarker* userMarker = [NSEntityDescription insertNewObjectForEntityForName:@"UserMarker" inManagedObjectContext:[appDelegate managedObjectContext]];
        User *user = ModelHelper.getCurrentUser;
        userMarker.user = user;
        userMarker.marker = self.marker;
        userMarker.createdAt = [NSDate date];
        [appDelegate saveContext];
    }
    NSString *dialogMessage = @"Your place has been saved";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Place Saved" message:dialogMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   	
    [self becomeFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDirectionsButtonPressed:(id)sender {
    tagId = ((UIControl*)sender).tag;
    NSString *dialogMessage = @"Open directions in Map app?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Directions" message:dialogMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)viewOnMapButtonPressed:(id)sender {
    DataItemDetailMapViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataItemDetailMapStoryboard"];
    controller.marker = self.marker;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)emailThisPlaceButtonPressed:(id)sender {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:[NSString stringWithFormat:@"Your Mapper Location: %@", self.marker.name]];
    [controller setMessageBody:self.marker.permalink isHTML:NO];
    [self presentModalViewController:controller animated:YES];
}

- (void)moreDetailsButtonPressed:(id)sender {
    DataItemDetailWebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DataItemDetailWebStoryboard"];
    controller.urlAddress = self.marker.detailLink;
    [self.navigationController pushViewController:controller animated:YES];
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    _hudView = [[HudView alloc] init];
    [_hudView loadActivityIndicator]; 
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:scrollView];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:self.marker.dataSetId];
    self.title = self.marker.name;
    
    //self.marker.permalink
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundDown];
    NSString *roundedDistance = [formatter stringFromNumber:[NSNumber numberWithFloat:[self.marker.distance floatValue]]];
    float centerX = (self.view.frame.size.width - 280) / 2;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, yyyy (cccc)"];
    
    int yHeight = 10;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(centerX, yHeight, 280, 20)];
    nameLabel.textAlignment = UITextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"%@", [self.marker.name stringByConvertingHTMLToPlainText]];
    nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
    [self.scrollView addSubview:nameLabel];
    
    yHeight = yHeight + 25;
    NSString *imageName =  [self.marker.categoryImage stringByAppendingString:@".png"];
    float center = (self.view.frame.size.width / 2);
    categoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(center - 65,35 + 3,13,13)];
    categoryImage.image = [UIImage imageNamed:imageName];
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(center - 45, yHeight, 170, 20)];
    categoryLabel.textAlignment = UITextAlignmentLeft;
    categoryLabel.text = [NSString stringWithFormat:@"%@", self.marker.category];
    categoryLabel.textColor = [UIColor grayColor];
    categoryLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:14];
    [self.scrollView addSubview:categoryImage];
    [self.scrollView addSubview:categoryLabel];
    
    yHeight = yHeight + 25;
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(centerX, yHeight, 280, 20)];
    addressLabel.textAlignment = UITextAlignmentCenter;
    addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@", self.marker.address, self.marker.city, self.marker.state];
    addressLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
    [self.scrollView addSubview:addressLabel];
    
    yHeight = yHeight + 20;
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(centerX, yHeight, 280, 20)];
    distanceLabel.textAlignment = UITextAlignmentCenter;
    distanceLabel.text = [NSString stringWithFormat:@"%@ miles from center of search", roundedDistance];
    distanceLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:12];
    [self.scrollView addSubview:distanceLabel];
    
    
    if (self.marker.date != nil) {
        yHeight = yHeight + 27;
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(centerX, yHeight, 280, 20)];
        dateLabel.textAlignment = UITextAlignmentCenter;
        dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:self.marker.date]];
        dateLabel.font = [UIFont fontWithName:@"ArialMT" size:13];
        [self.scrollView addSubview:dateLabel];
    }
    
    int xIndent = 25;
    markerImageView = nil;
    if (self.marker.imagePath != nil) {
        markerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, yHeight + 25, 53, 65)];
        xIndent = xIndent + 56;
        [self.scrollView addSubview:markerImageView];
    }
    
    int descriptionFrameHeight = 0;
    
    if (self.marker.itemDescription != nil) {
        yHeight = yHeight + 25;
        UILabel *descriptoinLabel = [[UILabel alloc] initWithFrame:CGRectMake(xIndent, yHeight, 240, 200)];
        //Needed to remove html except \n
        NSMutableString *replacedDescription = [NSMutableString stringWithString:[self.marker.itemDescription stringByConvertingHTMLToPlainText]];
        [replacedDescription replaceOccurrencesOfString:@"<br>" withString:@"YYYYYYY"
                                                options:NSCaseInsensitiveSearch range:(NSRange){0,[replacedDescription length]}];
        [replacedDescription replaceOccurrencesOfString:@"<br/>" withString:@"YYYYYYY"
                                                options:NSCaseInsensitiveSearch range:(NSRange){0,[replacedDescription length]}];
        replacedDescription = [NSMutableString stringWithString:[replacedDescription stringByConvertingHTMLToPlainText]];
        [replacedDescription replaceOccurrencesOfString:@"YYYYYYY" withString:@"\n"
                                                options:NSCaseInsensitiveSearch range:(NSRange){0,[replacedDescription length]}];
        descriptoinLabel.text = replacedDescription;
        descriptoinLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        descriptoinLabel.lineBreakMode = UILineBreakModeWordWrap; 
        descriptoinLabel.numberOfLines = 0;
        [descriptoinLabel sizeToFit];
        [self.scrollView addSubview:descriptoinLabel];
        
        if (descriptoinLabel.frame.size.height > 25) {
            yHeight = yHeight + descriptoinLabel.frame.size.height - 25;
        }
        
        descriptionFrameHeight = descriptoinLabel.frame.size.height;
    }
    
    if (markerImageView != nil && markerImageView.frame.size.height > descriptionFrameHeight) {
        yHeight += markerImageView.frame.size.height - descriptionFrameHeight + 15;
    } else if (markerImageView != nil && descriptionFrameHeight == 0) {
        yHeight += markerImageView.frame.size.height + 15;
    }
    
    if (self.marker.detailLink != nil && self.marker.detailLink.length > 0) {
        yHeight = yHeight + 25;
        UIButton *moreDetailsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [moreDetailsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        moreDetailsButton.frame = CGRectMake(centerX, yHeight, 280, 30);
        [moreDetailsButton setTitle:dataSet.externalLinkName forState:UIControlStateNormal];
        [moreDetailsButton addTarget:self action:@selector(moreDetailsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:moreDetailsButton];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        yHeight = yHeight + 35;
        UIButton *emailThisPlaceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        emailThisPlaceButton.frame = CGRectMake(centerX, yHeight, 280, 30);
        emailThisPlaceButton.tag = 13;
        [emailThisPlaceButton setTitle:@"Email This Place" forState:UIControlStateNormal];
        [emailThisPlaceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [emailThisPlaceButton addTarget:self action:@selector(emailThisPlaceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:emailThisPlaceButton];
    }
    
    yHeight = yHeight + 35;
    UIButton *viewOnMapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    viewOnMapButton.frame = CGRectMake(20, yHeight, 90, 54);
    [viewOnMapButton setTitle:@"View on\nMap" forState:UIControlStateNormal];
    viewOnMapButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap; 
    viewOnMapButton.titleLabel.numberOfLines = 2;
    [viewOnMapButton addTarget:self action:@selector(viewOnMapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:viewOnMapButton];
    
    UIButton *directionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    directionsButton.frame = CGRectMake(117, yHeight, 90, 54);
    [directionsButton setTitle:@"Directions\nto Here" forState:UIControlStateNormal];
    directionsButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap; 
    directionsButton.titleLabel.numberOfLines = 2;
    directionsButton.tag = 15;
    [directionsButton addTarget:self action:@selector(viewDirectionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:directionsButton];
    
    UIButton *reverseDirectionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reverseDirectionsButton.frame = CGRectMake(214, yHeight, 90, 54);
    [reverseDirectionsButton setTitle:@"Directions\nfrom Here" forState:UIControlStateNormal];
    reverseDirectionsButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap; 
    reverseDirectionsButton.titleLabel.numberOfLines = 2;
    reverseDirectionsButton.tag = 16;
    [reverseDirectionsButton addTarget:self action:@selector(viewDirectionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:reverseDirectionsButton];
    
    self.scrollView.contentSize = CGSizeMake(320, yHeight + 240);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        
        float startLatitude = 0.0;
        float endLatitude = 0.0;
        float startLongitude = 0.0;
        float endLongitude = 0.0;
        if (tagId == 15) {
            startLatitude = [settings doubleForKey:@"lastLatitude"];
            startLongitude = [settings doubleForKey:@"lastLongitude"];
            endLatitude = [self.marker.latitude floatValue];
            endLongitude = [self.marker.longitude floatValue];
        } else {
            startLatitude = [self.marker.latitude floatValue];
            startLongitude = [self.marker.longitude floatValue];
            endLatitude = [settings doubleForKey:@"lastLatitude"];
            endLongitude = [settings doubleForKey:@"lastLongitude"];
        }
        
        NSString* url = [NSString stringWithFormat:[[appDelegate defaults] objectForKey:@"GoogleDirectionsMapAPI"],
                         startLatitude, startLongitude, endLatitude, endLongitude];
        
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

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
