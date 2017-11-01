//
//  SearchNearMeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/27/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import "SearchNearMeController.h"
#import "SearchResultsMearMeProfilesController.h"

@implementation SearchNearMeController

CLLocationManager* lmanager;

- (id)init {
	if ((self = [super initWithNibNameOnly:@"SearchNearMeView"])) {
		
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Search Near Me", @"search near me form view title");	
}

- (void)dealloc {
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
	lmanager = [[CLLocationManager alloc] init];
	[lmanager setDelegate:self];
	[lmanager setDesiredAccuracy:kCLLocationAccuracyBest];
	[lmanager startUpdatingLocation];
	[self addProgressIndicator];	
}

- (IBAction)actionRealSearch:(id)sender {	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = nil;
	ctrl = [[SearchResultsMearMeProfilesController alloc] initWithLat:sLat lng:sLng onlineOnlyFlag:switchOnlineOnly.on withPhotosOnlyFlag:switchWithPhotosOnly.on startFrom:0 searchForm:self];
	[app.searchNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];
}

/**********************************************************************************************************************
 DELEGATES: CLLocationManager
 **********************************************************************************************************************/

#pragma mark - CLLocationManager Delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
	[self removeProgressIndicator];
	CLLocationCoordinate2D coord = [newLocation coordinate];
	
	sLat = [NSString stringWithFormat:@"%.4f", coord.latitude];
	sLng = [NSString stringWithFormat:@"%.4f", coord.longitude];
	
	[self actionRealSearch:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
	[self removeProgressIndicator];
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Error Alert Title") message:NSLocalizedString(@"Location update failed", @"Location update failed alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
	[al show];
	[al release];
}

@end
