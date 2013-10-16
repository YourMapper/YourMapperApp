//
//  StartEndFilterViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartEndFilterViewController : UIViewController <UITableViewDelegate> {
    IBOutlet UIDatePicker *_datePicker;
    IBOutlet UITableView *_dateTableView;
    NSDate *_startDate;
    NSDate *_endDate;
    NSInteger _selectedRow;
}

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UITableView *dateTableView;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, assign) NSInteger selectedRow;
- (IBAction)dateChanged;
- (IBAction)cancel;
- (IBAction)save;

@end
