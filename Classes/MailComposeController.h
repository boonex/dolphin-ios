//
//  MailComposeController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"
#import "UserPickerController.h"
#import "TextViewPlaceholder.h"

@interface MailComposeController : BaseUserController <UITextViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, UserPickerDelegate> {
	
	IBOutlet UIButton *btnSelectRecipient;
	IBOutlet UITextField *fieldRecipient;
	IBOutlet UITextField *fieldSubj;
	IBOutlet TextViewPlaceholder *fieldText;	
	IBOutlet UISegmentedControl *options;
	
	IBOutlet UILabel *labelOptions;
	
	IBOutlet UIView *viewContainer;
	IBOutlet UIScrollView *viewScroll;

	NSString *recipient;
	NSString *recipientTitle;    
	NSString *suggestedSubject;
	UINavigationController *navController;
}

- (IBAction)actionSubmit:(id)sender;

- (id)initWithRecipient:(NSString*)sRecipient recipientTitle:(NSString*)sRecipientTitle subject:(NSString*)sSubject nav:(UINavigationController *)nav;
- (void)switchToEditMode:(BOOL)isEditBegin;
- (void)sendMesasge;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionSelectRecipient:(id)sender;

@end
