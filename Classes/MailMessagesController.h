//
//  MailMessagesController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 9/17/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserTableController.h"

@interface MailMessagesController : BaseUserTableController {
	BOOL isInbox;
}

@property (assign) BOOL isInbox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUser:(BxUser*)anUser isInbox:(BOOL)inboxFlag;
- (void)requestMessages;

@end
