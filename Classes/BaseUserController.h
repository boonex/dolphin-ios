//
//  BaseUserController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "config.h"
#import "Dolphin6AppDelegate.h"
#import "BaseController.h"

@interface BaseUserController : BaseController {
	BxUser *user;
	id rightButtonSave;
	BOOL isEditingMode;
    BOOL isProgress;
}

@property (nonatomic, retain) BxUser *user;
@property (nonatomic, retain) id rightButtonSave;
@property (assign) BOOL isProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUser:(BxUser*)anUser;

- (void)addProgressIndicator;
- (void)removeProgressIndicator;

- (void)displayDoneButton:(BOOL)isEditBegin textField:(UIView*)aTextField;

- (void)openPageUrl:(NSString*)sUrl title:(NSString*)aTitle nav:(UINavigationController*)aNav openInNewWindow:(BOOL)isOpenInNewWindow;

@end
