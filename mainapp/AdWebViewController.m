//
//  AdWebViewController.m
//  mainapp
//
//  Created by Eric Roland on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdWebViewController.h"
#import "AppDelegate.h"
#import "HudView.h"

@interface AdWebViewController ()

@end

@implementation AdWebViewController
@synthesize webView = _webView;
@synthesize adUrl = _adUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_hudView stopActivityIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_hudView stopActivityIndicator];
    [AppDelegate showConnectionError];
}

- (IBAction)openBrowser:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.adUrl]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.adUrl = [settings valueForKey:@"AdUrl"];
    NSURL *url = [NSURL URLWithString:self.adUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_hudView startActivityIndicator:self.view];
    [self.webView loadRequest:requestObj];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView setDelegate: self];
    _hudView = [[HudView alloc] init];
    [_hudView loadActivityIndicator];
    UIBarButtonItem *browserButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Browser"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(openBrowser:)];
    self.navigationItem.rightBarButtonItem = browserButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
