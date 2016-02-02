//
//  SearchResultsMearMeProfilesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/27/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultsBaseProfilesController.h"

@interface SearchResultsMearMeProfilesController : SearchResultsBaseProfilesController {
	NSString *sLat;
	NSString *sLng;
}

- (id) initWithLat:(NSString*)aLatitude lng:(NSString*)aLongitude onlineOnlyFlag:(BOOL)onlineOnlyFlag withPhotosOnlyFlag:(BOOL)withPhotosOnlyFlag startFrom:(NSInteger)startFrom searchForm:(UIViewController*)searchCtrl;

@end
