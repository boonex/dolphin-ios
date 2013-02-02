//
//  ImageAddController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 12/1/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "ImageAddController.h"
#import "ImagesListController.h"
#import "ImagesAlbumsController.h"
#import "Designer.h"

#define BX_OFFSET_IMAGE_ADD_DESC 185.0 // content offset for description field when we are entering text 
#define BX_OFFSET_IMAGE_ADD_TAGS 0.0 // content offset for tags field when we are entering text
#define BX_IMAGE_ADD_FORM_SIZE 550.0 // whole for height
#define BX_IMAGE_MAX_SIZE 1280 // max image size

@implementation ImageAddController

@synthesize ctrlImagePicker, ctrlPopover;

- (id)initWithAlbum:(NSString*)anAlbumName imagesListController:(UIViewController*)aController nav:(UINavigationController*)aNav {
	if ((self = [super initWithNibName:@"ImageAddView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		albumName = [anAlbumName copy];
		ctrlImagesContainer = aController;
        navContrioller = aNav;
	}
	return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
		
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save button title") style:UIBarButtonItemStyleDone target:self action:@selector(actionSave:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];	
	
	self.navigationItem.title = albumName;		
	
	fieldTitle.font = [UIFont boldSystemFontOfSize:17];
	fieldTags.font = [UIFont boldSystemFontOfSize:17];
	textDesc.text = @"";	
		
	btnChooseImage.titleLabel.text = NSLocalizedString(@"Choose image", "Choose image for uploading");
	
	fieldTitle.placeholder = NSLocalizedString(@"Title cell", @"Title cell title");
	fieldTags.placeholder = NSLocalizedString(@"Tags cell", @"Tags cell title");
	textDesc.placeholder = NSLocalizedString(@"Description cell", @"Description cell title");
	
	[Designer applyStylesForButton:btnChooseImage];
	[Designer applyStylesForTextEdit:fieldTitle];
	[Designer applyStylesForTextEdit:fieldTags];
	[Designer applyStylesForTextArea:textDesc];
	
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];
	
	[viewScroll setContentSize:CGSizeMake(viewContainer.frame.size.width, BX_IMAGE_ADD_FORM_SIZE)];	

    // init image picker dialog    
    ctrlImagePicker = [[UIImagePickerController alloc] init];
    
    ctrlImagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];    
    ctrlImagePicker.allowsEditing = NO;
    ctrlImagePicker.delegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ctrlPopover = [[UIPopoverController alloc] initWithContentViewController:self.ctrlImagePicker]; 
    }
}

- (void)dealloc {
	[fieldTitle release];
	[fieldTags release];
	[textDesc release];
	[imageView release];
	[btnChooseImage release];
	
    [ctrlPopover release];
    [ctrlImagePicker release];
    
	[viewContainer release];
	[viewScroll release];
	
	[currentChoosenImage release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS 
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestUploadImage:(NSData*)aData title:(NSString*)aTitle tags:(NSString*)theTags desc:(NSString*)aDesc {	
	
	NSLog (@"Album name: %@", albumName);
	NSString *sDataLen = [NSString stringWithFormat:@"%d", [aData length]];
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nil == albumName ? @"Hidden" : albumName, aData, sDataLen, aTitle, theTags, aDesc, nil];
	
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.uploadImage" withParams:myArray withSelector:@selector(actionUploadImage:) andSelectorObject:self andSelectorData:nil useIndicator:nil];	
}

- (void)switchToEditMode:(BOOL)isEditBegin {
	editMode = BX_EDIT_MODE_DESC;
    [viewScroll setContentOffset:CGPointMake(0, isEditBegin ? BX_OFFSET_IMAGE_ADD_DESC : 0) animated:YES];
	[self displayDoneButton:isEditBegin textField:textDesc];
}

- (void)switchToEditMode2:(BOOL)isEditBegin {
	editMode = BX_EDIT_MODE_TAGS;
	if (isEditBegin == YES && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		[viewScroll setContentOffset:CGPointMake(0, BX_OFFSET_IMAGE_ADD_TAGS) animated:YES];
}


- (BOOL) startMediaBrowserFromViewController:(UIImagePickerControllerSourceType)aSourceType {
        
    ctrlImagePicker.sourceType = aSourceType;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        CGRect rectPopover = [self.view convertRect:[btnChooseImage frame] fromView:[btnChooseImage superview]];        
        rectPopover.size.width = MIN(rectPopover.size.width, 300);    
        
        [ctrlPopover presentPopoverFromRect:rectPopover inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        [self presentViewController:self.ctrlImagePicker animated:YES completion:NULL];
    }
    
    return YES;
}

- (void)pickPhotoFromCamera:(id)sender {
    [self startMediaBrowserFromViewController:UIImagePickerControllerSourceTypeCamera];
}

- (void)pickPhotoFromPhotoLibrary:(id)sender {
    [self startMediaBrowserFromViewController:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info { 
    [self useImage:(UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage]];    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [ctrlPopover dismissPopoverAnimated:YES]; 
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)useImage:(UIImage*)theImage {
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

- (IBAction)showPhotoPickerActionSheet:(id)sender {
	
	UIActionSheet *actionSheet = nil;
	NSString *strFromLibrary = NSLocalizedString(@"Add Photo from Library", @"Add Photo from Library button title");
	NSString *strFromCamera = NSLocalizedString(@"Take Photo with Camera", @"Take Photo with Camera button title");
	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		actionSheet = [[UIActionSheet alloc] 
					   initWithTitle:@""
					   delegate:self 
					   cancelButtonTitle:@"Cancel" 
					   destructiveButtonTitle:nil
					   otherButtonTitles:strFromLibrary, strFromCamera, nil];
	} else {
		actionSheet = [[UIActionSheet alloc] 
					   initWithTitle:@""
					   delegate:self 
					   cancelButtonTitle:@"Cancel" 
					   destructiveButtonTitle:nil
					   otherButtonTitles:strFromLibrary, nil];
	}

    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {        
        CGRect rect = [self.view convertRect:[btnChooseImage frame] fromView:[btnChooseImage superview]];        
        rect.size.width = MIN(rect.size.width, 200);            
        [actionSheet showFromRect:rect inView:self.view animated:YES];
    } else {
        [actionSheet showFromTabBar:app.tabController.tabBar];
    }
    
    [actionSheet release];		
}

/**
 * callback function on upload image request 
 */
- (void)actionUploadImage:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"upload image: %@", resp);
	
	if ([resp isEqualToString:@"ok"]) {
		
		if (nil != ctrlImagesContainer) 
			((ImagesListController*)ctrlImagesContainer).isReloadRequired = YES;

		// app.homeImages.isReloadRequired = YES; - TODO:
		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Great!", @"Image added success alert title") message:NSLocalizedString(@"Image hase been successfully uploaded", @"Image upload success message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];		
		
		[self performSelectorOnMainThread:@selector(actionBack:) withObject:nil waitUntilDone:NO];
		
	} else if ([resp isEqualToString:@"fail access"]) {
		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Your membership level do not allow photo upload", @"Your membership level do not allow photo upload") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];
		return;		
		
	} else {
		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Image upload error", @"Image upload error message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];
		return;		
		
	}
}

- (IBAction)actionBack:(id)sender {
    [navContrioller popViewControllerAnimated:YES];	
}


/**
 * editing done
 */
- (IBAction)actionDone:(id)sender {
	if (editMode == BX_EDIT_MODE_DESC)
		[self switchToEditMode:NO];
	else
		[self switchToEditMode2:NO];
}


/**
 * save
 */
- (IBAction)actionSave:(id)sender {
	
	// check inputed values 
	if (fieldTags.text.length == 0 || fieldTitle.text.length == 0 || textDesc.text.length == 0 || currentChoosenImage == nil) {		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Title, Tags, Description or Image is not specified", @"Not all fields are filled on Add Image form error message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
		[al show];
		[al release];
		return;
	}

	NSData *imgData = UIImageJPEGRepresentation(currentChoosenImage, 0.8);
	[self requestUploadImage:imgData title:fieldTitle.text tags:fieldTags.text desc:textDesc.text];
}


/**********************************************************************************************************************
 DELEGATES: UITextView
 **********************************************************************************************************************/

#pragma mark - UITextView delegates

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
	[self switchToEditMode:YES];
}

/**********************************************************************************************************************
 DELEGATES: TextField
 **********************************************************************************************************************/

#pragma mark - UITextField delegates

- (void)textFieldDidBeginEditing:(UITextField *)aTextField {
	if (aTextField == fieldTags)
		[self switchToEditMode2:YES];
}

/**
 * when user press return button jump to next field or hide keyboard in login form 
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	
    if (theTextField == fieldTags) {
		[self switchToEditMode2:NO];
        [textDesc becomeFirstResponder];
    } else if (theTextField == fieldTitle) {
        [fieldTags becomeFirstResponder];
    }		
	
    return YES;
}

/**********************************************************************************************************************
 DELEGATES: UIActionSheet
 **********************************************************************************************************************/

#pragma mark - UIActionSheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == [actionSheet cancelButtonIndex]) {
		return;
	}
	
	if (buttonIndex == 0)
		[self pickPhotoFromPhotoLibrary:nil];
	else if(buttonIndex == 1 )
		[self pickPhotoFromCamera:nil];
}	

@end
