//
//  MediaListController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface MediaListController : BaseUserTableController {
	NSIndexPath *indexPathForRemoving;
	NSMutableArray *mediaList;
	NSString *profile;
	NSString *album;
    NSString *albumName;
	UINavigationController *navController;
	BOOL isReloadRequired;
    BOOL isEditAllowed;
    BOOL isAddAllowed;
    BOOL isAlbumDefault;
	NSString *method;
    NSString *methodRemove;
    id rightButtonSave2;
}

@property (nonatomic, assign) BOOL isReloadRequired;

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum albumName:(NSString*)anAlbumName albumDefault:(BOOL)isDefault nav:(UINavigationController*)aNav;

- (void)requestMedia;
- (void)requestRemoveMedia:(NSString*)sMediaId;
- (void)reloadData;

- (void)actionDone:(id)sender;
- (void)actionEdit:(id)sender;
- (void)actionEditAdd:(id)sender;

@end
