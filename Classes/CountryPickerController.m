//
//  UserPicker.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "CountryPickerController.h"

@implementation CountryPickerController

- (id)initWithReciver:(id)aReciver nav:(UINavigationController *)aNav {
	if ((self = [super initWithReciver:aReciver nav:aNav])) {
		nameKey = @"Name";
	}
	return self;
}
		
- (void)dealloc {
	[super dealloc];
}

- (void)viewDidLoad {
	self.navigationItem.title = NSLocalizedString(@"Countries", @"Countries View Title");
	[super viewDidLoad];
	
}

- (void)requestData {	
	if (nil == dataList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:@"dolphin.getCountries" withParams:myArray withSelector:@selector(actionRequestData:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	}
	
}

- (void)actionRequestData:(id)idData {
    // must be overridden
}

/**********************************************************************************************************************
 DELEGATES: UITableView
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *strLetter = [indexList objectAtIndex:indexPath.section];
	NSArray *a = [lettersDict valueForKey:strLetter];
	NSMutableDictionary *dict = [a objectAtIndex:indexPath.row];

	NSString* name = [dict valueForKey:@"Name"];
	NSString* code = [dict valueForKey:@"Code"];
	[reciver setCountry:name code:code];
	
	[super tableView:aTableView didSelectRowAtIndexPath:indexPath];
}

@end
