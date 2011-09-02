    //
//  ModalBrowserViewController.m
//  Eventful
//
//  Created by Vatroslav Dino Matijas on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModalBrowserViewController.h"

@interface ModalBrowserViewController()

- (UIImage *)backArrowImage;
- (UIImage *)forwardArrowImage;
- (CGContextRef)createContext;
- (void)refreshNavigationButtons;
-(void)back;
-(void)forward;
-(void)refresh;
-(void)done;
-(void)openIn;
@end


@implementation ModalBrowserViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(id)initWithURL:(NSURL*)theUrl callingController:(UIViewController*) controller {
	return [self initWithURLRequest:[NSURLRequest requestWithURL: theUrl] callingController:controller];
}

-(id)initWithURLRequest:(NSURLRequest*)theRequest callingController:(UIViewController*) controller {
	self = [super init];
	if (self) {
		request = [theRequest retain];
		callingController = controller;
	}
	return self;
}

- (void)dealloc {
	[request release];
	[activityIndicator release];
	[webView release];
	[backButtonItem release];
	[forwardButtonItem release];
	[spinnerItem release];
	
    [super dealloc];
}


- (CGContextRef)createContext
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,27,27,8,0,
												 colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	return context;
}


- (UIImage *)backArrowImage
{
	CGContextRef context = [self createContext];
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 8.0f, 13.0f);
	CGContextAddLineToPoint(context, 24.0f, 4.0f);
	CGContextAddLineToPoint(context, 24.0f, 22.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return [image autorelease];
}

- (UIImage *)forwardArrowImage
{
	CGContextRef context = [self createContext];
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 24.0f, 13.0f);
	CGContextAddLineToPoint(context, 8.0f, 4.0f);
	CGContextAddLineToPoint(context, 8.0f, 22.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return [image autorelease];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleBlack;
	
    //Set the toolbar to fit the width of the app.
    [toolbar sizeToFit];
	
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [toolbar frame].size.height;
	
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.view.bounds;
	
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
	
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
	
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
	
	CGRect webViewFrame = CGRectMake(0, 0, self.view.frame.size.width, rootViewHeight - toolbarHeight);
	
	webView = [[UIWebView alloc] initWithFrame: webViewFrame];
	webView.delegate = self;
	
	
	[self.view addSubview: webView];
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
	[activityIndicator sizeToFit];
	

	spinnerItem = [[[UIBarButtonItem alloc] initWithCustomView:activityIndicator] retain];
		
	backButtonItem =
	[[[UIBarButtonItem alloc] initWithImage:[self backArrowImage]
									 style:UIBarButtonItemStylePlain 
									target:self 
									action:@selector(back)] retain];
	
	forwardButtonItem =
	[[[UIBarButtonItem alloc] initWithImage:[self forwardArrowImage]
									 style:UIBarButtonItemStylePlain 
									target:self 
									action:@selector(forward)] retain];
	
	backButtonItem.enabled = NO;
	forwardButtonItem.enabled = NO;
	
		
	NSArray* toolbarItems = [NSArray arrayWithObjects:
							 backButtonItem,
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		   target:nil
																		   action:nil],
							forwardButtonItem,
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		   target:nil
																		   action:nil],							 
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																		   target:self
																		   action:@selector(refresh)],
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		   target:nil
																		   action:nil],							 
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																		   target:self
																		   action:@selector(openIn)],
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		   target:nil
																		   action:nil],	
																			spinnerItem,
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		   target:nil
																		   action:nil],							 							 
							 
							 [[UIBarButtonItem alloc] initWithTitle:@"Done" 
															  style:UIBarButtonItemStyleDone 
															 target:self 
															 action:@selector(done)],
							 nil];
    [toolbarItems makeObjectsPerformSelector:@selector(release)];
    [toolbar setItems: toolbarItems animated: NO];
	[self.view addSubview:toolbar];
	[toolbar release];
	
	
	
	//Load the request in the UIWebView.
	[webView loadRequest:request];
	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)refreshNavigationButtons {
	backButtonItem.enabled = webView.canGoBack;
	forwardButtonItem.enabled = webView.canGoForward;
}

-(void)back {
	[webView goBack];
}

-(void)forward { 
	[webView goForward];
}

-(void)refresh { 
	[webView reload];
}

-(void)done {
	[callingController dismissModalViewControllerAnimated:YES];
}

-(void)openIn {
	UIActionSheet* openInActionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
																	delegate:self 
														   cancelButtonTitle:@"Cancel" 
													  destructiveButtonTitle:nil 
														   otherButtonTitles:@"Open in safari",nil] autorelease];
	[openInActionSheet showInView:self.view];
}

#pragma mark -
#pragma mark UIWebViewDelegate


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[activityIndicator stopAnimating];
	[self refreshNavigationButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicator stopAnimating];
	[self refreshNavigationButtons];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityIndicator startAnimating];
	[self refreshNavigationButtons];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0: //Open in safari
			[[UIApplication sharedApplication] openURL:[webView.request URL]];
			[self done];
			break;
	}
}


@end
