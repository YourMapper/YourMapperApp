//
//  DataSetDetailsInfoViewController.h
//  mainapp
//
//  Created by Eric Roland on 1/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HudView.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface DataSetDetailsInfoViewController : UIViewController {
    HudView *_hudView;
    IBOutlet UILabel *name;
    IBOutlet UILabel *description;
    IBOutlet UILabel *center;
    IBOutlet UILabel *coverage;
    IBOutlet UILabel *userName;
    IBOutlet UILabel *update;
    IBOutlet UILabel *last;
    IBOutlet UILabel *created;
    IBOutlet UILabel *viewCount;
    IBOutlet UILabel *ratings;
    IBOutlet UILabel *category;
    IBOutlet UIScrollView *markerLegend;
}

- (IBAction)done;
- (void)getItems;
- (void)fetchedData:(NSData *)responseData;
- (void)getCategoryItems;
- (void)fetchedCategoryData:(NSData *)responseData;

@end
