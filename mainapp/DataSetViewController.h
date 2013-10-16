//
//  DataSetViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h> 
#import "AppDelegate.h"
#import "HudView.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 

@interface DataSetViewController : UITableViewController <UIActionSheetDelegate> {
    CLLocationCoordinate2D coordiante;
    NSArray *_items;
    NSArray *_content;
    NSArray *_indices;
    NSMutableArray *_externalIds;
    HudView *_hudView;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordiante;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSArray *content;
@property (nonatomic, retain) NSArray *indices;
@property (nonatomic, retain) NSMutableArray *externalIds;

- (IBAction)showActionSheet:(id)sender;
- (void)getItems;
- (void)loadItems;
- (NSArray*)groupedContent;
- (NSMutableArray *)addRow:(NSMutableArray *)content:(NSMutableDictionary *)row:(NSMutableArray *)groupedItems:(NSString *)headerTitle;
- (NSMutableArray *)viewCountContent;
- (NSMutableArray *)nameContent;
- (NSMutableArray *)daysUpdatedContent;
- (NSMutableArray *)ratingsContent;
- (NSMutableArray *)coverageContent;
- (NSMutableArray *)typeContent;

@end
