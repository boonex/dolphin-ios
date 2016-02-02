//
//  FriendsHomeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "FriendsHomeController.h"
#import "FriendsProfilesController.h"
#import "FriendRequestsProfilesController.h"
#import "Designer.h"

@implementation FriendsHomeController

- (id)init {
	if ((self = [super initWithNibName:@"FriendsHomeView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
        self.title = NSLocalizedString(@"Friends tab", @"Friends tab title");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_friends.png"];		
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.navigationItem.title = NSLocalizedString(@"Friends", @"Friends View Title");
}

- (void)dealloc {
	[super dealloc];
}

/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	if (indexPath.section == 0) {		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = NSLocalizedString(@"Friends List row", @"Friends List row title");
				break;
			case 1:
				if (user.numFriendRequests) {
					NSString *s = [[NSString alloc] initWithFormat:NSLocalizedString(@"Friend Requests (<Num>)", @"Friend Requests more than zero row title"), user.numFriendRequests];
					cell.textLabel.text = s;
					[s release];
				} else {
					cell.textLabel.text = NSLocalizedString(@"Friend Requests row", @"Friend Requests with no friend requests row title");
				}
				break;
		}
	}
	
	[Designer applyStylesForCell:cell];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return BX_TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
        [self setupBackButton];
		Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
		UIViewController *ctrl = nil;
		switch (indexPath.row) {
			case 0:			
			{		
				ctrl = [[FriendsProfilesController alloc] initWithProfile:user.strUsername nav:app.friendsNavigationController];
				break;
			}
			case 1:
				ctrl = [[FriendRequestsProfilesController alloc] init];
				break;
		}
		[app.friendsNavigationController pushViewController:ctrl animated:YES];			
		[ctrl release];
	}
}

@end
