//
//  MoreViewController.h
//  mainapp
//
//  Created by Eric Roland on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MoreViewController : UITableViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>  {
    NSString *targetUrl;
    NSIndexPath *selectedIndexPath;
}

@end
