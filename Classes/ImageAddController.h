//
//  ImageAddController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 12/1/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"
#import "TextViewPlaceholder.h"

#define BX_EDIT_MODE_DESC 1 
#define BX_EDIT_MODE_TAGS 2

@interface ImageAddController : BaseUserController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
	IBOutlet UIImageView *imageView;
	IBOutlet UITextField *fieldTitle;
	IBOutlet UITextField *fieldTags;
	IBOutlet TextViewPlaceholder *textDesc;
	IBOutlet UIButton *btnChooseImage;
		
	IBOutlet UIView *viewContainer;
	IBOutlet UIScrollView *viewScroll;
	
	NSString *albumName;

	NSInteger editMode;
	
	UIImage *currentChoosenImage; 
	
    UIPopoverController *ctrlPopover;
    UIImagePickerController *ctrlImagePicker;
    
	UIViewController *ctrlImagesContainer;    
    UINavigationController *navContrioller;
}

@property (nonatomic, retain) UIImagePickerController *ctrlImagePicker;
@property (nonatomic, retain) UIPopoverController *ctrlPopover;

- (id)initWithAlbum:(NSString*)anAlbumName imagesListController:(UIViewController*)aController nav:(UINavigationController*)aNav;

- (void)switchToEditMode:(BOOL)isEditBegin;
- (void)switchToEditMode2:(BOOL)isEditBegin;

- (void)actionUploadImage:(id)idData;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionDone:(id)sender;
- (IBAction)actionSave:(id)sender;
- (IBAction)showPhotoPickerActionSheet:(id)sender;

- (void)pickPhotoFromCamera:(id)sender;
- (void)pickPhotoFromPhotoLibrary:(id)sender;
- (void)useImage:(UIImage*)theImage;
- (void)requestUploadImage:(NSData*)aData title:(NSString*)aTitle tags:(NSString*)theTags desc:(NSString*)aDesc;
- (void)rotateImage;

@end
