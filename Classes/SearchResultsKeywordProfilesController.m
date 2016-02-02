//
//  ProfilesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "SearchResultsKeywordProfilesController.h"

@implementation SearchResultsKeywordProfilesController

- (id) initWithKeyword:(NSString*)aKeyword onlineOnlyFlag:(BOOL)onlineOnlyFlag withPhotosOnlyFlag:(BOOL)withPhotosOnlyFlag startFrom:(NSInteger)startFrom searchForm:(UIViewController*)searchCtrl {
	if ((self = [super initWithOnlineOnlyFlag:onlineOnlyFlag withPhotosOnlyFlag:withPhotosOnlyFlag startFrom:startFrom searchForm:searchCtrl])) {
		strKeyword = [aKeyword copy];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Search Results", @"Search results view title");
}


- (void)dealloc {
	[strKeyword release];
	[super dealloc];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionClickNext:(id)idData {	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = nil;
	ctrl = [[SearchResultsKeywordProfilesController alloc] initWithKeyword:strKeyword onlineOnlyFlag:isOnlineOnly withPhotosOnlyFlag:isWithPhotosOnly startFrom:intStartFrom+intPerPage searchForm:searchFormViewController];
	[app.searchNavigationController pushViewController:ctrl animated:YES];			
	[ctrl release];	
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void) requestData {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], strKeyword, isOnlineOnly ? @"1" : @"", isWithPhotosOnly ? @"1" : @"", [NSString stringWithFormat:@"%d", intStartFrom], [NSString stringWithFormat:@"%d", intPerPage], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.getSearchResultsKeyword" withParams:myArray withSelector:@selector(actionRequestFillProfilesArray:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

@end