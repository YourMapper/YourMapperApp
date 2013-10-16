//
//  DataItemDetailWebViewController.m
//  mainapp
//
//  Created by Eric Roland on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataItemDetailWebViewController.h"
#import "Marker.h"
#import "HudView.h"
#import "AppDelegate.h"

@implementation DataItemDetailWebViewController
@synthesize urlAddress = _urlAddress;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_hudView stopActivityIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_hudView stopActivityIndicator];
    [AppDelegate showConnectionError];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.051 green:0.345 blue:0.6 alpha:1];
    NSURL *url = [NSURL URLWithString:self.urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_hudView startActivityIndicator:self.view];
    [self.webView loadRequest:requestObj];
}

- (void)viewDidLoad {
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

- (IBAction)openBrowser:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.urlAddress]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
