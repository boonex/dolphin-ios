//
//  MailMessageController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/29/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MailMessageController.h"
#import "MailComposeController.h"
#import "ProfileBlock.h"
#import "Designer.h"

@implementation MailMessageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUser:(BxUser*)anUser andMsgId:(NSInteger)anId isInbox:(BOOL)inboxFlag {
	
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil withUser:anUser])) {
		msgId = anId;
		isInbox = inboxFlag;
		nick = nil;
	}
	return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	// left nav item
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Inbox", @"Inbox button title") style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
	self.navigationItem.leftBarButtonItem = btn;
	[btn release];	
	
	// right nav item
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reply", @"Reply button title") style:UIBarButtonItemStyleDone target:self action:@selector(actionReply:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];	
	
	self.navigationItem.title = isInbox ? NSLocalizedString(@"Message From", @"Message From user view title") : NSLocalizedString(@"Message To", @"Message To user view title"); 	
	
	labelSubj.text = NSLocalizedString(@"Loading...", @"Loading text");
	labelAuthor.text = @"";
	labelDate.text = @"";
	
	[Designer applyStylesForLabelTitle:labelSubj];
	[Designer applyStylesForLabelDesc:labelAuthor];
	[Designer applyStylesForLabelDesc:labelDate];
	[Designer applyStylesForWebView:text];
    
	[Designer applyStylesForScreen:self.view];
	[Designer applyStylesForContainer:viewContainer];

	viewImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, viewContainerThumb.frame.size.width, viewContainerThumb.frame.size.height)];
	[viewContainerThumb addSubview:viewImage];
	
	[self requestMessage];
}

- (void)dealloc {
	[labelSubj release];
	[labelAuthor release];
	[labelDate release];
	[text release];
	[nick release];
	[viewImage release];
	[viewContainer release];
	[viewContainerThumb release];
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)requestMessage {	
	[self addProgressIndicator];
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [NSString stringWithFormat:@"%d", (int)msgId], nil];
	if (isInbox)
		[user.connector execAsyncMethod:@"dolphin.getMessageInbox" withParams:myArray withSelector:@selector(actionRequestMessage:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	else
		[user.connector execAsyncMethod:@"dolphin.getMessageSent" withParams:myArray withSelector:@selector(actionRequestMessage:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on request info 
 */
- (void)actionRequestMessage:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"requested msg: %@", resp);
	
	nick = [[resp valueForKey:@"Nick"] retain];
	    
	labelSubj.text = [resp valueForKey:@"Subject"];
	labelDate.text = [resp valueForKey:@"Date"];
    sUserTitle = [Dolphin6AppDelegate formatUserTitle:resp field:@"UserTitleInterlocutor" default:@""];
	if (isInbox)
		labelAuthor.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"From <User>", @"Display 'From: User' in mail messages list"), sUserTitle];
	else
		labelAuthor.text = [[NSString alloc] initWithFormat:NSLocalizedString(@"To <User>", @"Display 'To: User' in mail messages list"), sUserTitle];

	[text loadHTMLString:[resp valueForKey:@"Text"] baseURL:nil];
	
	NSString *strUrl = [resp valueForKey:@"Thumb"];
	NSURL *url = [[NSURL alloc] initWithString:(nil == strUrl ? @"" : strUrl)];
	[viewImage loadImageFromURL:url];
	[viewImage setClickable:nick navigationController:self.navigationController];
	[url release];
		
	if ([(NSString*)[resp valueForKey:@"New"] isEqualToString:@"1"] && user.numUnreadLetters > 0)
		[user decUnreadLettersNum];
}

/**
 * back button pressed
 */
- (IBAction)actionBack:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	[app.mailNavigationController popViewControllerAnimated:YES];
}

/**
 * reply button pressed
 */
- (IBAction)actionReply:(id)sender {

	if (nil == nick)
		return;
	
	NSString * strReplySubject = [NSString stringWithFormat:NSLocalizedString(@"Re: <string>", @"Reply to message subject format"), labelSubj.text];
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	MailComposeController *ctrl = [[MailComposeController alloc] initWithRecipient:nick recipientTitle:sUserTitle subject:strReplySubject nav:app.mailNavigationController];
			
	[app.mailNavigationController pushViewController:ctrl animated:YES];			
	[ctrl release];		
}

@end
