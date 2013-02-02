//
//  ImagesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserController.h"
#import "AsyncImageView.h"

@interface ImagesController : BaseUserController <UIScrollViewDelegate, AsyncImageViewDelegate> {

	NSString *profile;    
    NSString *albumId;    
    NSString *imageId;
	NSInteger currentImageIndex;
	NSArray *imagesList;

	IBOutlet UIToolbar *toolBar;
	IBOutlet UIToolbar *toolBarBottom;
	IBOutlet AsyncImageView *imageView;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIBarButtonItem *prevButtonItem;
	IBOutlet UIBarButtonItem *nextButtonItem;
	IBOutlet UIBarButtonItem *titleButtonItem;
	IBOutlet UIBarButtonItem *backButtonItem;
	IBOutlet UIBarButtonItem *makeThumbButtonItem;
	IBOutlet UIBarButtonItem *captionButtonItem;

	UINavigationController *navContrioller;
	BOOL isMakeTumbnailAllowed;
}

- (id)initWithAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile nav:(UINavigationController*)aNav selectedImageId:(NSString*)anImageId;
- (id)initWithAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile nav:(UINavigationController*)aNav selectedImageIndex:(NSInteger)anIndex makeThumbnailFlag:(BOOL)makeTumbnailFlag;
- (id)initWithList:(NSArray*)aList profile:(NSString*)aProfile nav:(UINavigationController*)aNav selectedImageIndex:(NSInteger)anIndex 
    makeThumbnailFlag:(BOOL)makeTumbnailFlag;

- (IBAction)prevImage:(id)sender;
- (IBAction)nextImage:(id)sender;
- (IBAction)actionClose:(id)sender;
- (IBAction)actionMakeThumbnail:(id)sender;

- (void)requestImages;
- (void)setImageIndex:(NSInteger)anIndex;

- (void)setScale:(UIImage*)anImage;

- (BOOL)isGesturesRecognizerSupported;

@end
