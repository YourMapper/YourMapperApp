//
//  DataItemDetailWebViewController.h
//  mainapp
//
//  Created by Eric Roland on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Marker.h"
#import "HudView.h"
 
@interface DataItemDetailWebViewController : UIViewController <UIWebViewDelegate> {
    NSString *_urlAddress;
    IBOutlet UIWebView *_webView;
    HudView *_hudView;
}

@property (nonatomic, retain) NSString *urlAddress;
@property (nonatomic, retain) UIWebView *webView;

- (IBAction)openBrowser:(id)sender;

@end
