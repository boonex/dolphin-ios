//
//  BaseUserController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "BaseUserController.h"
#import "WebPageController.h"
#import "User.h"
#import "Designer.h"

@implementation BaseUserController

@synthesize user, rightButtonSave, isProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUser:(BxUser*)anUser {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		user = [anUser retain];
		rightButtonSave = nil;
        isProgress = NO;
	}
	return self;
}

- (void)addProgressIndicator
{
    if (NO != isProgress)
        return;
	
	UIActivityIndicatorView *aivSmall = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	UIBarButtonItem *activityButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aivSmall];
	[aivSmall startAnimating]; 
	[aivSmall release];
    
    if (rightButtonSave != nil) {
        [rightButtonSave release];
        rightButtonSave = nil;
    }
    
	rightButtonSave = [self.navigationItem.rightBarButtonItem retain];
	self.navigationItem.rightBarButtonItem = activityButtonItem;
	[activityButtonItem release];
    
    isProgress = YES;
}

- (void)removeProgressIndicator
{	
    if (YES != isProgress)
        return;        
    
	// wait in case the other thread did not complete its work.
	while (self.navigationItem.rightBarButtonItem == rightButtonSave)
	{
		[[NSRunLoop currentRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:0.1]];
	}
	
	self.navigationItem.rightBarButtonItem = rightButtonSave;
	
	[rightButtonSave release];
	rightButtonSave = nil;
    
    isProgress = NO;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    UITabBarController *tabController = [Dolphin6AppDelegate getApp].tabController;
    [Designer applyStylesForTabbar:[tabController tabBar] orientation:interfaceOrientation];
}

- (void)dealloc {
	[user release];
	[rightButtonSave release];
	[super dealloc];
}

- (void)displayDoneButton:(BOOL)isEditBegin textField:(UIView*)aTextField {	
	if (nil != rightButtonSave && isEditBegin) return;
	if (nil == rightButtonSave && !isEditBegin) return;
	if (isEditBegin == isEditingMode) return;
	
	if (isEditBegin)
	{
		UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done button title") style:UIBarButtonItemStyleDone target:self action:@selector(actionDone:)];
        
        if (rightButtonSave != nil) {
            [rightButtonSave release];
            rightButtonSave = nil;
        }

		rightButtonSave = [self.navigationItem.rightBarButtonItem retain];
		self.navigationItem.rightBarButtonItem = btn;
		[btn release];			
	}
	else
	{
		self.navigationItem.rightBarButtonItem = rightButtonSave;
		[rightButtonSave release];
		rightButtonSave = nil;
		[aTextField resignFirstResponder];
	}
	
	isEditingMode = isEditBegin;
}

- (IBAction)actionDone:(id)sender {
    // must be overriden
}

- (void)openPageUrl:(NSString*)sUrl title:(NSString*)aTitle nav:(UINavigationController*)aNav openInNewWindow:(BOOL)isOpenInNewWindow {
    if (isOpenInNewWindow) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrl]];
    } else {
        NSLog(@"openPageUrl: %@ (%@)", sUrl, aTitle);
        WebPageController *ctrl = [[WebPageController alloc] initWithUrl:sUrl title:aTitle user:self.user nav:aNav];
        [aNav pushViewController:ctrl animated:YES];
        [ctrl release];
    }
}


@end
