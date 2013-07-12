//
//  VideoListController.m
//  Dolphin
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "VideoListController.h"
#import "VideoAddController.h"
#import "Dolphin6AppDelegate.h"

@implementation VideoListController

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum albumName:(NSString*)anAlbumName nav:(UINavigationController*)aNav {
	if ((self = [super initWithProfile:aProfile album:anAlbum albumName:anAlbumName nav:aNav])) {
		method = @"dolphin.getVideoInAlbum";
        methodRemove = @"dolphin.removeVideo";
        if (user.intProtocolVer >= 5) {
            isEditAllowed = true;
            isAddAllowed = true;
        } else {
            isEditAllowed = false;
            isAddAllowed = false;
        }
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
			VideoAddController *ctrl = [[VideoAddController alloc] initWithAlbum:albumName mediaListController:self nav:navController];
			[navController pushViewController:ctrl animated:YES];
			[ctrl release];
			return;
		}
	}
    
    [super actionEditAdd:sender];
}

@end
