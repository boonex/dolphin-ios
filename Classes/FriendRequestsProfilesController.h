//
//  ProfilesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilesController.h"

@interface FriendRequestsProfilesController : ProfilesController <UIActionSheetDelegate> {
	NSIndexPath *indexPathForRemoving;
}

- (id) init;

- (void)actionRequestAcceptDeclineFriendRequest:(id)idData;
- (void)friendRequestAcceptDecline:(id)sender method:(NSString*)aMethod;

- (IBAction)actionFriendRequestAccept:(id)sender;
- (IBAction)actionFriendRequestDecline:(id)sender;

@end
