//
//  ViewController.m
//  PayPalETicketingClient
//
//  Created by Peter Georgeson on 6/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize web;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [web setHidden:YES];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"htm"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [web setBackgroundColor:[UIColor clearColor]];
    [web loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL fileURLWithPath:path]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [web setHidden:NO];
}

- (void) showScanner {
    // present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
        
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    // disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                    config: ZBAR_CFG_ENABLE
                    to: 0];
        
    // present and release the controller
    [self presentModalViewController:reader animated:YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    NSLog(@"got barcode info...");
    // get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) {
        // grab the first barcode
        break;
    }

    // set code on web page
    [web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"eticketing.set_code( '%s' )", [symbol.data UTF8String]]];

    [reader dismissModalViewControllerAnimated: YES];
    [reader release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"got request: %s", [[[request URL] absoluteString] UTF8String]  );
    if ( [[[request URL] absoluteString] hasPrefix:@"native:qr"]) {
        NSLog(@"got qr command");
        [self showScanner];
        return NO;
    }
    return YES;
}

@end
