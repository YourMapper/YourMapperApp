//
//  PlacesViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacesViewController : UITableViewController {
    NSArray *_userMarkers;
    UIBarButtonItem *_editButton;
    UIBarButtonItem *_doneButton;
}

@property (nonatomic, retain) NSArray *userMarkers;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

- (IBAction)doEdit:(id)sender;

@end
