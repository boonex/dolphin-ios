//
//  ImagesHomeController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/26/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface MediaAlbumsController : BaseUserTableController {
	NSArray *catList;
	NSString *profile;
	NSString *profileTitle;
	BOOL isReloadRequired;
	UINavigationController *navContrioller;
	NSString *method;
}

@property (nonatomic, assign) BOOL isReloadRequired;
@property (nonatomic, assign) UINavigationController *navContrioller;

- (id)initWithProfile:(NSString*)aProfile title:(NSString*)aProfileTitle nav:(UINavigationController*)aNav;
- (id)initWithProfile:(NSString*)aProfile nav:(UINavigationController*)aNav;

- (void)requestData;

- (void)reloadData;

@end
