//
//  StatusMessageController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/4/09.
//  Copyright 2009 BoonEx. All rights reserved.
//

#import "StatusMessageController.h"
#import "HomeController.h"
#import "Designer.h"

@implementation StatusMessageController

- (id)initWithStatusMessage: (NSString*)aStatus {
	if ((self = [super initWithNibName:@"StatusMessageView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
		status = [aStatus copy];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// right nav item
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save") style:UIBarButtonItemStyleDone target:self action:@selector(actionSave:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];		
	
	self.navigationItem.title = NSLocalizedString(@"Status", @"Status title");

	textStatusMessage.text = status;	
	[Designer applyStylesForTextEdit:textStatusMessage];
	
	labelStatusMessage.text = NSLocalizedString(@"Status Message", @"Status message field caption");
	[Designer applyStylesForLabel:labelStatusMessage];
	
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];
}

- (void)dealloc {
	[status release];
	[labelStatusMessage release];
	[textStatusMessage release];
	[viewContainer release];
    [super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Funtions

- (void)requestUpdateStatus {
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, textStatusMessage.text, nil];
	[user.connector execAsyncMethod:@"dolphin.updateStatusMessage" withParams:myArray withSelector:@selector(actionUpdateStatusMessageCompleted:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

/**********************************************************************************************************************
 ACTIONS
 *************************************** *******************************************************************************/

#pragma mark - Actions

/**
 * callback function on request info 
 */
- (void)actionUpdateStatusMessageCompleted:(id)idData {	
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"status message updated: %@", resp);
	[resp release];
	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
    
	NSArray *viewControllers = [app.homeNavigationController viewControllers];
	HomeController *ctrlHome = (HomeController *)[viewControllers objectAtIndex:0];
	[ctrlHome setReloadRequired];
    
	[app.homeNavigationController popViewControllerAnimated:YES];	
}

/**
 * reload button pressed
 */
- (IBAction)actionSave:(id)sender {
	[self requestUpdateStatus];
}

/**********************************************************************************************************************
 DELEGATES: UITextField
 **********************************************************************************************************************/

#pragma mark - UITextField Delegates

/**
 * when user press return button jump to next field or hide keyboard 
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[textStatusMessage resignFirstResponder];
    return YES;
}

@end
