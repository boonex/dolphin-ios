//
//  HomeController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/20/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"
#import "BaseUserThumbTableController.h"
#import "AsyncImageView.h"
#import "HomeButtonView.h"
#import "HomeButton3rdPartyView.h"

@interface HomeController : BaseUserController<HomeButtonViewDelegate> {
	int intImagesCount;
	bool isReloadProfileInfoRequired;	
    NSString *stringStatus;
    NSString *stringThumbUrl;
    NSString *stringUserTitle;
    NSString *stringUserInfo;    
    NSString *stringUserLocation;
	IBOutlet UIScrollView *viewScroll;
	
    NSMutableArray *aButtons;
	HomeButtonView *btnMail;
	HomeButtonView *btnFriends;
}

@property (nonatomic, readonly) NSString *stringUserTitle;
@property (nonatomic, readonly) NSString *stringUserInfo;
@property (nonatomic, readonly) NSString *stringUserLocation;
@property (nonatomic, readonly) NSString *stringStatus;
@property (nonatomic, readonly) NSString *stringThumbUrl;

- (IBAction)actionOpenMail:(id)sender;
- (IBAction)actionOpenFriends:(id)sender;

- (void)requestHomepageInfo;
- (void)setReloadRequired;

- (void)removeButtons;

@end
