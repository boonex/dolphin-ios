//
//  ProfilesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilesController.h"

@interface SearchResultsBaseProfilesController : ProfilesController {
	BOOL isOnlineOnly;
	BOOL isWithPhotosOnly;
	NSInteger intStartFrom;
	NSInteger intPerPage;
	NSInteger intStart;
	UIViewController *searchFormViewController;
	UISegmentedControl *segmentedControl;
}

- (id) initWithOnlineOnlyFlag:(BOOL)onlineOnlyFlag withPhotosOnlyFlag:(BOOL)withPhotosOnlyFlag startFrom:(NSInteger)startFrom searchForm:(UIViewController*)searchCtrl;

- (void)actionClickNext:(id)idData;
- (void)actionClickPrev:(id)idData;

- (BOOL) isPrevProfilesAvail;
- (BOOL) isNextProfilesAvail;

@end
