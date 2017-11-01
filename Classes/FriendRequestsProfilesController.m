//
//  ProfilesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "FriendRequestsProfilesController.h"
#import "ProfileController.h"
#import "ProfileIconBlock.h"
#import "DataButton.h"


/**********************************************************************************************************************/

@interface FriendRequestsProfilesControllerActionSheet : UIActionSheet {
    id cutomSender;
}

@property(assign) id customSender;

@end

@implementation FriendRequestsProfilesControllerActionSheet

@synthesize customSender;

@end

/**********************************************************************************************************************/


@implementation FriendRequestsProfilesController

- (id)init {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	if ((self = [super initWithNavigation:app.friendsNavigationController])) {
		indexPathForRemoving = nil;
	}
	return self;
}

- (void)viewDidLoad {
	self.navigationItem.title = NSLocalizedString(@"Friend Requests", @"Friend Requests view title");	
	[super viewDidLoad];
}


- (void)dealloc {
	[indexPathForRemoving release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void) requestData {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.getFriendRequests" withParams:myArray withSelector:@selector(actionRequestFillProfilesArray:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

- (void)friendRequestAcceptDecline:(id)sender method:(NSString*)aMethod {
	DataButton *btn = sender;
	ProfileIconBlock *cell = [btn getButtonData];
	NSMutableDictionary *dict = cell.data;
	NSString* nick = [dict valueForKey:@"Nick"];	
	
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nick, nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:aMethod withParams:myArray withSelector:@selector(actionRequestAcceptDeclineFriendRequest:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	
	[indexPathForRemoving release];
	indexPathForRemoving = [[table indexPathForCell:cell] retain];
	NSLog(@"%@ at row: %d", aMethod, (int)indexPathForRemoving.row);	
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionRequestAcceptDeclineFriendRequest:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		[indexPathForRemoving release];
		indexPathForRemoving = nil;
		return;
	}
	
	NSLog(@"accept/decline friend request result: %@", resp);
	NSString *strResult = resp;
	
	if ([strResult isEqualToString:@"ok"])
	{
		[profilesList removeObjectAtIndex:indexPathForRemoving.row];
		[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForRemoving] withRowAnimation:YES];		
		[indexPathForRemoving release];
		indexPathForRemoving = nil;
		
		if (user.numFriendRequests > 0)
			[user decFriendRequestsNum];
		
		return;
	}
	
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Error occured", @"Error occured alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button text") otherButtonTitles:nil];
	[al show];
	[al release];
	[indexPathForRemoving release];
	indexPathForRemoving = nil;
}

/**
 * accept friend request
 */
- (IBAction)actionFriendRequestAccept:(id)sender {
	[self friendRequestAcceptDecline:sender method:@"dolphin.acceptFriendRequest"];
}

/**
 * decline friend request
 */
- (IBAction)actionFriendRequestDecline:(id)sender {
    
    
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	
    FriendRequestsProfilesControllerActionSheet *actionSheet = [[FriendRequestsProfilesControllerActionSheet alloc]
					   initWithTitle:@""
					   delegate:self
					   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
					   destructiveButtonTitle:NSLocalizedString(@"Confirm Deletion", @"Confirm Deletion")
					   otherButtonTitles:nil];
	
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect rect = [self.view convertRect:[(UIView*)sender frame] fromView:[(UIView*)sender superview]];
        rect.size.width = MIN(rect.size.width, 200);
        [actionSheet showFromRect:rect inView:self.view animated:YES];
    } else {
        [actionSheet showFromTabBar:app.tabController.tabBar];
    }
    
    actionSheet.customSender = sender;
    
    [actionSheet release];
}

/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - UIActionSheet delegates

- (void)actionSheet:(FriendRequestsProfilesControllerActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self friendRequestAcceptDecline:actionSheet.customSender method:@"dolphin.declineFriendRequest"];
    }
}

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ProfileIconBlock *cell = (ProfileIconBlock *)[super tableView:tableView cellForRowAtIndexPath:indexPath];	

	if (cell) {	
		[cell setFriendRequestControlsTarget:self selectorAccept:@selector(actionFriendRequestAccept:) selectorDecline:@selector(actionFriendRequestDecline:)];
	}

	return cell;
}

@end
