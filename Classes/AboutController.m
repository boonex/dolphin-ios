//
//  AboutController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/12/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "AboutController.h"
#import "Dolphin6AppDelegate.h"
#import "TesterController.h"
#import "Designer.h"

@implementation AboutController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

	}
	return self;
}

- (void)viewDidLoad {
	
#ifdef DEBUG
	// right nav item
	UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Test", @"Test button title") style:UIBarButtonItemStyleBordered target:self action:@selector(actionTest:)];
	self.navigationItem.rightBarButtonItem = testButton;
	[testButton release];	
#endif
		    
    NSString *sAboutText = [NSString stringWithFormat:NSLocalizedString(@"About Text", @"About text in HTML format"), BX_VER];
	[webAbout loadHTMLString:sAboutText baseURL:nil];
    webAbout.opaque = NO;
    webAbout.backgroundColor = [UIColor clearColor];
    
    [Designer applyStylesForContainer:webAbout];
    [Designer applyStylesForScreen:self.view];
}

- (void)dealloc {
	[webAbout release];
	[super dealloc];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (IBAction)actionTest:(id)sender {
	TesterController * cntrl = [[TesterController alloc] init];
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	[app.navigationController pushViewController:cntrl animated:YES];
	[cntrl release];
}


/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - Delegates

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType; {
    NSURL *requestURL = [[request URL] retain]; 
    if (([[requestURL scheme] isEqualToString:@"http"] || [[requestURL scheme] isEqualToString:@"https"] || [[requestURL scheme] isEqualToString:@"mailto"]) 
        && (navigationType == UIWebViewNavigationTypeLinkClicked)) { 
        return ![[UIApplication sharedApplication] openURL:[requestURL autorelease]]; 
    } 
    [requestURL release];
    return YES; 
}

@end
