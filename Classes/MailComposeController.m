//
//  MailComposeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/31/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MailComposeController.h"
#import "UserPickerController.h"
#import "Designer.h"

#define BX_OFFSET_MAIL_COMPOSE_TEXT 105.0 // content offset for text field when we are entering text 
#define BX_MAIL_COMPOSE_FORM_SIZE 540.0 // form size

@implementation MailComposeController

- (id)initWithRecipient:(NSString*)sRecipient recipientTitle:(NSString*)sRecipientTitle subject:(NSString*)sSubject nav:(UINavigationController *)nav {
	if ((self = [super initWithNibName:@"MailComposeView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		recipient = [sRecipient copy];
        recipientTitle = [sRecipientTitle copy]; 
		suggestedSubject = [sSubject copy];
		navController = nav;
	}
	return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel button title") style:UIBarButtonItemStyleBordered target:self action:@selector(actionBack:)];
	self.navigationItem.leftBarButtonItem = btn;
	[btn release];	
		
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button title") style:UIBarButtonItemStyleDone target:self action:@selector(actionSubmit:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];	

	self.navigationItem.title = NSLocalizedString(@"Compose", @"Message compose view title");	
	
	fieldRecipient.text = (nil == recipientTitle ? @"" : recipientTitle);
	if (nil != suggestedSubject)
		fieldSubj.text = suggestedSubject;
	fieldText.text = @"";
    
    fieldRecipient.placeholder = NSLocalizedString(@"Recipient", @"Message recipient field caption");    
    fieldSubj.placeholder = NSLocalizedString(@"Subject", @"Message subject field caption");
    fieldText.placeholder = NSLocalizedString(@"Text", @"Message text field caption");
	labelOptions.text = NSLocalizedString(@"Send Copy To", @"Send Message copy to(my email, recipient email) field caption");
	
	[options removeAllSegments];
	[options insertSegmentWithTitle:NSLocalizedString(@"Send to my email", @"Message send option: my email") atIndex:0 animated:NO];
	[options insertSegmentWithTitle:NSLocalizedString(@"Send to recipient email", @"Message send option: recipient email") atIndex:1 animated:NO];
	[options insertSegmentWithTitle:NSLocalizedString(@"Send to both", @"Message send option: both") atIndex:2 animated:NO];
	
	[Designer applyStylesForTextEdit:fieldRecipient];
	[Designer applyStylesForTextEdit:fieldSubj];
	[Designer applyStylesForTextArea:fieldText];
	
	[Designer applyStylesForLabel:labelOptions];
	
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];
	
	[viewScroll setContentSize:CGSizeMake(viewContainer.frame.size.width, BX_MAIL_COMPOSE_FORM_SIZE)];	
}

- (void)dealloc {
	[fieldRecipient release];
	[btnSelectRecipient release];
	[fieldSubj release];
	[fieldText release];	
	[options release];
	
	[labelOptions release];
	
    [recipient release];
    [recipientTitle release];
	[suggestedSubject release];	
	[super dealloc];
}

/**********************************************************************************************************************
 DELEGATES: UITextView
 **********************************************************************************************************************/

#pragma mark - UITextView Delegates

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
	[self switchToEditMode:YES];
}

/**********************************************************************************************************************
 DELEGATES: UIAlertView Delegate
 **********************************************************************************************************************/

#pragma mark - UIAlertView Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView.title isEqualToString:NSLocalizedString(@"Great!", @"Message sent success alert title")])	{
		[self actionBack:nil];
	}
}

/**********************************************************************************************************************
 DELEGATES: UserPickerDelegate
 **********************************************************************************************************************/

#pragma mark - UserPicker Delegates

- (void)setRecipient:(NSString*)sRecipient title:(NSString*)sRecipientTitle {
	if (recipient != nil)
		[recipient release];
	recipient = [sRecipient copy];

    if (recipientTitle != nil)
		[recipientTitle release];
	recipientTitle = [sRecipientTitle copy];
    
	fieldRecipient.text = recipientTitle;
}

/**********************************************************************************************************************
 DELEGATES: UITextField
 **********************************************************************************************************************/

#pragma mark - UITextField Delegates

/**
 * when user press return button jump to next field or hide keyboard in login form 
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == fieldSubj) {
        [fieldText becomeFirstResponder];
    }		
    return YES;
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Action

- (IBAction)actionSelectRecipient:(id)sender {
	UserPickerController * ctrl = [[UserPickerController alloc] initWithReciver:self nav:navController];
	[navController pushViewController:ctrl animated:YES];
	[ctrl release];
}

/**
 * back button pressed
 */
- (IBAction)actionBack:(id)sender {
	[navController popViewControllerAnimated:YES];
}

/**
 * editing done
 */
- (IBAction)actionDone:(id)sender {
	[self switchToEditMode:NO];
}

/**
 * subject editing done
 */
- (IBAction)actionSubjectEditingDone:(id)sender {
	
}

- (IBAction)actionSubmit:(id)sender {

	if(nil == recipient || 0 == fieldSubj.text.length || 0 == fieldText.text.length)
	{		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert titile") message:NSLocalizedString(@"Please specify message subject, text and recipient", @"Not all fields are filled in message compose error message text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
		[al show];
		[al release];
		return;
	}

	[self sendMesasge];
}

/**
 * callback function on message sent
 */
- (void)actionMessageSent:(id)idData {
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
		
	NSLog(@"messages sent: %@", resp);
	
	NSInteger intErrCode = [((NSString*)resp) integerValue];
	
	NSString *strError = nil;
	switch (intErrCode)
	{
		case 1:
			strError = NSLocalizedString(@"Message send failed", @"Sent mail error message");
			break;
		case 3:
			strError = NSLocalizedString(@"You have to wait before sending another message", @"Sent mail error message");
			break;
		case 5:
			strError = NSLocalizedString(@"You are in block list of recipient", @"Sent mail error message");
			break;
		case 10:
			strError = NSLocalizedString(@"Recipient profile is not activated", @"Sent mail error message");
			break;			
		case 1000:
			strError = NSLocalizedString(@"Unknown recipient", @"Sent mail error message");
			break;
		case 1001:
			strError = NSLocalizedString(@"Your membership doesn't allow you to send messages", @"Sent mail error message");
			break;
            
	}	
	
	
	if(strError != nil)
	{		
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:strError delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
		[al show];
		[al release];
		return;
	}
	
	UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Great!", @"Message sent success alert title") message:NSLocalizedString(@"Message sent", @"Message sent success alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button text") otherButtonTitles:nil];
	[al show];
	[al release];
}


/**********************************************************************************************************************
 CUSTOM FUNCTIONS 
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)sendMesasge {	
	
	NSString * strOptions = @"";
	switch (options.selectedSegmentIndex)
	{
		case 0: strOptions = @"me"; break;
		case 1: strOptions = @"recipient"; break;
		case 2: strOptions = @"both"; break;
	}

	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, recipient, fieldSubj.text, fieldText.text, strOptions, nil];
	[self addProgressIndicator];
	[user.connector execAsyncMethod:@"dolphin.sendMessage" withParams:myArray withSelector:@selector(actionMessageSent:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

- (void)switchToEditMode:(BOOL)isEditBegin {
	[viewScroll setContentOffset:CGPointMake(0, isEditBegin ? BX_OFFSET_MAIL_COMPOSE_TEXT : 0) animated:YES];
	[self displayDoneButton:isEditBegin textField:fieldText];
}

@end
