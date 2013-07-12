//
//  AudioListController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/27/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "AudioListController.h"
#import "Dolphin6AppDelegate.h"

@implementation AudioListController

- (id)initWithProfile:(NSString*)aProfile album:(NSString*)anAlbum albumName:(NSString*)anAlbumName nav:(UINavigationController*)aNav {
	if ((self = [super initWithProfile:aProfile album:anAlbum albumName:anAlbumName nav:aNav])) {
		method = @"dolphin.getAudioInAlbum";
        methodRemove = @"dolphin.removeAudio";
        isAddAllowed = false;
        if (user.intProtocolVer >= 5) {
            isEditAllowed = true;
        } else {
            isEditAllowed = false;
        }
        
	}
	return self;
}

@end
