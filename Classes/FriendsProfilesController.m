//
//  ProfilesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "FriendsProfilesController.h"
#import "ProfileController.h"
#import "ProfileIconBlock.h"
#import "DataButton.h"

@implementation FriendsProfilesController

- (id) initWithProfile:(NSString*)aProfile title:(NSString*)aProfileTitle nav:(UINavigationController*)aNav {
	if ((self = [super initWithNavigation:aNav])) {
		profile = [aProfile copy];
		profileTitle = [aProfileTitle copy];        
		indexPathForRemoving = nil;
	}
	return self;
}
    
- (id) initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav {
	return [self initWithProfile:aProfile title:aProfile nav:aNav];
}

- (void)viewDidLoad {		        
	if ([profile isEqualToString:user.strUsername])	{
		self.navigationItem.title = NSLocalizedString(@"My Friends", @"My Friends view title");
        
        
		UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit button title") style:UIBarButtonItemStylePlain target:self action:@selector(actionEdit:)];
		self.navigationItem.rightBarButtonItem = btn2;
		[btn2 release];
        
	} else {
		self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"<user>'s friends", @"user's friends view title"), profileTitle];	
	}
    
    [super viewDidLoad];
}

- (void)dealloc {
	[profile release];
    [profileTitle release];
	[indexPathForRemoving release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void) requestData {
	
	if (profilesList != nil) return;
	
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.getFriends" withParams:myArray withSelector:@selector(actionRequestFillProfilesArray:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

- (void) requestRemoveFriend:(NSString *)aFriend {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, aFriend, nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.removeFriend" withParams:myArray withSelector:@selector(actionRequestRemoveFriend:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}


/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionRequestRemoveFriend:(id)idData {
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"remove friend request result: %@", resp);
	NSString *strResult = resp;
	
	if ([strResult isEqualToString:@"ok"] && indexPathForRemoving != nil)
	{
		[profilesList removeObjectAtIndex:indexPathForRemoving.row];
		[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForRemoving] withRowAnimation:YES];
		[indexPathForRemoving release];
		indexPathForRemoving = nil;
		return;
	}
	
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Error occured", @"Error occured alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
	[al show];
	[al release];
}


/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle != UITableViewCellEditingStyleDelete) 
		return;
	
	if (![profilesList count]) 	
		return;
			
	NSLog(@"Deleting row: %d", (int)indexPath.row); 
	
	NSMutableDictionary *dict = [profilesList objectAtIndex:indexPath.row];
	NSString* nick = [dict valueForKey:@"Nick"];
	indexPathForRemoving = [indexPath retain];
	[self requestRemoveFriend:nick];
}

@end
