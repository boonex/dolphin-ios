//
//  SearchLocationController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/11/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "SearchBaseFormController.h"
#import "Designer.h"
#import "HomeController.h"

@implementation SearchBaseFormController

- (id)initWithNibNameOnly:(NSString*)aNibName {
	if ((self = [super initWithNibName:aNibName bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {

	}
	return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	UIBarButtonItem *btn;
	
	btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back button text") style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
	self.navigationItem.leftBarButtonItem = btn;
	[btn release];	

	btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search", @"Search button text") style:UIBarButtonItemStyleDone target:self action:@selector(actionSearch:)];
	self.navigationItem.rightBarButtonItem = btn;
	[btn release];	
	
    Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
    NSArray *viewControllers = [app.homeNavigationController viewControllers];
    HomeController *ctrlHome = (HomeController *)[viewControllers objectAtIndex:0];
    if (ctrlHome != nil && !ctrlHome.isSearchWithPhotos) {
        labelWithPhotosOnly.hidden = YES;
        switchWithPhotosOnly.hidden = YES;
        
        CGRect r = viewContainer.frame;
        viewContainer.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height - CGRectGetHeight(switchWithPhotosOnly.frame));
    }
        
    
	labelOnlineOnly.text = NSLocalizedString(@"Online Only", @"online Only field caption");
	labelWithPhotosOnly.text = NSLocalizedString(@"With Photos Only", @"With Photos Only field caption");
	
	[Designer applyStylesForLabel:labelOnlineOnly];
	[Designer applyStylesForLabel:labelWithPhotosOnly];
	
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];
}

- (void)dealloc {
	
	[labelOnlineOnly release];
	[labelWithPhotosOnly release];
	
	[switchOnlineOnly release];
	[switchWithPhotosOnly release];
	
	[viewContainer release];
	
	[super dealloc];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * go back
 */
- (IBAction)actionBack:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	[app.searchNavigationController popViewControllerAnimated:YES];
}

/**
 * do search
 */
- (IBAction)actionSearch:(id)sender {	
	NSLog(@"Override this!!!!!!!!!!!!!!!");
}

/**********************************************************************************************************************
 DELEGATES: UITextField
 **********************************************************************************************************************/

#pragma mark - UITextField Delegates

/**
 * when user press return button jump to next field or hide keyboard in login form 
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

@end
