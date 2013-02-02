//
//  ImagesListController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface MediaListController : BaseUserTableController {
	NSMutableArray *mediaList;
	NSString *profile;
	NSString *album;
	UINavigationController *navController;
	BOOL isReloadRequired;
	NSString *method;
	}

@property (nonatomic, assign) BOOL isReloadRequired;

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum nav:(UINavigationController*)aNav;
- (void)requestMedia;
- (void)reloadData;

@end
