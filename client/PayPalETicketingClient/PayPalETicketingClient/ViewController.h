//
//  ViewController.h
//  PayPalETicketingClient
//
//  Created by Peter Georgeson on 6/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZBarSDK.h"

@interface ViewController : UIViewController<UIWebViewDelegate, ZBarReaderDelegate> {
    UIWebView *web;
}

@property (retain) IBOutlet UIWebView *web;

- (void) showScanner;

@end
