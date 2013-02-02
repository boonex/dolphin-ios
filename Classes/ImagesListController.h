//
//  ImagesListController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface ImagesListController : BaseUserTableController {
	NSMutableArray *imagesList;
	NSString *profile;
	NSString *album;
	NSString *albumName;
	UINavigationController *navController;
	NSIndexPath *indexPathForRemoving;
	id rightButtonSave2;
	BOOL isReloadRequired;
}

@property (nonatomic, assign) BOOL isReloadRequired;

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum albumName:(NSString*)anAlbumName nav:(UINavigationController*)aNav;
- (void)requestImages;
- (void)reloadData;

@end
