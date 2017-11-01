//
//  ProfilesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/7/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilesController.h"

@interface FriendsProfilesController : ProfilesController {
	NSIndexPath *indexPathForRemoving;
	NSString *profile;
	NSString *profileTitle;    
}

- (id) initWithProfile:(NSString*)aProfile title:(NSString*)aProfileTitle nav:(UINavigationController*)aNav;
- (id) initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav;
- (void) requestRemoveFriend:(NSString *)aFriend;
- (void)actionRequestRemoveFriend:(id)idData;

@end
