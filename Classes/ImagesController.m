//
//  ImagesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 11/6/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIGestureRecognizer.h>
#import "ImagesController.h"
#import "AsyncImageView.h"

#define ZOOM_STEP 1.5
#define ZOOM_MAX 3.0

@interface ImagesController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation ImagesController

- (id)initWithAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile nav:(UINavigationController*)aNav selectedImageIndex:(NSInteger)anIndex makeThumbnailFlag:(BOOL)makeTumbnailFlag {
	if ((self = [super initWithNibName:@"ImagesView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
        albumId = [anAlbumId copy];
		profile = [aProfile copy];
		navContrioller = aNav;
		currentImageIndex = anIndex;
		isMakeTumbnailAllowed = makeTumbnailFlag;        
	}
	return self;
}

- (id)initWithAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile nav:(UINavigationController*)aNav selectedImageId:(NSString*)anImageId {
	if ((self = [self initWithAlbum:anAlbumId profile:aProfile nav:aNav selectedImageIndex:-1 makeThumbnailFlag:NO])) {
        imageId = [anImageId copy];
	}
	return self;
}

- (id)initWithList:(NSArray*)aList profile:(NSString*)aProfile nav:(UINavigationController*)aNav selectedImageIndex:(NSInteger)anIndex makeThumbnailFlag:(BOOL)makeThumbnailFlag {
	if ((self = [self initWithAlbum:nil profile:aProfile nav:aNav selectedImageIndex:anIndex makeThumbnailFlag:makeThumbnailFlag])) {
		imagesList = [aList retain];
	}
	return self;
}

- (void)loadView {
    [super loadView];
    
    if ([self isGesturesRecognizerSupported]) {
        
        // add gesture recognizers 
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        
        [singleTap setNumberOfTapsRequired:1];
        [doubleTap setNumberOfTapsRequired:2];
        [twoFingerTap setNumberOfTouchesRequired:2];
        
        [singleTap requireGestureRecognizerToFail: doubleTap];
        
        [scrollView addGestureRecognizer:singleTap];
        [scrollView addGestureRecognizer:doubleTap];
        [scrollView addGestureRecognizer:twoFingerTap];

        scrollView.clipsToBounds = YES;
	
        [singleTap release];
        [doubleTap release];
        [twoFingerTap release];
    }
}


- (void)viewDidLoad {
  
	if (isMakeTumbnailAllowed) {
		makeThumbButtonItem.title = NSLocalizedString(@"Make Thumbnail", @"Make thumbnail button title");
	} else {
		
		NSRange theRange;
		NSArray *items = toolBar.items;
		
		theRange.location = 0;
		theRange.length = [items count] - 1;
				
		toolBar.items = [items subarrayWithRange:theRange];
	}
	
	backButtonItem.title = NSLocalizedString(@"Close", @"Close button");
	captionButtonItem.title = NSLocalizedString(@"Loading...", @"Loading text");
	titleButtonItem.title = @"0/0";
	prevButtonItem.enabled = NO;
	nextButtonItem.enabled = NO;
	
	scrollView.clipsToBounds = YES;
	scrollView.maximumZoomScale = ZOOM_MAX;	
    
	[self requestImages];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
}

// iOS 6
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// iOS 6
- (BOOL)shouldAutorotate {
    return YES;
}

// iOS 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self setScale:[imageView getImage]];
}

- (void)dealloc {
    [imageId release];
    [albumId release];
	[profile release];
	[imageView release];
	[prevButtonItem release];
	[nextButtonItem release];
	[titleButtonItem release];
	[imagesList release];
	[backButtonItem release];
	[makeThumbButtonItem release];
	[captionButtonItem release];
	[scrollView release];
	[toolBar release];	
	[toolBarBottom release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark Custom Functions

- (BOOL)isGesturesRecognizerSupported {
    Class TapGestureRecognizerClass = NSClassFromString(@"UITapGestureRecognizer");
    if (nil == TapGestureRecognizerClass)
        return NO;
    
    UITapGestureRecognizer *singleTap = [[TapGestureRecognizerClass alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    if (nil == singleTap)
        return NO;
    
    if (![singleTap respondsToSelector:@selector(setNumberOfTapsRequired:)])
        return NO;
    
    return YES;
}

- (void)setScale:(UIImage*)anImage {
	
	if (imageView.loading) {
		NSLog (@"Skip auzoooming");
		return;
	}
	
	float iw = anImage.size.width;
	float ih = anImage.size.height;
	float sw = scrollView.frame.size.width;
	float sh = scrollView.frame.size.height;
	
    NSLog (@"iw x ih: %f x %f", iw, ih);
    NSLog (@"sw x sh: %f x %f", sw, sh);
    
	CGRect r = imageView.frame;
	r.origin = CGPointMake(0, 0);
	imageView.frame = r;
	
	// calculate minimum scale to perfectly fit image width, and begin at that scale
	float minimumScale;
	if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
		minimumScale = sw / iw;
	else
		minimumScale = sh / ih;
	
	
	NSLog (@"----------Autozooooomm: %f --> %f", scrollView.zoomScale, minimumScale);
	
    [scrollView setMinimumZoomScale:minimumScale];
    [scrollView setZoomScale:minimumScale animated:YES];
	
}

- (void)setImageIndex:(NSInteger)anIndex {
	
	if (anIndex < 0) anIndex = 0;
	NSInteger count = [imagesList count];
	if (anIndex > (count-1)) anIndex = count-1;
	NSMutableDictionary *dict = [imagesList objectAtIndex:anIndex];
    
	currentImageIndex = anIndex;
	
	captionButtonItem.title = [dict valueForKey:@"title"];
	
	NSURL *url = [NSURL URLWithString:[dict valueForKey:@"file"]];

	if (imageView != nil) {
		[imageView removeFromSuperview];
		[imageView release];
		imageView = nil;
	}
		
	[scrollView setZoomScale:1.0 animated:NO];		
	
	NSLog (@"ZOOM SCALE: %f (setImageIndex)", scrollView.zoomScale);
	
	imageView = [[AsyncImageView alloc] initWithFrame:scrollView.frame];
	imageView.delegate = self;
	imageView.ajustFrameToImageSize = YES;
	[imageView loadImageFromURL:url];
	[scrollView addSubview:imageView];
	
	titleButtonItem.title = [NSString stringWithFormat:@"%d/%d", (int)currentImageIndex+1, (int)count];

	prevButtonItem.enabled = NO;
	nextButtonItem.enabled = NO;		

}

- (void)findImageIndex {	
    if (-1 == currentImageIndex) {
        NSInteger iCount = [imagesList count];
		for (int i=0 ; i < iCount ; ++i) {
			NSMutableDictionary *dict = [imagesList objectAtIndex:i];
            if ([imageId isEqualToString:[dict valueForKey:@"id"]]) {
                currentImageIndex = i;
                return;
            }
        }
        currentImageIndex = 0;
    }    
}


- (void)requestImages {	
	
	if (nil == imagesList) {
		NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, albumId, nil];
		[self addProgressIndicator];
		[user.connector execAsyncMethod:@"dolphin.getImagesInAlbum" withParams:myArray withSelector:@selector(actionRequestImages:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	} else {

        [self findImageIndex];
        
		if ([imagesList count] > 0) {
			[self setImageIndex:currentImageIndex];
		} else if ([imagesList count] == 0) {
			captionButtonItem.title = NSLocalizedString(@"No Images", @"No Images view title");
		}
	}
	
}

- (void)requestMakeThumbnail {	

	NSInteger count = [imagesList count];
	if (count < 1) return;
	NSMutableDictionary *dict = [imagesList objectAtIndex:currentImageIndex];	
	
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [dict valueForKey:@"id"], nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.makeThumbnail" withParams:myArray withSelector:@selector(actionRequestMakeThumbnail:) andSelectorObject:self andSelectorData:nil useIndicator:nil];	
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (void)actionRequestImages:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"images: %@", resp);
	
	if (nil == imagesList && [resp count] > 0) {
		imagesList = [resp retain];        
        [self findImageIndex];
        [self setImageIndex:currentImageIndex];
	} else {
        NSLog(@"No such image!");
        captionButtonItem.title = NSLocalizedString(@"No Images", @"No Images view title");
    }
}

/**
 * callback function on make thumb request 
 */
- (void)actionRequestMakeThumbnail:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"make thumbnail: %@", resp);
	
	if ([resp isEqualToString:@"ok"]) {
				
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Great!", @"Set primary image success alert title") message:NSLocalizedString(@"Primary image has been successfully set", @"Set primary image success message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];		
		
	} else {
		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Error occured", @"Error occured alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];
		return;		
		
	}
	
}

- (IBAction)prevImage:(id)sender {
    if (0 == currentImageIndex)
        return;    
	[self setImageIndex:currentImageIndex - 1];
}

- (IBAction)nextImage:(id)sender {
	NSInteger count = [imagesList count];
	if (currentImageIndex == (count-1)) 
        return;
	[self setImageIndex:currentImageIndex + 1];
}

- (IBAction)actionClose:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    [navContrioller.visibleViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionMakeThumbnail:(id)sender {
	[self requestMakeThumbnail];
}

/**********************************************************************************************************************
 DELEGATES AsyncImageView
 **********************************************************************************************************************/

#pragma mark AsyncImageViewDelegate methods

- (void)loadingFinished:(UIImageView*)aImageView {
	
	NSLog (@"ZOOM SCALE: %f (loadingFinished)", scrollView.zoomScale);
	
	CGFloat fSaveZoom = scrollView.zoomScale;
	[scrollView setZoomScale:1.0 animated:NO];		
	scrollView.contentSize = CGSizeMake(aImageView.image.size.width, aImageView.image.size.height);
	[scrollView setZoomScale:fSaveZoom animated:NO];
	
	[self setScale:aImageView.image];

	NSInteger count = [imagesList count];
	
	if (1 == count)	{
		prevButtonItem.enabled = NO;
		nextButtonItem.enabled = NO;		
	}
	else if (count > 1)	{
			
		if (0 == currentImageIndex) {
			prevButtonItem.enabled = NO;
			nextButtonItem.enabled = YES;
		} else if ((count-1) == currentImageIndex) {
			prevButtonItem.enabled = YES;
			nextButtonItem.enabled = NO;
		} else {
			prevButtonItem.enabled = YES;
			nextButtonItem.enabled = YES;
		}
	}
	
}

/**********************************************************************************************************************
 DELEGATES UIScrollView
 **********************************************************************************************************************/

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return imageView;
}

/**
 * The following delegate method works around a known bug in zoomToRect:animated: 
 * In the next release after 3.0 this workaround will no longer be necessary      
 */
- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [aScrollView setZoomScale:scale+0.01 animated:NO];
    [aScrollView setZoomScale:scale animated:NO];
}

/**********************************************************************************************************************
 DELEGATES TapDetectingImageView 
 **********************************************************************************************************************/

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
	
	static BOOL toolbarHidden = NO;
	
	[UIView beginAnimations:@"toolbar" context:nil];
	if (toolbarHidden) {
		toolBar.frame = CGRectOffset(toolBar.frame, 0, +toolBar.frame.size.height);
		toolBar.alpha = 1;
		
		toolBarBottom.frame = CGRectOffset(toolBarBottom.frame, 0, -toolBarBottom.frame.size.height);
		toolBarBottom.alpha = 1;

		toolbarHidden = NO;
        
	} else {
		toolBar.frame = CGRectOffset(toolBar.frame, 0, -toolBar.frame.size.height);
		toolBar.alpha = 0;
		
		toolBarBottom.frame = CGRectOffset(toolBarBottom.frame, 0, +toolBarBottom.frame.size.height);
		toolBarBottom.alpha = 0;

		toolbarHidden = YES;
	}
	[UIView commitAnimations];	
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    float newScale = [scrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [scrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
}


@end
