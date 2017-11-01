//
//  ImageAddController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 12/1/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import "ImageAddController.h"
#import "Designer.h"

#define BX_IMAGE_MAX_SIZE 1280 // max image size

@implementation ImageAddController

- (id)initWithAlbum:(NSString*)anAlbumName mediaListController:(UIViewController*)aController nav:(UINavigationController*)aNav {
	if ((self = [super initWithAlbum:anAlbumName mediaListController:aController nav:aNav])) {
        mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
        methodUpload = @"dolphin.uploadImage";
        pickerDataKey = UIImagePickerControllerOriginalImage;
        fileExt = nil;
        msgSuccess = NSLocalizedString(@"Image hase been successfully uploaded", @"Image upload success message");
	}
	return self;
}

- (void)dealloc {
	[currentChoosenImage release];
	[super dealloc];
}


/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions



- (void)useMedia:(id)media {
    UIImage *theImage = (UIImage *)media;
	if (currentChoosenImage != nil)
		[currentChoosenImage release];
	NSLog (@"useImage before copy");
	currentChoosenImage = [theImage retain];
	[self rotateImage];
	NSLog (@"useImage after copy");
	imageView.image = currentChoosenImage;
}

- (void)rotateImage
{	
	UIImage *image = currentChoosenImage;
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);

	NSLog (@"Original image size: %f x %f", width, height);
	
	CGAffineTransform transform;
	CGRect bounds = CGRectMake(0, 0, width, height);	
	
	CGFloat scaleRatio;
	if ((width > height ? width : height) > BX_IMAGE_MAX_SIZE)
		scaleRatio = BX_IMAGE_MAX_SIZE / (width > height ? width : height);
	else
		scaleRatio = 1.0;
	
	NSLog (@"Scale: %f", scaleRatio);
	
	CGSize imageSize = CGSizeMake(width, height);
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
		
	switch(orient) {
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;			
			
	}
	
	UIGraphicsBeginImageContext(CGSizeMake(bounds.size.width*scaleRatio, bounds.size.height*scaleRatio));//bounds.size);
	
	NSLog (@"Scaled image size: %f x %f", width*scaleRatio, height*scaleRatio);
								
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	

	if (currentChoosenImage != nil)
		[currentChoosenImage release];
    
    CGImageRef cgImage = [imageCopy CGImage];
    currentChoosenImage = [[UIImage alloc] initWithCGImage:cgImage];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * save
 */
- (IBAction)actionSave:(id)sender {
	
    if (![self checkRequiredFields:currentChoosenImage])
        return;
    
	NSData *imgData = UIImageJPEGRepresentation(currentChoosenImage, 0.8);
	[self requestUploadMedia:imgData title:fieldTitle.text tags:fieldTags.text desc:textDesc.text];
}

@end
