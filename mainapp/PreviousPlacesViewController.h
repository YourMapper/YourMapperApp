//
//  PreviousPlacesViewController.h
//  mainapp
//
//  Created by Eric Roland on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviousPlacesViewController : UITableViewController {
    NSArray *_userLocations;
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_doneButton;
}

@property (nonatomic, retain) NSArray *userLocations;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

- (IBAction)doEdit:(id)sender;

@end
