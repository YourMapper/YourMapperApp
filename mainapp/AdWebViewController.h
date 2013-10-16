//
//  AdWebViewController.h
//  mainapp
//
//  Created by Eric Roland on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HudView.h"

@interface AdWebViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *_webView;
    NSString *_adUrl;
    HudView *_hudView;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *adUrl;

- (IBAction)openBrowser:(id)sender;
@end
