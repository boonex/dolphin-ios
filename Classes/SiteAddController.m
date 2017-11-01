//
//  SiteAddController.m
//  Dolphin
//
//  Created by Alex Trofimov on 21/01/13.
//
//

#import "SiteAddController.h"
#import "DolphinUsers.h"
#import "Designer.h"

@interface SiteAddController ()

@end

@implementation SiteAddController

- (id)init
{
	if ((self = [super initWithNibName:@"SiteAddView" bundle:nil withUser:nil])) {
		
	}
    
    return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
			    
	[Designer applyStylesForTextEdit:textDomain];
	[Designer applyStylesForButton:btnSave];
    
	textDomain.placeholder = NSLocalizedString(@"Site URL", @"Site URL field name");
	
    [btnSave setTitle:NSLocalizedString(@"Save", @"Save button title") forState:UIControlStateNormal];
    
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];
	   
}


- (void)dealloc {
	[textDomain release];
	[btnSave release];
    
    [viewContainer release];
    [viewScroll release];
    
	[super dealloc];
}


/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * login action - user press login/save button
 */
- (IBAction)actionCheckDomain:(id)sender {
	NSString *stringDomain = textDomain.text;
    
	// check inputed values
	if (stringDomain.length == 0) {
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Site URL can not be empty", @"Site URL is not filled in Login/Add Site pages error message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
		[al show];
		[al release];
		return;
	}
	
	// hide keyboard
	[textDomain resignFirstResponder];
	
	// check login and password
	NSArray *myArray = [NSArray arrayWithObjects:@"O", @"K", nil];
	BxUser *anUser;
	
    anUser = [[BxUser alloc] initWithUser:@"" id:0 passwordHash:@"" site:stringDomain protocolVer:0];
    
	NSMutableDictionary * data = [NSMutableDictionary dictionary];
	[data setObject:anUser forKey:BX_KEY_USER];
    
	[self addProgressIndicator];
	
	[anUser.connector execAsyncMethod:@"dolphin.concat" withParams:myArray withSelector:@selector(callbackCheckDomain:) andSelectorObject:self andSelectorData:data useIndicator:nil];
	[anUser release];
}

/**
 * callback function on login
 */
- (void)callbackCheckDomain:(id)idData {
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	BxUser *anUser = [[idData valueForKey:BX_KEY_USER] retain];
	
	[self removeProgressIndicator];
	
    NSLog(@"Check domain responce: %@ (%@)", resp, [resp class]);
    
	// if error occured or returned members' id is 0 - show "login failed" popup
	if ([resp isKindOfClass:[NSError class]]) {
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	}
    
    if (![resp isKindOfClass:[NSString class]] || ![resp isEqualToString:@"OK"] ) {
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Can't add this URL, it must be Dolphin based site", @"Domain error message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil];
		[al show];
		[al release];
		return;
    }
    
	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
    [users addUser:anUser];
	[users saveUsers];
		
	[resp release];
	[anUser release];
    
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
    [app.navigationController popViewControllerAnimated:YES];
}


@end
