//
//  MailMessageController.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 10/29/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUserController.h"
#import "BaseUserThumbTableController.h"
#import "AsyncImageView.h"

@interface MailMessageController : BaseUserController {
	NSString *nick;
    NSString *sUserTitle;
	NSInteger msgId;
	BOOL isInbox;
	AsyncImageView *viewImage;
	IBOutlet UILabel *labelSubj;
	IBOutlet UILabel *labelAuthor;
	IBOutlet UILabel *labelDate;
	IBOutlet UIWebView *text;
	IBOutlet UIView *viewContainer;
	IBOutlet UIView *viewContainerThumb;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withUser:(BxUser*)anUser andMsgId:(NSInteger)anId isInbox:(BOOL)inboxFlag;
- (void)requestMessage;

@end
