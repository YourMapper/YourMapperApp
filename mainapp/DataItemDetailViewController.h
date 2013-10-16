//
//  DataItemDetailView.h
//  mainapp
//
//  Created by Eric Roland on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Marker.h"
#import "User.h"
#import "HudView.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface DataItemDetailViewController : UIViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    Marker *_marker;
    NSString *_adUrl;
    IBOutlet UIScrollView *scrollView;
    HudView *_hudView;
    int tagId;
    UIImageView *categoryImage;
    UIImageView *markerImageView;
}

@property (nonatomic, retain) Marker *marker;
@property (nonatomic, retain) NSString *adUrl;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)save:(id)sender;
- (void)moreDetailsButtonPressed:(id)sender;
- (void)emailThisPlaceButtonPressed:(id)sender;
- (void)viewOnMapButtonPressed:(id)sender;
- (void)viewDirectionsButtonPressed:(id)sender;
- (void)fetchedImage:(NSData *)responseData;

@end
