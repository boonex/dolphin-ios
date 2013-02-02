//
//  SearchLocationController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/11/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "SearchLocationController.h"
#import "CountryPickerController.h"
#import "SearchResultsLocationProfilesController.h"
#import "Designer.h"

@implementation SearchLocationController

@synthesize countryName, countryCode;

- (id)init {
	if ((self = [super initWithNibNameOnly:@"SearchLocationView"])) {
		countryName = nil;
		countryCode = nil;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedString(@"Location Search", @"Location Search view title");
	
	[Designer applyStylesForTextEdit:textCity];
	[Designer applyStylesForTextEdit:textCountry];	
	
	textCity.placeholder = NSLocalizedString(@"City", @"City field caption");
	textCountry.placeholder = NSLocalizedString(@"Select Country...", @"Choose country from countries list");
		
}

- (void)dealloc {
	
	[btnCountry release];
	
	[textCountry release];
	[textCity release];
		
	[countryName release];
	[countryCode release];
	
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
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = nil;
	ctrl = [[SearchResultsLocationProfilesController alloc] initWithCountryCode:countryCode city:textCity.text onlineOnlyFlag:switchOnlineOnly.on withPhotosOnlyFlag:switchWithPhotosOnly.on startFrom:0 searchForm:self];
	[app.searchNavigationController pushViewController:ctrl animated:YES];			
	[ctrl release];
}

/**
 * run select country activity
 */
- (IBAction)actionSelectCountry:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	CountryPickerController * ctrl = [[CountryPickerController alloc] initWithReciver:self nav:app.searchNavigationController];
	[app.searchNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];
}


/**********************************************************************************************************************
 DELEGATES: CountryPickerDelegate
 **********************************************************************************************************************/

#pragma mark - CountryPickerDelegate Delegate

- (void)setCountry:(NSString*)aName code:(NSString*)aCode {
	self.countryName = aName;
	self.countryCode = aCode;
	textCountry.text = self.countryName;
}

/**********************************************************************************************************************
 DELEGATES: UITextField
 **********************************************************************************************************************/

#pragma mark - UITextField Delegate

/**
 * when user press Done button - hide keyboard 
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	
    if (theTextField == textCity) {
        [textCity resignFirstResponder];
    }
	
    return YES;
}

@end
