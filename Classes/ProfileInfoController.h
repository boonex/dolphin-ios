//
//  ProfileInfoController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/24/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserThumbTableController.h"

@interface ProfileInfoController : BaseUserThumbTableController {
	NSString *profile;
	NSString *title;    
    NSString *thumb;
    NSString *info;
    NSString *location;
	UINavigationController *navController;
	NSArray *profileInfoList;
}

- (id)initWithProfile:(NSString*)aProfile title:(NSString*)sTitle thumb:(NSString*)sThumb info:(NSString*)sInfo location:(NSString*)sLocation nav:(UINavigationController *)aNav;
- (void)requestUserInfo;

@end
