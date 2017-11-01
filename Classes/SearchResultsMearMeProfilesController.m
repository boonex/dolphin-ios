//
//  SearchResultsMearMeProfilesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/27/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import "SearchResultsMearMeProfilesController.h"

@implementation SearchResultsMearMeProfilesController

- (id) initWithLat:(NSString*)aLatitude lng:(NSString*)aLongitude onlineOnlyFlag:(BOOL)onlineOnlyFlag withPhotosOnlyFlag:(BOOL)withPhotosOnlyFlag startFrom:(NSInteger)startFrom searchForm:(UIViewController*)searchCtrl {
	if ((self = [super initWithOnlineOnlyFlag:onlineOnlyFlag withPhotosOnlyFlag:withPhotosOnlyFlag startFrom:startFrom searchForm:searchCtrl])) {
		sLat = [aLatitude copy];
		sLng = [aLongitude copy];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Search Results", @"Search results view title");
}


- (void)dealloc {
	[sLat release];
	[sLng release];
	[super dealloc];
}


/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionClickNext:(id)idData {	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = nil;
	ctrl = [[SearchResultsMearMeProfilesController alloc] initWithLat:sLat lng:sLng onlineOnlyFlag:isOnlineOnly withPhotosOnlyFlag:isWithPhotosOnly startFrom:intStartFrom+intPerPage searchForm:searchFormViewController];
	[app.searchNavigationController pushViewController:ctrl animated:YES];			
	[ctrl release];	
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void) requestData {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], sLat, sLng, isOnlineOnly ? @"1" : @"", isWithPhotosOnly ? @"1" : @"", [NSString stringWithFormat:@"%d", (int)intStartFrom], [NSString stringWithFormat:@"%d", (int)intPerPage], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.getSearchResultsNearMe" withParams:myArray withSelector:@selector(actionRequestFillProfilesArray:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

@end
