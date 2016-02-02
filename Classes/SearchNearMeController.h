//
//  SearchNearMeController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/27/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import "SearchBaseFormController.h"

@interface SearchNearMeController : SearchBaseFormController <CLLocationManagerDelegate> {
	NSString *sLat;
	NSString *sLng;
}

- (id)init;

@end
