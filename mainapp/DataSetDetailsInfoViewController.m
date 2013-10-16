//
//  DataSetDetailsInfoViewController.m
//  mainapp
//
//  Created by Eric Roland on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataSetDetailsInfoViewController.h"
#import "NSString+HTML.h"
#import "AppDelegate.h"
#import "Dataset.h"
#import "ModelHelper.h"
#import "HudView.h"
#define appDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

@implementation DataSetDetailsInfoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    name.text = @"";
    description.text = @"";
    center.text = @"";
    coverage.text = @"";
    //userName.text = @"";
    update.text = @"";
    last.text = @"";
    created.text = @"";
    viewCount.text = @"";
    ratings.text =  @"";
    category.text = @"";
    [self getItems];
    [self getCategoryItems];
}

- (void)getItems {
    [_hudView startActivityIndicator:self.view];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *dataSetId = [settings stringForKey:@"dataSetId"];
    NSMutableString *url = [[[appDelegate defaults] objectForKey:@"DataSetInfoUrl"] mutableCopy];
    NSMutableString *yourMapperAPIKey = [[[appDelegate defaults] objectForKey:@"YourMapperAPIKey"] mutableCopy];

    [url replaceOccurrencesOfString:@"KEY" withString:[[NSString alloc] initWithFormat:@"%@", yourMapperAPIKey] 
                            options:NSLiteralSearch range:(NSRange){0,[url length]}];
    
    [url replaceOccurrencesOfString:@"ID" withString:[[NSString alloc] initWithFormat:@"%@", dataSetId] 
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

- (void)fetchedData:(NSData *)responseData {
    [_hudView stopActivityIndicator];
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:json];
    if (isValid) {    
        name.text = [json objectForKey:@"Name"];
        name.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        UIFont *standarFont = [UIFont fontWithName:@"ArialMT" size:14];
        description.text = [NSMutableString stringWithString:[[json objectForKey:@"Description"] stringByConvertingHTMLToPlainText]];
        description.font = [UIFont fontWithName:@"ArialMT" size:12];
        center.text = [NSString stringWithFormat:@"Center: %@, %@", [json objectForKey:@"StartCity"], [json objectForKey:@"StartState"]];
        center.font = standarFont;
        coverage.text = [NSString stringWithFormat:@"Coverage Area: %@", [json objectForKey:@"Coverage"]];
        coverage.font = standarFont;
        //userName.text = [NSString stringWithFormat:@"Mapper Username: %@", [json objectForKey:@"MapperName"]];
        update.text = [NSString stringWithFormat:@"Update Frequency: %@", [json objectForKey:@"UpdateFrequency"]];
        update.font = standarFont;
        last.text = [NSString stringWithFormat:@"Last Update: %@", [json objectForKey:@"UpdatedDate"]];
        last.font = standarFont;
        created.text = [NSString stringWithFormat:@"Created Date: %@", [json objectForKey:@"CreatedDate"]];
        created.font = standarFont;
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSString *dataSetId = [settings stringForKey:@"dataSetId"];
        Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:dataSetId];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setGroupingSize:3];
        [formatter setGroupingSeparator:@","];
        [formatter setUsesGroupingSeparator:YES];
        
        viewCount.text = [NSString stringWithFormat:@"View Count: %@", [formatter stringFromNumber:dataSet.viewCount]];
        viewCount.font = standarFont;
        ratings.text =  [NSString stringWithFormat:@"Rating: %@/5 (%@ ratings)", dataSet.ratingScore, [json objectForKey:@"RatingCount"]];
        ratings.font = standarFont;
        category.text = @"Categories";
        category.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
    } else {
        [AppDelegate showConnectionError];
    }
}

- (void)getCategoryItems {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *dataSetId = [settings stringForKey:@"dataSetId"];
    NSMutableString *url = [[[appDelegate defaults] objectForKey:@"DataSetCategoriesUrl"] mutableCopy];
    NSMutableString *yourMapperAPIKey = [[[appDelegate defaults] objectForKey:@"YourMapperAPIKey"] mutableCopy];
    
    [url replaceOccurrencesOfString:@"KEY" withString:[[NSString alloc] initWithFormat:@"%@", yourMapperAPIKey] 
                            options:NSLiteralSearch range:(NSRange){0,[url length]}];
    
    [url replaceOccurrencesOfString:@"ID" withString:[[NSString alloc] initWithFormat:@"%@", dataSetId] 
                            options:NSLiteralSearch range:(NSRange){0,[url length]}];
    
    NSURL *finalUrl = [NSURL URLWithString:[NSString stringWithString:url]];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:finalUrl];
        if (data == nil) {
			[_hudView stopActivityIndicator];
			[AppDelegate showConnectionError];
		} else {
            [self performSelectorOnMainThread:@selector(fetchedCategoryData:) 
                                   withObject:data waitUntilDone:YES];
        }
    });     
}

- (void)fetchedCategoryData:(NSData *)responseData {
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    BOOL isValid = [NSJSONSerialization isValidJSONObject:json];
    if (isValid) {
        int yHeight = 0;
        float centerX = ((self.view.frame.size.width - 28) / 2) - 25;
        NSArray *items = [json objectForKey:@"items"];
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSString *dataSetId = [settings stringForKey:@"dataSetId"];
        Dataset *dataSet = [ModelHelper getAndSaveDatasetByExternalId:dataSetId];
        for (NSDictionary *item in items) {
            NSURL *url = [NSURL URLWithString:[item objectForKey:@"icon"]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            UIImageView *markerImageView = [[UIImageView alloc] initWithImage:image];
            if ([dataSet.markerType intValue] == 1) {
                markerImageView.frame = CGRectMake(centerX - 28, yHeight + 3, 13, 20);
            } else {
                markerImageView.frame = CGRectMake(centerX - 28, yHeight + 3, 13, 13);
            }
            [markerLegend addSubview:markerImageView];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(centerX, yHeight, 180, 20)];
            nameLabel.textAlignment = UITextAlignmentLeft;
            nameLabel.text =  [item objectForKey:@"name"];
            nameLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
            [markerLegend addSubview:nameLabel];
            yHeight += 28;
        }
        [markerLegend setContentSize:CGSizeMake(320, yHeight + 20)];
    } else {
        [AppDelegate showConnectionError];
    }
}   

- (IBAction)done
{
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    _hudView = [[HudView alloc] init];
    [_hudView loadActivityIndicator]; 
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.title = @"Dataset Details";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(done)];
    self.navigationItem.leftBarButtonItem = doneButton;
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
