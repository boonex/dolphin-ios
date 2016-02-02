//
//  ProfilesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultsBaseProfilesController.h"

@interface SearchResultsLocationProfilesController : SearchResultsBaseProfilesController {
	NSString *strCountryCode;
	NSString *strCity;
}

- (id) initWithCountryCode:(NSString*)aCountryCode city:(NSString*)aCity onlineOnlyFlag:(BOOL)onlineOnlyFlag withPhotosOnlyFlag:(BOOL)withPhotosOnlyFlag startFrom:(NSInteger)startFrom searchForm:(UIViewController*)searchCtrl;

@end
