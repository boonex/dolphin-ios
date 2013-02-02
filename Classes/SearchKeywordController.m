//
//  SearchLocationController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/11/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "SearchKeywordController.h"
#import "SearchResultsKeywordProfilesController.h"
#import "Designer.h"

@implementation SearchKeywordController

- (id)init {
	if ((self = [super initWithNibNameOnly:@"SearchKeywordView"])) {

	}
	return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Keyword Search", @"keyword search form view title");
	
	[Designer applyStylesForTextEdit:textKeyword];
	
	textKeyword.placeholder = NSLocalizedString(@"Keyword", @"Keyword field caption");	
}

- (void)dealloc {
	[textKeyword release];
	[super dealloc];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * do search
 */
- (IBAction)actionSearch:(id)sender {	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = nil;
	ctrl = [[SearchResultsKeywordProfilesController alloc] initWithKeyword:textKeyword.text onlineOnlyFlag:switchOnlineOnly.on withPhotosOnlyFlag:switchWithPhotosOnly.on startFrom:0 searchForm:self];
	[app.searchNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];
}

@end
