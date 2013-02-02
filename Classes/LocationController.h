//
//  LocationController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/14/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import "LocationViewController.h" 

@interface LocationController : LocationViewController <CLLocationManagerDelegate> {

}

- (id)init;

@end
