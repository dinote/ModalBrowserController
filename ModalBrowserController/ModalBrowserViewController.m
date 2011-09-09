//
//  ModalBrowserViewController.m
//
//  Created by Vatroslav Dino Matijas on 8/19/11.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//



#import "ModalBrowserViewController.h"

@interface ModalBrowserViewController()

- (UIImage *)backArrowImage;
- (UIImage *)forwardArrowImage;
- (void)refreshNavigationButtons;
-(void)back;
-(void)forward;
-(void)refresh;
-(void)done;
-(void)openIn;
@end


@implementation ModalBrowserViewController

-(id)initWithURL:(NSURL*)theUrl {
	return [self initWithURLRequest:[NSURLRequest requestWithURL: theUrl]];
}

-(id)initWithURLRequest:(NSURLRequest*)theRequest {
	self = [super init];
	if (self) {
		webView = [[UIWebView alloc] init];
		webView.delegate = self;
		[webView loadRequest:theRequest];	
	}
	return self;
}

- (void)dealloc {
	[activityIndicator release];
	[webView release];
	[backButtonItem release];
	[forwardButtonItem release];
	
    [super dealloc];
}



- (void)loadView {
	[super loadView];
	
	UIToolbar* toolbar = [[[UIToolbar alloc] init] autorelease];
	toolbar.barStyle = UIBarStyleBlack;	
	[toolbar sizeToFit];
	
	CGFloat toolbarHeight = [toolbar frame].size.height;
	
	CGRect rootViewBounds = self.view.bounds;
	CGFloat rootViewHeight = rootViewBounds.size.height;
	CGFloat rootViewWidth = rootViewBounds.size.width;
	CGRect toolbarFrame = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
	
	[toolbar setFrame:toolbarFrame];
	
	CGRect webViewFrame = CGRectMake(0, 0, rootViewWidth, rootViewHeight - toolbarHeight);
	
	
	webView.frame = webViewFrame;
	webView.scalesPageToFit = YES;
	
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: webView];
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
	[activityIndicator sizeToFit];
	
	
	UIBarButtonItem* spinnerItem = [[[UIBarButtonItem alloc] initWithCustomView:activityIndicator] autorelease];
	
	backButtonItem = [[UIBarButtonItem alloc] initWithImage:[self backArrowImage]
													  style:UIBarButtonItemStylePlain 
													 target:self 
													 action:@selector(back)];
	backButtonItem.enabled = NO;
	
	forwardButtonItem = [[UIBarButtonItem alloc] initWithImage:[self forwardArrowImage]
														 style:UIBarButtonItemStylePlain 
														target:self 
														action:@selector(forward)];
	forwardButtonItem.enabled = NO;
	
	
	NSArray* toolbarItems = [NSArray arrayWithObjects:
							 backButtonItem,
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:nil
																			action:nil] autorelease],
							 forwardButtonItem,
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:nil
																			action:nil] autorelease], 
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																			target:self
																			action:@selector(refresh)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:nil
																			action:nil] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			target:self
																			action:@selector(openIn)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:nil
																			action:nil] autorelease],	
							 spinnerItem,
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			target:nil
																			action:nil] autorelease],		 
							 
							 [[[UIBarButtonItem alloc] initWithTitle:@"Done" 
															   style:UIBarButtonItemStyleDone 
															  target:self 
															  action:@selector(done)] autorelease],
							 nil];
	
    [toolbar setItems: toolbarItems animated: NO];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:toolbar];
	
}


- (void)viewDidUnload {
    [super viewDidUnload];
	
	[activityIndicator release], activityIndicator = nil;
	[backButtonItem release], backButtonItem = nil;
	[forwardButtonItem release], forwardButtonItem = nil;	
}


- (void)refreshNavigationButtons {
	backButtonItem.enabled = webView.canGoBack;
	forwardButtonItem.enabled = webView.canGoForward;
}

#pragma mark -
#pragma mark Private

- (UIImage *)backArrowImage
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,32,32,8,0,colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 4.0f, 14.0f);	
	CGContextAddLineToPoint(context, 26.0f, 5.0f);
	CGContextAddLineToPoint(context, 26.0f, 23.0f);	
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
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,32,32,8,0,colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 28.0f, 14.0f);
	CGContextAddLineToPoint(context, 6.0f, 5.0f);
	CGContextAddLineToPoint(context, 6.0f, 23.0f);	
	
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return [image autorelease];
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
	[self dismissModalViewControllerAnimated:YES];
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
