//
//  MediaAddController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 07/12/13.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MediaAddController.h"
#import "MediaListController.h"
#import "MediaAlbumsController.h"
#import "Designer.h"

#define BX_OFFSET_MEDIA_ADD_DESC 185.0 // content offset for description field when we are entering text
#define BX_OFFSET_MEDIA_ADD_TAGS 0.0 // content offset for tags field when we are entering text
#define BX_MEDIA_ADD_FORM_SIZE 550.0 // whole for height

@implementation MediaAddController

@synthesize ctrlImagePicker, ctrlPopover;

- (id)initWithAlbum:(NSString*)anAlbumName mediaListController:(UIViewController*)aController nav:(UINavigationController*)aNav {
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
		
	btnChooseMedia.titleLabel.text = NSLocalizedString(@"Choose file", "Choose file for uploading");
	
	fieldTitle.placeholder = NSLocalizedString(@"Title cell", @"Title cell title");
	fieldTags.placeholder = NSLocalizedString(@"Tags cell", @"Tags cell title");
	textDesc.placeholder = NSLocalizedString(@"Description cell", @"Description cell title");
	
	[Designer applyStylesForButton:btnChooseMedia];
	[Designer applyStylesForTextEdit:fieldTitle];
	[Designer applyStylesForTextEdit:fieldTags];
	[Designer applyStylesForTextArea:textDesc];
	
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];
	
	[viewScroll setContentSize:CGSizeMake(viewContainer.frame.size.width, BX_MEDIA_ADD_FORM_SIZE)];

    // init image picker dialog    
    ctrlImagePicker = [[UIImagePickerController alloc] init];

    ctrlImagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
    ctrlImagePicker.mediaTypes = mediaTypes;
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
	[btnChooseMedia release];
	
    [ctrlPopover release];
    [ctrlImagePicker release];
    
	[viewContainer release];
	[viewScroll release];
	
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS 
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestUploadMedia:(NSData*)aData title:(NSString*)aTitle tags:(NSString*)theTags desc:(NSString*)aDesc {
	
	NSLog (@"Album name: %@", albumName);
	NSString *sDataLen = [NSString stringWithFormat:@"%d", [aData length]];
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nil == albumName ? @"Hidden" : albumName, aData, sDataLen, aTitle, theTags, aDesc, fileExt, nil];
	
	[self addProgressIndicator];
	[user.connector execAsyncMethod:methodUpload withParams:myArray withSelector:@selector(actionUploadMedia:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

- (void)switchToEditMode:(BOOL)isEditBegin {
	editMode = BX_EDIT_MODE_DESC;
    [viewScroll setContentOffset:CGPointMake(0, isEditBegin ? BX_OFFSET_MEDIA_ADD_DESC : 0) animated:YES];
	[self displayDoneButton:isEditBegin textField:textDesc];
}

- (void)switchToEditMode2:(BOOL)isEditBegin {
	editMode = BX_EDIT_MODE_TAGS;
	if (isEditBegin == YES && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		[viewScroll setContentOffset:CGPointMake(0, BX_OFFSET_MEDIA_ADD_TAGS) animated:YES];
}

- (BOOL) startMediaBrowserFromViewController:(UIImagePickerControllerSourceType)aSourceType {
        
    ctrlImagePicker.sourceType = aSourceType;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        CGRect rectPopover = [self.view convertRect:[btnChooseMedia frame] fromView:[btnChooseMedia superview]];
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
    [self useMedia:[info objectForKey:pickerDataKey]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [ctrlPopover dismissPopoverAnimated:YES]; 
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)useMedia:(id)media {
}

- (BOOL)checkRequiredFields:(id)media {
	
	// check inputed values
	if (fieldTitle.text.length == 0 || media == nil) {
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Title or file is empty", @"Not all fields are filled on Add File form error message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
		[al show];
		[al release];
		return false;
	}
    return true;
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (IBAction)showPhotoPickerActionSheet:(id)sender {
	
	UIActionSheet *actionSheet = nil;
	NSString *strFromLibrary = NSLocalizedString(@"Add File from Library", @"Add File from Library button title");
	NSString *strFromCamera = NSLocalizedString(@"Take File with Camera", @"Take File with Camera button title");
	
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
        CGRect rect = [self.view convertRect:[btnChooseMedia frame] fromView:[btnChooseMedia superview]];
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
- (void)actionUploadMedia:(id)idData {
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured
	if ([resp isKindOfClass:[NSError class]]) {
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	} else if ([resp isKindOfClass:[NSDictionary class]]) {
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    } else if ([resp isKindOfClass:[NSString class]] && [resp isEqualToString:@"fail access"]) {
		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Your membership level do not allow file upload", @"Your membership level do not allow file upload") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];
		return;
		
	}
	
	NSLog(@"upload media: %@", resp);
	
	if ([resp isKindOfClass:[NSString class]] && [resp isEqualToString:@"ok"]) {
		
		if (nil != ctrlImagesContainer) 
			((MediaListController*)ctrlImagesContainer).isReloadRequired = YES;

		// app.homeImages.isReloadRequired = YES; - TODO:
		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Great!", @"File added success alert title") message:msgSuccess delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];		
		
		[self performSelectorOnMainThread:@selector(actionBack:) withObject:nil waitUntilDone:NO];
		
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
