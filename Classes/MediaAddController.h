//
//  MediaAddController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 07/12/13.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"
#import "TextViewPlaceholder.h"

#define BX_EDIT_MODE_DESC 1 
#define BX_EDIT_MODE_TAGS 2

@interface MediaAddController : BaseUserController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
	IBOutlet UIImageView *imageView;
	IBOutlet UITextField *fieldTitle;
	IBOutlet UITextField *fieldTags;
	IBOutlet TextViewPlaceholder *textDesc;
	IBOutlet UIButton *btnChooseMedia;
		
	IBOutlet UIView *viewContainer;
	IBOutlet UIScrollView *viewScroll;
	
	NSString *albumName;

	NSInteger editMode;
	
    UIPopoverController *ctrlPopover;
    UIImagePickerController *ctrlImagePicker;
    
	UIViewController *ctrlImagesContainer;    
    UINavigationController *navContrioller;
    
    NSArray *mediaTypes;
    NSString *fileExt;
    NSString *methodUpload;
    NSString *pickerDataKey;
    NSString *msgSuccess;
}

@property (nonatomic, retain) UIImagePickerController *ctrlImagePicker;
@property (nonatomic, retain) UIPopoverController *ctrlPopover;

- (id)initWithAlbum:(NSString*)anAlbumName mediaListController:(UIViewController*)aController nav:(UINavigationController*)aNav;

- (void)switchToEditMode:(BOOL)isEditBegin;
- (void)switchToEditMode2:(BOOL)isEditBegin;

- (void)actionUploadMedia:(id)idData;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionDone:(id)sender;
- (IBAction)actionSave:(id)sender;
- (IBAction)showPhotoPickerActionSheet:(id)sender;

- (void)pickPhotoFromCamera:(id)sender;
- (void)pickPhotoFromPhotoLibrary:(id)sender;
- (void)useMedia:(id)media;
- (BOOL)checkRequiredFields:(id)media;
- (void)requestUploadMedia:(NSData*)aData title:(NSString*)aTitle tags:(NSString*)theTags desc:(NSString*)aDesc;

@end
