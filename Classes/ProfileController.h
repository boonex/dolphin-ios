//
//  ProfileController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/5/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BaseUserTableController.h"
#import "BaseUserThumbTableController.h"

@class ProfileBlock;

@interface ProfileController : BaseUserThumbTableController<MFMailComposeViewControllerDelegate> {
	NSString *profile;
    NSString *title;
    NSString *location;
    NSString *info;
    NSString *thumb;
    NSMutableArray *aButtons;
	IBOutlet UIView *viewActionButtons;
	UINavigationController *navController;
    BOOL bGoBackAfterAlert;
}

- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController *)aNav;

- (void)requestUserInfo;
- (void)requestAddFriend:(NSString*)aProfile;

- (void)actionRequestAddFriend:(id)idData;
- (IBAction)actionAddFriend:(id)sender;

@end
