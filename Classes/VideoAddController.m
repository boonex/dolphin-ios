//
//  VideoAddController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 12/07/13.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoAddController.h"
#import "Designer.h"

@implementation VideoAddController

- (id)initWithAlbum:(NSString*)anAlbumName mediaListController:(UIViewController*)aController nav:(UINavigationController*)aNav {
	if ((self = [super initWithAlbum:anAlbumName mediaListController:aController nav:aNav])) {
        mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        methodUpload = @"dolphin.uploadVideo";
        pickerDataKey = UIImagePickerControllerMediaURL;
        fileExt = @"mov";
        msgSuccess = NSLocalizedString(@"Video upload success message", @"Video upload success message");
	}
	return self;
}


- (void)useMedia:(id)media {
    NSLog (@"useMedia: %@", media);
    
	if (mediaURL != nil)
		[mediaURL release];
    mediaURL = [(NSURL*)media copy];
    
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:mediaURL];
    moviePlayer.shouldAutoplay = NO;
    UIImage *thumbnail = [[moviePlayer thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame] retain];
    [imageView setImage:thumbnail];  
    [moviePlayer release];
    [thumbnail release];
}

- (void)dealloc {
	[mediaURL release];
	[super dealloc];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * save
 */
- (IBAction)actionSave:(id)sender {
	
    if (![self checkRequiredFields:mediaURL])
        return;
    
    NSData *data = [NSData dataWithContentsOfURL:mediaURL];
	[self requestUploadMedia:data title:fieldTitle.text tags:fieldTags.text desc:textDesc.text];
}


@end
