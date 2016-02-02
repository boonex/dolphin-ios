//
//  MailMessagesController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MailMessagesController.h"
#import "MailMsgRowView.h"
#import "MailMessages.h"
#import "MailMessageController.h"
#import "Designer.h"

@implementation MailMessagesController

@synthesize isInbox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUser:(BxUser*)anUser isInbox:(BOOL)inboxFlag {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil withUser:anUser])) {
		isInbox = inboxFlag;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    	
	// right nav item
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reload", @"Reload button title") style:UIBarButtonItemStyleBordered target:self action:@selector(actionReload:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];	
	
	self.navigationItem.title = isInbox ? NSLocalizedString(@"Inbox", @"Inbox view title") : NSLocalizedString(@"Sent", @"Sent view title");	

	[self requestMessages];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Funvtions

- (void)requestMessages {	
	
	MailMessages *mailMessages = [MailMessages sharedMailMessages:user];
	
	if (YES == mailMessages.initialized)
		[mailMessages resetData];
	
	NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nil];
	[self addProgressIndicator];
	if (isInbox)
		[user.connector execAsyncMethod:@"dolphin.getMessagesInbox" withParams:myArray withSelector:@selector(actionRequestMessages:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	else
		[user.connector execAsyncMethod:@"dolphin.getMessagesSent" withParams:myArray withSelector:@selector(actionRequestMessages:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on request info 
 */
- (void)actionRequestMessages:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"requested info: %@", resp);
	
	MailMessages *mailMessages = [MailMessages sharedMailMessages:user];
	if (NO == mailMessages.initialized)
	{
		[mailMessages setMessagesArray:resp];
		[table reloadData];
	}
}

/**
 * reload button pressed
 */
- (IBAction)actionReload:(id)sender {
	MailMessages *mailMessages = [MailMessages sharedMailMessages:user];
	[mailMessages resetData];
	[self requestMessages];
}

/**********************************************************************************************************************
 DELEGATES: UITableView
 **********************************************************************************************************************/

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	MailMessages *mailMessages = [MailMessages sharedMailMessages:user];
	return [mailMessages countOfMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	if (indexPath.section == 0) {		
		
		MailMsgRowView *cell;
		
		MailMessages *mailMessages = [MailMessages sharedMailMessages:user];
		NSMutableDictionary *msg = [mailMessages msgAtIndex:indexPath.row];
		cell = [msg valueForKey:@"Cell"];
		if (cell != nil)
			return cell;
		
		NSString* nick = [Dolphin6AppDelegate formatUserTitle:msg field:@"UserTitleInterlocutor" default:@""];
		NSString* subj = [msg valueForKey:@"Subject"];
		NSString* date = [msg valueForKey:@"Date"];
		NSString* thumb = [msg valueForKey:@"Thumb"];
		NSString* tmp = [msg valueForKey:@"New"];		
		BOOL isNew = [tmp isEqualToString:@"1"] ? YES : NO;

		cell = [[MailMsgRowView alloc] initWithNickname:nick subject:subj date:date thumb:thumb new:isNew isInbox:isInbox selected:NO];
				
		[msg setValue:cell forKey:@"Cell"];
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {		
		MailMessages *mailMessages = [MailMessages sharedMailMessages:user];
		NSMutableDictionary *msg = [mailMessages msgAtIndex:indexPath.row];
		NSString *strTmpId = [msg valueForKey:@"ID"];
		NSInteger intMsgId = [strTmpId intValue]; 
		[msg setValue:@"0" forKey:@"New"];
		
		Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
		MailMessageController * ctrl = [[MailMessageController alloc] initWithNibName:@"MailMessageView" bundle:nil withUser:user andMsgId:intMsgId isInbox:isInbox];
		[app.mailNavigationController pushViewController:ctrl animated:YES];			
		[ctrl release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return BX_TABLE_CELL_HEIGHT_THUMB;
}

@end