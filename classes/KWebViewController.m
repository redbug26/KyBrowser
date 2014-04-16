//
//  KWebViewController.m
//  kymark
//
//  Created by Miguel Vanhove on 15/05/13.
//  Copyright (c) 2013 Less Code Limited. All rights reserved.
//

#import "KWebViewController.h"

@implementation NSString (XQueryComponents)

- (NSString *)stringByDecodingURLFormat {
	NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
	result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return result;
}

- (instancetype)stringByEncodingURLFormat {
	static NSString *unsafe = @" <>#%'\";?:@&=+$/,{}|\\^~[]`-*!()";
	CFStringRef resultRef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
	                                                                (__bridge CFStringRef)self,
	                                                                NULL,
	                                                                (__bridge CFStringRef)unsafe,
	                                                                kCFStringEncodingUTF8);
	return (__bridge_transfer NSString *)resultRef;
}

@end

@interface KWebViewController ()

@end

@implementation KWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// - (void)checkNavigationStatus;

- (id)initWithRequest:(NSURLRequest *)request {
	if (self = [super init]) {
		_request = request;
		self.hidesBottomBarWhenPushed = YES;

		// Create toolbar (to make sure that we can access it at any time)
		_toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Load content of web view
	[_webView loadRequest:_request];

	//_webView.scrollView.bounces = NO; // (old) dot notation
	_webView.scrollView.scrollEnabled = false;

	// Create action button. This shows a selection of available actions in context of the displayed page
	_actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
	                                                              target:self
	                                                              action:@selector(showAvailableActions)];

	[_actionButton setEnabled:[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"x-kypass://"]]];


	// Create reload button to reload the current page
	_reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
	                                                              target:self
	                                                              action:@selector(reload)];

	// Create loading button that is displayed if the web view is loading anything
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[activityView startAnimating];
	_loadingButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];

	// Shows the next page, is disabled by default. Web view checks if it can go forward and disables the button if neccessary
	_forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PWWebViewControllerArrowRight.png"] style:UIBarButtonItemStylePlain
	                                                 target:self
	                                                 action:@selector(goForward)];
	_forwardButton.enabled = NO;

	// Shows the last page, is disabled by default. Web view checks if it can go back and disables the button if neccessary
	_backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PWWebViewControllerArrowLeft.png"] style:UIBarButtonItemStylePlain
	                                              target:self
	                                              action:@selector(goBack)];
	_backButton.enabled = NO;


	_autoFill = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"autofill.png"] style:UIBarButtonItemStylePlain
	                                            target:self
	                                            action:@selector(autoFill)];
	_autoFill.enabled = NO;


	// Flexible space
	_flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

	// Assign buttons to toolbar
	_toolbar.items = [NSArray arrayWithObjects:_actionButton, _flexibleSpace, _backButton, _flexibleSpace, _autoFill, _flexibleSpace, _forwardButton, _flexibleSpace, _reloadButton, nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
	        interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	        interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidUnload {
	// Save last request
	_request = _webView.request;

	_webView = nil;

	_actionButton = nil;

	_reloadButton = nil;

	_loadingButton = nil;

	_forwardButton = nil;

	_backButton = nil;

	_flexibleSpace = nil;
}

#pragma mark -
#pragma mark Accessors

- (UIWebView *)webView {
	return _webView;
}

- (UIToolbar *)toolbar {
	return _toolbar;
}

#pragma mark -
#pragma mark Button actions

- (void)showAvailableActions {
	// Create action sheet without any buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[self.webView.request.URL absoluteString]
	                                                         delegate:self
	                                                cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

	// Add buttons
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Search password in KyPass", nil)];

	// Add cancel button and mark is as cancel button
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;

	// Assign tag, show it from toolbar and release it
	actionSheet.tag = kPWWebViewControllerActionSheetTag;
	[actionSheet showFromToolbar:_toolbar];
}

- (void)reload {
	[self.webView reload];
}

- (void)goBack {
	if (self.webView.canGoBack == YES) {
		// We can go back. So make the web view load the previous page.
		[self.webView goBack];

		// Check the status of the forward/back buttons
		[self checkNavigationStatus];
	}
}

- (void)goForward {
	if (self.webView.canGoForward == YES) {
		// We can go forward. So make the web view load the next page.
		[self.webView goForward];

		// Check the status of the forward/back buttons
		[self checkNavigationStatus];
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	// Change toolbar items
	_toolbar.items = [NSArray arrayWithObjects:_actionButton, _flexibleSpace, _backButton, _flexibleSpace, _forwardButton, _flexibleSpace, _loadingButton, nil];

	// Set title
	self.title = NSLocalizedString(@"Loading...", nil);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// Change toolbar items
	_toolbar.items = [NSArray arrayWithObjects:_actionButton, _flexibleSpace, _backButton, _flexibleSpace, _forwardButton, _flexibleSpace, _reloadButton, nil];

	// Set title
	NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	self.title = title;

	// Check if forward/back buttons are available
	[self checkNavigationStatus];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// Change toolbar items
	_toolbar.items = [NSArray arrayWithObjects:_actionButton, _flexibleSpace, _backButton, _flexibleSpace, _forwardButton, _flexibleSpace, _reloadButton, nil];

	// Check if forward/back buttons are available
	[self checkNavigationStatus];

	// Set title
	self.title = NSLocalizedString(@"Page not found", nil);

	// Display an alert view that tells the userr what went wrong.
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection did fail", nil)
	                                                    message:[error localizedDescription]
	                                                   delegate:nil
	                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
	                                          otherButtonTitles:nil];
	[alertView show];
}

- (BOOL)handleOpenURL:(NSURL *)url {
	NSLog(@"url: %@", url);

	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *param in[[url query] componentsSeparatedByString:@"&"]) {
		NSArray *elts = [param componentsSeparatedByString:@"="];
		if ([elts count] < 2) continue;

		NSString *key = [[elts objectAtIndex:0] stringByDecodingURLFormat];
		NSString *value = [[elts objectAtIndex:1] stringByDecodingURLFormat];

		[params setObject:value forKey:key];
	}

	username = [params objectForKey:@"username"];
	password = [params objectForKey:@"password"];

	_autoFill.enabled = YES;

	return YES;
}

- (void)autoFill {
	NSString *jScriptString = [NSString stringWithFormat:@"var forms = document.getElementsByTagName(\"form\"); \
                                   for (var i=0; i<forms.length; i++) { \
                                   var inputs = forms[i].getElementsByTagName(\"input\"); \
                                   var username=0,password=0; \
                                   for (var j=0; j<inputs.length; j++) { \
                                   if ((inputs[j].type==\"text\") || (inputs[j].type==\"email\")) username++; \
                                   if (inputs[j].type==\"password\") password++; \
                                   } \
                                   if ((username>=1) & (password==1)) { \
                                   for (var j=0; j<inputs.length; j++) { \
                                   if ((inputs[j].type==\"text\") || (inputs[j].type==\"email\")) inputs[j].value='%@'; \
                                   if (inputs[j].type==\"password\") inputs[j].value='%@'; \
                                   if (inputs[j].name==\"submit\") inputs[j].name='btn_submit';  \
                                   } \
                                   forms[i].submit(); \
                                   } \
                                   }", username, password];


	[self.webView stringByEvaluatingJavaScriptFromString:jScriptString];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == kPWWebViewControllerActionSheetTag && buttonIndex != actionSheet.cancelButtonIndex) {
		// It is one of your action sheets and it was not canceled
		if (buttonIndex == kPWWebViewControllerActionSheetSafariIndex) {
			// Search URL in KyPass

			NSURL *requestURL = self.webView.request.URL;
			NSString *successURL = @"kybrowser://success/usepassword";
			NSString *errorURL = @"kybrowser://failure";

			NSString *kyPassURL;

			kyPassURL = [NSString stringWithFormat:@"x-kypass://x-callback-url/search?x-success=%@&x-error=%@&url=%@", successURL, errorURL, [requestURL host]];

			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kyPassURL]];
		}
	}
}

#pragma mark -
#pragma mark Private methods

- (void)checkNavigationStatus {
	// Check if we can go forward or back
	_backButton.enabled = self.webView.canGoBack;
	_forwardButton.enabled = self.webView.canGoForward;
}

@end
