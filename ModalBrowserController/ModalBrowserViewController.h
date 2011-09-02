//
//  ModalBrowserViewController.h
//  Eventful
//
//  Created by Vatroslav Dino Matijas on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModalBrowserViewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate> {
	UIWebView*					webView;
	UIBarButtonItem*			backButtonItem;
	UIBarButtonItem*			forwardButtonItem;
	UIBarButtonItem*			spinnerItem;
	UIActivityIndicatorView*	activityIndicator;
	
	UIViewController*			callingController;
	NSURLRequest*				request;
}


-(id)initWithURL:(NSURL*)url callingController:(UIViewController*) controller;
-(id)initWithURLRequest:(NSURLRequest*)theRequest callingController:(UIViewController*) controller;
@end
