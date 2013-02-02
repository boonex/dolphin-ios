//
//  MailHomeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "MailHomeController.h"
#import "MailMessagesController.h"
#import "MailComposeController.h"
#import "Designer.h"

@implementation MailHomeController

- (id)init {
	if ((self = [super initWithNibName:@"MailHomeView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
        self.title = NSLocalizedString(@"Mail tab", @"Mail tab title");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_mail.png"];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.navigationItem.title = NSLocalizedString(@"Mail", @"Mail View Title");    
}

- (void)dealloc {
	[super dealloc];
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
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	if (indexPath.section == 0) {		
		switch (indexPath.row) {
			case 0:
				if (user.numUnreadLetters) {
					NSString *s = [[NSString alloc] initWithFormat:NSLocalizedString(@"Inbox row (<Num>)", @"Inbox with unread letters num"), user.numUnreadLetters];
					cell.textLabel.text = s;
					[s release];
				} else {
					cell.textLabel.text = NSLocalizedString(@"Inbox row", @"Inbox row title");
				}
				break;
			case 1:
				cell.textLabel.text = NSLocalizedString(@"Sent row", @"Sent row title");
				break;
			case 2:
				cell.textLabel.text = NSLocalizedString(@"Compose row", @"Compose row title");
				break;
		}
	}
	
	[Designer applyStylesForCell:cell];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return BX_TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
        [self setupBackButton];
		Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
		UIViewController *ctrl = nil;
		switch (indexPath.row) {
			case 0:			
				ctrl = [[MailMessagesController alloc] initWithNibName:@"MailMessagesView" bundle:nil withUser:user isInbox:YES];
				break;
			case 1:
				ctrl = [[MailMessagesController alloc] initWithNibName:@"MailMessagesView" bundle:nil withUser:user isInbox:NO];					
				break;
			case 2:
				ctrl = [[MailComposeController alloc] initWithRecipient:nil recipientTitle:nil subject:nil nav:app.mailNavigationController];
				break;
		}
		[app.mailNavigationController pushViewController:ctrl animated:YES];
		[ctrl release];
	}
}

@end
