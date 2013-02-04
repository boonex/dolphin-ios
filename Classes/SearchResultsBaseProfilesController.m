//
//  ProfilesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "SearchResultsBaseProfilesController.h"
#import "Designer.h"

@implementation SearchResultsBaseProfilesController

- (id) initWithOnlineOnlyFlag:(BOOL)onlineOnlyFlag withPhotosOnlyFlag:(BOOL)withPhotosOnlyFlag startFrom:(NSInteger)startFrom searchForm:(UIViewController*)searchCtrl {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	if ((self = [super initWithNavigation:app.searchNavigationController])) {
		isOnlineOnly = onlineOnlyFlag;
		isWithPhotosOnly = withPhotosOnlyFlag;
		intStartFrom = startFrom;
		intPerPage = BX_SEARCH_RESULTS_PER_PAGE;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            intPerPage = BX_SEARCH_RESULTS_PER_PAGE_IPAD;
		searchFormViewController = [searchCtrl retain];
	}
	return self;
}

- (void)viewDidLoad {
    [Designer applyStylesClear:table];
    [Designer applyStylesForTableBackgroundClear:table];
	[Designer applyStylesForScreen:self.view];
    
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search Form", @"Search form button text") style:UIBarButtonItemStyleBordered target:self action:@selector(actionHome:)];
	self.navigationItem.leftBarButtonItem = btn;
	[btn release];
	
	
	// "Segmented" control on the right
	segmentedControl = [[UISegmentedControl alloc] initWithItems:
											 [NSArray arrayWithObjects:
											  [UIImage imageNamed:@"icon_prev.png"],
											  [UIImage imageNamed:@"icon_next.png"], 
											  nil]];
	[segmentedControl addTarget:self action:@selector(actionPrevNext:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 90, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.tintColor = [UIColor blackColor];
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
    
	[self requestData];	
}

- (void)dealloc {
	[searchFormViewController release];
    [segmentedControl release];
	[super dealloc];
}

/**********************************************************************************************************************
 DELEGATES: UIAlertView
 **********************************************************************************************************************/

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView.title isEqualToString:NSLocalizedString(@"Error", @"Error alert title")])	{
		[self actionBack:nil];
	}
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionPrevNext:(id)sender {
	UISegmentedControl* segCtl = sender;
	NSInteger buttonIndex = [segCtl selectedSegmentIndex];
	switch (buttonIndex)
	{
		case 0:
			[self actionClickPrev:sender];
			break;
		case 1:
			[self actionClickNext:sender];
			break;
	}
}

- (IBAction)actionHome:(id)sender {
	[navController popToViewController:searchFormViewController animated:YES];
}

- (IBAction)actionBack:(id)sender {
	[navController popViewControllerAnimated:YES];
}

- (void)actionClickNext:(id)idData {	
	NSLog(@"Next pressed override this function!!!");
}

- (void)actionClickPrev:(id)idData {	
	[self actionBack:idData];
}

- (void)actionRequestFillProfilesArray:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
    if([resp isKindOfClass:[NSDictionary class]] && nil != [(NSDictionary *)resp objectForKey:@"faultString"]) {        
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    }
        
	NSLog(@"profiles list (%@): %@", [resp class], resp);
	if (![resp count])
	{
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"No profiles found", @"No profiles found alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button text") otherButtonTitles:nil];
		[al show];
		[al release];		
		return;
	}
	
    if (nil != profilesList) {
        [profilesList release];
        profilesList = nil;
    }
	profilesList = [resp retain];	
	
	if (YES == [self isPrevProfilesAvail] && segmentedControl.numberOfSegments > 0) {
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	}

	if (YES == [self isNextProfilesAvail] && segmentedControl.numberOfSegments > 1) {		
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
		
	[table reloadData];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (BOOL) isNextProfilesAvail {
	if ([profilesList count] < intPerPage)
		return NO;
	return YES;
}

- (BOOL) isPrevProfilesAvail {
	if (intStartFrom > 0)
		return YES;
	return NO;
}

@end
