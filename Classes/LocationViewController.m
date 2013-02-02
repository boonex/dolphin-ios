//
//  LocationViewController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/14/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import "LocationViewController.h"

@implementation LocationAnnotation

@synthesize coordinate;

- (id)initWithLat:(double)lat lng:(double)lng {
	if ((self = [super init])) {
		CLLocationCoordinate2D coord;	
		coord.latitude = lat;
		coord.longitude = lng;
		coordinate = coord;
	}
	return self;
}

@end

@implementation LocationViewController

- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav {
	if ((self = [super initWithNibName:@"LocationViewView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		profile = [aProfile copy];
		navContrioller = aNav;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Location", @"Location title");
	
    self.view.backgroundColor = [UIColor colorWithRed:BX_TABLE_BG_RED green:BX_TABLE_BG_GREEN blue:BX_TABLE_BG_BLUE alpha:BX_TABLE_BG_ALPHA];
	
	mapView.zoomEnabled = YES;
	mapView.scrollEnabled = YES;
	mapView.mapType = MKMapTypeStandard;
	
	[self requestLocation];
}

- (void)dealloc {
	[profile release];
	[currAnnotation release];
    [super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (double)zoomToDelta:(int)intZoom {
	return 180.0/pow(2,intZoom);
}

- (int)deltaToZoom:(double)delta {
	return round(log2(180.0/delta));
}

- (void)requestLocation {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, nil];
	[user.connector execAsyncMethod:@"dolphin.getUserLocation" withParams:myArray withSelector:@selector(actionUserLocation:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on request info 
 */
- (void)actionUserLocation:(id)idData {	
		
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"user location: %@", resp);	
	
    if([resp isKindOfClass:[NSDictionary class]] && nil != [(NSDictionary *)resp objectForKey:@"error"]) {        
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    }
    
	[self performSelectorOnMainThread:@selector(actionUpdateMap:) withObject:resp waitUntilDone:YES];
	[resp release];
}

- (void)actionUpdateMap:(id)resp {	
	
	if([resp isKindOfClass:[NSString class]]) {
		
		NSString *s = (NSString*)resp;
		NSString *sMsg;
		if ([s isEqualToString:@"0"]) {
			sMsg = NSLocalizedString(@"Location is undefined", @"Location is undefined alert msg");
		} else if ([s isEqualToString:@"-1"]) { 
			sMsg = NSLocalizedString(@"Access denied", @"Access denied alert msg");
		} else {
			sMsg = s;
		}
		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:sMsg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
		[al show];
		[al release];				
		
	} else {
	
		MKCoordinateRegion region;
		CLLocationCoordinate2D coord; 
		coord.latitude = [[resp valueForKey:@"lat"] doubleValue]; 
		coord.longitude = [[resp valueForKey:@"lng"] doubleValue]; 
		MKCoordinateSpan span;
		span.latitudeDelta = [self zoomToDelta:[[resp valueForKey:@"zoom"] intValue]];
		span.longitudeDelta = span.latitudeDelta;
		region.span = span;
		region.center = coord;
		[mapView regionThatFits:region];
		[mapView setRegion:region animated:YES];
		if ([[resp valueForKey:@"type"] isEqualToString:@"hybrid"]) {
			mapView.mapType = MKMapTypeHybrid;		
			mapType.selectedSegmentIndex = 2;
		} else if ([[resp valueForKey:@"type"] isEqualToString:@"satellite"]) {
			mapView.mapType = MKMapTypeSatellite;		
			mapType.selectedSegmentIndex = 1;
		}
	
		if (currAnnotation) {
			[mapView removeAnnotation:currAnnotation];
			[currAnnotation release];
			currAnnotation = nil;
		}
		
		currAnnotation = [[LocationAnnotation alloc] initWithLat:coord.latitude lng:coord.longitude];
		[mapView addAnnotation:currAnnotation];
	}
}

- (IBAction)changeType:(id)sender{
	if(mapType.selectedSegmentIndex==0){
		mapView.mapType=MKMapTypeStandard;
	}
	else if (mapType.selectedSegmentIndex==1){
		mapView.mapType=MKMapTypeSatellite;
	}
	else if (mapType.selectedSegmentIndex==2){
		mapView.mapType=MKMapTypeHybrid;
	}
}

@end
