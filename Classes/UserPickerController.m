//
//  UserPicker.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "UserPickerController.h"

@implementation UserPickerController

- (id)initWithReciver:(id)aReciver nav:(UINavigationController *)aNav {
	if ((self = [super initWithReciver:aReciver nav:aNav])) {
		nameKey = user.intProtocolVer > 2 ? @"UserTitle" : @"Nick";
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)viewDidLoad {
	self.navigationItem.title = NSLocalizedString(@"Contacts", @"Contacts View Title");
	[super viewDidLoad];
}

- (void)requestData {		
	if (nil == dataList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:@"dolphin.getContacts" withParams:myArray withSelector:@selector(actionRequestData:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	}
}

/**********************************************************************************************************************
 DELEGATES: UITableView
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *strLetter = [indexList objectAtIndex:indexPath.section];
	NSArray *a = [lettersDict valueForKey:strLetter];
	NSMutableDictionary *dict = [a objectAtIndex:indexPath.row];
    
	NSString* name = [dict valueForKey:@"Nick"];
	NSString* title = [Dolphin6AppDelegate formatUserTitle:dict field:@"UserTitle" default:@""];
	[reciver setRecipient:name title:title];
	
	[super tableView:aTableView didSelectRowAtIndexPath:indexPath];
}


@end
