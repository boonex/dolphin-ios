//
//  LocationViewController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/14/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MKAnnotation.h>
#import "BaseUserController.h" 

@interface LocationAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithLat:(double)lat lng:(double)lng;

@end

@interface LocationViewController : BaseUserController {
	IBOutlet MKMapView *mapView;
	IBOutlet UISegmentedControl *mapType;
	NSString *profile;
	UINavigationController *navContrioller;	
	LocationAnnotation *currAnnotation;
}

- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav;
- (void)requestLocation;
- (IBAction)changeType:(id)sender;

- (double)zoomToDelta:(int)intZoom;
- (int)deltaToZoom:(double)delta;

@end

