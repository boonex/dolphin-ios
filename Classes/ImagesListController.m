//
//  ImagesListController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ImagesListController.h"
#import "Dolphin6AppDelegate.h"
#import "ImageIconBlock.h"
#import "ImagesController.h"
#import "ImageAddController.h"
#import "ImagesAlbumsController.h"
#import "Designer.h"

@implementation ImagesListController


- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum albumName:(NSString*)anAlbumName albumDefault:(BOOL)isDefault nav:(UINavigationController*)aNav {
	if ((self = [super initWithProfile:aProfile album:anAlbum albumName:anAlbumName albumDefault:isDefault nav:aNav])) {
		method = @"dolphin.getImagesInAlbum";
        methodRemove = @"dolphin.removeImage";
	}
	return self;
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionEditAdd:(id)sender {
	UISegmentedControl* segCtl = sender;
	
	NSInteger buttonIndex = [segCtl selectedSegmentIndex];
	switch (buttonIndex)
	{
		case 1:
		{
			ImageAddController *ctrl = [[ImageAddController alloc] initWithAlbum:albumName mediaListController:self nav:navController];
			[navController pushViewController:ctrl animated:YES];
			[ctrl release];
			return;
		}
	}
    
    [super actionEditAdd:sender];
}

/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - UITableView delegates


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ImagesController *ctrl = [[ImagesController alloc] initWithList:mediaList profile:profile nav:navController selectedImageIndex:indexPath.row makeThumbnailFlag:(isAlbumDefault && [profile isEqualToString:user.strUsername])];
    
    [ctrl setWantsFullScreenLayout:YES];
	[navController presentModalViewController:ctrl animated:YES];
	[ctrl release];
}


@end