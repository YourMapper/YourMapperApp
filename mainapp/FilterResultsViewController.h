//
//  FilterResultsViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Dataset.h"
#import "HudView.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 

@interface FilterResultsViewController : UITableViewController <UITextFieldDelegate> {
    NSMutableArray *_filterItems;
    NSMutableArray *_savedCategoryItems;
    NSMutableString *_savedCurrentCategoryIds;
    UITextField *_searchText;
    HudView *_hudView;
    BOOL _hasDateFilter;
    Dataset *_dataSet;
}

@property (nonatomic, retain) NSMutableArray *filterItems;
@property (nonatomic, retain) NSMutableArray *savedCategoryItems;
@property (nonatomic, retain) NSMutableString *savedCurrentCategoryIds;
@property (nonatomic, retain) UITextField *searchText;
@property (nonatomic) BOOL hasDateFilter;
@property (nonatomic, retain) Dataset *dataSet;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
